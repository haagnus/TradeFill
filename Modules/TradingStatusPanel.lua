local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)
local TradingStatusPanel = TradeFill:NewModule("TradingStatusPanel")

local PANEL_NAME = "TradeRulesFrame"

local EDGE_PADDING = 8
local TITLE_SPACING = 4
local EXTRA_WIDTH = 73
local MIN_WIDTH = 200
local DEFAULT_HEIGHT = 40

function TradingStatusPanel:OnInitialize()
    self.messages = {}
    self.messageSet = {}
end

function TradingStatusPanel:GetPanelWidth()
    if not TradeFrame then
        return MIN_WIDTH
    end

    return math.max(MIN_WIDTH, TradeFrame:GetWidth() + EXTRA_WIDTH)
end

function TradingStatusPanel:CreatePanel()
    if self.frame then
        return self.frame
    end

    if not TradeFrame then
        return nil
    end

    local frame = CreateFrame("Frame", PANEL_NAME, TradeFrame, "BackdropTemplate")
    frame:SetPoint("TOPLEFT", TradeFrame, "BOTTOMLEFT", -2, 1)
    frame:SetWidth(self:GetPanelWidth())
    frame:SetHeight(DEFAULT_HEIGHT)

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.7)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", EDGE_PADDING, -EDGE_PADDING)
    frame.title:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -EDGE_PADDING, -EDGE_PADDING)
    frame.title:SetJustifyH("LEFT")
    frame.title:SetText(TF.Loc["TRADING_STATUS_PANEL"])

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.text:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -TITLE_SPACING)
    frame.text:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -EDGE_PADDING, 0)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetJustifyV("TOP")
    frame.text:SetTextColor(1, 1, 1)

    frame:Hide()
    self.frame = frame

    return frame
end

function TradingStatusPanel:ShowMessage(message)
    if TradeFill:GetUi("status") then
        self:Hide()
        return
    end

    local frame = self:CreatePanel()
    if not frame then
        return
    end

    local fullText =
        TradeFill:SetColor(TF.Loc["TRADING_STATUS_PANEL_MESSAGE"], TF.colors.addon.panel) ..
        (message or "")

    local frameWidth = self:GetPanelWidth()

    frame:SetWidth(frameWidth)
    frame.text:SetWidth(frameWidth - (EDGE_PADDING * 2))
    frame.text:SetText(fullText)

    local textHeight = frame.text:GetStringHeight()
    local titleHeight = frame.title:GetStringHeight()
    local frameHeight = EDGE_PADDING + titleHeight + TITLE_SPACING + textHeight + EDGE_PADDING

    frame:SetHeight(math.max(DEFAULT_HEIGHT, frameHeight))
    frame:Show()
end

function TradingStatusPanel:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function TradingStatusPanel:AddMessage(msg, ...)
    if not msg or msg == "" then
        return
    end

    if select("#", ...) > 0 then
        msg = string.format(msg, ...)
    end

    self.messageSet = self.messageSet or {}

    if self.messageSet[msg] then
        return
    end

    table.insert(self.messages, msg)
    self.messageSet[msg] = true

    self:ShowMessage(table.concat(self.messages, "\n"))
end

function TradingStatusPanel:Clear()
    self.messages = {}
    self.messageSet = {}

    if self.frame then
        self.frame.text:SetText("")
        self.frame:Hide()
    end
end

return TradingStatusPanel
