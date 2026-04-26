local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

local function hasItemLink(item)
    local pattern = "|c%x%x%x%x%x%x%x%x|Hitem:(%d+):.-|h%[.-%]|h|r"

    if type(item) == "string" then
        return string.match(item, pattern) ~= nil
    end

    if type(item) == "table" and type(item.link) == "string" then
        return string.match(item.link, pattern) ~= nil
    end

    return false
end

function TradeFill:RefreshTree(tree)
    if tree.refreshScheduled then
        return
    end

    tree.refreshScheduled = true

    C_Timer.After(0.1, function()
        tree:SetTree(self:GetTreeData())
        tree.refreshScheduled = false
    end)
end

local function renderTotalTab(self, container, totalItems, totalMoney)
    local width = container.frame:GetWidth()

    local group = AceGUI:Create("SimpleGroup")
    group:SetWidth(width)
    group:SetFullHeight(true)
    group:SetLayout("Flow")
    container:AddChild(group)

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    group:AddChild(scrollFrame)

    if totalMoney ~= "" then
        local money = AceGUI:Create("Label")
        money:SetText(GetMoneyString(totalMoney, 1000))
        money:SetFullWidth(true)
        scrollFrame:AddChild(money)
    end

    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetFullWidth(true)
    spacer:SetHeight(20)
    scrollFrame:AddChild(spacer)

    for _, tradeItem in ipairs(totalItems) do
        local label = AceGUI:Create("InteractiveLabel")
        local fontName, _, fontFlags = label.label:GetFont()
        label.label:SetFont(fontName, 10, fontFlags)
        label:SetFullWidth(true)
        label:SetText(tradeItem.name .. " x " .. tostring(tradeItem.total))
        label:SetImage(C_Item.GetItemIconByID(tradeItem.id))
        label:SetImageSize(24, 24)
        scrollFrame:AddChild(label)

        if tradeItem.link and not tradeItem.link.id then
            self:SetToolTipLink(label, tradeItem.link)
        end
    end
end

function TradeFill:TradelogTotal(frame)
    local tradelogModule = self:GetModule("TradeLog")
    local totals = tradelogModule:BuildTotals()

    local mainGroup = AceGUI:Create("SimpleGroup")
    mainGroup:SetFullWidth(true)
    mainGroup:SetFullHeight(true)
    mainGroup:SetLayout("List")
    frame:AddChild(mainGroup)

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")
    tabGroup:SetTabs({
        { text = TF.Loc["TAB_TRADED"], value = "player" },
        { text = TF.Loc["TAB_RECEIVED"], value = "target" },
    })
    tabGroup:SetFullWidth(true)
    tabGroup:SetFullHeight(true)

    local tabHolder = AceGUI:Create("SimpleGroup")
    tabHolder:SetFullWidth(true)
    tabHolder:SetHeight(320)
    tabHolder:SetLayout("Fill")
    tabHolder:AddChild(tabGroup)
    mainGroup:AddChild(tabHolder)

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetFullWidth(true)
    buttonGroup:SetLayout("Flow")
    mainGroup:AddChild(buttonGroup)

    local deleteAllButton = AceGUI:Create("Button")
    deleteAllButton:SetText(TF.Loc["BUTTON_DELETE_ALL"])
    deleteAllButton:SetWidth(200)
    buttonGroup:AddChild(deleteAllButton)

    local function updateTabHolderHeight()
        local frameHeight = frame.frame and frame.frame:GetHeight() or 0
        local buttonHeight = buttonGroup.frame and buttonGroup.frame:GetHeight() or 0
        local reservedHeight = buttonHeight + 16
        local tabHeight = math.max(120, frameHeight - reservedHeight)

        tabHolder:SetHeight(tabHeight)
        mainGroup:DoLayout()
    end

    local function refreshTabs()
        totals = tradelogModule:BuildTotals()
        tabGroup:SelectTab("player")
        updateTabHolderHeight()
    end

    deleteAllButton:SetCallback("OnClick", function()
        StaticPopupDialogs["CONFIRM_DELETE_ALL"] = {
            text = TF.Loc["BUTTON_DELETE_ALL_CONFIRM"],
            button1 = TF.Loc["BUTTON_YES"],
            button2 = TF.Loc["BUTTON_CANCEL"],
            OnAccept = function()
                tradelogModule:Clear()
                self:RefreshTree(frame:GetUserData("tree"))
                refreshTabs()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            exclusive = true,
            showAlert = true,
            enterClicksFirstButton = false,
            preferredIndex = 3,
        }

        StaticPopup_Show("CONFIRM_DELETE_ALL")
    end)

    self:SetToolTipText(deleteAllButton, TF.Loc["BUTTON_REMOVE_ALL"])

    frame:SetCallback("OnHeightSet", function()
        updateTabHolderHeight()
    end)

    tabGroup:SetCallback("OnGroupSelected", function(container, _, group)
        container:ReleaseChildren()

        if group == "player" then
            renderTotalTab(self, container, totals.items.player, totals.money.player)
        else
            renderTotalTab(self, container, totals.items.target, totals.money.target)
        end
    end)

    tabGroup:SelectTab("player")
    C_Timer.After(0, updateTabHolderHeight)
end

function TradeFill:Tradelog(frame, timeStamp)
    local tradelogModule = self:GetModule("TradeLog")
    local contentGroup = self:ContentGroup(AceGUI, frame)
    contentGroup:SetUserData("timeStamp", timeStamp)

    local playerName = self.tradelog.profile[timeStamp].player
    local targetName = self.tradelog.profile[timeStamp].target

    local firstGroup = self:Group(AceGUI, "InlineGroup", contentGroup)
    firstGroup:SetTitle(playerName)

    self:GetTradelogEntries(AceGUI, firstGroup, timeStamp, "tradePlayer")

    local secondGroup = self:Group(AceGUI, "InlineGroup", contentGroup)
    secondGroup:SetTitle(targetName)

    self:GetTradelogEntries(AceGUI, secondGroup, timeStamp, "tradeTarget")

    local deleteButton = AceGUI:Create("Button")
    deleteButton:SetText(TF.Loc["BUTTON_DELETE_DAY"])
    deleteButton:SetWidth(100)
    deleteButton:SetUserData("parentGroup", contentGroup)

    deleteButton:SetCallback("OnClick", function(widget)
        local parentGroup = widget:GetUserData("parentGroup")
        local timeStampDelete = parentGroup:GetUserData("timeStamp")

        if timeStampDelete then
            tradelogModule:DeleteEntry(timeStampDelete)
            self:RefreshTree(frame:GetUserData("tree"))
            parentGroup:ReleaseChildren()
        end
    end)

    self:SetToolTipText(deleteButton, TF.Loc["BUTTON_REMOVE_TRADE"])

    contentGroup:AddChild(deleteButton)

    frame:DoLayout()
    frame.frame:SetClipsChildren(true)
end

function TradeFill:GetTradelogEntries(AceGUIInstance, widget, timeStamp, unit)
    local tradelogModule = self:GetModule("TradeLog")

    for _, entry in ipairs(tradelogModule:GetSortedEntries(timeStamp, unit)) do
        local tradeItem = entry.value

        if entry.type == "money" then
            if tradeItem ~= "" then
                local money = AceGUIInstance:Create("Label")
                money:SetText(GetMoneyString(tradeItem, 1000))
                money:SetFullWidth(true)
                widget:AddChild(money)
            end

            local spacer = AceGUIInstance:Create("Label")
            spacer:SetText(" ")
            spacer:SetFullWidth(true)
            spacer:SetHeight(20)
            widget:AddChild(spacer)
        elseif entry.index <= MAX_TRADABLE_ITEMS then
            local label = AceGUIInstance:Create("InteractiveLabel")
            local fontName, _, fontFlags = label.label:GetFont()
            label.label:SetFont(fontName, 12, fontFlags)
            label:SetFullWidth(true)
            label:SetText(tradeItem.name .. " x " .. tostring(tradeItem.quantity))
            label:SetImage(C_Item.GetItemIconByID(tradeItem.id))
            label:SetImageSize(24, 24)
            widget:AddChild(label)

            if hasItemLink(tradeItem.link) then
                self:SetToolTipLink(label, tradeItem.link)
            else
                local _, itemLink = C_Item.GetItemInfo(tradeItem.name)

                if itemLink then
                    self.tradelog.profile[timeStamp][unit][tostring(entry.index)].link = itemLink
                    self:SetToolTipLink(label, itemLink)
                end
            end
        else
            local notTrade = AceGUIInstance:Create("Label")
            local fontName, _, fontFlags = notTrade.label:GetFont()
            notTrade.label:SetFont(fontName, 12, fontFlags)
            notTrade:SetText(TradeFill:SetColor(TF.Loc["NOT_TRADED"], TF.colors.tradelog.notrade))
            notTrade:SetFullWidth(true)
            notTrade:SetHeight(20)
            notTrade.label:SetJustifyH("CENTER")
            widget:AddChild(notTrade)

            local label = AceGUIInstance:Create("InteractiveLabel")
            local labelFont, _, labelFlags = label.label:GetFont()
            label.label:SetFont(labelFont, 12, labelFlags)
            label:SetFullWidth(true)
            label:SetText(tradeItem.name .. " " .. "|cFF00FF00" .. tradeItem.enchantment .. "|r")
            label:SetImage(C_Item.GetItemIconByID(tradeItem.id))
            label:SetImageSize(24, 24)
            widget:AddChild(label)

            if hasItemLink(tradeItem.link) then
                self:SetToolTipLink(label, tradeItem.link)
            else
                local _, itemLink = C_Item.GetItemInfo(tradeItem.name)

                if itemLink then
                    self.tradelog.profile[timeStamp][unit][tostring(entry.index)].link = itemLink
                    self:SetToolTipLink(label, itemLink)
                end
            end
        end
    end
end
