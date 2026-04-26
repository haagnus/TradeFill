local addonName, TF = ...

local waters = {
    { level = 60, id = 30703, spell = 37420, texture = 132830, stack = 20, quality = 1, name = "Conjured Mountain Spring Water", link = "|cffffffff|Hitem:30703::::::::70:::::|h[Conjured Mountain Spring Water]|h|r" },
    { level = 65, id = 22018, spell = 27090, texture = 132803, stack = 20, quality = 1, name = "Conjured Glacier Water", link = "|cffffffff|Hitem:22018::::::::70:::::|h[Conjured Glacier Water]|h|r" },
}

local foods = {
    { level = 55, id = 22895, spell = 28612, texture = 134029, stack = 20, quality = 1, name = "Conjured Cinnamon Roll", link = "|cffffffff|Hitem:22895::::::::60:::::|h[Conjured Cinnamon Roll]|h|r" },
    { level = 65, id = 22019, spell = 33717, texture = 133988, stack = 20, quality = 1, name = "Conjured Croissant", link = "|cffffffff|Hitem:22019::::::::70:::::|h[Conjured Croissant]|h|r" },
}

local stones = {
    { level = 60, id = 22103, spell = 27235, texture = 135230, stack = 20, quality = 1, name = "Master Healthstone", link = "|cffffffff|Hitem:22103::::::::70:::::|h[Master Healthstone]|h|r" },
    { level = 60, id = 22104, spell = 27236, texture = 135230, stack = 20, quality = 1, name = "Master Healthstone", link = "|cffffffff|Hitem:22104::::::::70:::::|h[Master Healthstone]|h|r" },
    { level = 60, id = 22105, spell = 27237, texture = 135230, stack = 20, quality = 1, name = "Master Healthstone", link = "|cffffffff|Hitem:22105::::::::70:::::|h[Master Healthstone]|h|r" },
}

for _, item in ipairs(waters) do
    table.insert(TF.water, item)
end

for _, item in ipairs(foods) do
    table.insert(TF.food, item)
end

for _, item in ipairs(stones) do
    table.insert(TF.stone, item)
end
