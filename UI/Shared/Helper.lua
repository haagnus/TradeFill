local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local Minimap = TradeFill:GetModule("Minimap")

local function NormalizeKey(key)
    return tostring(key)
end

local function NormalizePlayerName(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    return name
end

local function NormalizeLegacyPlayerName(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    return string.lower(name)
end

local function GetPlayerNameBase(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    return string.match(name, "^([^%-]+)") or name
end

local function AbbreviatePlayerRealm(name)
    if type(name) ~= "string" or name == "" then
        return name
    end

    local prefix, realm, suffix = string.match(name, "^(.-%-)([^|]+)(|r.*)$")

    if prefix and realm and suffix then
        return prefix .. string.sub(realm, 1, 3) .. suffix
    end

    prefix, realm = string.match(name, "^(.-%-)(.+)$")

    if prefix and realm then
        return prefix .. string.sub(realm, 1, 3)
    end

    return name
end

local function GetPlayerOverrideByName(overrides, name)
    if type(overrides) ~= "table" then
        return nil
    end

    local key = NormalizePlayerName(name)
    if not key then
        return nil
    end

    local legacyKey = NormalizeLegacyPlayerName(key)
    local baseKey = GetPlayerNameBase(key)
    local legacyBaseKey = NormalizeLegacyPlayerName(baseKey)

    local direct = rawget(overrides, key)
        or (legacyKey and rawget(overrides, legacyKey))
        or (baseKey and rawget(overrides, baseKey))
        or (legacyBaseKey and rawget(overrides, legacyBaseKey))

    if direct then
        return direct
    end

    for overrideName, override in pairs(overrides) do
        if type(overrideName) == "string" and type(override) == "table" then
            local overrideBase = GetPlayerNameBase(overrideName)

            if overrideBase and legacyBaseKey and string.lower(overrideBase) == legacyBaseKey then
                return override
            end
        end
    end

    return nil
end

local function GetItemOverrideKey(item)
    if not item or not item.id or item.id <= 0 then
        return nil
    end

    return tostring(item.id)
end

local function GetItemDataByID(itemID)
    local numericID = tonumber(itemID)

    if not numericID or numericID <= 0 then
        return nil
    end

    local name, link, quality, _, level, _, _, stack, _, texture = C_Item.GetItemInfo(numericID)

    return {
        id = numericID,
        name = name or string.format(TF.Loc["PLAYER_OVERRIDE_ITEM_ID"], numericID),
        link = link or tostring(numericID),
        quality = quality or 0,
        level = level or 0,
        stack = stack or 0,
        texture = texture or 0,
        limit = 0,
        playerOverrideTradeAnyway = true,
    }
end

local function IsConfiguredItemID(db, itemID)
    local itemKey = tostring(itemID)

    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        local item = db.item and db.item[NormalizeKey(tradeSlot)]

        if item and tostring(item.id) == itemKey then
            return true
        end
    end

    return false
end

local function GetEmptyConfiguredSlot(db, runtimeItems)
    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        local key = NormalizeKey(tradeSlot)
        local item = db.item and db.item[key]

        if not runtimeItems[key] and (not item or not item.id or item.id <= 0) then
            return key
        end
    end

    return nil
end

local function HasPlayerOverrideItems(playerOverride)
    if type(playerOverride) ~= "table" then
        return false
    end

    for key, value in pairs(playerOverride) do
        if tonumber(key) and type(value) == "table" then
            return true
        end
    end

    return false
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
    local override = self:GetActivePlayerItemOverride(index)

    if override and override.stack ~= nil then
        return tonumber(override.stack) or 0
    end

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
    local override = self:GetActivePlayerItemOverride(index)

    if override and override.size ~= nil then
        return tonumber(override.size) or 0
    end

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

function TradeFill:GetBaseActiveGroupStack(key)
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

function TradeFill:GetBaseActiveGroupSize(key)
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

function TradeFill:GetPlayerOverride(playerName)
    local overrides = self.db and self.db.profile and self.db.profile.playerOverrides

    return GetPlayerOverrideByName(overrides, playerName)
end

function TradeFill:GetActivePlayerOverride()
    local target = TF.state and TF.state.target

    if not target then
        return nil
    end

    return self:GetPlayerOverride(target.fullName or target.name)
end

function TradeFill:GetActivePlayerItemOverride(key)
    local override = self:GetActivePlayerOverride()
    local item = self:GetEffectiveItem(key)
    local itemKey = GetItemOverrideKey(item)

    if not override or not itemKey then
        return nil
    end

    local itemOverride = rawget(override, itemKey)

    if itemOverride then
        return itemOverride
    end

    if override.stack or override.size then
        local index = NormalizeKey(key)

        return {
            stack = override.stack and override.stack[index],
            size = override.size and override.size[index],
        }
    end

    return nil
end

function TradeFill:SetPlayerOverride(playerName, values)
    local key = NormalizePlayerName(playerName)

    if not key or type(values) ~= "table" then
        return
    end

    local db = self.db.profile
    db.playerOverrides = db.playerOverrides or {}
    local existing = db.playerOverrides[key]

    if type(existing) == "table" then
        for itemID, itemOverride in pairs(values) do
            local existingItem = existing[itemID]

            if type(itemOverride) == "table" and type(existingItem) == "table" and existingItem.tradeAnyway then
                itemOverride.tradeAnyway = true
            end
        end
    end

    db.playerOverrides[key] = values

    if TF.state and TF.state.target and TF.state.target.class and TF.state.target.class.file and TF.state.target.fullName then
        db.playerOverrides[key].name = self:ColorizeUnitNameByClass(TF.state.target.class.file, TF.state.target.fullName)
    end
end

function TradeFill:GetPlayerOverrides()
    local db = self.db and self.db.profile

    if not db then
        return {}
    end

    db.playerOverrides = db.playerOverrides or {}

    return db.playerOverrides
end

function TradeFill:GetPlayerOverrideDisplayName(playerName)
    local override = self:GetPlayerOverride(playerName)

    if type(override) == "table" and type(override.name) == "string" and override.name ~= "" then
        return AbbreviatePlayerRealm(override.name)
    end

    return AbbreviatePlayerRealm(playerName)
end

function TradeFill:GetPlayerOverrideFullDisplayName(playerName)
    local override = self:GetPlayerOverride(playerName)

    if type(override) == "table" and type(override.name) == "string" and override.name ~= "" then
        return override.name
    end

    return playerName
end

function TradeFill:SetPlayerOverrideItem(playerName, itemID, stack, size)
    local playerKey = NormalizePlayerName(playerName)
    local itemKey = NormalizeKey(itemID)

    if not playerKey or not itemKey then
        return
    end

    local overrides = self:GetPlayerOverrides()
    overrides[playerKey] = overrides[playerKey] or {}
    local existing = overrides[playerKey][itemKey]

    overrides[playerKey][itemKey] = {
        stack = tonumber(stack) or 0,
        size = tonumber(size) or 0,
        tradeAnyway = type(existing) == "table" and existing.tradeAnyway or false,
    }
end

function TradeFill:SetPlayerOverrideItemTradeAnyway(playerName, itemID, enabled)
    local playerKey = NormalizePlayerName(playerName)
    local itemKey = NormalizeKey(itemID)

    if not playerKey or not itemKey then
        return
    end

    local overrides = self:GetPlayerOverrides()
    overrides[playerKey] = overrides[playerKey] or {}
    overrides[playerKey][itemKey] = overrides[playerKey][itemKey] or { stack = 0, size = 0 }
    overrides[playerKey][itemKey].tradeAnyway = enabled and true or false
end

function TradeFill:IsPlayerOverrideItemConfigured(itemID)
    local db = self.db and self.db.profile

    if not db then
        return false
    end

    return IsConfiguredItemID(db, itemID)
end

function TradeFill:GetActivePlayerOverrideUsage()
    local db = self.db and self.db.profile
    local playerOverride = self:GetActivePlayerOverride()
    local usage = {
        hasOverride = type(playerOverride) == "table",
        hasUsableOverride = false,
        hasTradeAnywayDisabled = false,
    }

    if not usage.hasOverride or not db then
        return usage
    end

    for itemID, itemOverride in pairs(playerOverride) do
        if tonumber(itemID) and type(itemOverride) == "table" then
            local hasAmount = (tonumber(itemOverride.stack) or 0) > 0 and (tonumber(itemOverride.size) or 0) > 0

            if IsConfiguredItemID(db, itemID) then
                usage.hasUsableOverride = true
            elseif hasAmount and itemOverride.tradeAnyway then
                usage.hasUsableOverride = true
            elseif hasAmount then
                usage.hasTradeAnywayDisabled = true
            end
        end
    end

    if not usage.hasUsableOverride and type(playerOverride.stack) == "table" and type(playerOverride.size) == "table" then
        for tradeSlot = 1, MAX_TRADABLE_ITEMS do
            local item = self:GetTradeItem(tradeSlot)

            if item and item.id and item.id > 0 then
                local stack = tonumber(playerOverride.stack[NormalizeKey(tradeSlot)]) or 0
                local size = tonumber(playerOverride.size[NormalizeKey(tradeSlot)]) or 0

                if stack > 0 and size > 0 then
                    usage.hasUsableOverride = true
                    break
                end
            end
        end
    end

    return usage
end

function TradeFill:PrepareTradeAnywayPlayerOverrides()
    local db = self.db and self.db.profile

    TF.runtimeItems = {}

    if not db then
        return
    end

    local playerOverride = self:GetActivePlayerOverride()

    if type(playerOverride) ~= "table" then
        return
    end

    for itemID, itemOverride in pairs(playerOverride) do
        if tonumber(itemID)
            and type(itemOverride) == "table"
            and itemOverride.tradeAnyway
            and (tonumber(itemOverride.stack) or 0) > 0
            and (tonumber(itemOverride.size) or 0) > 0
            and not IsConfiguredItemID(db, itemID)
        then
            local slot = GetEmptyConfiguredSlot(db, TF.runtimeItems)

            if not slot then
                self:GetModule("TradingStatusPanel"):AddMessage(TF.Loc["MESSAGE_PLAYER_OVERRIDE_NO_EMPTY_SLOT"])
                return
            end

            local item = GetItemDataByID(itemID)

            if item then
                TF.runtimeItems[slot] = item
            end
        end
    end
end

function TradeFill:ClearRuntimeItems()
    TF.runtimeItems = nil
end

function TradeFill:DeletePlayerOverrideItem(playerName, itemID)
    local overrides = self:GetPlayerOverrides()
    local playerKey = NormalizePlayerName(playerName)
    local playerOverride = rawget(overrides, playerKey or "")

    if not playerOverride then
        return
    end

    playerOverride[NormalizeKey(itemID)] = nil

    if not HasPlayerOverrideItems(playerOverride) then
        overrides[playerKey] = nil
    end
end

function TradeFill:DeletePlayerOverride(playerName)
    local key = NormalizePlayerName(playerName)

    if not key then
        return
    end

    self:GetPlayerOverrides()[key] = nil
end

function TradeFill:DeleteAllPlayerOverrides()
    local db = self.db and self.db.profile

    if not db then
        return
    end

    db.playerOverrides = {}
end

function TradeFill:GetItem(key)
    local index = NormalizeKey(key)

    return TradeFill.db.profile.item[index]
end

function TradeFill:GetTradeItem(key)
    local index = NormalizeKey(key)

    if TF.runtimeItems and TF.runtimeItems[index] then
        return TF.runtimeItems[index]
    end

    return self:GetItem(index)
end

function TradeFill:GetEffectiveItem(key, level)
    local index = NormalizeKey(key)
    local item = self:GetTradeItem(index)

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
    return self:GetModule("LimitService"):Get(name, key)
end

function TradeFill:SetLimit(name, key, value)
    self:GetModule("LimitService"):Set(name, key, value)
end
