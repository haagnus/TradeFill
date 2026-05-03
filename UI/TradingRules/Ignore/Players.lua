local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

local function FormatPlayersForDisplay(value)
    local formatted = {}

    for line in (value or ""):gmatch("[^\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" then
            table.insert(formatted, string.upper(line:sub(1, 1)) .. string.lower(line:sub(2)))
        end
    end

    return table.concat(formatted, "\n")
end

local function NormalizePlayersForStorage(value)
    local normalized = {}

    for line in (value or ""):gmatch("[^\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" then
            table.insert(normalized, string.lower(line))
        end
    end

    return table.concat(normalized, "\n")
end

function TradeFill:IgnorePlayers(frame)
    local contentGroup = self:ContentGroup(AceGUI, frame)
    local group = self:Group(AceGUI, "SimpleGroup", contentGroup)
    local playerColor = self:GetRGB(self:FormatColorText(TF.colors.ignore.player, ""))

    self:SetInfoLabel(
        AceGUI,
        group,
        TF.Loc["INFO_PLAYERS"],
        string.format(
            TF.Loc["INFO_PLAYERS_DESC"],
            self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto)
        )
    )

    local name = AceGUI:Create("MultiLineEditBox")
    name:SetText(FormatPlayersForDisplay(self:NormalizeNameList(self:GetFilter("players"), {
        allowSpaces = false,
        compactWhitespaceToNewlines = false,
    })))
    name:SetLabel(TF.Loc["INPUT_TEXTAREA_PLAYERS"])
    name:SetNumLines(20)
    name.editBox:SetTextColor(playerColor[1] / 255, playerColor[2] / 255, playerColor[3] / 255)
    group:AddChild(name)

    name:SetCallback("OnEnterPressed", function(_, _, value)
        local player = NormalizePlayersForStorage(self:NormalizeNameList(value, {
            allowSpaces = false,
            compactWhitespaceToNewlines = true,
        }))

        self:SetFilter("players", player)
        name:SetText(FormatPlayersForDisplay(player))
    end)

    frame.frame:SetClipsChildren(true)
end
