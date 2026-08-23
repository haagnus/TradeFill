local addonName, TF = ...

TF.tradelog = {
    profile = {
        ["*"] = {
            player = "",
            tradePlayer = {
                money = "",
                ["*"] = {
                    ["*"] = {
                        id = 0,
                        name = "",
                        link = "",
                        texture = 0,
                        quantity = 0,
                        enchantment = "",
                    },
                },
            },
            target = "",
            tradeTarget = {
                money = "",
                ["*"] = {
                    ["*"] = {
                        id = 0,
                        name = "",
                        link = "",
                        texture = 0,
                        quantity = 0,
                        enchantment = "",
                    },
                },
            },
        },
    },
}
