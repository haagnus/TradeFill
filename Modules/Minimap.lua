local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local MinimapModule = TradeFill:NewModule("Minimap", "AceEvent-3.0")

local LDB = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

function MinimapModule:OnInitialize()
    self.dataObject = LDB:NewDataObject("TradeFillMinimap", self:DefaultsMinimap())

    LibDBIcon:Register("TradeFillMinimap", self.dataObject, TradeFill.db.profile.settings.minimap)
end

function MinimapModule:OnEnable()
    self:SetVisibility()
    self:SetMinimapButton()
end

function MinimapModule:InitializeMinimapButton()
    if not TradeFill.minimap then
        TradeFill.minimap = LibDBIcon
    end

    local minimapButton = self:DefaultsMinimap()

    LibDBIcon:Register("TradeFillMinimap", minimapButton, TradeFill.db.profile.settings.minimap)
end

function MinimapModule:SetVisibility()
    if TradeFill.db.profile.settings.minimap.hide then
        LibDBIcon:Hide("TradeFillMinimap")
    else
        LibDBIcon:Show("TradeFillMinimap")
    end
end

function MinimapModule:SetMinimapButton()
    if TradeFill:GetTrade("auto") then
        self:SetButtonOn()
    else
        self:SetButtonOff()
    end
end

function MinimapModule:SetButtonOn()
    if self.dataObject then
        self.dataObject.icon = "Interface\\AddOns\\" .. addonName .. "\\Images\\Spell_Nature_Polymorph_Cow.tga"
    end
end

function MinimapModule:SetButtonOff()
    if self.dataObject then
        self.dataObject.icon = "Interface\\AddOns\\" .. addonName .. "\\Images\\Spell_Nature_Polymorph_Cow_Red.tga"
    end
end

function MinimapModule:DefaultsMinimap()
    return {
        type = "data source",
        text = "TradeFillMinimap",
        icon = "Interface\\AddOns\\" .. addonName .. "\\Images\\Spell_Nature_Polymorph_Cow.tga",

        OnTooltipShow = function(tooltip)
            self:UpdateTooltip(tooltip)
        end,

        OnClick = function(_, click)
            self:HandleClick(click)

            if GameTooltip:IsShown() then
                self:UpdateTooltip(GameTooltip)
            end
        end
    }
end

function MinimapModule:HandleClick(click)

    -- Shift + Right Click = reset limit
    if IsShiftKeyDown() and click == "RightButton" then
        TradeFill:ResetLimit()
        return
    end

    -- Right Click = toggle auto trade
    if click == "RightButton" then
        if TradeFill:GetTrade("auto") then
            TradeFill:Off()
            self:SetButtonOff()
        else
            TradeFill:On()
            self:SetButtonOn()
        end
        return
    end

    -- Left Click = open UI
    if click == "LeftButton" then
        TradeFill:Open()
        return
    end
end

function MinimapModule:UpdateTooltip(tooltip)
    tooltip:ClearLines()

    tooltip:SetText(
        string.format(
            TradeFill:SetColor(TF.Loc["SIGNATURE"], TF.colors.addon.signature),
            addonName
        )
    )

    tooltip:AddLine(self:GetLeftClickText())
    tooltip:AddLine(self:GetRightClickText())
    tooltip:AddLine(
        string.format(
            TF.Loc["MINIMAP_SHIFT_CLICK_REFRESH"],
            TF.Loc["TEXT_SHIFT"],
            TradeFill:SetColor(TF.Loc["TEXT_PLUS"], TF.colors.minimap.text),
            TF.Loc["TEXT_RIGHT_CLICK"],
            TradeFill:SetColor(TF.Loc["TEXT_TO_CLEAR"], TF.colors.minimap.text),
            TradeFill:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto),
            TradeFill:SetColor(TF.Loc["LIMIT"], TF.colors.minimap.text)
        )
    )

    tooltip:Show()
end

function MinimapModule:GetRightClickText()
    if TradeFill:GetTrade("auto") then
        return string.format(
            TF.Loc["MINIMAP_RIGHT_CLICK_DISABLE"],
            TF.Loc["TEXT_RIGHT_CLICK"],
            TradeFill:SetColor(TF.Loc["TEXT_TO"], TF.colors.minimap.text),
            TradeFill:SetColor(TF.Loc["TEXT_DISABLED"], TF.colors.minimap.off),
            TradeFill:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto)
        )
    else
        return string.format(
            TF.Loc["MINIMAP_RIGHT_CLICK_ENABLE"],
            TF.Loc["TEXT_RIGHT_CLICK"],
            TradeFill:SetColor(TF.Loc["TEXT_TO"], TF.colors.minimap.text),
            TradeFill:SetColor(TF.Loc["TEXT_ENABLED"], TF.colors.minimap.on),
            TradeFill:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto)
        )
    end
end

function MinimapModule:GetLeftClickText()
    if TF.frame ~= nil and TF.frame:IsVisible() then
        return string.format(
            TF.Loc["MINIMAP_LEFT_CLICK_CLOSE"],
            TF.Loc["TEXT_CLICK"],
            TradeFill:SetColor(TF.Loc["TEXT_TO"], TF.colors.minimap.text),
            TradeFill:SetColor(TF.Loc["TEXT_CLOSE"], TF.colors.minimap.close),
            TradeFill:SetColor(TF.Loc["TEXT_THE_OPTION_MENU"], TF.colors.minimap.text)
        )
    else
        return string.format(
            TF.Loc["MINIMAP_LEFT_CLICK_OPEN"],
            TF.Loc["TEXT_CLICK"],
            TradeFill:SetColor(TF.Loc["TEXT_TO"], TF.colors.minimap.text),
            TradeFill:SetColor(TF.Loc["TEXT_OPEN"], TF.colors.minimap.open),
            TradeFill:SetColor(TF.Loc["TEXT_THE_OPTION_MENU"], TF.colors.minimap.text)
        )
    end
end
