local addonName, TF = ...
local TradeFill = LibStub("AceAddon-3.0"):GetAddon(addonName)

function TradeFill:CreateCheckBox(parent, config)
    local check = LibStub("AceGUI-3.0"):Create("CheckBox")

    check:SetLabel(config.label)
    check:SetValue(config.get())
    check:SetWidth(config.width or 180)
    check:SetHeight(config.height or 24)

    if config.tooltip then
        self:SetToolTipText(check, config.tooltip)
    end

    check:SetCallback("OnValueChanged", function(_, _, value)
        config.set(value)

        if config.onChange then
            config.onChange(value)
        end
    end)

    parent:AddChild(check)

    return check
end

function TradeFill:AddSpacer(AceGUI, group)
    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetFullWidth(true)
    group:AddChild(spacer)
end

function TradeFill:SetToolTipLink(widget, link)
    if link then
        widget:SetCallback("OnEnter", function(widget)
            GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR_RIGHT")
            GameTooltip:SetHyperlink(link)
            GameTooltip:Show()
        end)
    else
        widget:SetCallback("OnEnter", function(widget)
            GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR_RIGHT")
            GameTooltip:SetText("None")
            local tooltipName = GameTooltip:GetName()
            local line = _G[tooltipName .. "TextLeft1"]
            if line then
                line:SetTextColor(1, 1, 1)
            end
            GameTooltip:Show()
        end)
    end

    widget:SetCallback("OnLeave", function(widget)
        GameTooltip:Hide()
    end)
end

function TradeFill:SetToolTipText(widget, text)
    widget:SetCallback("OnEnter", function(widget)
        GameTooltip:SetOwner(widget.frame, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:SetText(text, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)

    widget:SetCallback("OnLeave", function(widget)
        GameTooltip:Hide()
    end)
end

function TradeFill:ContentGroup(AceGUI, widget)
    local group = AceGUI:Create("SimpleGroup")
    group:SetFullWidth(true)
    group:SetFullHeight(true)
    group:SetLayout("Flow")
    widget:AddChild(group)

    return group
end

function TradeFill:Group(AceGUI, type, widget)
    local group = AceGUI:Create(type)
    group:SetFullWidth(true)
    group:SetLayout("Flow")
    widget:AddChild(group)

    return group
end

function TradeFill:SetInfoLabel(AceGUI, widget, text, tooltip)
    local label = AceGUI:Create("InteractiveLabel")
    local fontName, _, fontFlags = label.label:GetFont()
    label.label:SetFont(fontName, 12, fontFlags)
    label:SetWidth(500)
    label:SetText(text)
    widget:AddChild(label)

    if tooltip then
        self:SetToolTipText(label, tooltip)
    end
end

function TradeFill:SetInlineInfo(widget, tooltip)
    self:SetToolTipText(widget, tooltip)
end

function TradeFill:ToggleWidget(widget, item)
    local id = item and item.id

    if type(id) == "number" and id > 0 then
        widget:SetDisabled(false)
    else
        widget:SetDisabled(true)
    end
end
