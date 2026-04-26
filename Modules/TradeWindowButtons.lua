local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local floor = math.floor

local GetContainerNumSlots = C_Container.GetContainerNumSlots
local GetContainerItemInfo = C_Container.GetContainerItemInfo

local TradeWindowButtons = TradeFill:NewModule("TradeWindowButtons", "AceEvent-3.0")
local buttonOffsets = { 30, 68, 106, 144, 182, 220 }
local panelBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}

function TradeWindowButtons:OnInitialize()
    self.buttons = {}
    self.spellButtons = {}
    self.pendingSpellFillIndex = nil
    self.pendingFillRetry = nil

    self.bagWatcher = CreateFrame("Frame")
    self.bagWatcher.owner = self
    self.bagWatcher:SetScript("OnEvent", function(frame, event)
        if event ~= "BAG_NEW_ITEMS_UPDATED" then
            return
        end

        local owner = frame.owner
        local index = owner and owner.pendingSpellFillIndex

        owner.pendingSpellFillIndex = nil
        frame:UnregisterEvent("BAG_NEW_ITEMS_UPDATED")

        if index then
            C_Timer.After(0.05, function()
                owner:TryFillAfterSpell(index, 1)
            end)
        end
    end)
end

function TradeWindowButtons:OnEnable()
    self:RegisterEvent("TRADE_SHOW")
    self:RegisterEvent("TRADE_CLOSED")
    self:RegisterEvent("BAG_UPDATE_DELAYED", "UpdateButtons")
end

function TradeWindowButtons:GetAvailableStackCount(itemID, stackSize)
    local availableStacks = self:GetStackAvailability(itemID, stackSize)

    return availableStacks
end

function TradeWindowButtons:GetStackAvailability(itemID, stackSize)
    if not itemID or itemID <= 0 then
        return 0, 0
    end

    local availableStacks = 0
    local lockedStacks = 0

    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)

        for slot = 1, slots do
            local item = GetContainerItemInfo(bag, slot)

            if item and item.itemID == itemID then
                local stackCount = 1

                if stackSize and stackSize > 0 then
                    stackCount = floor(item.stackCount / stackSize)
                end

                if stackCount > 0 then
                    if item.isLocked then
                        lockedStacks = lockedStacks + stackCount
                    else
                        availableStacks = availableStacks + stackCount
                    end
                end
            end
        end
    end

    return availableStacks, lockedStacks
end

function TradeWindowButtons:ClearTrade()
    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        if GetTradePlayerItemLink and GetTradePlayerItemLink(tradeSlot) then
            ClearCursor()
            ClickTradeButton(tradeSlot)
            ClearCursor()
        end
    end
end

function TradeWindowButtons:RemoveFromTrade(index)
    local tradeItem = TradeFill:GetEffectiveItem(index)

    if not tradeItem or tradeItem.id <= 0 or not GetTradePlayerItemLink then
        return
    end

    for tradeSlot = MAX_TRADABLE_ITEMS, 1, -1 do
        local itemLink = GetTradePlayerItemLink(tradeSlot)

        if itemLink then
            local itemName = GetItemInfo(itemLink)

            if itemName == tradeItem.name then
                ClearCursor()
                ClickTradeButton(tradeSlot)
                ClearCursor()
                C_Timer.After(0.05, function()
                    self:UpdateButtons()
                end)
                return
            end
        end
    end
end

function TradeWindowButtons:ManualFill(index)
    local desiredStacks = TradeFill:GetActiveGroupStack(index)
    local desiredSize = TradeFill:GetActiveGroupSize(index)
    local tradeItem = TradeFill:GetEffectiveItem(index)

    if TF.state then
        TF.state.manualFillActive = true
    end

    TradeFill:GetModule("InventoryManager"):ScanInventory(function()
        local availableStacks = TradeFill:GetModule("Trade"):GetAvailableTradeCount(index)
        local tradeSlot = TradeFrame_GetAvailableSlot()

        if availableStacks <= 0 then
            if TF.state then
                TF.state.manualFillActive = false
            end

            if tradeItem and tradeItem.link and desiredSize > 0 then
                TradeFill:GetModule("TradingStatusPanel"):AddMessage(
                    string.format(TF.Loc["MESSAGE_NO_STACK"], tradeItem.link, desiredSize)
                )
            end

            self:UpdateButtons()
            return
        end

        if not tradeSlot then
            if TF.state then
                TF.state.manualFillActive = false
            end
            TradeFill:GetModule("TradingStatusPanel"):AddMessage(TF.Loc["MESSAGE_FULL"])
            return
        end

        self:TryManualFillIntoSlot(index, tradeSlot, 1)
    end, {
        index = tostring(index),
        count = 1,
    })
end

function TradeWindowButtons:TryManualFillIntoSlot(index, tradeSlot, attempt)
    local currentAttempt = attempt or 1
    local placed = TradeFill:GetModule("Trade"):FillTradeSlot(index, tradeSlot)

    if placed then
        C_Timer.After(0.1, function()
            if TF.state then
                TF.state.manualFillActive = false
            end
            self:UpdateButtons()
        end)
        return
    end

    if currentAttempt >= 10 then
        C_Timer.After(0.1, function()
            if TF.state then
                TF.state.manualFillActive = false
            end
            self:UpdateButtons()
        end)
        return
    end

    C_Timer.After(0.1, function()
        if TradeFrame and TradeFrame:IsShown() then
            self:TryManualFillIntoSlot(index, tradeSlot, currentAttempt + 1)
        elseif TF.state then
            TF.state.manualFillActive = false
        end
    end)
end

function TradeWindowButtons:TryFillAfterSpell(index, attempt)
    local currentAttempt = attempt or 1
    local tradeItem = TradeFill:GetEffectiveItem(index)

    if not tradeItem or not tradeItem.id or tradeItem.id <= 0 then
        return
    end

    local desiredStacks = TradeFill:GetActiveGroupStack(index)
    local desiredSize = TradeFill:GetActiveGroupSize(index)

    if desiredStacks <= 0 or desiredSize <= 0 then
        local tradeSlot = TradeFrame_GetAvailableSlot()

        if tradeSlot and self:PlaceSingleCreatedItem(index, tradeSlot) then
            self.pendingFillRetry = nil
            C_Timer.After(0.1, function()
                self:UpdateButtons()
            end)
            return
        end
    end

    local availableStacks = self:GetAvailableStackCount(tradeItem.id, desiredSize)

    if availableStacks > 0 then
        self.pendingFillRetry = nil
        self:ManualFill(index)
        return
    end

    if currentAttempt >= 20 then
        self.pendingFillRetry = nil
        self:UpdateButtons()
        return
    end

    self.pendingFillRetry = index
    C_Timer.After(0.1, function()
        if self.pendingFillRetry == index then
            self:TryFillAfterSpell(index, currentAttempt + 1)
        end
    end)
end

function TradeWindowButtons:PlaceSingleCreatedItem(index, tradeSlot)
    local tradeItem = TradeFill:GetEffectiveItem(index)
    if not tradeItem or not tradeItem.id or tradeItem.id <= 0 or not tradeSlot then
        return false
    end

    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)

        for slot = 1, slots do
            local item = GetContainerItemInfo(bag, slot)

            if item and item.itemID == tradeItem.id and not item.isLocked then
                ClearCursor()
                C_Container.PickupContainerItem(bag, slot)
                ClickTradeButton(tradeSlot)
                ClearCursor()
                return true
            end
        end
    end

    return false
end

function TradeWindowButtons:EnsureButtons()
    if self.initialized then
        return
    end
    local background = CreateFrame("Frame", addonName .. "TradeButtonPanel", TradeFrame, "BackdropTemplate")
    background:SetSize(74, TradeFrame:GetHeight())
    background:SetPoint("BOTTOMRIGHT", TradeFrame, "BOTTOMRIGHT", 71, -2)
    background:SetBackdrop(panelBackdrop)
    background:SetBackdropColor(0, 0, 0, 0.75)
    background:SetFrameStrata(TradeFrame:GetFrameStrata())
    background:SetFrameLevel(TradeFrame:GetFrameLevel() - 1)
    background:Hide()
    self.background = background

    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        local currentTradeSlot = tradeSlot
        local buttonName = addonName .. "TradeButton" .. tradeSlot
        local button = CreateFrame("Button", buttonName, background, "UIPanelButtonTemplate")
        button:SetSize(32, 32)
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
        icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)

        local count = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
        count:SetJustifyH("RIGHT")

        button.icon = icon
        button.count = count

        button:SetPoint("BOTTOM", background, "BOTTOM", -12, buttonOffsets[currentTradeSlot])

        button:SetScript("OnEnter", function(widget)
            local item = TradeFill:GetEffectiveItem(widget.tradeIndex) or TradeFill:GetItem(widget.tradeIndex)

            GameTooltip:SetOwner(widget, "ANCHOR_RIGHT")

            if item and item.link and item.id > 0 then
                GameTooltip:SetHyperlink(item.link)
            else
                GameTooltip:SetText(TF.Loc["OPTION_NONE"], 1, 1, 1)
            end

            GameTooltip:AddLine(
                string.format(
                    TF.Loc["BUTTON_TOOLTIP"],
                    TradeFill:SetColor(TF.Loc["TEXT_CLICK"], TF.colors.addon.click),
                    TradeFill:SetColor(TF.Loc["TEXT_RIGHT_CLICK"], TF.colors.addon.click),
                    1, 1, 1, true
                )
            )

            if not widget:IsEnabled() then
                GameTooltip:AddLine(TF.Loc["BUTTON_DISABLE"], 1, 0.2, 0.2, true)
            end

            GameTooltip:Show()
        end)

        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        button:SetScript("OnClick", function(_, mouseButton)
            if mouseButton == "RightButton" then
                self:RemoveFromTrade(currentTradeSlot)
            else
                self:ManualFill(currentTradeSlot)
            end
        end)

        self.buttons[currentTradeSlot] = button

        local spellButtonName = addonName .. "TradeSpellButton" .. tradeSlot
        local spellButton = CreateFrame("Button", spellButtonName, background, "SecureActionButtonTemplate,UIPanelButtonTemplate")
        spellButton:SetSize(32, 32)
        spellButton:RegisterForClicks("LeftButtonUp")
        spellButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
        spellButton:SetPoint("BOTTOM", background, "BOTTOM", -12, buttonOffsets[currentTradeSlot])

        local spellIcon = spellButton:CreateTexture(nil, "ARTWORK")
        spellIcon:SetPoint("TOPLEFT", spellButton, "TOPLEFT", -2, 2)
        spellIcon:SetPoint("BOTTOMRIGHT", spellButton, "BOTTOMRIGHT", 2, -2)

        local spellCount = spellButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        spellCount:SetPoint("BOTTOMRIGHT", spellButton, "BOTTOMRIGHT", -2, 2)
        spellCount:SetJustifyH("RIGHT")

        local cooldown = CreateFrame("Cooldown", nil, spellButton, "CooldownFrameTemplate")
        cooldown:SetAllPoints(spellButton)

        spellButton.icon = spellIcon
        spellButton.count = spellCount
        spellButton.cooldown = cooldown

        spellButton:SetScript("OnEnter", function(widget)
            GameTooltip:SetOwner(widget, "ANCHOR_RIGHT")

            if widget.itemID and widget.itemID > 0 then
                GameTooltip:SetItemByID(widget.itemID)
            else
                GameTooltip:SetText(TF.Loc["OPTION_NONE"], 1, 1, 1)
            end

            GameTooltip:AddLine(TF.Loc["CREATE_NEW_STACK"], 0.0, 0.44, 0.87, true)
            GameTooltip:Show()
        end)

        spellButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        spellButton:SetScript("PostClick", function(widget)
            local spellID = widget.spellID
            if not spellID then
                return
            end

            self.pendingSpellFillIndex = widget.tradeIndex
            self.pendingFillRetry = widget.tradeIndex
            self.bagWatcher:RegisterEvent("BAG_NEW_ITEMS_UPDATED")

            C_Timer.After(0.05, function()
                local start, duration = GetSpellCooldown(spellID)
                if duration and duration > 0 then
                    widget:Disable()
                    widget.cooldown:SetCooldown(start, duration)
                    C_Timer.After(duration, function()
                        if widget:IsShown() then
                            widget:Enable()
                        end
                    end)
                end
            end)

            C_Timer.After(0.2, function()
                if self.pendingFillRetry == widget.tradeIndex then
                    self:TryFillAfterSpell(widget.tradeIndex, 1)
                end
            end)
        end)

        self.spellButtons[currentTradeSlot] = spellButton
    end

    local clearButton = CreateFrame("Button", addonName .. "TradeButtonClear", background, "UIPanelButtonTemplate")
    clearButton:SetSize(66, 22)
    clearButton:SetText(TF.Loc["BUTTON_CLEAR"])
    clearButton:SetPoint("BOTTOM", background, "BOTTOM", 0, 7)

    clearButton:SetScript("OnClick", function()
        self:ClearTrade()
        C_Timer.After(0.05, function()
            self:UpdateButtons()
        end)
    end)

    self.clearButton = clearButton
    self.initialized = true
end

function TradeWindowButtons:HideButtons()
    if self.background then
        self.background:Hide()
    end

    for _, button in pairs(self.buttons) do
        button:Hide()
    end

    for _, spellButton in pairs(self.spellButtons) do
        spellButton:Hide()
    end

    if self.clearButton then
        self.clearButton:Hide()
    end
end

function TradeWindowButtons:UpdateButtons()
    if not TradeFrame or not TradeFrame:IsShown() then
        return
    end

    self:EnsureButtons()

    if TradeFill:GetUi("button") then
        self:HideButtons()
        return
    end

    if self.background then
        self.background:Show()
    end

    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        local button = self.buttons[tradeSlot]
        local spellButton = self.spellButtons[tradeSlot]
        local configuredItem = TradeFill:GetItem(tradeSlot)
        local tradeItem = TradeFill:GetEffectiveItem(tradeSlot)

        if configuredItem and configuredItem.id > 0 and tradeItem and tradeItem.id > 0 then
            local desiredStacks = TradeFill:GetActiveGroupStack(tradeSlot)
            local desiredSize = TradeFill:GetActiveGroupSize(tradeSlot)
            local availableStacks, lockedStacks = self:GetStackAvailability(tradeItem.id, desiredSize)
            local hasUsableStack = availableStacks > 0
            local hasOnlyLockedStacks = lockedStacks > 0 and not hasUsableStack
            local hasNoStacks = availableStacks <= 0 and lockedStacks <= 0
            local canCreateWithSpell = tradeItem.spell and (hasNoStacks or hasOnlyLockedStacks)
            local spellID = canCreateWithSpell and tradeItem.spell or nil

            button.tradeIndex = tradeSlot
            button.icon:SetTexture(tradeItem.texture or C_Item.GetItemIconByID(tradeItem.id))
            button.count:SetText(availableStacks)
            button.icon:SetDesaturated(false)
            button:Enable()
            button:SetAlpha(1)

            if canCreateWithSpell and spellID then
                spellButton.tradeIndex = tradeSlot
                spellButton.spellID = spellID
                spellButton.itemID = tradeItem.id
                spellButton.icon:SetTexture(tradeItem.texture or C_Item.GetItemIconByID(tradeItem.id))
                spellButton.count:SetText(availableStacks)
                spellButton.icon:SetDesaturated(false)
                spellButton:SetAttribute("type", "spell")
                spellButton:SetAttribute("spell", spellID)
                spellButton:Enable()
                spellButton:SetAlpha(1)
                spellButton:Show()
                button:Hide()
            else
                spellButton.spellID = nil
                spellButton.itemID = nil
                spellButton:SetAttribute("type", nil)
                spellButton:SetAttribute("spell", nil)
                spellButton:Hide()
                button:Show()
            end
        else
            spellButton.spellID = nil
            spellButton.itemID = nil
            spellButton:SetAttribute("type", nil)
            spellButton:SetAttribute("spell", nil)
            spellButton:Hide()
            button:Hide()
        end
    end

    if self.clearButton then
        self.clearButton:Show()
    end
end

function TradeWindowButtons:TRADE_SHOW()
    self:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED")
    self:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")

    C_Timer.After(0.05, function()
        self:UpdateButtons()
    end)
end

function TradeWindowButtons:TRADE_CLOSED()
    if TF.state then
        TF.state.manualFillActive = false
    end
    self:UnregisterEvent("TRADE_PLAYER_ITEM_CHANGED")
    self:UnregisterEvent("TRADE_TARGET_ITEM_CHANGED")
    self:HideButtons()
end

function TradeWindowButtons:TRADE_PLAYER_ITEM_CHANGED()
    C_Timer.After(0.05, function()
        self:UpdateButtons()
    end)
end

function TradeWindowButtons:TRADE_TARGET_ITEM_CHANGED()
    if not TradeFill:GetFilter("clear") then
        return
    end

    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        if GetTradeTargetItemLink(tradeSlot) then
            self:ClearTrade()
            TradeFill:GetModule("TradingStatusPanel"):AddMessage(
                TF.Loc["MESSAGE_CLEAR"],
                TradeFill:SetName(TF.state)
            )
            C_Timer.After(0.05, function()
                self:UpdateButtons()
            end)
            return
        end
    end
end
