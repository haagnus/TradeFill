local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local Evaluator = TradeFill:NewModule("TradeRulesEvaluator")

function Evaluator:OnInitialize()
    self.generalTradeRules = TradeFill:GetModule("TradeRulesGeneral")
    self.itemTradeRules = TradeFill:GetModule("TradeRulesItems")
end

function Evaluator:PassesGeneralChecks()
    local context = {
        state = TF.state,
        settings = TF.settings,
    }

    return self.generalTradeRules:CheckAll(context)
end

function Evaluator:EvaluateItems()
    local results = {}

    local state = TF.state
    local level = TF.state.target.level
    local name = TF.state.target.fullName
    local settings = TF.settings

    self.itemTradeRules:BeginEvaluation()

    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        local item = TF.item[tostring(tradeSlot)]
        local isValid = false

        if item and item.id and item.id > 0 then
            local effective = TradeFill:GetEffectiveItem(tradeSlot, level)

            local context = {
                item = item,
                effective = effective,
                state = state,
                settings = settings,
                stack = TradeFill:GetActiveGroupStack(tradeSlot),
                limit = TradeFill:GetLimit(name, tradeSlot)
            }

            isValid = self.itemTradeRules:CheckAll(context)
        end

        results[tradeSlot] = isValid
    end

    self.itemTradeRules:EndEvaluation()

    return results
end
