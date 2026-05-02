local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local AceGUI = LibStub("AceGUI-3.0")

-- =========================
-- LOOKUPS (performance)
-- =========================
local classLookup = {}
for _, class in pairs(TF.classes) do
    classLookup[class] = true
end

-- =========================
-- HANDLERS
-- =========================
local handlers = {}

function handlers.A(contentContainer, path)
    if path[2] == "bags" then
        TradeFill:Bags(contentContainer)
    end

    if path[1] == "A" then
        TradeFill:General(contentContainer)
    end
end

function handlers.B(contentContainer, path)
    if path[1] == "B" and not path[2] then
        local group = TradeFill:ContentGroup(AceGUI, contentContainer)
        group:SetLayout("List")

        TradeFill:Allowed(contentContainer, group)
        TradeFill:AddSpacer(AceGUI, group)
        TradeFill:Requirements(contentContainer, group)
        TradeFill:AddSpacer(AceGUI, group)
        TradeFill:Rules(contentContainer, group)

        local frameWidget = contentContainer.frame
        frameWidget:SetClipsChildren(true)
        return
    end

    local map = {
        allowed = function() TradeFill:Allowed(contentContainer) end,
        requirements = function() TradeFill:Requirements(contentContainer) end,
        rules = function() TradeFill:Rules(contentContainer) end,
        players = function() TradeFill:IgnorePlayers(contentContainer) end,
        guilds = function() TradeFill:IgnoreGuilds(contentContainer) end,
    }

    local handler = map[path[2]] or map[path[3]]
    if handler then
        handler()
    end
end

function handlers.C(contentContainer, path)
    if path[2] == "playerOverrides" then
        TradeFill:PlayerOverrides(contentContainer, path[3])
    elseif path[2] and classLookup[path[2]] then
        TradeFill:Stack(contentContainer, path[2])
    elseif path[1] == "C" then
        TradeFill:Item(contentContainer)
    end
end

function handlers.D(contentContainer, path)
    if path[2] then
        TradeFill:TradeLog(contentContainer, path[2])
    end

    TradeFill:TradeLogTotal(contentContainer)
end

-- =========================
-- TREE DATA
-- =========================
function TradeFill:GetTreeData()
    local classChildren = {}
    local tradelogChildren = {}
    local playerOverrideChildren = {}

    for _, class in pairs(TF.classes) do
        classChildren[#classChildren + 1] = {
            value = class,
            text = TradeFill:SetClass(class)
        }
    end

    for playerName in pairs(self:GetPlayerOverrides()) do
        playerOverrideChildren[#playerOverrideChildren + 1] = {
            value = playerName,
            text = self:GetPlayerOverrideDisplayName(playerName),
        }
    end

    table.sort(playerOverrideChildren, function(a, b)
        return a.text < b.text
    end)

    classChildren[#classChildren + 1] = {
        value = "playerOverrides",
        text = TF.Loc["PLAYER_OVERRIDES"],
        children = playerOverrideChildren,
    }

    for timeStamp in pairs(TradeFill.tradelog.profile) do
        tradelogChildren[#tradelogChildren + 1] = {
            value = timeStamp,
            text = date("%d %B, |cFFFFFFFF%H:%M|r", timeStamp)
        }
    end

    table.sort(tradelogChildren, function(a, b)
        return a.value > b.value
    end)

    return {
        {
            value = "A",
            text = TF.Loc["GROUP_GENERAL"],
            children = {
                { value = "bags", text = TF.Loc["BAGS"] },
            },
        },
        {
            value = "B",
            text = TF.Loc["GROUP_TRADING_RULES"],
            children = {
                { value = "players", text = TF.Loc["PLAYERS"] },
                { value = "guilds", text = TF.Loc["GUILDS"] },
            }
        },
        {
            value = "C",
            text = TF.Loc["GROUP_TRADING_SETUP"],
            children = classChildren,
        },
        {
            value = "D",
            text = TF.Loc["GROUP_TRADE_LOG"],
            children = tradelogChildren,
        },
    }
end

-- =========================
-- TREE UI
-- =========================
function TradeFill:CreateTreeGroup(frame)
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Fill")
    frame:AddChild(container)

    local tree = AceGUI:Create("TreeGroup")
    tree:SetTree(TradeFill:GetTreeData())
    tree:SetLayout("Flow")
    tree:EnableButtonTooltips(false)
    container:AddChild(tree)

    local contentContainer = AceGUI:Create("SimpleGroup")
    contentContainer:SetFullWidth(true)
    contentContainer:SetFullHeight(true)
    contentContainer:SetLayout("Flow")
    tree:AddChild(contentContainer)

    -- default view
    TradeFill:General(contentContainer)

    tree:SetCallback("OnGroupSelected", function(_, _, group)
        local path = TradeFill:Split(group, "\001")
        contentContainer:ReleaseChildren()

        local handler = handlers[path[1]]
        if handler then
            handler(contentContainer, path)
        end
    end)

    local groups = {
        ["A"] = true,
        ["B"] = true,
        ["C"] = true,
        ["D"] = true,
    }

    for _, class in pairs(TF.classes) do
        groups["C\001" .. class] = true
    end

    groups["C\001playerOverrides"] = true

    for playerName in pairs(self:GetPlayerOverrides()) do
        groups["C\001playerOverrides\001" .. playerName] = true
    end

    tree:SetStatusTable({
        groups = groups,
        scrollvalue = 0,
        treesizable = false,
    })

    contentContainer:SetUserData("tree", tree)

    frame:SetCallback("OnWidthSet", function(_, width)
        container:SetWidth(width)
    end)

    frame:SetCallback("OnHeightSet", function(_, height)
        container:SetHeight(height)
    end)

    container.frame:SetPoint("TOPLEFT", 0, 0)
    container.frame:SetPoint("BOTTOMRIGHT", 0, 0)
end

function TradeFill:FrameModule()
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(addonName)
    frame:SetWidth(800)
    frame:SetHeight(600)
    frame:SetLayout("Fill")
    frame.frame:SetFrameStrata("DIALOG")

    _G["TradeFillFrame"] = frame.frame
    tinsert(UISpecialFrames, "TradeFillFrame")

    return frame
end

-- =========================
-- OPEN / CLOSE
-- =========================
function TradeFill:Open()
    TF.messages = {}

    if SettingsPanel and SettingsPanel:IsShown() then
        HideUIPanel(SettingsPanel)

        if GameMenuFrame then
            HideUIPanel(GameMenuFrame)
        end
    end

    if not TF.frame or not TF.frame:IsVisible() then
        --self:GetAvailableItems()
        TradeFill:GetModule("InventoryManager"):GetAvailableItems()
        TF.frame = TradeFill:FrameModule()
        self:CreateTreeGroup(TF.frame)
    else
        TF.frame:Release()
    end
end
