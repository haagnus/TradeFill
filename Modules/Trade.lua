local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local Trade = TradeFill:NewModule("Trade")

function Trade:GetTradeWindowItemCount(itemName)
    if not itemName or not GetTradePlayerItemInfo then
        return 0
    end

    local count = 0

    for tradeSlot = 1, MAX_TRADABLE_ITEMS do
        local name = GetTradePlayerItemInfo(tradeSlot)

        if name == itemName then
            count = count + 1
        end
    end

    return count
end

function Trade:GetMissingTradeCount(index)
    local item = TradeFill:GetEffectiveItem(index)
    local desiredCount = TradeFill:GetActiveGroupStack(index)
    local existingCount = self:GetTradeWindowItemCount(item and item.name)

    return math.max(0, desiredCount - existingCount)
end

function Trade:GetAvailableReadyCount(index)
    local available = 0
    local stackSlots = (TF.inventory.stackReady and TF.inventory.stackReady[tostring(index)]) or {}

    for _, slot in ipairs(stackSlots) do
        local info = C_Container.GetContainerItemInfo(slot.bag, slot.slot)

        if info and not info.isLocked then
            available = available + 1
        end
    end

    return available
end

function Trade:GetAvailableTradeCount(index)
    local stackSize = TradeFill:GetActiveGroupSize(index)
    local available = self:GetAvailableReadyCount(index)

    if stackSize <= 0 then
        return available
    end

    local itemStacks = (TF.inventory.itemStack and TF.inventory.itemStack[tostring(index)]) or {}

    for _, slot in ipairs(itemStacks) do
        if slot.count and slot.count >= stackSize then
            available = available + math.floor(slot.count / stackSize)
        end
    end

    return available
end

function Trade:FillTradeSlot(entry, position)
    local index = entry
    local item = TradeFill:GetEffectiveItem(index)
    if not item or not item.id or item.id <= 0 then
        return false
    end

    local link = item.link
    local stackSize = TradeFill:GetActiveGroupSize(index)
    local stackSlots = (TF.inventory.stackReady and TF.inventory.stackReady[tostring(index)]) or {}
    local missingCount = self:GetMissingTradeCount(index)

    for readyIndex, slot in ipairs(stackSlots) do
        local info = C_Container.GetContainerItemInfo(slot.bag, slot.slot)
        if slot.bound then
            TradeFill:GetModule("TradingStatusPanel"):AddMessage(
                string.format(TF.Loc["MESSAGE_SOULBOUND"], link)
            )
        elseif info and not info.isLocked then
            ClearCursor()
            C_Container.PickupContainerItem(slot.bag, slot.slot)
            ClickTradeButton(position)
            ClearCursor()
            table.remove(stackSlots, readyIndex)
            return true
        end
    end

    if stackSize > 0 and self:GetAvailableTradeCount(index) < missingCount then
        TradeFill:GetModule("TradingStatusPanel"):AddMessage(
            string.format(TF.Loc["MESSAGE_NO_STACK"], link, stackSize)
        )
    end

    return false
end

function Trade:FillLockboxSlot()
    local target = TF.state and TF.state.target
    local lockboxes = TF.inventory and TF.inventory.lockboxes

    if not target or not target.class or target.class.file ~= "ROGUE" then
        return false
    end

    if not TradeFill:GetFilter("lock") then
        return false
    end

    if not lockboxes or #lockboxes == 0 then
        return false
    end

    if GetTradePlayerItemLink and GetTradePlayerItemLink(TRADE_ENCHANT_SLOT) then
        return false
    end

    for _, slot in ipairs(lockboxes) do
        local info = C_Container.GetContainerItemInfo(slot.bag, slot.slot)

        if info and not info.isLocked then
            ClearCursor()
            C_Container.PickupContainerItem(slot.bag, slot.slot)
            ClickTradeButton(TRADE_ENCHANT_SLOT)
            ClearCursor()
            return true
        end
    end

    return false
end
