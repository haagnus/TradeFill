local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

local function GetAddonVersion()
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(addonName, "Version")
    end

    if GetAddOnMetadata then
        return GetAddOnMetadata(addonName, "Version")
    end

    return "unknown"
end

function TradeFill:HandleSlashCommand(input)
    input = (input or ""):lower():match("^%s*(.-)%s*$")

    if input == "" then
        self:Open()
    elseif input == "on" then
        self:On()
    elseif input == "off" then
        self:Off()
    elseif input == "limit" then
        self:ResetLimit()
    else
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "%s commands: /tf, /tf on, /tf off, /tf limit",
            string.format(
                self:SetColor(TF.Loc["SIGNATURE"], TF.colors.addon.signature),
                addonName
            )
        ))
    end
end

local function RegisterChatCommands(self)
    self:RegisterChatCommand("tradefill", "HandleSlashCommand")
    self:RegisterChatCommand("tf", "HandleSlashCommand")
end

local function BuildOptions()
    return {
        name = addonName,
        handler = TradeFill,
        type = "group",
        args = {
            button = {
                type = "execute",
                name = TF.Loc["BUTTON_SETTING"],
                desc = TF.Loc["BUTTON_SETTING_DESC"],
                func = function()
                    TradeFill:Open()
                end,
                width = 0.5,
                order = 1,
            },
        },
    }
end

function TradeFill:OnInitialize()
    TF.Loc = LibStub("AceLocale-3.0"):GetLocale(addonName)

    self.db = LibStub("AceDB-3.0"):New("TradeFillDB", TF.items)
    self.migratedLegacyProfile = TF:MigrateLegacyProfile(self.db)
    self.tradelog = LibStub("AceDB-3.0"):New("TradeFillHistoryDB", TF.tradelog)
    self.limit = LibStub("AceDB-3.0"):New("TradeFillLimitDB", TF.limit)

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, BuildOptions())
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    AceConfigDialog:AddToBlizOptions(addonName, addonName)
end

function TradeFill:OnEnable()
    RegisterChatCommands(self)

    if self:GetTrade("refresh") then
        self:GetModule("LimitService"):Reset()
    end

    DEFAULT_CHAT_FRAME:AddMessage(
        string.format(
            TF.Loc["VERSION"],
            string.format(
                self:SetColor(TF.Loc["SIGNATURE"], TF.colors.addon.signature),
                addonName
            ),
            GetAddonVersion()
        )
    )

    if self.migratedLegacyProfile then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            TF.Loc["MESSAGE_MIGRATION_COMPLETE"],
            string.format(
                self:SetColor(TF.Loc["SIGNATURE"], TF.colors.addon.signature),
                addonName
            ),
            self:SetColor(TF.Loc["TAB_MAIN"], TF.colors.tab.main),
            self:SetColor(TF.Loc["TAB_UNGROUPED"], TF.colors.tab.ungrouped),
            self:SetColor(TF.Loc["TAB_PARTY"], TF.colors.tab.party),
            self:SetColor(TF.Loc["TAB_RAID"], TF.colors.tab.raid)
        ))

        DEFAULT_CHAT_FRAME:AddMessage(string.format(TF.Loc["MESSAGE_MIGRATION_BAGS"],
            string.format(
                self:SetColor(TF.Loc["SIGNATURE"], TF.colors.addon.signature),
                addonName
            )
        ))
    end
end
