local addonName, TF = ...

local refreshments = {
    { level = 5, id = 65500, spell = 190336, stack = 20, quality = 1, name = "Conjured Mana Cookie", link = "|cffffffff|Hitem:65500::::::::80:::::|h[Conjured Mana Cookie]|h|r" },
    { level = 11, id = 65515, spell = 190336, stack = 20, quality = 1, name = "Conjured Mana Brownie", link = "|cffffffff|Hitem:65515::::::::80:::::|h[Conjured Mana Brownie]|h|r" },
    { level = 21, id = 65516, spell = 190336, stack = 20, quality = 1, name = "Conjured Mana Cupcake", link = "|cffffffff|Hitem:65516::::::::80:::::|h[Conjured Mana Cupcake]|h|r" },
    { level = 26, id = 65517, spell = 190336, stack = 20, quality = 1, name = "Conjured Mana Lollipop", link = "|cffffffff|Hitem:65517::::::::80:::::|h[Conjured Mana Lollipop]|h|r" },
    { level = 31, id = 43518, spell = 190336, stack = 20, quality = 1, name = "Conjured Mana Pie", link = "|cffffffff|Hitem:43518::::::::80:::::|h[Conjured Mana Pie]|h|r" },
    { level = 36, id = 43523, spell = 190336, stack = 20, quality = 1, name = "Conjured Mana Strudel", link = "|cffffffff|Hitem:43523::::::::80:::::|h[Conjured Mana Strudel]|h|r" },
    { level = 41, id = 65499, spell = 190336, stack = 20, quality = 1, name = "Conjured Mana Cake", link = "|cffffffff|Hitem:65499::::::::80:::::|h[Conjured Mana Cake]|h|r" },
    { level = 46, id = 80610, spell = 190336, stack = 20, quality = 1, name = "Conjured Mana Pudding", link = "|cffffffff|Hitem:80610::::::::80:::::|h[Conjured Mana Pudding]|h|r" },
    { level = 51, id = 113509, spell = 190336, stack = 20, quality = 1, name = "Conjured Mana Bun", link = "|cffffffff|Hitem:113509::::::::80:::::|h[Conjured Mana Bun]|h|r" },
}

for _, item in ipairs(refreshments) do
    table.insert(TF.water, item)
    table.insert(TF.food, item)
end

table.insert(TF.stone, { level = 7, id = 5512, spell = 6201, texture = 135230, stack = 1, quality = 1, name = "Healthstone", link = "|cffffffff|Hitem:5512:::::::|h[Healthstone]|h|r" })
