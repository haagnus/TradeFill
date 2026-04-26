local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

local dropdowns = {}

function TradeFill:Limit(frame)
    local contentGroup = self:ContentGroup(AceGUI, frame)
    local group = self:Group(AceGUI, "SimpleGroup", contentGroup)

    local limit = AceGUI:Create("CheckBox")
    limit:SetLabel(TF.Loc["REFRESH_LIMIT"])
    limit:SetValue(self:GetTrade("refresh"))
    limit:SetWidth(120)
    limit:SetHeight(40)
    self:SetToolTipText(limit, TF.Loc["REFRESH_LIMIT_DESC"])

    limit:SetCallback("OnValueChanged", function(_, _, value)
        self:SetTrade("refresh", value)
    end)

    group:AddChild(limit)

    self:SetInfoLabel(AceGUI, group, TF.Loc["INFO_LIMIT"], TF.Loc["INFO_LIMIT_DESC"])

    self:AddSpacer(AceGUI, group)

    for i = 1, MAX_TRADABLE_ITEMS do
        local tradeItem = self:GetItem(i)

        local label = AceGUI:Create("InteractiveLabel")
        local fontName, fontHeight, fontFlags = label.label:GetFont()
        label.label:SetFont(fontName, 12, fontFlags)
        label:SetFullWidth(true)

        if tradeItem.id > 0 then
            label:SetText(TradeFill:FormatColorText(self:GetColor(tradeItem.link), tradeItem.name))
            label:SetImage(C_Item.GetItemIconByID(tradeItem.id))
            self:SetToolTipLink(label, tradeItem.link)
        else
            label:SetText(TF.Loc["OPTION_NONE"])
            self:SetToolTipLink(label, nil)
        end

        local dropdown = AceGUI:Create("Dropdown")
        dropdown:SetWidth(100)
        dropdown:SetHeight(40)
        dropdown:AddItem(0, TF.Loc["OPTION_NONE"])
        for value = 1, 10 do
            dropdown:AddItem(value, value)
        end

        dropdowns[i] = dropdown

        --change databaste value to number
        if type(tradeItem.limit) == "string" then
            self.db.profile.item[i].limit = tonumber(tradeItem.limit)
        end

        if tradeItem.id > 0 and tradeItem.limit > 0 then
            dropdown:SetValue(tradeItem.limit)
        else
            dropdown:SetValue(0)
        end

        dropdown:SetCallback("OnValueChanged", function(widget, _, value)
            for index, dd in pairs(dropdowns) do
                if dd == widget then
                    self.db.profile.item[tostring(index)].limit = value
                    break
                end
            end
        end)

        self:SetToolTipText(dropdown, TF.Loc["SELECT_LIMIT_DESC"])

        TradeFill:ToggleWidget(dropdown, tradeItem)

        group:AddChild(label)

        group:AddChild(dropdown)
    end

    local frameWidget = frame.frame
    frameWidget:SetClipsChildren(true)
end