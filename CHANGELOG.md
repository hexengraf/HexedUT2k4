# v6.0

Major changes:
* HexedUTComp is now called HexedNET and only provides the enhanced netcode and the new EyeHeight algorithm.
* The enhanced map vote menu now has its own mutator: HexedVOTE, which can also be enabled with a server actor.

Please check the README for updated information.

New features:
* Map filters (HexedVOTE): create custom map filters that are saved and can be quickly accessed to apply to the map list.
* Map vote menu (hexedVOTE): options to configure custom backgrounds for the lists, map preview banner and chat box.
* HexedMenu is more generic now, displaying configuration from multiple mutators in a single page.
* Partial GUI styles overhaul. The idea is to eventually consolidate everything in customizable themes.

Bugfixes:
* Fixed backspace not working on the map vote menu's chat.
* Fixed HexedNET (HexedUTComp) issues on game types with rounds (e.g. Assault, Onslaught).

# v5.0

No new features, only ironing out bugs that slipped into v4 and restoring HexedSRC as shared resources package.

HexedUT changes:
* Fixed server status and buttons in the configuration menu missing text after a map change.
* Fixed map vote menu's chat not showing new messages after being closed and reopened.
* Fixed spawn protection timer not resetting after changing view target in spectator mode.
* Fixed health leech applying to friendly fire.
* Fixed lingering replication channels after a player disconnects.
* Fixed small memory leak client-side over multiple matches.
* Moved a bunch of generic code to HexedSRC and added it as dependency.

HexedUTComp changes:
* Fixed new eye height algorithm interfering with landing viewshake and unintendedly disabling further viewshakes and weapon bob.
  * Keep in mind: landing viewshake offsets the aim, so you might want to disable it for better aiming.
* Reworked new net weapons to be independent of xPawn replacement.
* Removed unneeded replication channels.
* Fixed lingering replication channels after a player disconnects.
* Swapped HexedUT with HexedSRC as dependency.

# v4.0

This version moves the enhanced map vote menu and the spawn protection timer from HexedPatches to HexedUT, so now you can enable them from the server side.

With this release, HexedUT is now capable of transferring the configuration from a previous version to the current one:
* **Players**: when upgrading to a new version of HexedUT, keep the old version in you system folder to allow HexedUT to automatically copy your configuration to the new version.
* **Server administrators**: when upgrading to a new version of HexedUT, add the previous version to your `ServerPackages` to allow players that don't have it locally installed to automatically copy their configuration to the new version.

HexedUT changes:
* Added enhanced map vote menu and spawn protection timer.
* Added server-side option to disable spawn protection timer.
* Increased the net priority and update frequency of skin highlights to fix desynchronization issues.
* Reworked hit effects configuration variables to allow custom hit sounds and custom fonts.
* Overhauled the options menu, moving server options to a separate menu.

HexedPatches changes:
* Removed enhanced map vote menu and spawn protection timer.
* Reorganized HexedPatches settings into two sections: Fixes and Legacy 3369 Fixes.
* Fully disabled HUD replacements on OldUnreal patched versions.
* Removed validation of netspeed at every level change on OldUnreal patched versions.

# v3.0

First release aiming to be compatible wit OldUnreal patches!

HexedPatches changes:
* Added code to detect OldUnreal patches and disable conflicting changes.
  * HUD replacements are currently allowed on 3374P9 solely as a temporary fix for weapon FOV.
* Map voting: added graphical indicator for the sorting order when sorting by last played.
* Made the spawn protection timer HUD-independent, so it doesn't require HUD replacements anymore.

HexedUT changes:
* Added skin highlights:
  * Set skin colors per team;
  * Use fixed or randomized colors on solo matches;
  * Replace or disable original hit highlights;
* Fixed a bug related to movement modifiers in listen servers.

General changes:
* Merged HexedSRC back into HexedUT. Now there are only 3 packages: HexedPatches, HexedUT and HexedUTComp.
* Cleaned up a lot of GUI code, abandoning some not-generic-enough abstractions.

# v2.3.1

Hotfix for the map voting page:
* Fixed incorrect map being displayed after a player changes their vote.
* Fixed bug preventing mouse scrolling to work with the game type drop list.
* Fixed bug preventing mouse scrolling after clicking on a list header.

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
