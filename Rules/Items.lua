local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local TradeRulesItems = TradeFill:NewModule("TradeRulesItems")

local function FormatMessage(msg, ...)
    if not msg or msg == "" then
        return nil
    end

    if select("#", ...) > 0 then
        return string.format(msg, ...)
    end

    return msg
end

local function GetContextLink(ctx)
    local effective = ctx and ctx.effective
    local item = ctx and ctx.item

    return (effective and effective.link) or (item and item.link) or ""
end

function TradeRulesItems:OnInitialize()
    self.registered = {}
    self.limitService = TradeFill:GetModule("LimitService")

    self:Register("Limit", function(ctx)
        if not ctx.effective then
            return false
        end

        local itemLimit = tonumber(ctx.item.limit) or 0

        if itemLimit == 0 then
            return true
        end

        if self.limitService:HasReachedLimit(ctx.targetName, ctx.tradeSlot, itemLimit) then
            local link = GetContextLink(ctx)

            return TradeRulesItems:Fail(string.format(
                TF.Loc["MESSAGE_LIMIT"],
                link,
                itemLimit
            ))
        end

        return true
    end)

    self:Register("Required", function(ctx)
        if not ctx.effective then
            return false
        end

        if not TradeFill:GetFilter("required") then
            return true
        end

        local link = GetContextLink(ctx)
        local requiredLevel = ctx.item.level
        local targetLevel = ctx.state.target.level

        if not requiredLevel or requiredLevel <= 0 then
            return true
        end

        if requiredLevel > targetLevel then
            return TradeRulesItems:Fail(string.format(
                TF.Loc["MESSAGE_REQUIREMENTS_REQUIRED"],
                TradeFill:SetColor(TF.Loc["REQUIRED"], TF.colors.filter.required),
                requiredLevel,
                link
            ))
        end

        return true
    end)

    self:Register("Stack", function(ctx)
        if not ctx.effective then
            return false
        end

        local link = GetContextLink(ctx)
        local groupType = ctx.state.groupType

        if groupType == "ungrouped" and ctx.stack == 0 then
            return TradeRulesItems:Fail(string.format(
                TF.Loc["MESSAGE_STACK_UNGROUPED"],
                link,
                TradeFill:SetColor(TF.Loc["UNGROUPED"], TF.colors.trade.ungrouped)
            ))
        end

        if groupType == "party" and ctx.stack == 0 then
            return TradeRulesItems:Fail(string.format(
                TF.Loc["MESSAGE_STACK_PARTY"],
                link,
                TradeFill:SetColor(TF.Loc["PARTY"], TF.colors.trade.party)
            ))
        end

        if groupType == "raid" and ctx.stack == 0 then
            return TradeRulesItems:Fail(string.format(
                TF.Loc["MESSAGE_STACK_RAID"],
                link,
                TradeFill:SetColor(TF.Loc["RAID"], TF.colors.trade.raid)
            ))
        end

        return true
    end)
end

function TradeRulesItems:Register(name, func)
    table.insert(self.registered, { name = name, func = func })
end

function TradeRulesItems:Fail(msg, ...)
    local formatted = FormatMessage(msg, ...)

    if not formatted then
        return false
    end

    self.pendingMessages = self.pendingMessages or {}

    if not self.pendingMessages[formatted] then
        self.pendingMessages[formatted] = true
        local panel = TradeFill:GetModule("TradingStatusPanel")
        panel:AddMessage(formatted)
    end

    return false
end

function TradeRulesItems:CheckAll(context)
    local allOk = true

    for _, tradeRule in ipairs(self.registered) do
        local ok = tradeRule.func(context)

        if not ok then
            allOk = false
        end
    end

    return allOk
end

function TradeRulesItems:BeginEvaluation()
    self.pendingMessages = {}
end

function TradeRulesItems:EndEvaluation()
    self.pendingMessages = nil
end

