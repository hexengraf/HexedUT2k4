# HexedUT2k4 - Hexed Unreal Tournament 2004

This is a collection of packages and mutators providing a variety of features and QoL improvements. The following packages are provided:
* HexedUT: main hexed mutator, provides hit sounds, damage numbers, colored death messages, changing hidden game parameters, and more (versioned, server/client package).
* HexedPatches: provides QoL improvements, such as better scaling for fonts, HUDs, and weapons (non-versioned, client-only package).
* HexedUTComp: hexed-compliant version of UTComp, stripped down to eye height algorithms and NewNet weapons (versioned, server/client package). Not thoroughly tested, so it might have some bugs (due to the process of stripping it down to NewNet weapons and eye height algorithms).

## Installation

Download the [latest release](https://github.com/hexengraf/HexedUT2k4/releases/latest) and extract it inside the root directory of your UT2004 installation, merging the `System` directory when asked. You can safely delete the `.uz2` files extracted to the root directory (only useful for download redirection servers).

To enable HexedPatches, open `System/UT2004.ini` and replace the default value of `GUIController` with `HexedPatches.HxGUIController`:
```ini
; GUIController=GUI2K4.UT2K4GUIController
GUIController=HexedPatches.HxGUIController
```
All configuration can be changed through a new tab called "Patches" in the settings.

HexedUT and HexedUTComp provide MutHexedUT and MutUTComp mutators respectively. Enable them in-game or through the command line for your dedicated server. E.g.:
```bash
./ucc-bin server DM-Gestalt?game=XGame.xTeamGame?Mutator=HexedUTv2.MutHexedUT,HexedUTCompv2.MutUTComp ini=Server.ini -nohomedir
```

An in-game menu is provided to configure the mutators. To open it, execute either `mutate HexedMenu` or `mutate HexedUT` (the last one is only available if HexedUT is enabled).
It is recommended to bind this command to a key (e.g. `set input F5 mutate HexedMenu`).

## Features

### HexedPatches

The following QoL improvements are provided:
* Modern resolutions available in the settings menu (3369 only).
* Higher FOV limit in the settings menu (3369 only).
* Player models are no longer cropped in the settings menu (when using a widescreen resolution, 3369 only).
* Better font scaling for higher resolutions (may cause some font cropping/overflow, since some background elements are not properly scaled).
* Small cursor to compensate absurd scaling when using high resolutions (3369 only).
* Correct widescreen scaling for default HUDs (3369 only, weapon FOV allowed in 3374P9).
* A timer to indicate spawn protection duration.
* Persistent custom network speed (applied on every level change).
* Master server selector (either 333network or OpenSpy, 3369 only).
* Enhanced map voting page:
    * On-screen map previews: screenshots, number of players, author and description.
    * Liked/disliked map classification.
    * New column with the recommended minimum/maximum of players.
    * Search bar for each column of the map list.
    * New button to select a random map.
    * Filter by source: any map, official maps or custom maps.
    * Several improvements to font size, line spacing, alignments, backgrounds and colors.

### HexedUT

The following features are provided:
* Hit sounds: pings and pongs to know when you hit someone.
* Damage numbers: pop-up numbers to know how much damage you've dealt.
* Skin highlights: can't see your enemy? Paint him radioactive green.
* Colored death messages: easily identify from which team is the killer and the victim.
* Health leech: part of damage dealt restores health, similar to the Vampire mutator, but with more customization.
* Movement modifiers: change movement speed, jump acceleration, number of jumps, etc.
* Starting values modifiers: add/remove health, shield, number of Assault Rifle grenades, adrenaline, etc.
* Disable specific combos and/or UDamage on maps.

### HexedUTComp

[HexedUTComp](https://github.com/hexengraf/HexedUTComp) is a fork of [WSUTComp](https://github.com/zenakuten/WSUTComp) made to work together with HexedUT and significantly reduce the amount of features.
For the sake of a streamlined building process, releases of HexedUTComp are bundled together with HexedUT here.

The following features are provided:
* New eye height algorithm: fixes where your aim is on uneven terrain (such as ramps).
* NewNet Weapons (a.k.a. enhanced netcode): ping compensation implementation.
* Timed overtime: limit overtime duration.

## Troubleshooting

If you find any bugs, feel free to [open an issue](https://github.com/hexengraf/HexedUT2k4/issues/new/choose).

### The cursor is too small

The small cursor should be an adequate size for the most commonly used resolutions nowadays, but if you think it is too small, disable it in the Patches tab.

### Fonts are too big or too small

Font size is automatically determined based on the current resolution.
You can override the font size in the Patches tab (a restart is required). Try different values (between 0 and 6) to find the one that suites your needs.

### HUD options are grayed out

You have foxWSFix enabled. In order to use HexedPatches's HUDs, you need to disable foxWSFix.
Restore all `InputClass` values in `System/User.ini` to the default value:
```ini
InputClass=Class'Engine.PlayerInput'
```

### Can't access HexedUT's Server tab

You need to log-in as administrator first. Open the in-game terminal and execute:
```
adminlogin YOUR_ADMIN_PASSWORD
```
