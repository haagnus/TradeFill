local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local Minimap = TradeFill:GetModule("Minimap")

local function NormalizeKey(key)
    return tostring(key)
end

function TradeFill:SetGroupValue(mode, class, field, key, value)
    local db = self.db.profile
    db.groups[mode] = db.groups[mode] or { stack = {}, size = {} }
    local group = db.groups[mode]

    group[field] = group[field] or {}

    group[field][class] = group[field][class] or {}
    group[field][class][NormalizeKey(key)] = value
end

function TradeFill:GetGroupValue(mode, class, field, key)
    local db = self.db.profile
    local group = db.groups[mode]

    if not group or not group[field] or not group[field][class] then
        return 0
    end

    return group[field][class][NormalizeKey(key)] or 0
end

function TradeFill:GetEffectiveGroupValue(mode, class, field, key)
    local value = tonumber(self:GetGroupValue(mode, class, field, key)) or 0

    if value < 0 then
        return 0
    end

    if mode == "main" or value > 0 then
        return value
    end

    return tonumber(self:GetGroupValue("main", class, field, key)) or 0
end

function TradeFill:SetGroupStack(mode, class, key, value)
    self:SetGroupValue(mode, class, "stack", key, value)
end

function TradeFill:GetGroupStack(mode, class, key)
    return self:GetGroupValue(mode, class, "stack", key)
end

function TradeFill:SetGroupSize(mode, class, key, value)
    self:SetGroupValue(mode, class, "size", key, value)
end

function TradeFill:GetGroupSize(mode, class, key)
    return self:GetGroupValue(mode, class, "size", key)
end

function TradeFill:GetActiveGroupStack(key)
    local index = NormalizeKey(key)
    local class = TF.state and TF.state.target and TF.state.target.class and TF.state.target.class.file
    local mode = (TF.state and TF.state.groupType) or self:GroupType()

    if TF.stacks then
        local value = tonumber(TF.stacks[index]) or 0

        if value < 0 then
            return 0
        end

        if value > 0 then
            return value
        end

        if TF.mainStacks then
            return tonumber(TF.mainStacks[index]) or 0
        end
    end

    return self:GetEffectiveGroupValue(mode, class, "stack", index)
end

function TradeFill:GetActiveGroupSize(key)
    local index = NormalizeKey(key)
    local class = TF.state and TF.state.target and TF.state.target.class and TF.state.target.class.file
    local mode = (TF.state and TF.state.groupType) or self:GroupType()

    if TF.size then
        local value = tonumber(TF.size[index]) or 0

        if value < 0 then
            return 0
        end

        if value > 0 then
            return value
        end

        if TF.mainSize then
            return tonumber(TF.mainSize[index]) or 0
        end
    end

    return self:GetEffectiveGroupValue(mode, class, "size", index)
end

function TradeFill:GetItem(key)
    return TradeFill.db.profile.item[NormalizeKey(key)]
end

function TradeFill:GetEffectiveItem(key, level)
    local index = NormalizeKey(key)
    local item = self:GetItem(index)

    if not item or type(item.id) ~= "number" or item.id <= 0 then
        return item
    end

    if not self:GetRank(index) then
        return item
    end

    local resolvedLevel = level
    if type(resolvedLevel) ~= "number" or resolvedLevel <= 0 then
        resolvedLevel = TF.state and TF.state.target and TF.state.target.level
    end

    if type(resolvedLevel) ~= "number" or resolvedLevel <= 0 then
        resolvedLevel = UnitLevel("player")
    end

    local spellItem = self:GetSpell(item.id, resolvedLevel)
    if spellItem and spellItem.id and spellItem.id > 0 then
        return spellItem
    end

    return item
end

function TradeFill:SetItem(key, value)
    TradeFill.db.profile.item[NormalizeKey(key)] = value
end

function TradeFill:GetRank(key)
    return TradeFill.db.profile.rank[NormalizeKey(key)]
end

function TradeFill:SetRank(key, value)
    TradeFill.db.profile.rank[NormalizeKey(key)] = value
end

function TradeFill:GetTrade(key)
    return TradeFill.db.profile.settings.trade[key]
end

function TradeFill:SetTrade(key, value)
    TradeFill.db.profile.settings.trade[key] = value
end

function TradeFill:GetFilter(key)
    return TradeFill.db.profile.settings.filter[key]
end

function TradeFill:SetFilter(key, value)
    TradeFill.db.profile.settings.filter[key] = value
end

function TradeFill:GetUi(key)
    return TradeFill.db.profile.settings.ui[key]
end

function TradeFill:SetUi(key, value)
    TradeFill.db.profile.settings.ui[key] = value
end

function TradeFill:GetBag(key)
    return TradeFill.db.profile.settings.bags[NormalizeKey(key)]
end

function TradeFill:SetBag(key, value)
    TradeFill.db.profile.settings.bags[NormalizeKey(key)] = value
end

function TradeFill:GetLimit(name, key)
    return TradeFill.limit.profile[name][NormalizeKey(key)]
end

function TradeFill:SetLimit(name, key, value)
    TradeFill.limit.profile[name][NormalizeKey(key)] = value
end
