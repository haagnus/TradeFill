local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

TF.colors = {
    tradelog = {
        notrade = "ff0000",
    },

    trade = {
        ungrouped = "ffffff",
        party = "66ccff",
        raid = "ff7f00",
        auto = "ffff00",
        complete = "00ff00",
        canceled = "ff0000",
        limit = "ffff00",
        anyway = "40ff40",
    },

    filter = {
        player = "40ff40",
        guild = "40ff40",
        required = "ffff00",
        level = "ffff00",
        lock = "ffff00",
        clear = "ffff00",
        master = "ffff00",
    },

    tab = {
        main = "ffff00",
        ungrouped = "ffffff",
        party = "66ccff",
        raid = "ff7f00",
    },

    addon = {
        signature = "88EEff",
        on = "00ff00",
        off = "ff0000",
        click = "ffff00",
        panel = "ffff00",
        message = "ffffff",
        open = "00ff00",
        close = "ff0000"
    },

    minimap = {
        text = "ffffff",
        open = "00ff00",
        close = "ff0000",
        on = "00ff00",
        off = "ff0000"
    }

}
