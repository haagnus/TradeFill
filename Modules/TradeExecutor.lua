local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local TradeExecutor = TradeFill:NewModule("TradeExecutor")

function TradeExecutor:FillInstant(items, trade)
    local delay = 0

    for slot, isValid in pairs(items) do
        if isValid then
            local missingCount = trade:GetMissingTradeCount(slot)

            for i = 1, missingCount do
                delay = delay + 0.1

                C_Timer.After(delay, function()
                    local tradeSlot = TradeFrame_GetAvailableSlot()
                    if tradeSlot then
                        trade:FillTradeSlot(slot, tradeSlot)
                    end
                end)
            end
        end
    end
end
