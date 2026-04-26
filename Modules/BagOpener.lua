local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local BagOpener = TradeFill:NewModule("BagOpener", "AceEvent-3.0")

local function HasSelectedBags(settings)
    if not settings then
        return false
    end

    for bag = 0, 4 do
        if settings[tostring(bag)] then
            return true
        end
    end

    return false
end

function BagOpener:OnEnable()
    self:RegisterEvent("TRADE_SHOW")
    self:RegisterEvent("TRADE_CLOSED")
end

function BagOpener:OpenSelectedBags()
    local settings = TradeFill.db.profile.settings.bags

    if not HasSelectedBags(settings) then return end

    local allSelected = true

    for bag = 0, 4 do
        if not settings[tostring(bag)] then
            allSelected = false
            break
        end
    end

    if allSelected then
        OpenAllBags()
        return
    end

    for bag = 0, 4 do
        if settings[tostring(bag)] then
            OpenBag(bag)
        end
    end
end

function BagOpener:CloseSelectedBags()
    local settings = TradeFill.db.profile.settings.bags
    if not HasSelectedBags(settings) then return end

    for bag = 0, 4 do
        if settings[tostring(bag)] then
            CloseBag(bag)
        end
    end
end

function BagOpener:TRADE_SHOW()
    self:OpenSelectedBags()
end

function BagOpener:TRADE_CLOSED()
    self:CloseSelectedBags()
end
