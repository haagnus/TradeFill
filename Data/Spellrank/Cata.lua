local addonName, TF = ...

local refreshments = {
    { level = 38, id = 65500, spell = 42955, stack = 20, quality = 1, name = "Conjured Mana Cookie", link = "|cffffffff|Hitem:65500::::::::85:::::|h[Conjured Mana Cookie]|h|r" },
    { level = 44, id = 65515, spell = 42955, stack = 20, quality = 1, name = "Conjured Mana Brownie", link = "|cffffffff|Hitem:65515::::::::85:::::|h[Conjured Mana Brownie]|h|r" },
    { level = 54, id = 65516, spell = 42955, stack = 20, quality = 1, name = "Conjured Mana Cupcake", link = "|cffffffff|Hitem:65516::::::::85:::::|h[Conjured Mana Cupcake]|h|r" },
    { level = 64, id = 65517, spell = 42955, stack = 20, quality = 1, name = "Conjured Mana Lollipop", link = "|cffffffff|Hitem:65517::::::::85:::::|h[Conjured Mana Lollipop]|h|r" },
    { level = 74, id = 43518, spell = 42955, stack = 20, quality = 1, name = "Conjured Mana Pie", link = "|cffffffff|Hitem:43518::::::::85:::::|h[Conjured Mana Pie]|h|r" },
    { level = 80, id = 43523, spell = 42955, stack = 20, quality = 1, name = "Conjured Mana Strudel", link = "|cffffffff|Hitem:43523::::::::85:::::|h[Conjured Mana Strudel]|h|r" },
    { level = 85, id = 65499, spell = 42955, stack = 20, quality = 1, name = "Conjured Mana Cake", link = "|cffffffff|Hitem:65499::::::::85:::::|h[Conjured Mana Cake]|h|r" },
}

for _, item in ipairs(refreshments) do
    table.insert(TF.water, item)
    table.insert(TF.food, item)
end

table.insert(TF.stone, { level = 9, id = 5512, spell = 6201, texture = 135230, stack = 1, quality = 1, name = "Healthstone", link = "|cffffffff|Hitem:5512:::::::|h[Healthstone]|h|r" })
