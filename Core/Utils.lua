local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

function TradeFill:SetColor(text, color)
    return "|cFF" .. color .. text .. "|r"
end

function TradeFill:GetClassHex(classFile)
    local _, _, _, argbHex = GetClassColor(classFile)

    if classFile == "SHAMAN" then
        argbHex = "FF0070DE"
    end

    return argbHex
end

function TradeFill:ColorizeByClass(classFile, text)
    return "|c" .. self:GetClassHex(classFile) .. text .. "|r"
end

function TradeFill:ColorizeUnitNameByClass(classFile, fullName)
    local name, realm = string.match(fullName or "", "^([^-]+)%-(.+)$")

    if not name or not realm then
        return self:ColorizeByClass(classFile, fullName or "")
    end

    return self:ColorizeByClass(classFile, name) .. "|cff808080-" .. realm .. "|r"
end

function TradeFill:GetFullUnitName(unit)
    local name, realm = UnitFullName(unit)

    if not name then
        return GetUnitName(unit, true)
    end

    if realm and realm ~= "" then
        return name .. "-" .. realm
    end

    return name
end

function TradeFill:SetClass(classFile)
    local className = LOCALIZED_CLASS_NAMES_MALE[classFile]
    return self:ColorizeByClass(classFile, className)
end

function TradeFill:SetName(ctx)
    local name = ctx.target.name
    local class = ctx.target.class.file
    return self:ColorizeByClass(class, name)
end

function TradeFill:GroupType()
    if IsInRaid() then
        return "raid"
    elseif IsInGroup() then
        return "party"
    else
        return "ungrouped"
    end
end

function TradeFill:GetSpell(id, level)
    local function matchAndFindBest(data)
        -- Check if the item ID matches any in the given data table
        for _, entry in ipairs(data) do
            if entry.id == id then
                local best = nil
                for _, item in ipairs(data) do
                    if level >= item.level and (not item.spell or IsPlayerSpell(item.spell)) then
                        best = item
                    end
                end
                return best
            end
        end
        return nil
    end

    -- Try each category
    local result = matchAndFindBest(TF.water)
    if result then return result end

    result = matchAndFindBest(TF.food)
    if result then return result end

    result = matchAndFindBest(TF.stone)
    if result then return result end

    return nil
end
