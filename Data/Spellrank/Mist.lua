local addonName, TF = ...

local refreshments = {
    { level = 90, id = 80610, spell = 42955, stack = 20, quality = 1, name = "Conjured Mana Pudding", link = "|cffffffff|Hitem:80610::::::::90:::::|h[Conjured Mana Pudding]|h|r" },
    { level = 90, id = 80618, spell = 43987, stack = 20, quality = 1, name = "Conjured Mana Buns", link = "|cffffffff|Hitem:80618::::::::90:::::|h[Conjured Mana Buns]|h|r" },
}

for _, item in ipairs(refreshments) do
    table.insert(TF.water, item)
    table.insert(TF.food, item)
end

table.insert(TF.stone, { level = 9, id = 5512, spell = 23517, texture = 135230, stack = 1, quality = 1, name = "Healthstone", link = "|cffffffff|Hitem:5512:::::::|h[Healthstone]|h|r" })
