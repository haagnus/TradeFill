local L = LibStub("AceLocale-3.0"):NewLocale("TradeFill", "enUS", true)
if not L then return end

L["VERSION"] = "%s Version %s Loaded"

L["SIGNATURE"] = "%s"

L["TEXT_ENABLED"] = "Enabled"
L["TEXT_DISABLED"] = "Disabled"

L["TEXT_COMPLETE"] = "Complete"
L["TEXT_CANCELED"] = "Canceled"

L["TEXT_TO"] = "to"
L["TEXT_OPEN"] = "Open"
L["TEXT_CLOSE"] = "Close"
L["TEXT_THE_OPTION_MENU"] = "the options menu"

L["TEXT_SHIFT"] = "Shift"
L["TEXT_PLUS"] = "+"
L["TEXT_TO_CLEAR"] = "to clear"

L["TEXT_CLICK"] = "Click"
L["TEXT_RIGHT_CLICK"] = "Right-Click"

L["OPTION_NONE"] = "None"
L["OPTION_USE_MAIN"] = "Use Main"

--------------------------------------------------------
-- General
--------------------------------------------------------
L["GROUP_GENERAL"] = "General"

L["AUTOFILL"] = "Autofill"
L["AUTOFILL_DESC"] = [=[Automatically fills the trade window with items when the appropriate trade rules are met

Enable/Disable
/tf on
/tf off
]=]

L["LABEL_GENERAL"] = "Hide UI Elements"
L["LABEL_GENERAL_DESC"] = "Choose which UI elements you want to hide"

L["TRADING_BUTTON"] = "Trade Buttons Panel"
L["TRADING_BUTTON_DESC"] = "Hides the trade buttons panel in the trade window"

L["TRADING_STATUS"] = "Trade Status Panel"
L["TRADING_STATUS_DESC"] = "Hides the status panel below the trade window"

L["MINIMAP"] = "Disable Minimap Icon"
L["MINIMAP_DESC"] = "Hides the minimap icon"

L["OLD_ICON"] = "Use Old Icon"
L["OLD_ICON_DESC"] = "Use the old cow icons for the %s enabled and disabled states"

--------------------------------------------------------
-- Open Bags
--------------------------------------------------------
L["BAGS"] = "Bag Settings"

L["LABEL_BAGS_DESC"] = "Open %s when trading"

L["INFO_BAGS"] = "Open bags in the trade window"
L["INFO_BAGS_DESC"] = "Select which bags should be opened when the trade window is active"

--------------------------------------------------------
-- Trading Rules
--------------------------------------------------------
L["GROUP_TRADING_RULES"] = "Trading Rules"

--------------------------------------------------------
-- Allowed Players
--------------------------------------------------------
L["TARGET"] = "Who to Trade With"
L["TARGET_DESC"] = [=[Choose which players can trigger %s

Autofill will only activate when trading with:
    - %s
    - %s
    - %s
]=]

L["UNGROUPED"] = "Ungrouped Players"
L["UNGROUPED_DESC"] = "Autofill with anyone when you're not in a group"
L["PARTY"] = "Party Members"
L["PARTY_DESC"] = "Autofill with party members"
L["RAID"] = "Raid Members"
L["RAID_DESC"] = "Autofill with raid members"

--------------------------------------------------------
-- Requirements
--------------------------------------------------------
L["REQUIREMENTS"] = "Additional Requirements"
L["REQUIREMENTS_DESC"] = [=[Additional trade rules that must be met before %s can activate

All selected requirements must be satisfied:
    - %s
    - %s
    - %s
]=]

L["GUILD"] = "Guild Members"
L["GUILD_DESC"] = "Only with guild members"
L["REQUIRED"] = "Required Level"
L["REQUIRED_DESC"] = "Only when the player has the required item level"
L["LEVEL"] = "Level %i"
L["LEVEL_DESC"] = "Only when the player is level cap"

--------------------------------------------------------
-- Special Rules
--------------------------------------------------------
L["RULES"] = "Optional Trade Rules"
L["RULES_DESC"] = [=[
Regardless of %s, when trading with a %s, locked boxes are placed in the "Will not be traded" slot.
    - %s

Clears the trade window when another player initiates a trade with you.
    - %s

Prevents %s when you are the loot master.
    - %s
]=]

L["LOCKBOX"] = "Locked Boxes"
L["LOCKBOX_DESC"] = "Place locked boxes in the right slot with %s"
L["CLEAR"] = "Clear Trade"
L["CLEAR_DESC"] = "Clears the trade window when players try to trade items to you"
L["MASTER"] = "Loot Master"
L["MASTER_DESC"] = "Disable autofill when you are the master looter"

--------------------------------------------------------
-- Ignore
--------------------------------------------------------

--------------------------------------------------------
-- Players
--------------------------------------------------------
L["PLAYERS"] = "Ignored Players"

L["INPUT_TEXTAREA_PLAYERS"] = "Player names"
L["INPUT_TEXTAREA_PLAYERS_USAGE"] = "Enter player names (letters only)"

L["INFO_PLAYERS"] = "Ignored players will not trigger autofill"
L["INFO_PLAYERS_DESC"] = "Players listed here will be ignored by %s"

--------------------------------------------------------
-- Guilds
--------------------------------------------------------
L["GUILDS"] = "Ignored Guilds"

L["INPUT_TEXTAREA_GUILDS"] = "Guild names"
L["INPUT_TEXTAREA_GUILDS_USAGE"] = "Enter guild names (letters only)"

L["INFO_GUILDS"] = "Ignored guilds will not trigger autofill"
L["INFO_GUILDS_DESC"] = "Players in these guilds will be ignored by %s"

--------------------------------------------------------
-- Trading Setup
--------------------------------------------------------
L["GROUP_TRADING_SETUP"] = "Trading Setup"
L["PLAYER_OVERRIDES"] = "Player Overrides"
L["INFO_PLAYER_OVERRIDES"] = "Saved player-specific trade amounts: %s"
L["INFO_PLAYER_OVERRIDES_DESC"] = "Player overrides let you save custom trade amounts for a specific player. When you trade a different stack size or amount than the normal group setup, a button appears in the trade window so you can save those settings. The saved override will be used automatically the next time you trade with that player"
L["PLAYER_OVERRIDES_EMPTY"] = "No player overrides saved"
L["PLAYER_OVERRIDES_SUMMARY"] = "%d players have saved overrides. Select a player in the menu to edit their overrides."
L["PLAYER_OVERRIDE_ITEM_ID"] = "Item ID: %s"
L["PLAYER_OVERRIDE_NOT_SELECTED"] = "Not selected"
L["PLAYER_OVERRIDE_NOT_SELECTED_DESC"] = "Saved override. This item is not currently selected in Trade Settings, so it will not be traded unless Trade anyway is enabled."
L["PLAYER_OVERRIDE_TRADE_ANYWAY"] = "Trade Anyway"
L["PLAYER_OVERRIDE_TRADE_ANYWAY_DESC"] = "Trade this saved override for this player even when the item is not selected in Trade Settings. Uses an empty trade slot during the current trade."
L["PLAYER_OVERRIDE_TRADE_ANYWAY_CONFIGURED_DESC"] = "This item is already selected in Trade Settings, so the override can trade normally. Keep this enabled if you want it to continue trading even when the item is later removed from Trade Settings"

--------------------------------------------------------
-- Items
--------------------------------------------------------
L["ITEM"] = "Item"

L["SHOW"] = "Show Only Full Stacks"
L["SHOW_DESC"] = "Hides stacks that are not full in the dropdown menu"

L["SELECT_ITEMS_DESC"] = "Select an item to trade"

L["APPROPRIATE_RANK"] = "Match Spell Rank"
L["APPROPRIATE_RANK_DESC"] = [=[Enabling this option ensures that %s and %s always trade the correct item level

%s: All Spell Ranks
]=]

--------------------------------------------------------
-- Limit
--------------------------------------------------------
L["LIMIT"] = "Limit"
L["INFO_LIMIT"] = "Set how many times each selected item can be traded to the same player before autofill stops"
L["INFO_LIMIT_DESC"] = "Trade limits are tracked per player and can be reset with the Refresh Limit option or the /tf limit command"

L["REFRESH_LIMIT"] = "Refresh Limit"
L["REFRESH_LIMIT_DESC"] = [=[Resets the %s limit at the start of each new session

Reset
/tf limit
]=]

L["SELECT_LIMIT_DESC"] = "Select the amount of %s trades you want to make with the same player"

--------------------------------------------------------
-- Stack
--------------------------------------------------------
L["STACK"] = "Stack"

L["TAB_MAIN"] = "Main"
L["TAB_UNGROUPED"] = "Ungrouped Players"
L["TAB_PARTY"] = "Party Members"
L["TAB_RAID"] = "Raid Members"


L["LABEL_STACK"] = "Stack"
L["INFO_STACK"] = "Set the amount you want to trade with %s"
L["INFO_STACK_DESC"] = [=[Use %s to trade the same amount in every situation
    - %s

Set different amounts for specific group types to override %s
    - %s
    - %s
    - %s
]=]

L["LABEL_SIZE"] = "Size"
L["SELECT_STACK_NUMBER_DESC"] = "Select the number of stacks"
L["SELECT_STACK_SIZE_DESC"] = "Select the stack size"

--------------------------------------------------------
-- Trade Log
--------------------------------------------------------
L["GROUP_TRADE_LOG"] = "Trade Log"

L["TAB_TRADED"] = "Traded"
L["TAB_RECEIVED"] = "Received"

L["BUTTON_YES"] = "Yes"
L["BUTTON_CANCEL"] = "Cancel"
L["BUTTON_RESET"] = "Reset"
L["BUTTON_RESET_DESC"] = [=[Reset all stack and size values for:
    - %s
    - %s
    - %s
]=]
L["BUTTON_DELETE_DAY"] = "Delete"
L["BUTTON_DELETE"] = "Delete"
L["BUTTON_DELETE_PLAYER_OVERRIDE"] = "Delete player override"
L["BUTTON_DELETE_ALL_PLAYER_OVERRIDES"] = "Delete all player overrides"
L["BUTTON_DELETE_ALL_PLAYER_OVERRIDES_DESC"] = "Remove all saved player override data"
L["BUTTON_DELETE_ALL_PLAYER_OVERRIDES_CONFIRM"] = "Are you sure you want to delete all player override data?"
L["BUTTON_DELETE_ALL"] = "Delete trade log"
L["BUTTON_DELETE_ALL_CONFIRM"] = "Are you sure you want to delete all tradelog entries"
L["BUTTON_REMOVE_TRADE"] = "Removed this trade log entry"
L["BUTTON_REMOVE_ALL"] = "Removed all trade log entries"

L["NOT_TRADED"] = "Not traded below"

--------------------------------------------------------
-- Minimap
--------------------------------------------------------
L["MINIMAP_RIGHT_CLICK_ENABLE"] = "%s %s %s %s"
L["MINIMAP_RIGHT_CLICK_DISABLE"] = "%s %s %s %s"

L["MINIMAP_LEFT_CLICK_OPEN"] = "%s %s %s %s"
L["MINIMAP_LEFT_CLICK_CLOSE"] = "%s %s %s %s"

L["MINIMAP_SHIFT_CLICK_REFRESH"] = "%s %s %s %s %s %s"

--------------------------------------------------------
-- Tradewindow
--------------------------------------------------------
L["TRADING_STATUS_PANEL"] = "Trade Status Panel"
L["TRADING_STATUS_PANEL_MESSAGE"] = "Cannot AutoFill due to the following reasons:\n"

L["BUTTON_DISABLE"] = "No stack number assigned"
L["BUTTON_TOOLTIP"] = [=[
%s to add one item
%s to remove one item
]=]

L["CREATE_NEW_STACK"] = "Create a new stack"

L["BUTTON_CLEAR"] = "Clear"
L["BUTTON_PLAYER_OVERRIDE"] = "Save"
L["BUTTON_PLAYER_OVERRIDE_DESC"] = "Save this trade for this player. Edit it in Player Overrides"
L["BUTTON_PLAYER_OVERRIDE_DISABLED"] = "Change the trade amount to save a player override"
L["BUTTON_SETTING"] = "Settings"
L["BUTTON_SETTING_DESC"] = "Open the addon to set your preference"

L["MESSAGE_ADDON_ON"] = "%s %s is %s"
L["MESSAGE_ADDON_OFF"] = "%s %s is %s"
L["MESSAGE_TRADE"] = "Trading %s with %s"
L["MESSAGE_SOULBOUND"] = "Item %s is soulbound and can't be traded"
L["MESSAGE_CLEAR"] = "Cleared trade window because %s tried to trade items"
L["MESSAGE_NO_EMPTY_SLOTS"] = "No empty slot available to split %s x %i"
L["MESSAGE_AUTOFILL"] = "%s is %s"
L["MESSAGE_FULL"] = "Trade window is full"
L["MESSAGE_NO_STACK"] = "Out of stock %s x %i"
L["MESSAGE_STACK_UNGROUPED"] = "No stack number assigned for %s as %s"
L["MESSAGE_STACK_PARTY"] = "No stack number assigned for %s as %s"
L["MESSAGE_STACK_RAID"] = "No stack number assigned for %s as %s"
L["MESSAGE_ALLOWED_NON"] =  "No allowed player type selected:\n%s\n%s\n%s"
L["MESSAGE_ALLOWED_UNGROUPED"] = "%s is not active"
L["MESSAGE_ALLOWED_PARTY"] = "%s is not active"
L["MESSAGE_ALLOWED_RAID"] = "%s is not active"
L["MESSAGE_REQUIREMENTS_GUILD"] = "%s is active and %s is not a guild member"
L["MESSAGE_REQUIREMENTS_REQUIRED"] = "%s is active and you need to be level %d for %s"
L["MESSAGE_REQUIREMENTS_MAX_LEVEL"] = "%s is active and %s is not high enough level"
L["MESSAGE_RULES_MASTER_LOOTER"] = "%s is active and you're the loot master"
L["MESSAGE_IGNORE_PLAYERS"] = "%s is on the ignored players list"
L["MESSAGE_IGNORE_GUILDS"] = "Players from %s are on the ignored list"
L["MESSAGE_LIMIT"] = "%s has reached the limit of %s"
L["MESSAGE_RESET_LIMIT"] = "%s %s has been refreshed"
L["MESSAGE_PLAYER_OVERRIDE_SAVED"] = "Saved player override for %s"
L["MESSAGE_PLAYER_OVERRIDE_USED"] = "Using player override for %s"
L["MESSAGE_PLAYER_OVERRIDE_TRADE_ANYWAY_DISABLED"] = "%s has Player Override settings but %s is not selected"
L["MESSAGE_PLAYER_OVERRIDE_NO_EMPTY_SLOT"] = "A Trade anyway player override was skipped because all Trade Settings slots are already selected"
L["MESSAGE_MIGRATION_COMPLETE"] = "%s Your old stack settings were moved to %s. You can keep using Main, or set custom stack amounts and sizes for %s, %s, and %s"
L["MESSAGE_MIGRATION_BAGS"] = "%s Bags can now open and close automatically with the trade window"
