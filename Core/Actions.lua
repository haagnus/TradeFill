local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

function TradeFill:On()
    self:SetTrade("auto", true)

    self:GetModule("Minimap"):SetButtonOn()
    self:UpdateGeneralAutofillIcon()

    DEFAULT_CHAT_FRAME:AddMessage(string.format(
        TF.Loc["MESSAGE_ADDON_ON"],
        string.format(
            self:SetColor(TF.Loc["SIGNATURE"], TF.colors.addon.signature),
            addonName
        ),
        self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto),
        self:SetColor(TF.Loc["TEXT_ENABLED"], TF.colors.addon.enabled)
    ))
end

function TradeFill:Off()
    self:SetTrade("auto", false)

    self:GetModule("Minimap"):SetButtonOff()
    self:UpdateGeneralAutofillIcon()

    DEFAULT_CHAT_FRAME:AddMessage(string.format(
        TF.Loc["MESSAGE_ADDON_OFF"],
        string.format(
            self:SetColor(TF.Loc["SIGNATURE"], TF.colors.addon.signature),
            addonName
        ),
        self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto),
        self:SetColor(TF.Loc["TEXT_DISABLED"], TF.colors.addon.disabled)
    ))
end

function TradeFill:ResetLimit()
    self:GetModule("LimitService"):Reset()

    DEFAULT_CHAT_FRAME:AddMessage(string.format(
        TF.Loc["MESSAGE_RESET_LIMIT"],
        string.format(
            self:SetColor(TF.Loc["SIGNATURE"], TF.colors.addon.signature),
            addonName
        ),
        self:SetColor(TF.Loc["LIMIT"], TF.colors.trade.limit)
    ))
end
