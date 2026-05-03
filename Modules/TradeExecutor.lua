local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local TradeExecutor = TradeFill:NewModule("TradeExecutor")

local FILL_RETRY_DELAY = 0.15
local MAX_FILL_ATTEMPTS = 12

function TradeExecutor:FillInstant(items, trade)
    local queue = {}

    for slot = 1, MAX_TRADABLE_ITEMS do
        if items[slot] and trade:GetMissingTradeCount(slot) > 0 then
            queue[#queue + 1] = slot
        end
    end

    if #queue == 0 then
        return
    end

    if TF.state then
        TF.state.autoFillActive = true
    end

    local queueIndex = 1
    local attempts = 0

    local function Finish()
        if TF.state then
            TF.state.autoFillActive = false
        end

        local buttons = TradeFill:GetModule("TradeWindowButtons", true)
        if buttons and buttons.UpdateButtons then
            buttons:UpdateButtons()
        end
    end

    local function FillNext()
        if not TradeFrame or not TradeFrame:IsShown() then
            Finish()
            return
        end

        local slot = queue[queueIndex]

        if not slot then
            Finish()
            return
        end

        if trade:GetMissingTradeCount(slot) <= 0 then
            queueIndex = queueIndex + 1
            attempts = 0
            C_Timer.After(FILL_RETRY_DELAY, FillNext)
            return
        end

        local tradeSlot = TradeFrame_GetAvailableSlot()

        if not tradeSlot then
            Finish()
            return
        end

        local placed = trade:FillTradeSlot(slot, tradeSlot)

        if placed then
            attempts = 0
        else
            attempts = attempts + 1

            if attempts >= MAX_FILL_ATTEMPTS then
                queueIndex = queueIndex + 1
                attempts = 0
            end
        end

        C_Timer.After(FILL_RETRY_DELAY, FillNext)
    end

    FillNext()
end
