local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local TradeLog = TradeFill:NewModule("TradeLog")

local function copyTradeItem(item)
    return {
        id = item.id,
        name = item.name,
        link = item.link,
        texture = item.texture,
        quantity = item.quantity,
        quality = item.quality,
        enchantment = item.enchantment or "",
    }
end

function TradeLog:DeleteEntry(timeStamp)
    TradeFill.tradelog.profile[timeStamp] = nil
end

function TradeLog:Clear()
    TradeFill.tradelog:ResetProfile()
end

function TradeLog:GetSortedEntries(timeStamp, unit)
    local moneyEntry
    local numericEntries = {}

    for tradedSlot, tradeItem in pairs(TradeFill.tradelog.profile[timeStamp][unit]) do
        if tradedSlot == "money" then
            moneyEntry = { type = "money", value = tradeItem }
        elseif type(tonumber(tradedSlot)) == "number" then
            table.insert(numericEntries, {
                type = "item",
                index = tonumber(tradedSlot),
                value = tradeItem,
            })
        end
    end

    table.sort(numericEntries, function(a, b)
        return a.index < b.index
    end)

    local sortedEntries = {}
    if moneyEntry then
        table.insert(sortedEntries, moneyEntry)
    end

    for _, entry in ipairs(numericEntries) do
        table.insert(sortedEntries, entry)
    end

    return sortedEntries
end

function TradeLog:BuildTotals()
    local totals = {
        money = {
            player = 0,
            target = 0,
        },
        items = {
            player = {},
            target = {},
        },
    }

    local function addTradeItem(unit, item)
        local bucket = totals.items[unit]

        for _, existing in ipairs(bucket) do
            if existing.name == item.name then
                existing.total = existing.total + item.quantity
                return
            end
        end

        local entry = copyTradeItem(item)
        entry.total = item.quantity
        table.insert(bucket, entry)
    end

    local function collectUnitTradelog(tradelogEntry, unitKey, totalKey)
        for tradedSlot, trade in pairs(tradelogEntry[unitKey]) do
            if tradedSlot == "money" and trade ~= "" then
                totals.money[totalKey] = totals.money[totalKey] + trade
            end

            if type(tonumber(tradedSlot)) == "number" and tonumber(tradedSlot) <= MAX_TRADABLE_ITEMS then
                addTradeItem(totalKey, trade)
            end
        end
    end

    for _, tradelogEntry in pairs(TradeFill.tradelog.profile) do
        collectUnitTradelog(tradelogEntry, "tradePlayer", "player")
        collectUnitTradelog(tradelogEntry, "tradeTarget", "target")
    end

    return totals
end

function TradeLog:CaptureCurrentTrade()
    TF.tradeLog = {
        time = "",
        player = {},
        target = {},
    }

    local player = TF.tradeLog.player
    local target = TF.tradeLog.target

    player.money = GetPlayerTradeMoney()
    target.money = GetTargetTradeMoney()

    for i = 1, MAX_TRADABLE_ITEMS do
        local playerLink = GetTradePlayerItemLink(i)
        if playerLink ~= nil then
            local name, texture, quantity, quality = GetTradePlayerItemInfo(i)
            local id = C_Item.GetItemInfoInstant(playerLink)

            if name ~= nil then
                player[i] = {
                    id = id,
                    name = name,
                    link = playerLink,
                    texture = texture,
                    quantity = quantity,
                    quality = quality,
                    enchantment = nil,
                }
            end
        end

        local targetLink = GetTradeTargetItemLink(i)
        if targetLink ~= nil then
            local name, texture, quantity, quality = GetTradeTargetItemInfo(i)
            local id = C_Item.GetItemInfoInstant(targetLink)

            if name ~= nil then
                target[i] = {
                    id = id,
                    name = name,
                    link = targetLink,
                    texture = texture,
                    quantity = quantity,
                    quality = quality,
                    enchantment = nil,
                }
            end
        end
    end

    local playerEnchantLink = GetTradePlayerItemLink(TRADE_ENCHANT_SLOT)
    if playerEnchantLink ~= nil then
        local name, texture, quantity, quality, enchantment = GetTradePlayerItemInfo(TRADE_ENCHANT_SLOT)
        local id = C_Item.GetItemInfoInstant(playerEnchantLink)
        local enchant = enchantment or ""

        if name ~= nil then
            player[TRADE_ENCHANT_SLOT] = {
                id = id,
                name = name,
                link = playerEnchantLink,
                texture = texture,
                quantity = quantity,
                quality = quality,
                enchantment = enchant,
            }
        end
    end

    local targetEnchantLink = GetTradeTargetItemLink(TRADE_ENCHANT_SLOT)
    if targetEnchantLink ~= nil then
        local name, texture, quantity, quality, _, enchantment = GetTradeTargetItemInfo(TRADE_ENCHANT_SLOT)
        local id = C_Item.GetItemInfoInstant(targetEnchantLink)
        local enchant = enchantment or ""

        if name ~= nil then
            target[TRADE_ENCHANT_SLOT] = {
                id = id,
                name = name,
                link = targetEnchantLink,
                texture = texture,
                quantity = quantity,
                quality = quality,
                enchantment = enchant,
            }
        end
    end

    if next(player) or next(target) or player.money > 0 or target.money > 0 then
        TF.tradeLog.time = tostring(GetServerTime())

        player.name = TradeFill:ColorizeByClass(select(2, UnitClass("player")), GetUnitName("player"))
        target.name = TradeFill:ColorizeUnitNameByClass(TF.state.target.class.file, TF.state.target.fullName)
    end
end

function TradeLog:PersistCurrentTrade()
    if not TF.tradeLog or not TF.tradeLog.time or TF.tradeLog.time == "" then
        return
    end

    local snapshot = TF.tradeLog
    local trade = TradeFill.tradelog.profile[snapshot.time]

    trade.player = snapshot.player.name
    trade.target = snapshot.target.name

    trade.tradePlayer.money = snapshot.player.money
    trade.tradeTarget.money = snapshot.target.money

    for slot, item in pairs(snapshot.player) do
        if type(slot) == "number" then
            trade.tradePlayer[tostring(slot)] = copyTradeItem(item)
        end
    end

    for slot, item in pairs(snapshot.target) do
        if type(slot) == "number" then
            trade.tradeTarget[tostring(slot)] = copyTradeItem(item)
        end
    end
end
