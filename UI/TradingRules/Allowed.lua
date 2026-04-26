local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

function TradeFill:Allowed(frame, parent)
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
        TF.Loc["TARGET"],
        string.format(
            TF.Loc["TARGET_DESC"],
            self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto),
            self:SetColor(TF.Loc["UNGROUPED"], TF.colors.trade.ungrouped),
            self:SetColor(TF.Loc["PARTY"], TF.colors.trade.party),
            self:SetColor(TF.Loc["RAID"], TF.colors.trade.raid)
        )
    )

    self:AddSpacer(AceGUI, group)

    -- Ungrouped
    self:CreateCheckBox(group, {
        label = self:SetColor(TF.Loc["UNGROUPED"], TF.colors.trade.ungrouped),
        tooltip = TF.Loc["UNGROUPED_DESC"],
        width = 150,
        get = function() return self:GetTrade("ungrouped") end,
        set = function(value)
            self:SetTrade("ungrouped", value)
        end
    })

    -- Party
    self:CreateCheckBox(group, {
        label = self:SetColor(TF.Loc["PARTY"], TF.colors.trade.party),
        tooltip = TF.Loc["PARTY_DESC"],
        width = 150,
        get = function() return self:GetTrade("party") end,
        set = function(value)
            self:SetTrade("party", value)
        end
    })

    -- Raid
    self:CreateCheckBox(group, {
        label = self:SetColor(TF.Loc["RAID"], TF.colors.trade.raid),
        tooltip = TF.Loc["RAID_DESC"],
        width = 150,
        get = function() return self:GetTrade("raid") end,
        set = function(value)
            self:SetTrade("raid", value)
        end
    })

    if not parent then
        local frameWidget = frame.frame
        frameWidget:SetClipsChildren(true)
    end
end
