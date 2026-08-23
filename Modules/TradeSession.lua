local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

local TradeSession = TradeFill:NewModule("TradeSession")

function TradeSession:Initialize()
    TF:ResetState()

    local playerService = TradeFill:GetModule("PlayerService")

    TF.state.target = playerService:GetTargetContext()

    local mode = playerService:GetGroupType()
    local db = TradeFill.db.profile
    local classFile = TF.state.target.class.file

    TF.state.active = true
    TF.state.groupType = mode

    db.groups.main = db.groups.main or { stack = {}, size = {} }
    db.groups.main.stack = db.groups.main.stack or {}
    db.groups.main.size = db.groups.main.size or {}
    db.groups.main.stack[classFile] = db.groups.main.stack[classFile] or {}
    db.groups.main.size[classFile] = db.groups.main.size[classFile] or {}
    db.playerOverrides = db.playerOverrides or {}

    TF.item = db.item
    TF.stacks = db.groups[mode].stack[classFile]
    TF.size = db.groups[mode].size[classFile]
    TF.mainStacks = db.groups.main.stack[classFile]
    TF.mainSize = db.groups.main.size[classFile]
    TF.settings = db.settings
    TF.limit = TradeFill.limit

    TradeFill:PrepareTradeAnywayPlayerOverrides()
end
