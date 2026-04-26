local addonName, TF = ...

function TF:ResetState()
    self.state = {
        active = false,
        isScanning = false,
        isProcessingBags = false,
        needsQueueProcessing = false,
        isWatchingBags = false,
        manualFillActive = false,
        --bothAccepted = false,
        completed = false,
        groupType = nil,
        target = {
            name = nil,
            guild = nil,
            level = nil,
            class = {
                name = nil,
                file = nil
            },
            faction = nil
        },
        exchange = {
            given = {
                items = {},
                gold = 0
            },
            received = {
                items = {},
                gold = 0
            }
        },
        timestamp = nil
    }
end
