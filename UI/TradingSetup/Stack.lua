local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

local MAIN_MODE = "main"
local STACK_GROUP_MODES = { "main", "ungrouped", "party", "raid" }
local MAIN_DROPDOWN_WIDTH = 80
local GROUP_DROPDOWN_WIDTH = 100
local RESET_BUTTON_IMAGE_Y_OFFSET = -2

local function NormalizeStackSelection(mode, value)
    local normalizedValue = tonumber(value) or 0

    if mode == MAIN_MODE then
        if normalizedValue < 0 then
            return 0
        end

        return normalizedValue
    end

    if normalizedValue < -1 then
        return -1
    end

    return normalizedValue
end

local function NormalizeSizeSelection(mode, value, maxStack)
    local normalizedValue = tonumber(value) or 0
    local maxValue = tonumber(maxStack) or 0
    local minimumValue = mode == MAIN_MODE and 0 or -1

    if normalizedValue < minimumValue then
        return minimumValue
    end

    if normalizedValue > 0 and maxValue > 0 and normalizedValue > maxValue then
        return maxValue
    end

    if normalizedValue > 0 and maxValue <= 0 then
        return minimumValue
    end

    return normalizedValue
end

local function GetDisplayValue(value, fallbackValue)
    if value == -1 then
        return "0"
    end

    if value == 0 then
        return tostring(fallbackValue or 0)
    end

    return tostring(value)
end

local function BuildGroupSummaryLine(self, class, index, modeKey, modeLabel, color)
    local rawStack = NormalizeStackSelection(modeKey, self:GetGroupStack(modeKey, class, index))
    local rawSize = NormalizeSizeSelection(modeKey, self:GetGroupSize(modeKey, class, index), self:GetItem(index).stack)
    local mainStack = NormalizeStackSelection(MAIN_MODE, self:GetGroupStack(MAIN_MODE, class, index))
    local mainSize = NormalizeSizeSelection(MAIN_MODE, self:GetGroupSize(MAIN_MODE, class, index), self:GetItem(index).stack)

    local stackText = GetDisplayValue(rawStack, mainStack)
    local sizeText = GetDisplayValue(rawSize, mainSize)
    local label = string.format("%s/%s", stackText, sizeText)
    local summaryColor = color

    if rawStack == 0 or rawSize == 0 then
        summaryColor = TF.colors.tab.main
    end

    return self:SetColor(label, summaryColor)
end

-- =========================
-- Build Content (per tab)
-- =========================
local function BuildStackContent(self, container, class, mode)
    local db = TradeFill.db.profile
    db.groups[mode] = db.groups[mode] or { stack = {}, size = {} }
    local group = db.groups[mode]

    group.stack = group.stack or {}
    group.size = group.size or {}
    group.stack[class] = group.stack[class] or {}
    group.size[class] = group.size[class] or {}

    local stackData = group.stack[class]
    local sizeData  = group.size[class]
    local inheritText = TF.Loc["OPTION_USE_MAIN"]
    local noneText = TF.Loc["OPTION_NONE"]

    for i = 1, MAX_TRADABLE_ITEMS do
        local tradeItem = self:GetItem(i)
        local currentMaxStack = tonumber(tradeItem.stack) or 0

        local stack = NormalizeStackSelection(mode, stackData[tostring(i)])
        local size  = NormalizeSizeSelection(mode, sizeData[tostring(i)], currentMaxStack)

        stackData[tostring(i)] = stack
        sizeData[tostring(i)] = size

        local itemGroup = AceGUI:Create("SimpleGroup")
        itemGroup:SetLayout("Flow")
        itemGroup:SetFullWidth(true)

        --[[local labelGroup = AceGUI:Create("SimpleGroup")
        labelGroup:SetLayout("Flow")
        labelGroup:SetFullWidth(true)]]

        --labelGroup:AddChild(label)
        --itemGroup:AddChild(labelGroup)

        -- STACK NUMBER
        local stackNumber = AceGUI:Create("Dropdown")
        stackNumber:SetWidth(mode == MAIN_MODE and MAIN_DROPDOWN_WIDTH or GROUP_DROPDOWN_WIDTH)
        stackNumber:SetLabel(TF.Loc["LABEL_STACK"])
        if mode == MAIN_MODE then
            stackNumber:AddItem(0, noneText)
        else
            stackNumber:AddItem(-1, noneText)
            stackNumber:AddItem(0, inheritText)
        end

        for value = 1, MAX_TRADABLE_ITEMS do
            stackNumber:AddItem(value, value)
        end

        stackNumber:SetValue(stack)

        if tradeItem.id > 0 then
            self:SetToolTipText(stackNumber, TF.Loc["SELECT_STACK_NUMBER_DESC"])
        end

        -- STACK SIZE
        local stackSize = AceGUI:Create("Dropdown")
        stackSize:SetWidth(mode == MAIN_MODE and MAIN_DROPDOWN_WIDTH or GROUP_DROPDOWN_WIDTH)
        stackSize:SetLabel(TF.Loc["LABEL_SIZE"])
        if mode == MAIN_MODE then
            stackSize:AddItem(0, noneText)
        else
            stackSize:AddItem(-1, noneText)
            stackSize:AddItem(0, inheritText)
        end

        for value = 1, currentMaxStack do
            stackSize:AddItem(value, value)
        end

        stackSize:SetValue(size)

        if tradeItem.id > 0 then
            self:SetToolTipText(stackSize, TF.Loc["SELECT_STACK_SIZE_DESC"])
        end

        local currentStackNumber = stackNumber
        local currentStackSize   = stackSize
        local currentIndex       = tostring(i)
        local currentDefaultSize = currentMaxStack
        local updateSummaryText

        currentStackNumber:SetCallback("OnValueChanged", function(widget, _, value)
            local normalizedValue = NormalizeStackSelection(mode, value)
            stackData[currentIndex] = normalizedValue

            if normalizedValue <= 0 then
                local resetValue = mode == MAIN_MODE and 0 or normalizedValue
                sizeData[currentIndex] = resetValue
                currentStackSize:SetValue(resetValue)
            elseif currentDefaultSize > 0 then
                local currentSizeValue = NormalizeSizeSelection(mode, sizeData[currentIndex], currentDefaultSize)

                if currentSizeValue <= 0 then
                    currentSizeValue = currentDefaultSize
                    sizeData[currentIndex] = currentSizeValue
                    currentStackSize:SetValue(currentSizeValue)
                end
            end

            if updateSummaryText then
                updateSummaryText()
            end
        end)

        currentStackSize:SetCallback("OnValueChanged", function(widget, _, value)
            local normalizedValue = NormalizeSizeSelection(mode, value, currentDefaultSize)
            local currentStackValue = tonumber(stackData[currentIndex]) or 0

            if normalizedValue > 0 and mode == MAIN_MODE and currentStackValue <= 0 then
                stackData[currentIndex] = 1
                currentStackNumber:SetValue(1)
            end

            sizeData[currentIndex] = normalizedValue

            if updateSummaryText then
                updateSummaryText()
            end
        end)

        TradeFill:ToggleWidget(stackNumber, tradeItem)
        TradeFill:ToggleWidget(stackSize, tradeItem)

        itemGroup:AddChild(stackNumber)

        local spacer = AceGUI:Create("Label")
        spacer:SetWidth(10)
        itemGroup:AddChild(spacer)

        itemGroup:AddChild(stackSize)

        local labelSpacer = AceGUI:Create("Label")
        labelSpacer:SetWidth(10)
        itemGroup:AddChild(labelSpacer)

        local label = AceGUI:Create("InteractiveLabel")
        label:SetWidth(180)

        local fontName, _, fontFlags = label.label:GetFont()
        label.label:SetFont(fontName, 12, fontFlags)

        if tradeItem.id > 0 then
            label:SetText(TradeFill:FormatColorText(
                TradeFill:GetColor(tradeItem.link),
                tradeItem.name
            ))
            --label:SetImage(C_Item.GetItemIconByID(tradeItem.id))
            TradeFill:SetToolTipLink(label, tradeItem.link)
        else
            label:SetText(TF.Loc["OPTION_NONE"])
            TradeFill:SetToolTipLink(label, nil)
        end

        itemGroup:AddChild(label)

        if mode == MAIN_MODE then
            local resetButton = AceGUI:Create("Icon")
            local resetTooltip = string.format(
                TF.Loc["BUTTON_RESET_DESC"],
                self:SetColor(TF.Loc["UNGROUPED"], TF.colors.tab.ungrouped),
                self:SetColor(TF.Loc["PARTY"], TF.colors.tab.party),
                self:SetColor(TF.Loc["RAID"], TF.colors.tab.raid)
            )

            resetButton:SetImage("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
            resetButton:SetImageSize(22, 22)
            resetButton:SetLabel("")
            resetButton:SetWidth(28)
            resetButton:SetHeight(28)
            resetButton.image:ClearAllPoints()
            resetButton.image:SetPoint("TOP", 0, RESET_BUTTON_IMAGE_Y_OFFSET)

            for regionIndex = 1, select("#", resetButton.frame:GetRegions()) do
                local region = select(regionIndex, resetButton.frame:GetRegions())
                if region and region.GetDrawLayer and region:GetDrawLayer() == "HIGHLIGHT" then
                    region:SetAlpha(0)
                end
            end

            resetButton:SetCallback("OnEnter", function(widget)
                widget.image:SetVertexColor(0.9, 0.9, 0.9, 1)
                GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR_RIGHT")
                GameTooltip:SetText(resetTooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            resetButton:SetCallback("OnLeave", function(widget)
                widget.image:SetVertexColor(1, 1, 1, 1)
                GameTooltip:Hide()
            end)
            resetButton:SetCallback("OnClick", function()
                for _, resetMode in ipairs(STACK_GROUP_MODES) do
                    db.groups[resetMode] = db.groups[resetMode] or { stack = {}, size = {} }

                    local resetGroup = db.groups[resetMode]
                    resetGroup.stack = resetGroup.stack or {}
                    resetGroup.size = resetGroup.size or {}
                    resetGroup.stack[class] = resetGroup.stack[class] or {}
                    resetGroup.size[class] = resetGroup.size[class] or {}

                    resetGroup.stack[class][currentIndex] = 0
                    resetGroup.size[class][currentIndex] = 0
                end

                currentStackNumber:SetValue(0)
                currentStackSize:SetValue(0)

                if updateSummaryText then
                    updateSummaryText()
                end
            end)
            TradeFill:ToggleWidget(resetButton, tradeItem)

            local summary = AceGUI:Create("InteractiveLabel")
            summary:SetWidth(100)

            local summaryFontName, _, summaryFontFlags = summary.label:GetFont()
            summary.label:SetFont(summaryFontName, 10, summaryFontFlags)

            updateSummaryText = function()
                local nextUngroupedSummary = BuildGroupSummaryLine(self, class, i, "ungrouped", TF.Loc["TAB_UNGROUPED"], TF.colors.tab.ungrouped)
                local nextPartySummary = BuildGroupSummaryLine(self, class, i, "party", TF.Loc["TAB_PARTY"], TF.colors.tab.party)
                local nextRaidSummary = BuildGroupSummaryLine(self, class, i, "raid", TF.Loc["TAB_RAID"], TF.colors.tab.raid)

                summary:SetText(string.format("%s %s %s", nextUngroupedSummary, nextPartySummary, nextRaidSummary))
            end

            updateSummaryText()
            itemGroup:AddChild(summary)

            local buttonSpacer = AceGUI:Create("Label")
            buttonSpacer:SetWidth(10)
            itemGroup:AddChild(buttonSpacer)

            itemGroup:AddChild(resetButton)
        end

        container:AddChild(itemGroup)
    end
end

-- =========================
-- MAIN STACK PAGE
-- =========================
function TradeFill:Stack(frame, class)
    local contentGroup = self:ContentGroup(AceGUI, frame)
    contentGroup:SetFullWidth(true)
    contentGroup:SetFullHeight(true)
    contentGroup:SetLayout("Flow")

    -- Top label
    self:SetInfoLabel(
        AceGUI,
        contentGroup,
        string.format(
            TF.Loc["INFO_STACK"],
            self:SetClass(class)
        ),
        string.format(
            TF.Loc["INFO_STACK_DESC"],
            self:SetColor(TF.Loc["TAB_MAIN"], TF.colors.tab.main),
            self:SetColor(TF.Loc["TAB_MAIN"], TF.colors.tab.main),
            self:SetColor(TF.Loc["TAB_MAIN"], TF.colors.tab.main),
            self:SetColor(TF.Loc["UNGROUPED"], TF.colors.tab.ungrouped),
            self:SetColor(TF.Loc["PARTY"], TF.colors.tab.party),
            self:SetColor(TF.Loc["RAID"], TF.colors.tab.raid)
        )
    )

    -- Tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetFullWidth(true)
    tabs:SetFullHeight(true) -- this now fills remaining space
    tabs:SetLayout("Fill")

    tabs:SetTabs({
        { text = self:SetColor(TF.Loc["TAB_MAIN"], TF.colors.tab.main), value = "main" },
        { text = self:SetColor(TF.Loc["TAB_UNGROUPED"], TF.colors.tab.ungrouped), value = "ungrouped" },
        { text = self:SetColor(TF.Loc["TAB_PARTY"], TF.colors.tab.party), value = "party" },
        { text = self:SetColor(TF.Loc["TAB_RAID"], TF.colors.tab.raid), value = "raid" },
    })

    contentGroup:AddChild(tabs)

    local isBuilding = false

    tabs:SetCallback("OnGroupSelected", function(container, _, value)
        if isBuilding then return end
        isBuilding = true

        container:ReleaseChildren()

        local scroll = AceGUI:Create("ScrollFrame")
        scroll:SetFullWidth(true)
        scroll:SetFullHeight(true)
        scroll:SetLayout("Flow")

        BuildStackContent(self, scroll, class, value)

        container:AddChild(scroll)

        isBuilding = false
    end)

    if not tabs.selected then
        tabs:SelectTab("main")
    end

    frame.frame:SetClipsChildren(true)
end
