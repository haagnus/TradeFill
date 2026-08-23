local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

function TradeFill:Requirements(frame, parent)
    local container = parent
    if not container then
        container = self:ContentGroup(AceGUI, frame)
    end

    local group = self:Group(AceGUI, "InlineGroup", container)
    group:SetFullWidth(true)
    group:SetLayout("List")

    self:SetInfoLabel(
        AceGUI,
        group,
        TF.Loc["REQUIREMENTS"],
        string.format(
            TF.Loc["REQUIREMENTS_DESC"],
            self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto),
            self:SetColor(TF.Loc["GUILD"], TF.colors.filter.guild),
            self:SetColor(TF.Loc["REQUIRED"], TF.colors.filter.required),
            self:SetColor(
                string.format(TF.Loc["LEVEL"], GetMaxPlayerLevel()),
                TF.colors.filter.level-------COLOR CODDE
            )
        )
    )

    self:AddRowSpacer(AceGUI, group)

    -- Guild
    self:CreateCheckBox(group, {
        label = self:SetColor(TF.Loc["GUILD"], TF.colors.filter.guild),
        tooltip = TF.Loc["GUILD_DESC"],
        width = 150,
        get = function() return self:GetFilter("guild") end,
        set = function(value)
            self:SetFilter("guild", value)
        end
    })

    -- Required
    self:CreateCheckBox(group, {
        label = self:SetColor(TF.Loc["REQUIRED"], TF.colors.filter.required),
        tooltip = TF.Loc["REQUIRED_DESC"],
        width = 130,
        get = function() return self:GetFilter("required") end,
        set = function(value)
            self:SetFilter("required", value)
        end
    })

    -- Level
    self:CreateCheckBox(group, {
        label = self:SetColor(self:GetMaxPlayerLevel(TF.Loc["LEVEL"]), TF.colors.filter.level),
        tooltip = TF.Loc["LEVEL_DESC"],
        width = 100,
        get = function() return self:GetFilter("level") end,
        set = function(value)
            self:SetFilter("level", value)
        end
    })

    if not parent then
        local frameWidget = frame.frame
        frameWidget:SetClipsChildren(true)
    end
end
