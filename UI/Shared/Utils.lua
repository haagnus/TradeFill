local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

function TradeFill:GetMaxPlayerLevel(text)
    return string.format(text, GetMaxPlayerLevel())
end

function TradeFill:GetRGB(link)
    local pattern = "|cff(%x%x)(%x%x)(%x%x)"

    local r, g, b = link:match(pattern)

    r, g, b = tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)

    return { r, g, b }
end

function TradeFill:GetColor(link)
    -- Try 6-digit hex (Classic)
    local hex6 = link:match("|cff(%x%x%x%x%x%x)")
    if hex6 then
        return hex6
    end

    -- Try 8-digit hex (Retail)
    local hex8 = link:match("|c(%x%x%x%x%x%x%x%x)")
    if hex8 then
        return hex8
    end

    -- Named color (Retail)
    local named = link:match("|c(n[^:]+):")
    if named then
        return named
    end

    return nil
end

function TradeFill:Split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function TradeFill:FormatColorText(color, text)
    if color:match("^%x%x%x%x%x%x$") then

        return "|cff" .. color .. text .. "|r"
    elseif color:match("^n[^:]+$") then

        return "|c" .. color .. ":" .. text .. "|r"
    else
        -- Invalid or no color
        return text
    end
end

function TradeFill:NormalizeNameList(value, options)
    value = (value or ""):gsub("\r\n", "\n")

    if options.compactWhitespaceToNewlines then
        value = value:gsub("%s+", "\n")
    end

    local cleaned = {}
    local allowedChars = options.allowSpaces and "[^A-Za-z \n]" or "[^A-Za-z\n]"

    for line in value:gmatch("[^\n]+") do
        line = line:gsub(allowedChars, "")
        line = line:match("^%s*(.-)%s*$")

        if line ~= "" then
            table.insert(cleaned, line)
        end
    end

    return table.concat(cleaned, "\n")
end
