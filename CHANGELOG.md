# Changelog

## v3.2 - 2025-08-18

Fixed crashes on first installation:
- ConcentrationRecharge.lua:228: attempt to index global 'ConcentrationRechargeSettings'

## v3.1 - 2025-08-08

- Upgraded ToC to 11.2.0

## v3.0 - 2025-06-29

- Concentration cooldown can now be updated during crafting - With the toggle option in Settings
- Fixed glow effects in Professions (K) page

## v2.0 - 2025-06-18

- Upgraded the glow effect to the new Combat Assist style and fixed crash:
    - ConcentrationRecharge.lua:57: CreateFrame(): Couldn't find inherited node "ActionBarButtonSpellActivationAlert"
- Added Russian language support

## v1.4.0 - 2025-06-17

- Upgraded ToC to 11.1.7
- Updated add icon

## v1.3.1 - 2025-04-30

### Fix

- Exiting vehicle no longer triggers cooldown glow for disabled spells

## v1.3.0 - 2025-04-29

- Now the cooldown glow effect visibility can be toggled in addon settings
- Hide glow and cooldown swipe UI effects during combat to reduce performance impact

## v1.2.0 - 2025-04-23

- Upgraded ToC to 11.1.5
- The tooltip now is visible only when CTRL is pressed - Other modifier key will not trigger the display

## v1.1.0 - 2025-04-17

- Reduced performance impact: release all related resources when button is hided.
- Added support to predict offline characters' concentration.
- Added chat command "/cr debug" to toggle debugging mode.

## v1.0.2 - 2025-04-15

### Fix

- Taint errors: Interface action failed because of an AddOn

## v1.0.1 - 2025-04-14

### Fix

- Now Concentration is not displaying decimal places.

## v1.0.0 - 2025-04-14

### First Release

Show Concentration recharge status directly on profession spell icons and tooltips.
