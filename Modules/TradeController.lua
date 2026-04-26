local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local TradeController = TradeFill:NewModule("TradeController", "AceEvent-3.0")

local function TargetHasTradeItems()
    if not GetTradeTargetItemLink then
        return false
    end

    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        if GetTradeTargetItemLink(tradeSlot) then
            return true
        end
    end

    return false
end

function TradeController:ResolveModules()
    if self.modulesResolved then
        return
    end

    self.session = TradeFill:GetModule("TradeSession")
    self.tradelog = TradeFill:GetModule("TradeLog")
    self.inventory = TradeFill:GetModule("InventoryManager")
    self.executor = TradeFill:GetModule("TradeExecutor")
    self.evaluator = TradeFill:GetModule("TradeRulesEvaluator")
    self.status = TradeFill:GetModule("TradingStatusPanel")
    self.trade = TradeFill:GetModule("Trade")
    self.buttons = TradeFill:GetModule("TradeWindowButtons")
    self.modulesResolved = true
end

function TradeController:OnEnable()
    self:RegisterEvent("TRADE_SHOW")
    self:RegisterEvent("BAG_UPDATE_DELAYED", function()
        if not TF.state or not TF.state.active then return end

        if TF.state.isScanning then return end
        if TF.state.isProcessingBags then return end
        if TF.state.manualFillActive then return end

        if TF.state.needsQueueProcessing then
            self:FillTrade()
        end
    end)
end

-- =========================
-- TRADE START
-- =========================
function TradeController:StartTrade()
    self:ResolveModules()
    self.status:Clear()
    self.tradeOutcomeHandled = false
    self.cleanupScheduled = false
    self.session:Initialize()

    self.inventory:ScanInventory(function()
        if TF.state.completed then
            self:FillTrade()
        end
    end)
end

function TradeController:FillTrade()
    if TradeFill:GetFilter("clear") and TargetHasTradeItems() then
        if self.buttons and self.buttons.ClearTrade then
            self.buttons:ClearTrade()
        end
        self.status:AddMessage(
            TF.Loc["MESSAGE_CLEAR"],
            TradeFill:SetName(TF.state)
        )
        return
    end

    self.trade:FillLockboxSlot()

    if not self.evaluator:PassesGeneralChecks() then
        return
    end

    local items = self.evaluator:EvaluateItems()

    self.executor:FillInstant(items, self.trade)
end

function TradeController:EndTrade()
    self:UnregisterEvent("TRADE_CLOSED")
    self:UnregisterEvent("TRADE_ACCEPT_UPDATE")
    self:UnregisterEvent("UI_INFO_MESSAGE")
    self.cleanupScheduled = false

    if TF.state then
        TF.state.active = false
    end

    self:RestoreInventory()
end

function TradeController:RestoreInventory()
    self:ResolveModules()

    if self.inventory and self.inventory.ReStack then
        self.inventory:ReStack()
    end
end

function TradeController:OnAcceptUpdate(playerAccepted, targetAccepted)
    if playerAccepted == 1 or targetAccepted == 1 then
        self.tradelog:CaptureCurrentTrade()
    end
end

function TradeController:UpdateTradeLimits()
    local targetName = TF.state and TF.state.target and TF.state.target.fullName
    local tradeLog = TF.tradeLog and TF.tradeLog.player

    if not targetName or not tradeLog then
        return
    end

    for tradedSlot = 1, MAX_TRADABLE_ITEMS do
        local tradedItem = tradeLog[tradedSlot]

        if tradedItem then
            for configuredSlot = 1, MAX_TRADABLE_ITEMS do
                local configuredItem = TradeFill:GetItem(configuredSlot)

                if configuredItem and (tonumber(configuredItem.limit) or 0) > 0 and tradedItem.name == configuredItem.name then
                    local currentLimit = TradeFill:GetLimit(targetName, configuredSlot)
                    TradeFill:SetLimit(targetName, configuredSlot, currentLimit + 1)
                end
            end
        end
    end
end

function TradeController:HandleTradeComplete()
    if self.tradeOutcomeHandled then
        return
    end

    self.tradeOutcomeHandled = true
    local context = TF.state

    DEFAULT_CHAT_FRAME:AddMessage(
        string.format(
            TF.Loc["MESSAGE_TRADE"],
            TradeFill:SetColor(TF.Loc["TEXT_COMPLETE"], TF.colors.trade.complete),
            TradeFill:SetName(context)
        )
    )

    self.tradelog:PersistCurrentTrade()
    self:UpdateTradeLimits()
    self:RestoreInventory()
end

function TradeController:HandleTradeCancelled()
    if self.tradeOutcomeHandled then
        return
    end

    self.tradeOutcomeHandled = true
    DEFAULT_CHAT_FRAME:AddMessage(
        string.format(
            TF.Loc["MESSAGE_TRADE"],
            TradeFill:SetColor(TF.Loc["TEXT_CANCELED"], TF.colors.trade.canceled),
            TradeFill:SetName(TF.state)
        )
    )
    self:RestoreInventory()
end


function TradeController:OnTradeMessage(message)
    if message == ERR_TRADE_COMPLETE then
        self:HandleTradeComplete()
        return
    end

    if message == ERR_TRADE_CANCELLED then
        self:HandleTradeCancelled()
    end
end

function TradeController:TRADE_SHOW()
    self:RegisterEvent("TRADE_CLOSED")
    self:RegisterEvent("TRADE_ACCEPT_UPDATE")
    self:RegisterEvent("UI_INFO_MESSAGE")
    self:StartTrade()
end

function TradeController:TRADE_CLOSED()
    if self.tradeOutcomeHandled then
        self:EndTrade()
        return
    end

    if self.cleanupScheduled then
        return
    end

    self.cleanupScheduled = true

    -- Let UI_INFO_MESSAGE arrive before tearing down the trade state.
    C_Timer.After(0.2, function()
        if not TF.state or not TF.state.active then
            self.cleanupScheduled = false
            return
        end

        self:EndTrade()
    end)
end

function TradeController:TRADE_ACCEPT_UPDATE(_, playerAccepted, targetAccepted)
    self:OnAcceptUpdate(playerAccepted, targetAccepted)
end

function TradeController:UI_INFO_MESSAGE(_, _, message)
    self:OnTradeMessage(message)
end
