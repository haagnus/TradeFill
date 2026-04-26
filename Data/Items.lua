local addonName, TF = ...

TF.items = {
    profile = {
        item = {
                ["*"] = {
                    id = 0,
                    name = "",
                    link = "",
                    quality = 0,
                    level = 0,
                    stack = 0,
                    texture = 0,
                    limit = 0,
                },
            },

        groups = {
            main = {
                stack = {
                    ["*"] = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0 },
                },
                size = {
                    ["*"] = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0 },
                },
            },

            ungrouped = {
                stack = {
                    ["*"] = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0 },
                },
                size = {
                    ["*"] = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0 },
                },
            },

            party = {
                stack = {
                    ["*"] = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0 },
                },
                size = {
                    ["*"] = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0 },
                },
            },

            raid = {
                stack = {
                    ["*"] = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0 },
                },
                size = {
                    ["*"] = { ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0, ["5"] = 0, ["6"] = 0 },
                },
            },
        },

        rank = {
            ["*"] = {
                ["1"] = false,
                ["2"] = false,
                ["3"] = false,
                ["4"] = false,
                ["5"] = false,
                ["6"] = false,
            },
        },

        settings = {
            trade = {
                ungrouped = false,
                party = true,
                raid = true,
                auto = true,
                refresh = true,
            },

            filter = {
                guild = false,
                required = false,
                level = false,
                master = true,
                lock = true,
                clear = true,
                guilds = "",
                players = "",
            },

            ui = {
                show = true,
                status = false,
                button = false,
            },

            minimap = {
                hide = false,
            },

            bags = {
                ["0"] = true,
                ["1"] = false,
                ["2"] = false,
                ["3"] = false,
                ["4"] = false,
            }
        },
    }
}
