local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

function TradeFill:Rules(frame, parent)
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
        TF.Loc["RULES"],
        string.format(
            TF.Loc["RULES_DESC"],
            self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto),
            self:SetClass("ROGUE"),
            self:SetColor(TF.Loc["LOCKBOX"], TF.colors.filter.lock),
            self:SetColor(TF.Loc["CLEAR"], TF.colors.filter.clear),
            self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto),
            self:SetColor(TF.Loc["MASTER"], TF.colors.filter.master)
        )
    )

    self:AddRowSpacer(AceGUI, group)

    -- Lockbox
    self:CreateCheckBox(group, {
        label = self:SetColor(TF.Loc["LOCKBOX"], TF.colors.filter.lock),
        tooltip = string.format(
            TF.Loc["LOCKBOX_DESC"],
            self:SetClass("ROGUE")
        ),
        width = 150,
        get = function() return self:GetFilter("lock") end,
        set = function(value)
            self:SetFilter("lock", value)
        end
    })

    -- Clear
    self:CreateCheckBox(group, {
        label = self:SetColor(TF.Loc["CLEAR"], TF.colors.filter.clear),
        tooltip = TF.Loc["CLEAR_DESC"],
        width = 120,
        get = function() return self:GetFilter("clear") end,
        set = function(value)
            self:SetFilter("clear", value)
        end
    })

    -- Master
    self:CreateCheckBox(group, {
        label = self:SetColor(TF.Loc["MASTER"], TF.colors.filter.master),
        tooltip = TF.Loc["MASTER_DESC"],
        width = 150,
        get = function() return self:GetFilter("master") end,
        set = function(value)
            self:SetFilter("master", value)
        end
    })

    if not parent then
        local frameWidget = frame.frame
        frameWidget:SetClipsChildren(true)
    end
end
