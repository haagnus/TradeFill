local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

local dropdowns = {}
local limits = {}
local ranks = {}
local groupModes = { "main", "ungrouped", "party", "raid" }

function TradeFill:Item(frame)
    -- Reset tables to avoid stale UI references.
    dropdowns = {}
    limits = {}
    ranks = {}

    local contentGroup = self:ContentGroup(AceGUI, frame)
    local group = self:Group(AceGUI, "SimpleGroup", contentGroup)

    local show = AceGUI:Create("CheckBox")
    show:SetLabel(TF.Loc["SHOW"])
    show:SetValue(self:GetUi("show"))
    show:SetWidth(180)
    show:SetHeight(40)
    TradeFill:SetInlineInfo(show, TF.Loc["SHOW_DESC"])

    show:SetCallback("OnValueChanged", function(_, _, value)
        self:SetUi("show", value)
        frame:ReleaseChildren()
        self:Item(frame)
    end)

    group:AddChild(show)

    local refreshLimit = AceGUI:Create("CheckBox")
    refreshLimit:SetLabel(TF.Loc["REFRESH_LIMIT"])
    refreshLimit:SetValue(self:GetTrade("refresh"))
    refreshLimit:SetWidth(140)
    refreshLimit:SetHeight(40)
    self:SetToolTipText(
        refreshLimit,
        string.format(
            TF.Loc["REFRESH_LIMIT_DESC"],
            self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto)
        )
    )

    refreshLimit:SetCallback("OnValueChanged", function(_, _, value)
        self:SetTrade("refresh", value)
    end)

    group:AddChild(refreshLimit)

    self:AddRowSpacer(AceGUI, group)

    for i = 1, MAX_TRADABLE_ITEMS do
        local tradeItem = self:GetItem(i)

        local label = AceGUI:Create("InteractiveLabel")
        local fontName, _, fontFlags = label.label:GetFont()
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
        dropdown:SetLabel(TF.Loc["ITEM"])
        dropdown:SetWidth(270)
        dropdown:SetHeight(40)
        dropdown:AddItem(TF.Loc["OPTION_NONE"], TF.Loc["OPTION_NONE"])

        for _, slot in pairs(TF.interfaceItem) do
            local color = self:GetColor(slot.hyperlink)
            if self:GetUi("show") == true then
                if slot.fullStack == true or slot.fullStack == nil then
                    dropdown:AddItem(slot.itemName, TradeFill:FormatColorText(color, slot.itemName))
                end
            else
                dropdown:AddItem(slot.itemName, TradeFill:FormatColorText(color, slot.itemName))
            end
        end

        dropdowns[i] = dropdown

        if tradeItem.id > 0 then
            dropdown:SetValue(tradeItem.name)
        else
            dropdown:SetValue(TF.Loc["OPTION_NONE"])
        end

        local limitDropdown = AceGUI:Create("Dropdown")
        limitDropdown:SetLabel(TF.Loc["LIMIT"])
        limitDropdown:SetWidth(100)
        limitDropdown:SetHeight(40)
        limitDropdown:AddItem(0, TF.Loc["OPTION_NONE"])
        for value = 1, 10 do
            limitDropdown:AddItem(value, value)
        end

        limits[i] = limitDropdown

        if type(tradeItem.limit) == "string" then
            self.db.profile.item[tostring(i)].limit = tonumber(tradeItem.limit)
            tradeItem.limit = self.db.profile.item[tostring(i)].limit
        end

        if tradeItem.id > 0 and tradeItem.limit and tradeItem.limit > 0 then
            limitDropdown:SetValue(tradeItem.limit)
        else
            limitDropdown:SetValue(0)
        end

        limitDropdown:SetCallback("OnValueChanged", function(widget, _, value)
            for index, dd in pairs(limits) do
                if dd == widget then
                    local item = self.db.profile.item[tostring(index)]
                    if item then
                        item.limit = value
                    end
                    break
                end
            end
        end)

        self:SetToolTipText(dropdown, TF.Loc["SELECT_ITEMS_DESC"])
        self:SetToolTipText(
            limitDropdown,
            string.format(
                TF.Loc["SELECT_LIMIT_DESC"],
                self:SetColor(TF.Loc["AUTOFILL"], TF.colors.trade.auto)
            )
        )

        TradeFill:ToggleWidget(limitDropdown, tradeItem)

        dropdown:SetCallback("OnValueChanged", function(widget, _, value)
            for index, dd in pairs(dropdowns) do
                if dd == widget then
                    if value == TF.Loc["OPTION_NONE"] then
                        self:SetItem(index, nil)
                        label:SetText(TF.Loc["OPTION_NONE"])
                        label:SetImage(nil)
                        self:SetToolTipLink(label, nil)

                        limits[index]:SetValue(0)
                        limits[index]:SetDisabled(true)
                        ranks[index]:SetValue(false)
                        ranks[index]:SetDisabled(true)
                        TradeFill.db.profile.rank[tostring(index)] = false

                        for _, mode in pairs(groupModes) do
                            for _, class in pairs(TF.classes) do
                                self:SetGroupStack(mode, class, index, 0)
                                self:SetGroupSize(mode, class, index, 0)
                            end
                        end
                        return
                    else
                        for key, _ in pairs(TF.interfaceItem) do
                            if TF.interfaceItem[key].itemName == value then
                                local interfaceItem = TF.interfaceItem[key]
                                local itemName, itemLink, itemQuality, _, itemMinLevel, _, _, itemStackCount, _, itemTexture =
                                    C_Item.GetItemInfo(interfaceItem.hyperlink)

                                local set = self:GetItem(index)
                                if not set then
                                    self:SetItem(index, {})
                                    set = self:GetItem(index)
                                end

                                set.id = interfaceItem.itemID
                                set.name = itemName
                                set.link = itemLink
                                set.quality = itemQuality
                                set.level = itemMinLevel
                                set.stack = itemStackCount
                                set.texture = itemTexture
                                set.limit = tonumber(set.limit) or 0

                                label:SetText(TradeFill:FormatColorText(self:GetColor(itemLink), itemName))
                                label:SetImage(C_Item.GetItemIconByID(interfaceItem.itemID))
                                self:SetToolTipLink(label, itemLink)

                                for _, mode in pairs(groupModes) do
                                    for _, class in pairs(TF.classes) do
                                        if self:GetGroupSize(mode, class, index) > itemStackCount then
                                            self:SetGroupSize(mode, class, index, itemStackCount)
                                        end
                                    end
                                end

                                limits[index]:SetValue(set.limit)
                                limits[index]:SetDisabled(false)

                                local level = UnitLevel("player")
                                local checkSpell = self:GetSpell(set.id, level)

                                if checkSpell and checkSpell.id > 0 then
                                    ranks[index]:SetDisabled(false)
                                    ranks[index]:SetValue(TradeFill.db.profile.rank[tostring(index)] or false)
                                else
                                    ranks[index]:SetValue(false)
                                    ranks[index]:SetDisabled(true)
                                    TradeFill.db.profile.rank[tostring(index)] = false
                                end
                                break
                            end
                        end
                    end
                    break
                end
            end
        end)

        group:AddChild(label)

        local rowGroup = AceGUI:Create("SimpleGroup")
        rowGroup:SetLayout("Flow")
        rowGroup:SetFullWidth(true)

        rowGroup:AddChild(dropdown)

        TradeFill:AddInlineSpacer(AceGUI, rowGroup, nil)

        rowGroup:AddChild(limitDropdown)

        TradeFill:AddInlineSpacer(AceGUI, rowGroup, nil)

        local rank = AceGUI:Create("CheckBox")
        rank:SetLabel(TF.Loc["APPROPRIATE_RANK"])
        rank:SetWidth(150)
        rank:SetHeight(20)
        TradeFill:SetInlineInfo(
            rank, 
            string.format(
                TF.Loc["APPROPRIATE_RANK_DESC"],
                self:SetClass("MAGE"),
                self:SetClass("WARLOCK"),
                self:SetColor(TF.Loc["TEXT_ENABLED"], TF.colors.addon.enabled)
            )
        )

        ranks[i] = rank

        local level = UnitLevel("player")
        local checkSpell = self:GetSpell(tradeItem.id, level)

        if checkSpell and checkSpell.id > 0 then
            rank:SetValue(TradeFill.db.profile.rank[tostring(i)] or false)
        else
            rank:SetValue(false)
            rank:SetDisabled(true)
        end

        rank:SetCallback("OnValueChanged", function(widget, _, value)
            for index, cb in pairs(ranks) do
                if cb == widget then
                    TradeFill.db.profile.rank[tostring(index)] = value and true or false
                    break
                end
            end
        end)

        rowGroup:AddChild(rank)
        group:AddChild(rowGroup)
    end

    local frameWidget = frame.frame
    frameWidget:SetClipsChildren(true)
end
