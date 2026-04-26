local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

local function FormatGuildsForDisplay(value)
    local formatted = {}

    for line in (value or ""):gmatch("[^\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" then
            local cleanLine = line:gsub("^<", ""):gsub(">$", "")
            table.insert(formatted, "<" .. cleanLine .. ">")
        end
    end

    return table.concat(formatted, "\n")
end

local function StripGuildDisplayFormatting(value)
    local stripped = {}

    for line in (value or ""):gmatch("[^\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" then
            local cleanLine = line:gsub("^<", ""):gsub(">$", "")
            table.insert(stripped, cleanLine)
        end
    end

    return table.concat(stripped, "\n")
end

function TradeFill:IgnoreGuilds(frame)
    local contentGroup = self:ContentGroup(AceGUI, frame)
    local group = self:Group(AceGUI, "SimpleGroup", contentGroup)
    local guildColor = self:GetRGB(self:FormatColorText(TF.colors.filter.guild, ""))

    self:SetInfoLabel(
        AceGUI,
        group,
        TF.Loc["INFO_GUILDS"],
        string.format(
            TF.Loc["INFO_GUILDS_DESC"],
            self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto)
        )
    )

    local guild = AceGUI:Create("MultiLineEditBox")
    guild:SetText(FormatGuildsForDisplay(self:NormalizeNameList(self:GetFilter("guilds"), {
        allowSpaces = true,
        compactWhitespaceToNewlines = false,
    })))
    guild:SetLabel(TF.Loc["INPUT_TEXTAREA_GUILDS"])
    guild:SetNumLines(20)
    guild.editBox:SetTextColor(guildColor[1] / 255, guildColor[2] / 255, guildColor[3] / 255)
    group:AddChild(guild)

    guild:SetCallback("OnEnterPressed", function(_, _, value)
        local guilds = self:NormalizeNameList(StripGuildDisplayFormatting(value), {
            allowSpaces = true,
            compactWhitespaceToNewlines = false,
        })

        self:SetFilter("guilds", guilds)
        guild:SetText(FormatGuildsForDisplay(guilds))
    end)

    frame.frame:SetClipsChildren(true)
end
