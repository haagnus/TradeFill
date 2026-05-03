local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

function TradeFill:UpdateGeneralAutofillIcon()
    local enabled = self:GetTrade("auto")

    if TF.generalAutofillIcon then
        TF.generalAutofillIcon:SetImage(self:GetAutofillIconPath(enabled))
    end

    if TF.generalAutofillCheckbox then
        TF.generalAutofillCheckbox:SetValue(enabled)
    end
end

function TradeFill:CreateGeneralAutofillStatus(parent)
    local icon = AceGUI:Create("Icon")
    icon:SetImage(self:GetAutofillIconPath(self:GetTrade("auto")))
    icon:SetImageSize(34, 34)
    icon:SetLabel("")
    icon:SetWidth(40)
    icon:SetHeight(40)

    icon.image:ClearAllPoints()
    icon.image:SetPoint("CENTER", icon.frame, "CENTER", 0, 0)

    icon:SetCallback("OnEnter", function(widget)
        local state = self:GetTrade("auto") and self:SetColor(TF.Loc["TEXT_ENABLED"], TF.colors.addon.enabled) or self:SetColor(TF.Loc["TEXT_DISABLED"], TF.colors.addon.disabled)

        GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:SetText(self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto) .. ": " .. state, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)

    icon:SetCallback("OnLeave", function()
        GameTooltip:Hide()
    end)

    icon:SetCallback("OnClick", function()
        self:SetTrade("auto", not self:GetTrade("auto"))
        self:GetModule("Minimap"):SetMinimapButton()
        self:UpdateGeneralAutofillIcon()
    end)

    parent:AddChild(icon)

    icon.frame:HookScript("OnHide", function()
        if TF.generalAutofillIcon == icon then
            TF.generalAutofillIcon = nil
        end
    end)

    TF.generalAutofillIcon = icon

    return icon
end

function TradeFill:General(frame)
    local contentGroup = self:ContentGroup(AceGUI, frame)
    local iconGroup = self:Group(AceGUI, "SimpleGroup", contentGroup)
    iconGroup:SetHeight(42)

    self:CreateGeneralAutofillStatus(iconGroup)

    local headerGroup = self:Group(AceGUI, "SimpleGroup", contentGroup)
    headerGroup:SetHeight(28)

    TF.generalAutofillCheckbox = self:CreateCheckBox(headerGroup, {
        label = self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto),
        tooltip = TF.Loc["AUTOFILL_DESC"],
        width = 100,
        get = function() return self:GetTrade("auto") end,
        set = function(value)
            self:SetTrade("auto", value)
        end,
        onChange = function()
            self:GetModule("Minimap"):SetMinimapButton()
            self:UpdateGeneralAutofillIcon()
        end
    })

    local autofillCheckbox = TF.generalAutofillCheckbox
    autofillCheckbox.frame:HookScript("OnHide", function()
        if TF.generalAutofillCheckbox == autofillCheckbox then
            TF.generalAutofillCheckbox = nil
        end
    end)

    self:CreateCheckBox(headerGroup, {
        label = TF.Loc["OLD_ICON"],
        tooltip = string.format(TF.Loc["OLD_ICON_DESC"], self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto)),
        width = 140,
        get = function() return self:GetUi("oldIcon") end,
        set = function(value)
            self:SetUi("oldIcon", value)
        end,
        onChange = function()
            self:GetModule("Minimap"):SetMinimapButton()
            self:UpdateGeneralAutofillIcon()
        end
    })

    local group = self:Group(AceGUI, "SimpleGroup", contentGroup)

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
