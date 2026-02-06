# v2.3

Another update focused on the map voting page.

HexedPatches changes:
* Added option to classify maps as liked/disliked.
* Fixed bug causing votes to not appear if the map voting page was closed when the vote was submitted.
* Several changes to Look and Feel.
* Converted "Seq" column to a compact column to sort by last played.

# v2.2

This update focus on further improving the map voting page.

HexedPatches changes:
* Added map description to the map preview.
* Added new column with the recommended minimum/maximum of players.
* Added search bar for each column of the map list.
* Added new button to select a random map.
* Added option to filter by source: any map, official maps or custom maps.
* Several improvements to font size, line spacing, alignments, backgrounds and colors.
* Made the map voting page persistent, allowing more intuitive behavior (e.g. sort column is remembered).

# v2.1

Very small update.

HexedPatches changes:
* Removed bold from some of the small fonts.
* Added an embedded map preview in the map voting page.

# v2.0

Second release of HexedUT2k4!

A new numbering system is being adopted for the releases: **vX.Y**, where:
* X is the highest version number of the versioned packages (HexedSRC, HexedUT, HexedUTComp).
* Y is used to create releases that only affect non-versioned packages (HexedPatches).

Some packages have been renamed/restructured:
* HexedGUI is now called HexedPatches.
* Some generic classes from HexedUT were moved to a new package, HexedSRC.
* HexedUT and HexedUTComp require HexedSRC, but now are independent between themselves.

HexedPatches changes:
* Added modern resolutions in the settings menu.
* Increased the FOV limit in the settings menu.
* Fixed player models being cropped in the settings menu (when using a widescreen resolution).
* Added new tab in settings for all HexedPatches options (called "Patches").
* Added option to scale fonts based on screen height instead of width.
* Added HUD replacements to fix widescreen scaling.
* Added a timer to indicate spawn protection duration (requires HUD replacements).
* Added option to validate KeepAliveTimer to make sure it has the default value (0.2).
* Added option to define a persistent custom network speed (applied on every level change).
* Added a master server selector (either 333network or OpenSpy).

HexedSRC changes:
* Initial release with base classes to create mutators, add an in-game menu, and manage sounds.

HexedUT changes:
* Added colored death messages.
* Added health leech options.
* Added movement modifiers.
* Added starting values modifiers.
* Added options to disable specific combos and/or UDamage on maps.

HexedUTComp changes:
* Removed starting health, shield, and grenades options.
* Removed colored death messages.
* Removed option to disable UDamage on maps.
* Fixed some None accesses.

# Version 1

Initial release of HexedUT, HexedGUI, and HexedUTComp.

HexedUT and HexedUTComp can be configured via `mutate HexedUT` in game.

HexedUT features:
* Hit sounds
* Damage numbers

HexedGUI features:
* New font scaling algorithm providing bigger font sizes for high resolutions (2K and 4K)
* Option to override resolution used by the font scaling algorithm
* New small cursor pointer (low pixel count, since the engine always scales with ScreenWidth/800)

HexedUTComp features:
* Enhanced netcode (NewNet weapons)
* New EyeHeight algorithm
  * View smoothing
* Disable double damage
* Number of Assault Rifle's grenades on spawn
* Colored death messages
* Timed overtime
* Starting health
* Starting shield
* UTComp's hit sound added to HexedUT's sound list
