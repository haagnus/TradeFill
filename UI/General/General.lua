local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

function TradeFill:General(frame)
    local contentGroup = self:ContentGroup(AceGUI, frame)
    local group = self:Group(AceGUI, "SimpleGroup", contentGroup)

    self:CreateCheckBox(group, {
        label = self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto),
        tooltip = TF.Loc["AUTOFILL_DESC"],
        width = 100,
        get = function() return self:GetTrade("auto") end,
        set = function(value)
            self:SetTrade("auto", value)
        end,
        onChange = function()
            self:GetModule("Minimap"):SetMinimapButton()
        end
    })

    self:AddRowSpacer(AceGUI, group)

    self:SetInfoLabel(
        AceGUI,
        group,
        TF.Loc["LABEL_GENERAL"],
        TF.Loc["LABEL_GENERAL_DESC"]
    )

    local listGroup = self:Group(AceGUI, "SimpleGroup", group)
    listGroup:SetLayout("List")
    listGroup:SetFullWidth(true)

    self:CreateCheckBox(listGroup, {
        label = TF.Loc["TRADING_BUTTON"],
        tooltip = TF.Loc["TRADING_BUTTON_DESC"],
        width = 160,
        get = function() return self:GetUi("button") end,
        set = function(value)
            self:SetUi("button", value)
            self:GetModule("TradeWindowButtons"):UpdateButtons()
        end
    })

    self:CreateCheckBox(listGroup, {
        label = TF.Loc["TRADING_STATUS"],
        tooltip = TF.Loc["TRADING_STATUS_DESC"],
        width = 160,
        get = function() return self:GetUi("status") end,
        set = function(value)
            self:SetUi("status", value)

            local panel = self:GetModule("TradingStatusPanel")
            if value then
                panel:Hide()
            elseif #panel.messages > 0 then
                panel:ShowMessage(table.concat(panel.messages, "\n"))
            end
        end
    })

    self:CreateCheckBox(listGroup, {
        label = TF.Loc["MINIMAP"],
        tooltip = TF.Loc["MINIMAP_DESC"],
        width = 180,
        get = function() return self.db.profile.settings.minimap.hide end,
        set = function(value)
            self.db.profile.settings.minimap.hide = value
        end,
        onChange = function()
            self:GetModule("Minimap"):SetVisibility()
        end
    })

    local frameWidget = frame.frame
    frameWidget:SetClipsChildren(true)
end
