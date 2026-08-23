local addonName, TF = ...

local refreshments = {
    { level = 74, id = 43518, spell = 61828, texture = 236212, stack = 20, quality = 1, name = "Conjured Mana Pie", link = "|cffffffff|Hitem:43518::::::::80:::::|h[Conjured Mana Pie]|h|r" },
    { level = 80, id = 43523, spell = 58648, texture = 236210, stack = 20, quality = 1, name = "Conjured Mana Strudel", link = "|cffffffff|Hitem:43523::::::::80:::::|h[Conjured Mana Strudel]|h|r" },
}

local stones = {
    { level = 63, id = 36889, spell = 47874, texture = 135230, stack = 20, quality = 1, name = "Demonic Healthstone", link = "|cffffffff|Hitem:36889::::::::80:::::|h[Demonic Healthstone]|h|r" },
    { level = 63, id = 36890, spell = 47873, texture = 135230, stack = 20, quality = 1, name = "Demonic Healthstone", link = "|cffffffff|Hitem:36890::::::::80:::::|h[Demonic Healthstone]|h|r" },
    { level = 63, id = 36891, spell = 47872, texture = 135230, stack = 20, quality = 1, name = "Demonic Healthstone", link = "|cffffffff|Hitem:36891::::::::80:::::|h[Demonic Healthstone]|h|r" },
}

for _, item in ipairs(refreshments) do
    table.insert(TF.water, item)
    table.insert(TF.food, item)
end

for _, item in ipairs(stones) do
    table.insert(TF.stone, item)
end
