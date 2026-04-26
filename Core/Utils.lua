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
    return self:GetModule("PlayerService"):GetFullUnitName(unit)
end

function TradeFill:SetClass(classFile)
    return self:GetModule("PlayerService"):FormatClass(classFile)
end

function TradeFill:SetName(ctx)
    return self:GetModule("PlayerService"):FormatName(ctx)
end

function TradeFill:GroupType()
    return self:GetModule("PlayerService"):GetGroupType()
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
