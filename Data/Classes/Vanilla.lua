local addonName, TF = ...

local faction = UnitFactionGroup("player")

if faction == "Alliance" then
    TF.classes = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "DRUID" }
elseif faction == "Horde" then
    TF.classes = { "WARRIOR", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }
end
