# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ConcentrationRecharge is a World of Warcraft addon that displays Concentration recharge status directly on profession spell icons and tooltips. It eliminates the need to open the Profession Book to monitor Concentration regeneration across multiple characters.

## Architecture

This is a World of Warcraft addon written in Lua following the standard WoW addon structure:

### Core Components

- **ConcentrationRecharge.lua** - Main addon file containing the core logic, UI overlays, tooltip integration, and event handlers
- **Character.lua** - Character data model and Concentration class for tracking profession concentration values
- **CharacterStore.lua** - Multi-character data persistence and sorting system
- **Settings.lua** - Custom settings system with UI panel and callback management
- **Util.lua** - Utility functions including debug logging, profession helpers, and UI formatting

### File Structure

```
ConcentrationRecharge.toc - Addon manifest with metadata and file load order
Locales/ - Internationalization strings for multiple languages
Embeds.xml - External library dependencies (currently minimal)
```

### Key Technical Details

1. **Concentration Tracking**: Uses `C_TradeSkillUI.GetConcentrationCurrencyID()` and `C_CurrencyInfo.GetCurrencyInfo()` to track concentration values across supported professions
2. **UI Integration**: Creates cooldown overlays on action bar buttons using `ConcentrationCooldownMixin` and integrates with profession book buttons
3. **Tooltip Enhancement**: Uses `TooltipDataProcessor.AddTooltipPostCall()` to add concentration information to spell tooltips
4. **Multi-Character Support**: Persists data via `ConcentrationRechargeDB` saved variable for warband-wide tracking

### Supported Professions

The addon supports these professions (defined in `Character.lua` skillLines):
- Alchemy (171)
- Blacksmithing (164) 
- Enchanting (333)
- Engineering (202)
- Inscription (773)
- Jewelcrafting (755)
- Leatherworking (165)
- Tailoring (197)

## Development Notes

- Uses WoW API version 120001 (The War Within)
- Concentration recharge rate: 250 per day (defined as `CONCENTRATION_RECHARGE_RATE_IN_SECONDS`)
- Maximum concentration: 1000 points
- Debug mode available via `/cr debug` command
- Settings currently use default values (custom settings system needed)

## Dependencies

External libraries are managed via .pkgmeta for packaging:
- WeeklyRewards library (v1.8.1)

## Development Notes

- Custom settings system implemented in Settings.lua (replaces Dashi dependency)
- Settings UI provides glow effect toggles and cooldown update preferences
- Compatible with both modern (10.0+) and legacy WoW interface systems

## Testing

No automated test framework is present. Testing requires loading the addon in-game with appropriate profession characters.