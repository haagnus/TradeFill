local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local LimitService = TradeFill:NewModule("LimitService")

local function NormalizeKey(key)
    return tostring(key)
end

function LimitService:Get(playerName, tradeSlot)
    if not playerName then
        return 0
    end

    local profile = TradeFill.limit and TradeFill.limit.profile
    local playerLimits = profile and profile[playerName]

    if not playerLimits then
        return 0
    end

    return tonumber(playerLimits[NormalizeKey(tradeSlot)]) or 0
end

function LimitService:Set(playerName, tradeSlot, value)
    if not playerName then
        return
    end

    TradeFill.limit.profile[playerName] = TradeFill.limit.profile[playerName] or {}
    TradeFill.limit.profile[playerName][NormalizeKey(tradeSlot)] = value
end

function LimitService:Increment(playerName, tradeSlot, amount)
    amount = amount or 1
    self:Set(playerName, tradeSlot, self:Get(playerName, tradeSlot) + amount)
end

function LimitService:Reset()
    TradeFill.limit:ResetProfile()
end

function LimitService:HasReachedLimit(playerName, tradeSlot, configuredLimit)
    configuredLimit = tonumber(configuredLimit) or 0

    if configuredLimit <= 0 then
        return false
    end

    return self:Get(playerName, tradeSlot) >= configuredLimit
end

