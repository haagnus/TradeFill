local addonName, TF = ...

local LEGACY_SETTING_MAPPINGS = {
    trade = {
        ungrouped = "solo",
        party = "party",
        raid = "raid",
        auto = "auto",
        refresh = "refresh",
    },
    filter = {
        guild = "guild",
        required = "require",
        level = "level",
        master = "master",
        lock = "lock",
        clear = "clear",
        guilds = "guilds",
        players = "players",
    },
    ui = {
        show = "show",
        button = "button",
        status = "message",
    },
}

local function GetMainGroup(profile)
    if type(profile.groups) ~= "table" then
        profile.groups = {}
    end

    if type(profile.groups.main) ~= "table" then
        profile.groups.main = { stack = {}, size = {} }
    end

    if type(profile.groups.main.stack) ~= "table" then
        profile.groups.main.stack = {}
    end

    if type(profile.groups.main.size) ~= "table" then
        profile.groups.main.size = {}
    end

    return profile.groups.main
end

local function CopyLegacyGroupField(profile, sourceField, targetField)
    local source = profile[sourceField]

    if type(source) ~= "table" then
        return
    end

    local mainGroup = GetMainGroup(profile)
    local target = mainGroup[targetField]

    for classFile, slots in pairs(source) do
        if type(slots) == "table" then
            target[classFile] = target[classFile] or {}

            for slot, value in pairs(slots) do
                target[classFile][tostring(slot)] = value or 0
            end
        end
    end
end

local function GetSlotValue(slots, slot)
    if type(slots) ~= "table" then
        return nil
    end

    local value = slots[slot] or slots[tostring(slot)]
    local numericSlot = tonumber(slot)

    if value == nil and numericSlot ~= nil then
        value = slots[numericSlot]
    end

    return value
end

local function GetLegacyItemStack(profile, slot)
    local items = profile.item

    if type(items) ~= "table" then
        return 0
    end

    local item = GetSlotValue(items, slot)

    if type(item) == "table" and type(item.stack) == "number" then
        return item.stack
    end

    return 0
end

local function HasLegacyItemSet(profile, slot)
    local items = profile.item

    if type(items) ~= "table" then
        return false
    end

    local item = GetSlotValue(items, slot)

    if type(item) ~= "table" then
        return false
    end

    if type(item.id) == "number" and item.id > 0 then
        return true
    end

    if type(item.link) == "string" and item.link ~= "" then
        return true
    end

    return type(item.name) == "string" and item.name ~= ""
end

local function ClearSlotValue(slots, slot)
    if type(slots) ~= "table" then
        return
    end

    local numericSlot = tonumber(slot)

    slots[slot] = nil
    slots[tostring(slot)] = nil

    if numericSlot ~= nil then
        slots[numericSlot] = nil
    end
end

local function ClearLegacySlotValues(profile, slot)
    ClearSlotValue(profile.item, slot)

    for _, sourceField in ipairs({ "stacks", "size" }) do
        local source = profile[sourceField]

        if type(source) == "table" then
            for _, slots in pairs(source) do
                ClearSlotValue(slots, slot)
            end
        end
    end
end

local function ClearLegacySlotsWithoutItems(profile)
    local slots = {}

    if type(profile.item) == "table" then
        for slot in pairs(profile.item) do
            slots[tostring(slot)] = true
        end
    end

    for _, sourceField in ipairs({ "stacks", "size" }) do
        local source = profile[sourceField]

        if type(source) == "table" then
            for _, classSlots in pairs(source) do
                if type(classSlots) == "table" then
                    for slot in pairs(classSlots) do
                        slots[tostring(slot)] = true
                    end
                end
            end
        end
    end

    for slot in pairs(slots) do
        if slot ~= "*" and not HasLegacyItemSet(profile, slot) then
            ClearLegacySlotValues(profile, slot)
        end
    end
end

local function HasAssignedLegacyStack(stackSlots, slot)
    local value = GetSlotValue(stackSlots, slot)

    return value ~= nil and value ~= 0
end

local function CopyLegacySizeField(profile)
    local legacySizes = profile.size
    local legacyStacks = profile.stacks

    local mainGroup = GetMainGroup(profile)

    local classFiles = {}

    if type(legacySizes) == "table" then
        for classFile in pairs(legacySizes) do
            classFiles[classFile] = true
        end
    end

    if type(legacyStacks) == "table" then
        for classFile in pairs(legacyStacks) do
            classFiles[classFile] = true
        end
    end

    for classFile in pairs(classFiles) do
        local sizeSlots = type(legacySizes) == "table" and legacySizes[classFile]
        local stackSlots = type(legacyStacks) == "table" and legacyStacks[classFile]
        local slots = {}

        if type(sizeSlots) == "table" then
            for slot in pairs(sizeSlots) do
                slots[tostring(slot)] = true
            end
        end

        if type(stackSlots) == "table" then
            for slot in pairs(stackSlots) do
                slots[tostring(slot)] = true
            end
        end

        mainGroup.size[classFile] = mainGroup.size[classFile] or {}

        for slot in pairs(slots) do
            local value = GetSlotValue(sizeSlots, slot)

            if value == nil and HasAssignedLegacyStack(stackSlots, slot) then
                value = GetLegacyItemStack(profile, slot)
            end

            mainGroup.size[classFile][tostring(slot)] = value or 0
        end
    end
end

local function CopyLegacySettings(profile)
    local legacySettings = profile.setting
    local settings = profile.settings

    if type(legacySettings) ~= "table" or type(settings) ~= "table" then
        return
    end

    for targetSection, mapping in pairs(LEGACY_SETTING_MAPPINGS) do
        local target = settings[targetSection]

        if type(target) == "table" then
            for newKey, oldKey in pairs(mapping) do
                local value = legacySettings[oldKey]

                if value ~= nil then
                    target[newKey] = value
                end
            end
        end
    end

    if type(settings.minimap) == "table" and type(legacySettings.minimap) == "table" then
        if legacySettings.minimap.hide ~= nil then
            settings.minimap.hide = legacySettings.minimap.hide
        end
    end
end

function TF:MigrateLegacyProfile(db)
    local profile = db and db.profile

    if type(profile) ~= "table" then
        return
    end

    local hasLegacyStacks = type(profile.stacks) == "table" and next(profile.stacks) ~= nil
    local hasLegacySize = type(profile.size) == "table" and next(profile.size) ~= nil
    local hasLegacySettings = type(profile.setting) == "table" and next(profile.setting) ~= nil

    if not hasLegacyStacks and not hasLegacySize and not hasLegacySettings then
        return
    end

    ClearLegacySlotsWithoutItems(profile)
    CopyLegacySettings(profile)
    CopyLegacyGroupField(profile, "stacks", "stack")
    CopyLegacySizeField(profile)

    profile.stacks = nil
    profile.size = nil
    profile.setting = nil

    return true
end
