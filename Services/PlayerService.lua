local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local PlayerService = TradeFill:NewModule("PlayerService")

function PlayerService:GetFullUnitName(unit)
    local name, realm = UnitFullName(unit)

    if not name then
        return GetUnitName(unit, true)
    end

    if realm and realm ~= "" then
        return name .. "-" .. realm
    end

    return name
end

function PlayerService:GetGroupType()
    if IsInRaid() then
        return "raid"
    end

    if IsInGroup() then
        return "party"
    end

    return "ungrouped"
end

function PlayerService:GetUnitContext(unit)
    local className, classFile = UnitClass(unit)

    return {
        name = GetUnitName(unit),
        fullName = self:GetFullUnitName(unit),
        guild = GetGuildInfo(unit),
        level = UnitLevel(unit),
        class = {
            name = className,
            file = classFile,
        },
    }
end

function PlayerService:GetTargetContext()
    return self:GetUnitContext("npc")
end

function PlayerService:FormatName(ctx)
    local name = ctx.target.name
    local class = ctx.target.class.file
    return TradeFill:ColorizeByClass(class, name)
end

function PlayerService:FormatClass(classFile)
    local className = LOCALIZED_CLASS_NAMES_MALE[classFile]
    return TradeFill:ColorizeByClass(classFile, className)
end

