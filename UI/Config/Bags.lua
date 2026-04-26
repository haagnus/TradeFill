local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

function TradeFill:Bags(frame)
    local contentGroup = self:ContentGroup(AceGUI, frame)
    local group = self:Group(AceGUI, "SimpleGroup", contentGroup)
    group:SetFullWidth(true)
    group:SetLayout("List")

    self:SetInfoLabel(
        AceGUI,
        group,
        TF.Loc["INFO_BAGS"],
        TF.Loc["INFO_BAGS_DESC"]
    )

    self:AddSpacer(AceGUI, group)

    local bagNames = {
        [0] = "Backpack",
        [1] = "Bag 1",
        [2] = "Bag 2",
        [3] = "Bag 3",
        [4] = "Bag 4",
    }

    for bag = 0, 4 do
        self:CreateCheckBox(group, {
            label = bagNames[bag],
            tooltip = string.format(TF.Loc["LABEL_BAGS_DESC"], bagNames[bag]),
            width = 150,
            get = function() return self:GetBag(bag) end,
            set = function(value)
                self:SetBag(bag, value)
            end
        })
    end

    local frameWidget = frame.frame
    frameWidget:SetClipsChildren(true)
end
