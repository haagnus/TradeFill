local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local TradeRulesGeneral = TradeFill:NewModule("TradeRulesGeneral")

local function GetLootMethodInfo()
    if C_PartyInfo and C_PartyInfo.GetLootMethod then
        return C_PartyInfo.GetLootMethod()
    end

    if GetLootMethod then
        return GetLootMethod()
    end
end

function TradeRulesGeneral:OnInitialize()
    self.registered = {}

    self:Register("AutoFill", function(ctx)
        local set = TradeFill.db.profile.settings

        if not set.trade.auto then
            return TradeRulesGeneral:Fail(string.format(
                TF.Loc["MESSAGE_AUTOFILL"],
                TradeFill:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto),
                TradeFill:SetColor(TF.Loc["TEXT_DISABLED"], TF.colors.addon.disabled)
            ))
        end

        return true
    end)

    self:Register("AllowedPlayers", function(ctx)
        local set = TradeFill.db.profile.settings
        local groupType = ctx.state.groupType
        local targetName = TradeFill:SetName(ctx.state)

        local allowUngrouped = set.trade.ungrouped
        local allowParty = set.trade.party
        local allowRaid = set.trade.raid

        if not allowUngrouped and not allowParty and not allowRaid then
            return TradeRulesGeneral:Fail(string.format(
                TF.Loc["MESSAGE_ALLOWED_NON"],
                TradeFill:SetColor(TF.Loc["UNGROUPED"], TF.colors.trade.ungrouped),
                TradeFill:SetColor(TF.Loc["PARTY"], TF.colors.trade.party),
                TradeFill:SetColor(TF.Loc["RAID"], TF.colors.trade.raid)
            ))
        end

        local isAllowed =
            (allowUngrouped and groupType == "ungrouped") or
            (allowParty and groupType == "party") or
            (allowRaid and groupType == "raid")

        if isAllowed then
            return true
        end

        if groupType == "ungrouped" then
            return TradeRulesGeneral:Fail(string.format(
                TF.Loc["MESSAGE_ALLOWED_UNGROUPED"],
                TradeFill:SetColor(TF.Loc["UNGROUPED"], TF.colors.trade.ungrouped),
                targetName
            ))
        end

        if groupType == "party" then
            return TradeRulesGeneral:Fail(string.format(
                TF.Loc["MESSAGE_ALLOWED_PARTY"],
                TradeFill:SetColor(TF.Loc["PARTY"], TF.colors.trade.party),
                targetName
            ))
        end

        if groupType == "raid" then
            return TradeRulesGeneral:Fail(string.format(
                TF.Loc["MESSAGE_ALLOWED_RAID"],
                TradeFill:SetColor(TF.Loc["RAID"], TF.colors.trade.raid),
                targetName
            ))
        end

        return false
    end)

    self:Register("Guild", function(ctx)
        local set = TradeFill.db.profile.settings

        if not set.filter.guild then return true end

        local guild = ctx.state.target.guild
        if guild ~= GetGuildInfo("player") then
            return TradeRulesGeneral:Fail(string.format(
                TF.Loc["MESSAGE_REQUIREMENTS_GUILD"],
                TradeFill:SetColor(TF.Loc["GUILD"], TF.colors.filter.guild),
                TradeFill:SetName(TF.state)
            ))
        end

        return true
    end)

    self:Register("Level", function(ctx)
        local set = TradeFill.db.profile.settings

        if not set.filter.level then return true end

        local max = GetMaxPlayerLevel()
        local level = ctx.state.target.level

        if level < max then
            local levelText = string.format(TF.Loc["LEVEL"], max)

            return TradeRulesGeneral:Fail(string.format(
                TF.Loc["MESSAGE_REQUIREMENTS_MAX_LEVEL"],
                TradeFill:SetColor(levelText, TF.colors.filter.level),
                TradeFill:SetName(TF.state)
            ))
        end

        return true
    end)

    self:Register("MasterLooter", function(ctx)
        local set = TradeFill.db.profile.settings

        if not set.filter.master then return true end

        local lootmethod, mlPartyID, mlRaidID = GetLootMethodInfo()

        local newLootMaster =
            mlRaidID and GetRaidRosterInfo(mlRaidID) or
            (mlPartyID == 0 and UnitName("player")) or
            (mlPartyID and UnitName("party" .. mlPartyID))

        if (lootmethod == "master" or lootmethod == 2) and UnitName("player") == newLootMaster then
            return TradeRulesGeneral:Fail(string.format(
                TF.Loc["MESSAGE_RULES_MASTER_LOOTER"],
                TradeFill:SetColor(TF.Loc["MASTER"], TF.colors.filter.master)
            ))
        end

        return true
    end)

    self:Register("Players", function(ctx)
        for name in string.gmatch(TradeFill.db.profile.settings.filter.players, "[^\n]+") do
            if string.lower(name) == string.lower(ctx.state.target.name) then
                return TradeRulesGeneral:Fail(string.format(
                    TF.Loc["MESSAGE_IGNORE_PLAYERS"],
                    TradeFill:SetColor(TF.state.target.name, TF.colors.ignore.player)
                ))
            end
        end

        return true
    end)

    self:Register("Guilds", function(ctx)
        local guild = ctx.state.target.guild

        if not guild then return true end

        for name in string.gmatch(TradeFill.db.profile.settings.filter.guilds, "[^\n]+") do
            if string.lower(name) == string.lower(guild) then
                return TradeRulesGeneral:Fail(string.format(
                    TF.Loc["MESSAGE_IGNORE_GUILDS"],
                    TradeFill:SetColor(guild, TF.colors.ignore.guild)
                ))
            end
        end

        return true
    end)
end

function TradeRulesGeneral:Register(name, func)
    table.insert(self.registered, { name = name, func = func })
end

function TradeRulesGeneral:Fail(msg, ...)
    local panel = TradeFill:GetModule("TradingStatusPanel")
    panel:AddMessage(msg, ...)
    return false
end

function TradeRulesGeneral:CheckAll(context)
    local allOk = true

    for _, tradeRule in ipairs(self.registered) do
        local ok = tradeRule.func(context)

        if not ok then
            allOk = false
        end
    end

    return allOk
end
