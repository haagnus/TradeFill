local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)
local InventoryManager = TradeFill:NewModule("InventoryManager", "AceEvent-3.0")
local TradeModule

-- API cache
local GetContainerNumSlots = C_Container.GetContainerNumSlots
local GetContainerItemInfo = C_Container.GetContainerItemInfo
local SplitContainerItem = C_Container.SplitContainerItem
local PickupContainerItem = C_Container.PickupContainerItem
local GetItemIconByID = C_Item.GetItemIconByID

-- Lua cache
local table_insert = table.insert
local table_remove = table.remove
local LOCKED_TOOLTIP_TEXT = _G.LOCKED or "Locked"

TF.StackSplitted = {
    ["1"] = {},
    ["2"] = {},
    ["3"] = {},
    ["4"] = {},
    ["5"] = {},
    ["6"] = {},
}

------------------------------------------------------------
-- Empty Slots
------------------------------------------------------------
function InventoryManager:GetEmptySlots()
    TF.inventory.emptySlot = {}
    local emptySlot = TF.inventory.emptySlot

    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)
        for slot = 1, slots do
            local currentItem = GetContainerItemInfo(bag, slot)
            if not currentItem then
                table_insert(emptySlot, { bag = bag, slot = slot })
            end
        end
    end
end

------------------------------------------------------------
-- Search Inventory
------------------------------------------------------------
function InventoryManager:SearchInventory(flag, onComplete, manualRequest)
    if TF.state.isScanning then
        return
    end

    TF.state.isScanning = true
    TF.state.isProcessingBags = true
    TF.state.needsQueueProcessing = false

    -- Initialize inventory structure
    TF.inventory = {
        emptySlot = {},
        lockboxes = {},
        itemStack = { ["1"] = {}, ["2"] = {}, ["3"] = {}, ["4"] = {}, ["5"] = {}, ["6"] = {} },
        stackReady = { ["1"] = {}, ["2"] = {}, ["3"] = {}, ["4"] = {}, ["5"] = {}, ["6"] = {} },
    }

    -- Safely unregister event if method exists
    if self.UnregisterEvent then
        self:UnregisterEvent("BAG_UPDATE_DELAYED")
    end

    self:GetEmptySlots()
    local inventory = TF.inventory
    local tooltip = GameTooltip
    -- Build trade lookup table
    local tradeLookup = {}
    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        local index = tostring(tradeSlot)
        local tradeItem = TradeFill:GetEffectiveItem(index)
        if tradeItem and tradeItem.id then
            tradeLookup[tradeItem.id] = index
        end
    end

    -- Scan all bags
    for bag = 0, 4 do
        local bagSlots = GetContainerNumSlots(bag)
        for slot = 1, bagSlots do
            local currentItem = GetContainerItemInfo(bag, slot)
            if currentItem then
                local index = tradeLookup[currentItem.itemID]

                -- Tradable item check
                if index and not currentItem.isLocked then
                    local itemData = TF.item[index]

                    local desiredSize = TradeFill:GetActiveGroupSize(index)
                    local entry = {
                        bag = bag,
                        slot = slot,
                        itemID = currentItem.itemID,
                        itemName = currentItem.itemName,
                        count = currentItem.stackCount,
                        link = currentItem.hyperlink
                    }

                    if desiredSize <= 0 or currentItem.stackCount == desiredSize then
                        table_insert(inventory.stackReady[index], entry)
                    else
                        table_insert(inventory.itemStack[index], entry)
                    end
                end

                -- Lockbox detection
                tooltip:SetOwner(UIParent, "ANCHOR_NONE")
                tooltip:SetBagItem(bag, slot)
                for i = 1, tooltip:NumLines() do
                    local line = _G["GameTooltipTextLeft"..i]
                    if line and line:GetText() == LOCKED_TOOLTIP_TEXT then
                        table_insert(inventory.lockboxes, { bag = bag, slot = slot })
                        break
                    end
                end
                tooltip:Hide()
            end
        end
    end

    --------------------------------------------------------
    -- Stack Processing
    --------------------------------------------------------
    local currentKey = 1

    local function ProcessNextItem(flag)
        if currentKey > MAX_TRADABLE_ITEMS then
            TF.state.isScanning = false
            TF.state.isProcessingBags = false

            if onComplete then
                TF.state.isWatchingBags = true

                if TF.state.needsQueueProcessing then
                    TF.state.needsQueueProcessing = false
                    C_Timer.After(0.5, onComplete)
                else
                    onComplete()
                end
            end

            -- ONLY register AFTER everything is done
            --[[if flag and self.RegisterEvent then
                self:RegisterEvent("BAG_UPDATE_DELAYED", function()
                    if not TF.state.isScanning then
                        InventoryManager:SearchInventory(flag, onComplete)
                    end
                end)
            end]]

            return
        end

        local index = tostring(currentKey)
        local tradeItem = TradeFill:GetEffectiveItem(index)
        if not tradeItem or not tradeItem.id or tradeItem.id <= 0 then
            currentKey = currentKey + 1
            ProcessNextItem(flag)
            return
        end

        local icon = tradeItem.link.." |T"..GetItemIconByID(tradeItem.id)..":0|t"
        if not TradeModule then
            TradeModule = TradeFill:GetModule("Trade")
        end

        local neededStacks
        if manualRequest and manualRequest.index == index then
            neededStacks = manualRequest.count or 1
        else
            neededStacks = TradeModule:GetMissingTradeCount(index)
        end

        local function RemainingNeeded()
            return neededStacks - #inventory.stackReady[index]
        end
        local desiredSize = TradeFill:GetActiveGroupSize(index)

        if desiredSize <= 0 then
            currentKey = currentKey + 1
            ProcessNextItem(flag)
            return
        end

        local function TrySplit()
            if RemainingNeeded() <= 0 then
                currentKey = currentKey + 1
                ProcessNextItem(flag)
                return
            end

            if #inventory.itemStack[index] == 0 then
                currentKey = currentKey + 1
                ProcessNextItem(flag)
                return
            end

            if #inventory.emptySlot == 0 then
                TradeFill:GetModule("TradingStatusPanel"):AddMessage(
                    string.format(TF.Loc["MESSAGE_NO_EMPTY_SLOTS"], icon, desiredSize)
                )
                return
            end

            local item = inventory.itemStack[index][1]
            local itemLoc = ItemLocation:CreateFromBagAndSlot(item.bag, item.slot)

            if C_Item.IsLocked(itemLoc) then
                C_Timer.After(0.05, TrySplit)
                return
            end

            local needed = RemainingNeeded()

            if needed <= 0 then
                return
            end

            if item.count > desiredSize then
                TF.state.needsQueueProcessing = true

                local emptySlot = table_remove(inventory.emptySlot, 1)
                ClearCursor()
                SplitContainerItem(item.bag, item.slot, desiredSize)

                if CursorHasItem() then
                    PickupContainerItem(emptySlot.bag, emptySlot.slot)
                    ClearCursor()

                    local newStack = {
                        bag = emptySlot.bag,
                        slot = emptySlot.slot,
                        itemID = item.itemID,
                        itemName = item.itemName,
                        count = desiredSize,
                        link = item.hyperlink
                    }

                    table_insert(inventory.stackReady[index], newStack)

                    table_insert(TF.StackSplitted[index], {
                        bagSource = item.bag,
                        slotSource = item.slot,
                        bagDestination = emptySlot.bag,
                        slotDestination = emptySlot.slot,
                        itemID = item.itemID,
                        itemName = item.itemName,
                        count = desiredSize,
                        link = item.link
                    })

                    item.count = item.count - desiredSize
                    if item.count <= 0 then
                        table_remove(inventory.itemStack[index], 1)
                    end

                    -- ✅ SMART CONTINUE
                    if RemainingNeeded() > 0 then
                        TrySplit()
                    else
                        currentKey = currentKey + 1
                        ProcessNextItem(flag)
                    end
                else
                    return
                end
            elseif item.count == desiredSize then
                table_insert(inventory.stackReady[index], item)
                table_remove(inventory.itemStack[index], 1)
                TrySplit()
            else
                table_remove(inventory.itemStack[index], 1)
                TrySplit()
            end
        end

        TrySplit()
    end

    TF.state.completed = true

    ProcessNextItem(flag)
    return true
end

------------------------------------------------------------
-- Restack
------------------------------------------------------------
function InventoryManager:ReStack()
    TF.state.isScanning = true
    TF.state.isProcessingBags = true
    TF.state.needsQueueProcessing = false

    if self.UnregisterEvent then
        self:UnregisterEvent("BAG_UPDATE_DELAYED")
    end

    local function processNext()
        for tradeSlot = 1, MAX_TRADABLE_ITEMS do
            local index = tostring(tradeSlot)
            local itemGroup = TF.StackSplitted[index]

            for key, item in pairs(itemGroup) do
                if item then
                    local destInfo = GetContainerItemInfo(item.bagDestination, item.slotDestination)
                    local srcInfo = GetContainerItemInfo(item.bagSource, item.slotSource)

                    if destInfo and srcInfo then
                        local destLoc = ItemLocation:CreateFromBagAndSlot(item.bagDestination, item.slotDestination)
                        local srcLoc = ItemLocation:CreateFromBagAndSlot(item.bagSource, item.slotSource)

                        -- 🛑 Wait if locked
                        if C_Item.IsLocked(destLoc) or C_Item.IsLocked(srcLoc) then
                            C_Timer.After(0.05, function() InventoryManager:ReStack() end)
                            return
                        end

                        ClearCursor()
                        PickupContainerItem(item.bagDestination, item.slotDestination)

                        -- ⏳ Delay before next action
                        C_Timer.After(0.05, function()
                            if CursorHasItem() then
                                local icon = item.link.." |T"..GetItemIconByID(item.itemID)..":0|t"
                                local total = destInfo.stackCount + srcInfo.stackCount

                                PickupContainerItem(item.bagSource, item.slotSource)

                                -- ⏳ Finalize after merge
                                C_Timer.After(0.05, function()
                                    ClearCursor()

                                    -- remove processed entry
                                    itemGroup[key] = nil

                                    -- 🔁 Continue processing next item
                                    InventoryManager:ReStack()
                                end)
                            else
                                C_Timer.After(0.05, function() InventoryManager:ReStack() end)
                            end
                        end)

                        return -- IMPORTANT: process one at a time
                    end
                end
            end
        end

        -- ✅ DONE: cleanup
        for itemIndex = 1, MAX_TRADABLE_ITEMS do
            TF.StackSplitted[tostring(itemIndex)] = {}
        end

        TF.state.isScanning = false
        TF.state.isProcessingBags = false
    end

    processNext()
end

function InventoryManager:ScanInventory(callback, manualRequest)
    self:SearchInventory(false, callback, manualRequest)
end

------------------------------------------------------------
-- Get Available Items for UI
------------------------------------------------------------
function InventoryManager:GetAvailableItems()
    TF.interfaceItem = {}

    local function findItemIndex(itemName)
        for index, value in ipairs(TF.interfaceItem) do
            if value.itemName == itemName then
                return index
            end
        end
        return nil
    end

    -- BAG SCAN
    for bag = 0, 4 do
        local slots = GetContainerNumSlots(bag)

        for slot = 1, slots do
            local currentItem = GetContainerItemInfo(bag, slot)

            if currentItem and not currentItem.isBound then
                local _,_,_,_,_,_,_,itemStackCount = C_Item.GetItemInfo(currentItem.hyperlink)
                local stackFlag = (currentItem.stackCount == itemStackCount)
                local idx = findItemIndex(currentItem.itemName)

                if idx == nil then
                    table_insert(TF.interfaceItem, {
                        itemID = currentItem.itemID,
                        itemName = currentItem.itemName,
                        hyperlink = currentItem.hyperlink,
                        fullStack = stackFlag
                    })
                else
                    -- ✅ FIX: upgrade if we find a full stack later
                    if stackFlag then
                        TF.interfaceItem[idx].fullStack = true
                    end
                end
            end
        end
    end

    -- TRADE WINDOW CHECK
    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        local index = tostring(tradeSlot)
        local tradeItem = TradeFill:GetItem(index)

        if tradeItem and tradeItem.id > 0 then
            local idx = findItemIndex(tradeItem.name)

            if not idx then
                table_insert(TF.interfaceItem, {
                    itemID = tradeItem.id,
                    itemName = tradeItem.name,
                    hyperlink = tradeItem.link,
                    fullStack = nil
                })
            else
                -- ✅ Trade items should never be considered full stack
                TF.interfaceItem[idx].fullStack = nil
            end
        end
    end

    table.sort(TF.interfaceItem, function(a, b)
        return a.itemName < b.itemName
    end)
end
