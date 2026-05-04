# TradeFill 2.0.2

TradeFill is a World of Warcraft addon that automatically fills the trade window with selected items when your configured trade rules are met. It is designed for players who regularly trade the same items, such as conjured food, water, healthstones, lockboxes, consumables, or other stackable items.

The addon also keeps a trade log, supports per-group trade setups, and adds helpful controls directly to the trade window.

## Features

- Automatically fills trade slots with configured items.
- Configure different stack counts and stack sizes for:
  - Ungrouped players
  - Party members
  - Raid members
- Save player-specific trade overrides for custom stack counts and stack sizes.
- Use saved player overrides automatically on future trades.
- Choose who can trigger autofill.
- Add requirements such as guild membership or required player level.
- Ignore specific players or guilds.
- Match the correct spell rank for class-created items where supported.
- Limit repeated trades with the same player.
- Open selected bags while trading and close them when the trade ends.
- Show trade buttons and a trading status panel in the trade window.
- Track completed trades in a trade log.
- Optional minimap button for quick access.

## What's New in 2.0.2

- Added player-specific trade overrides.
- Added a trade-window Save button for storing the current trade as an override for that player.
- Added a Player Overrides settings page to view, edit, and delete saved overrides.
- Added Trade Anyway support so saved override items can still be traded even when they are not currently selected in Trading Setup.
- Improved automatic filling with a queued retry flow for more reliable stack placement.
- Updated the addon icon, ignored player/guild colors, tab icons, localization, saved data defaults, and TOC file lists.

## Supported Game Versions

TradeFill includes TOC files for multiple WoW clients:

- Vanilla / Classic Era
- The Burning Crusade Classic
- Wrath of the Lich King Classic
- Cataclysm Classic
- Mists of Pandaria Classic
- Mainline / Retail

## Installation

1. Download or clone this repository.
2. Place the `TradeFill` folder in your World of Warcraft AddOns directory.

For Classic Era, for example:

```text
World of Warcraft\_classic_era_\Interface\AddOns\TradeFill
```

For other clients, use that client's `Interface\AddOns` folder.

3. Restart the game or run `/reload`.
4. Enable `TradeFill` from the in-game AddOns menu.

## Usage

Open the TradeFill settings with:

```text
/tf
```

You can also open the settings from the minimap button or from the game's addon options panel.

### Player Overrides

Player overrides let you save custom trade amounts for individual players. During a trade, adjust the items in the trade window to the amount you want for that player, then click `Save` in the trade window. TradeFill will use that saved setup automatically the next time you trade with the same player.

Saved overrides can be edited or deleted from `Trading Setup` > `Player Overrides`. If an override contains an item that is no longer selected in `Trading Setup`, enable `Trade Anyway` for that item if you still want TradeFill to place it during that player's trades.

### Slash Commands

```text
/tf          Open or close the TradeFill settings window
/tf on       Enable autofill
/tf off      Disable autofill
/tf limit    Reset trade limits
```

## Configuration Overview

TradeFill's settings window is organized into these sections:

- `General`: Toggle autofill and hide optional UI elements.
- `Bag Settings`: Choose which bags open while trading.
- `Trading Rules`: Configure allowed players, requirements, special rules, ignored players, and ignored guilds.
- `Trading Setup`: Select trade items and stack settings for each class/group setup.
- `Player Overrides`: Review, edit, or delete saved player-specific trade amounts.
- `Trade Log`: Review recorded trade history.

## Notes

- For spell-rank matching, make sure all relevant spell ranks are visible in your spellbook.
- Trade limits are stored per player and can be reset with `/tf limit`.
- Addon settings are saved in `TradeFillDB`, `TradeFillHistoryDB`, and `TradeFillLimitDB`.

## Project Structure

```text
Core/       Addon bootstrap, saved variable setup, shared actions, state, and utilities
Data/       Default data, classes, spell ranks, item setup, limits, and trade log data
Services/   Reusable player and limit helpers used by rules and modules
Rules/      Trade eligibility and item validation rules
Modules/    Trade flow, inventory scanning, minimap integration, and trade-window UI
UI/         AceGUI settings window, shared UI helpers, and settings screens
Locales/    Localization files
Images/     Addon icon textures
Libs/       Bundled addon libraries
```

## Dependencies

TradeFill bundles the libraries it needs in `Libs/`, including Ace3, LibDataBroker-1.1, and LibDBIcon-1.0.

## Author

Mafkees - Pyrewood Village


## Contact

Discord: haagnus
