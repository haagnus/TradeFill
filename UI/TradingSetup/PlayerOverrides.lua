local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")
local OVERRIDE_DROPDOWN_WIDTH = 80
local OVERRIDE_ITEM_WIDTH = 220
local OVERRIDE_TRADE_ANYWAY_WIDTH = 120
local OVERRIDE_DELETE_WIDTH = 28
local OVERRIDE_DELETE_IMAGE_Y_OFFSET = -2

local function SortedKeys(tbl)
    local keys = {}

    if type(tbl) ~= "table" then
        return keys
    end

    for key in pairs(tbl) do
        keys[#keys + 1] = key
    end

    table.sort(keys)

    return keys
end

local function GetConfiguredItemByID(itemID)
    local itemKey = tostring(itemID)

    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        local item = TradeFill:GetEffectiveItem(tradeSlot)

        if item and tostring(item.id) == itemKey then
            return item
        end
    end

    return nil
end

local function GetItemDisplay(itemID)
    local configuredItem = GetConfiguredItemByID(itemID)

    if configuredItem and configuredItem.name and configuredItem.name ~= "" then
        return configuredItem.name, configuredItem.link, configuredItem.stack, configuredItem.texture
    end

    local name, link, _, _, _, _, _, stack, _, texture = C_Item.GetItemInfo(tonumber(itemID) or itemID)

    return name or string.format(TF.Loc["PLAYER_OVERRIDE_ITEM_ID"], itemID), link, stack or 0, texture
end

local function SetOverrideItemTooltip(self, widget, itemLink, inactive)
    widget:SetCallback("OnEnter", function(widget)
        GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR_RIGHT")

        if itemLink then
            GameTooltip:SetHyperlink(itemLink)
            if inactive then
                GameTooltip:AddLine(TF.Loc["PLAYER_OVERRIDE_NOT_SELECTED_DESC"], 1, 0.82, 0, true)
            end
        else
            GameTooltip:SetText(inactive and TF.Loc["PLAYER_OVERRIDE_NOT_SELECTED"] or TF.Loc["OPTION_NONE"], 1, 1, 1, 1, true)
            if inactive then
                GameTooltip:AddLine(TF.Loc["PLAYER_OVERRIDE_NOT_SELECTED_DESC"], 1, 0.82, 0, true)
            end
        end

        GameTooltip:Show()
    end)

    widget:SetCallback("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function AddNumberDropdown(self, parent, labelText, value, maxValue, tooltipText, onChange)
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetLabel(labelText)
    dropdown:SetWidth(OVERRIDE_DROPDOWN_WIDTH)
    dropdown:AddItem(0, TF.Loc["OPTION_NONE"])

    for currentValue = 1, maxValue do
        dropdown:AddItem(currentValue, currentValue)
    end

    dropdown:SetValue(tonumber(value) or 0)
    dropdown:SetCallback("OnValueChanged", function(_, _, selectedValue)
        onChange(tonumber(selectedValue) or 0)
    end)

    if tooltipText then
        self:SetToolTipText(dropdown, tooltipText)
    end

    parent:AddChild(dropdown)

    return dropdown
end

local function AddIconDeleteButton(parent, tooltipText, onClick)
    local deleteButton = AceGUI:Create("Icon")
    deleteButton:SetImage("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    deleteButton:SetImageSize(22, 22)
    deleteButton:SetLabel("")
    deleteButton:SetWidth(OVERRIDE_DELETE_WIDTH)
    deleteButton:SetHeight(28)
    deleteButton.image:ClearAllPoints()
    deleteButton.image:SetPoint("TOP", 0, OVERRIDE_DELETE_IMAGE_Y_OFFSET)

    for regionIndex = 1, select("#", deleteButton.frame:GetRegions()) do
        local region = select(regionIndex, deleteButton.frame:GetRegions())
        if region and region.GetDrawLayer and region:GetDrawLayer() == "HIGHLIGHT" then
            region:SetAlpha(0)
        end
    end

    deleteButton:SetCallback("OnEnter", function(widget)
        widget.image:SetVertexColor(0.9, 0.9, 0.9, 1)
        GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    deleteButton:SetCallback("OnLeave", function(widget)
        widget.image:SetVertexColor(1, 1, 1, 1)
        GameTooltip:Hide()
    end)
    deleteButton:SetCallback("OnClick", onClick)

    parent:AddChild(deleteButton)

    return deleteButton
end

local function AddPlayerOverrideItemRow(self, parent, playerName, itemID, itemOverride, rebuild)
    local row = AceGUI:Create("SimpleGroup")
    row:SetLayout("Flow")
    row:SetFullWidth(true)

    local itemName, itemLink, maxStack, texture = GetItemDisplay(itemID)
    local isConfigured = self:IsPlayerOverrideItemConfigured(itemID)
    maxStack = tonumber(maxStack) or 0

    local itemLabel = AceGUI:Create("InteractiveLabel")
    itemLabel:SetWidth(OVERRIDE_ITEM_WIDTH)
    itemLabel:SetText(isConfigured and itemName or self:SetColor(itemName, "888888"))

    if texture then
        itemLabel:SetImage(texture)
    end

    SetOverrideItemTooltip(self, itemLabel, itemLink, not isConfigured)

    local stackValue = tonumber(itemOverride.stack) or 0
    local sizeValue = tonumber(itemOverride.size) or 0
    local sizeMax = maxStack > 0 and maxStack or math.max(sizeValue, 20)
    local defaultSize = maxStack > 0 and maxStack or sizeMax
    local stackDropdown
    local sizeDropdown

    stackDropdown = AddNumberDropdown(self, row, TF.Loc["LABEL_STACK"], stackValue, MAX_TRADABLE_ITEMS, TF.Loc["SELECT_STACK_NUMBER_DESC"], function(nextStack)
        itemOverride.stack = nextStack

        if nextStack <= 0 then
            itemOverride.size = 0

            if sizeDropdown then
                sizeDropdown:SetValue(0)
            end
        elseif (tonumber(itemOverride.size) or 0) <= 0 then
            itemOverride.size = defaultSize

            if sizeDropdown then
                sizeDropdown:SetValue(defaultSize)
            end
        end

        self:SetPlayerOverrideItem(playerName, itemID, itemOverride.stack, itemOverride.size)
    end)

    self:AddInlineSpacer(AceGUI, row, nil)

    sizeDropdown = AddNumberDropdown(self, row, TF.Loc["LABEL_SIZE"], sizeValue, sizeMax, TF.Loc["SELECT_STACK_SIZE_DESC"], function(nextSize)
        itemOverride.size = nextSize

        if nextSize > 0 and (tonumber(itemOverride.stack) or 0) <= 0 then
            itemOverride.stack = 1

            if stackDropdown then
                stackDropdown:SetValue(1)
            end
        elseif nextSize <= 0 then
            itemOverride.stack = 0

            if stackDropdown then
                stackDropdown:SetValue(0)
            end
        end

        self:SetPlayerOverrideItem(playerName, itemID, itemOverride.stack, itemOverride.size)
    end)

    self:AddInlineSpacer(AceGUI, row, nil)

    row:AddChild(itemLabel)

    self:AddInlineSpacer(AceGUI, row, nil)

    local tradeAnyway = AceGUI:Create("CheckBox")
    tradeAnyway:SetLabel(string.format(self:SetColor(TF.Loc["PLAYER_OVERRIDE_TRADE_ANYWAY"], TF.colors.trade.anyway)))
    tradeAnyway:SetWidth(OVERRIDE_TRADE_ANYWAY_WIDTH)
    tradeAnyway:SetValue(itemOverride.tradeAnyway and true or false)
    tradeAnyway:SetCallback("OnValueChanged", function(_, _, value)
        self:SetPlayerOverrideItemTradeAnyway(playerName, itemID, value)
        itemOverride.tradeAnyway = value and true or false
    end)
    self:SetToolTipText(
        tradeAnyway,
        isConfigured and TF.Loc["PLAYER_OVERRIDE_TRADE_ANYWAY_CONFIGURED_DESC"] or string.format(TF.Loc["PLAYER_OVERRIDE_TRADE_ANYWAY_DESC"], self:GetPlayerOverrideFullDisplayName(playerName))
    )
    row:AddChild(tradeAnyway)

    self:AddInlineSpacer(AceGUI, row, nil)

    AddIconDeleteButton(row, TF.Loc["BUTTON_DELETE"], function()
        self:DeletePlayerOverrideItem(playerName, itemID)
        rebuild()
    end)

    parent:AddChild(row)
end

local function AddPlayerOverrideGroup(self, parent, playerName, playerOverride, rebuild)
    local group = AceGUI:Create("InlineGroup")
    group:SetLayout("Flow")
    group:SetFullWidth(true)

    for _, itemID in ipairs(SortedKeys(playerOverride)) do
        local itemOverride = playerOverride[itemID]

        if tonumber(itemID) and type(itemOverride) == "table" then
            AddPlayerOverrideItemRow(self, group, playerName, itemID, itemOverride, rebuild)
        end
    end

    parent:AddChild(group)

    local deletePlayerButton = AceGUI:Create("Button")
    deletePlayerButton:SetText(TF.Loc["BUTTON_DELETE_PLAYER_OVERRIDE"])
    deletePlayerButton:SetWidth(180)
    deletePlayerButton:SetCallback("OnClick", function()
        self:DeletePlayerOverride(playerName)
        rebuild()
    end)
    parent:AddChild(deletePlayerButton)

    self:AddRowSpacer(AceGUI, parent)
end

local function AddDeleteAllPlayerOverrides(self, parent, frame, playerCount, rebuild)
    local summary = AceGUI:Create("Label")
    summary:SetFullWidth(true)
    summary:SetText(string.format(TF.Loc["PLAYER_OVERRIDES_SUMMARY"], playerCount))
    parent:AddChild(summary)

    self:AddRowSpacer(AceGUI, parent)

    local deleteAllButton = AceGUI:Create("Button")
    deleteAllButton:SetText(TF.Loc["BUTTON_DELETE_ALL_PLAYER_OVERRIDES"])
    deleteAllButton:SetWidth(220)
    deleteAllButton:SetCallback("OnClick", function()
        StaticPopupDialogs["CONFIRM_DELETE_ALL_PLAYER_OVERRIDES"] = {
            text = TF.Loc["BUTTON_DELETE_ALL_PLAYER_OVERRIDES_CONFIRM"],
            button1 = TF.Loc["BUTTON_YES"],
            button2 = TF.Loc["BUTTON_CANCEL"],
            OnAccept = function()
                self:DeleteAllPlayerOverrides()
                rebuild()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            exclusive = true,
            showAlert = true,
            enterClicksFirstButton = false,
            preferredIndex = 3,
        }

        StaticPopup_Show("CONFIRM_DELETE_ALL_PLAYER_OVERRIDES")
    end)

    self:SetToolTipText(deleteAllButton, TF.Loc["BUTTON_DELETE_ALL_PLAYER_OVERRIDES_DESC"])
    parent:AddChild(deleteAllButton)

    frame.frame:SetClipsChildren(true)
end

function TradeFill:PlayerOverrides(frame, selectedPlayerName)
    local contentGroup = self:ContentGroup(AceGUI, frame)
    contentGroup:SetFullWidth(true)
    contentGroup:SetFullHeight(true)
    contentGroup:SetLayout("Flow")

    self:SetInfoLabel(
        AceGUI,
        contentGroup,
        string.format(
            TF.Loc["INFO_PLAYER_OVERRIDES"],
            selectedPlayerName and self:GetPlayerOverrideFullDisplayName(selectedPlayerName) or ""
        ),
        TF.Loc["INFO_PLAYER_OVERRIDES_DESC"]
    )

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    scroll:SetLayout("Flow")
    contentGroup:AddChild(scroll)

    local function Rebuild()
        local tree = frame:GetUserData("tree")

        if tree and self.RefreshTree then
            self:RefreshTree(tree)
        end

        frame:ReleaseChildren()
        self:PlayerOverrides(frame, selectedPlayerName)
    end

    local overrides = self:GetPlayerOverrides()
    local playerNames = SortedKeys(overrides)

    if #playerNames == 0 then
        local empty = AceGUI:Create("Label")
        empty:SetText(TF.Loc["PLAYER_OVERRIDES_EMPTY"])
        empty:SetFullWidth(true)
        scroll:AddChild(empty)
        return
    end

    if not selectedPlayerName then
        AddDeleteAllPlayerOverrides(self, scroll, frame, #playerNames, Rebuild)
        return
    end

    if selectedPlayerName then
        local selectedOverride = overrides[selectedPlayerName]

        if type(selectedOverride) == "table" then
            AddPlayerOverrideGroup(self, scroll, selectedPlayerName, selectedOverride, Rebuild)
        else
            local empty = AceGUI:Create("Label")
            empty:SetText(TF.Loc["PLAYER_OVERRIDES_EMPTY"])
            empty:SetFullWidth(true)
            scroll:AddChild(empty)
        end

        frame.frame:SetClipsChildren(true)
        return
    end

    frame.frame:SetClipsChildren(true)
end
