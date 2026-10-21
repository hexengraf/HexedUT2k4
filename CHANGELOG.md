# v10.0

This version brings a huge rework of the HexedNET code. The changes listed below are a summary of the "visible" effects of the new code.

HexedUT changes:
* Fixed new/modified skin highlight colors not getting properly saved.
* Implemented support for new player stats:
  * Controlled by the new `bExtraStats` server option.
  * Three new stats implemented: accuracy, max spree, and team kills.
  * Accuracy is an approximation of the total accuracy across all weapons.
  * Max spree is the highest amount of frags without dying.
  * Team kills is the amount of teammates killed (including suicides).
* Added optional Rank stat for the scoreboard:
  * Servers that want to use it need to write their own mutator to populate the Rank field in each `HxPlayerReplicationInfo`.
  * More instructions [here](CONFIGURATION.md#enabling-rank-information-in-the-scoreboard).
* Implemented more customization options for the scoreboards:
  * Show/hide secondary stats, timestamp and shortcut hints.
  * Abbreviate long headings to fit more columns.
  * Choose vertical layout as the default layout to be used when first opening the scoreboard.
  * Control exactly which stats are shown for each game mode.
* Implemented character-specific cropping for portraits in the scoreboard.
  * Cropping for all official characters contributed by 21, much appreciated!
* Improved randomized skin highlights to reduce the occurrence of repeated colors.
* Removed `bHideDisabledFeatures` option (see the new global server option called `StatusVerbosity` for similar functionality).

HexedVOTE changes:
* Fixed map favorites sometimes failing to appear for some maps (due to a racing condition).

HexedNET changes:
* Fixed time conversions so all options are expressed in real milliseconds instead of game milliseconds.
* fixed missing lag compensation for monsters in Invasion.
* Fixed incorrect physics simulation when forwarding projectiles server-side to compensate lag.
  * Bouncing behavior and underwater physics are now properly accounted for.
* Fixed several issues with collision during projectile forwarding.
  * Ever seen bio globs stuck a considerable distance away from the actual surface? No more.
  * There is still an issue left to solve regarding volumes that switch projectiles to zero extent collision.
* Fixed issues caused by interpolation between predicted projectile and authoritative projectile.
  * E.g. duplicated rockets, duplicated explosions, duplicated decals on walls, bio globs entering walls.
* Fixed incorrect forwarding and prediction of seeking rockets and spinning rocket flocks.
* Added missing client-side predicted projectiles for bio rifle's charged shots.
* Added missing client-side predicted projectiles for assault rifle's grenades.
* Added seeded PRNGs to properly synchronize randomization between client and server.
  * Some projectiles have randomization applied, like flak cannon's primary fire and assault rifle's grenades.
  * Original solution from UTComp only applied to flak cannon and could loose synchronization, leading to erratic behavior of the primary fire.
* Added BAS - Boosted Aim Synchronization (sending location + rotation from client to server at the time of shooting) - to all viable weapons.
  * Minigun and link gun's primary fire are not viable due to the way they are programmed.
  * New server option `bBoostedAimSynchronization` to enable/disable BAS.
  * New server option `bForceStartFireRPCs` to control if BAS should force start fire RPCs when holding a fire button (to send fresh BAS information every shot).
  * New server option `bClientSideCollisions` to control if hitscan weapons should send client-side collision detection together with BAS.
  * New server option `CSCTolerance` to specify the maximum acceptable temporal distance to validate client-side collisions, expressed in server ticks.
* Added replication of explosion effects and decals when the projectile hits something during the forwarding.
  * It doesn't show up normally because the projectile is destroyed before it can be replicated to the client.
* Added proper projectile forwarding for shock cores, with rewind capabilities to correctly detect shock combos.
* Replaced ping measurement with new method that gives a more accurate value.
  * Previous version was heavily influenced by the tick rate of the server.
  * The new version isolates the actual latency of the network, (mostly) removing the delays caused by tick rate and FPS.
  * Removed `PingFrequency` and `PingSmoothing` options as a side effect.
  * Replaced `MaxPingFrequency` server option with `PingFrequency`: now the server controls the ping frequency for all players.
* Increased the default value of `ProjectileCompensationLimit` to 125.
  * This option is no longer experimental, all projectiles should behave correctly regardless of the chosen value.
  * Keep in mind that higher values increase how far the projectile will appear from the shooter's position from the POV of other players.
  * High values can lead to players being hit by "invisible" projectiles at (semi-)close quarters.
  * A cap based on distance (calculated per projectile type) might be explored in the future as an alternative to this time limit.
* Renamed `PingCompensationLimit` to `LagCompensationLimit` and decreased default value to 300.
* Renamed `bEnhancedNetcode` to `bLagCompensation`.

General changes:
* Added support for global server options shared between all mutators.
  * They should be specified in a new section `[HexedSRCv10.HxMutator]` when editing the `HexedMutators.ini` file directly.
* Reworked the running notification as a non-intrusive pop-up instead of a GUI window.
* Added new global server option to control when the running notification should be shown (`NotifyRunning`):
  * You can choose between never, per version (default, only shows once per new version), per session (when the player first joins the server), or always.
* Added new global server option to control the maximum duration of notifications (`MaxNotifyDuration`):
  * Change it if you want to force the duration of the running notification to be lower than the default ~4.75 seconds.
* Added new global server option to control how much information is shown in the server status (`StatusVerbosity`):
  * Default is medium (which only hides some properties that usually doesn't make sense to show).
* Restructured how the internals for handling property replication work, reducing the amount of replication channels required per mutator.
* Added more status information to the configuration menu.
* Moved HexedPatches to a separate [repository](https://github.com/hexengraf/HexedUT2k4-Patches).

# v9.0 hotfix 2

If you only play offline, you don't need to upgrade from v9 to this hotfix version. Dedicated servers using HexedUT are highly encourage to upgrade!

Fixed an issue causing interactions to bleed out of the server using HexedUT, which can trip other servers using AntiTCC.

In other words: a player joins a server with HexedUT, everything works, later they join a different server without HexedUT and with AntiTCC, they get kicked out. The issue can be circumvented by closing the game and reopening it before joining the server with AntiTCC, but this hotfix version solves the root cause.

The git tag is pointing to the wrong commit, since this release was compiled based on the v9.0hf tag + a few lines of code added to fix the bleeding interactions.

# v9.0 hotfix

If you only play offline, you don't need to upgrade from v9 to this hotfix version. Servers using HexedNET are highly encourage to upgrade!

HexedNET hotfix:
* Fixed `ProjectileCompensationLimit` not properly initialized in the server, causing rubberbanding in projectiles depending the amount of ping.

Changes meant for v10 that ended up included here:
* Fixed weak view smoothing causing jitter when playing on dedicated servers.
* Added a new view smoothing option: moderate.
  * Weak view smoothing disables view smoothing when walking on any surfaces with more than ~8 degrees of inclination.
  * Moderate view smoothing disables view smoothing when walking on any surfaces with more than ~16 degrees of inclination.
* Improved HexedNET's snapshot search algorithm to use binary search instead of a linear search.
* Moved first run variables to `HexedCache.ini` to keep `User.ini` clean and tidy.

# v9.0

HexedUT changes:
* **Enhanced scoreboards**: first version of enhanced scoreboards for all standard game modes! Providing:
  * Highly customizable appearance: change font size, colors, borders, row dividers, and more.
  * New columns to display additional information depending the game mode.
  * Option to switch to a vertical layout in team games to show more columns.
  * A scrollbar to handle more players than what fits in your screen: use the scroll wheel, up/down arrows, and home/end to navigate.
  * Additional stats are planned for future releases, right now only built-in stats are displayed.
  * Servers that are using a different scoreboard replacement can set `bAllowEnhancedScoreboards=false` to prevent conflicts.
* Reworked skin highlights to allow forcing specific character models for teammates and enemies.
  * Because some properties changed names you might need to re-configure some options, apologies for the inconvenience.
  * Servers control if forcing models is allowed and which models can be used, check the README for detailed instructions.
* Added a new option to control how skin highlights are assigned (`HighlightMode`):
  * Choose between role-based (current behavior) or team-based (a static assignment that doesn't care what is your current team).
* Added two new options to control the overlay used by spawn protection for teammates and enemies (`TeammateProtected` and `EnemyProtected`).
* Added a new option to control if skin highlights are applied to heads (`bDisableOnHeads`).
  * For players who prefer the way UTComp's brightskins work.
* Reworked the behavior of the "DEFAULT" value for hit overlays and spawn protection:
  * It now uses a pre-defined selection of colors for each overlay instead of the native overlays.
  * Added "NATIVE" as an option to allow using the native overlays.
* Added new server option to control the intensity used for skin overlays (`SkinOverlayIntensity`).
  * Works the same as `SkinHighlightIntensity`, but applies to the colored overlays instead.
* Added new server option to control hit overlays (`AllowHitOverlays`).
  * Decide if players can freely control the colors used for hit overlays or force a specific kind. Check the README for more details.
* Fixed some character models having translucent textures when skin highlight is active.
* Fixed missing destruction of skin highlight actors which could cause temporary lingering of open replication channels.
* Reworked font selection for damage numbers: it can now automatically choose the appropriate font for your resolution.
  * On first run the mutator will automatically override your `DisplayFontName` to `AUTOSELECT`, if you're using a custom font you will need to set it back.
* Simplified display modes for damage numbers.
  * Removed the old "float" options since they can't handle simultaneous hits well.
  * Renamed the enumeration values to use more meaningful names.
* Fixed "last hit" damage numbers not correctly showing individual hit values with a few weapons (e.g. flak cannon).
* Added new server-side option for hit effects (`bRequireLOS`): decide if line of sight is required between player and target to trigger hit sounds and damage numbers.
  * Off by default, competitive servers might want this on.
* Added new server-side option to hide disabled features from the server status (`bHideDisabledFeatures`).

HexedVOTE changes:
* Added option to disable the enhanced map vote menu (`bDisableMapVoteMenu`).
  * Acts as a failsafe for players facing the issue of not being able to vote.

HexedNET changes:
* Added new server-side option to control the ping compensation limit applied to projectiles (`ProjectileCompensationLimit`), previously hardcoded to 75ms.
  * Handle this option as experimental, it might bring unforeseen consequences.
  * In testing, values above ~130 caused weird behavior in flak chunks on high ping (~250).
* Renamed `PawnCollisionTimeWindow` to `PingCompensationLimit` and changed its unit to milliseconds.
  * This name better represents the practical effects of this option and it is more in line with the new `ProjectileCompensationLimit` option.
* Ported [WSUTComp](github.com/zenakuten/WSUTComp)'s fixes for hit detection in vehicles.
  * If you experience crashes set `bLinkMeshes=false`, according to WSUTComp's developers this mesh linking might cause crashes.
* Fixed an improper beam effect spawning when quickly pressing shock rifles' secondary fire followed by primary fire.

General changes:
* Moved all mutator configuration to a separate file: `HexedMutators.ini`.
* Capitalized all words in GUI labels to be consistent with the rest of the game.
* Further hardened client code to handle extreme replication issues where relevant actors are mistakenly destroyed client-side.
  * Server admins facing such issues can mitigate it by increasing `RelevantTimeout` in `[IpDrv.TcpNetDriver]`, but you might want to investigate why your server connection is getting saturated.
* Fixed a visual bug that could occur in the configuration menu's general panel when using certain resolutions.
* Updated the configuration menu to reflect the new options.

> [!WARNING]
> Make sure to properly migrate all mutator configuration to the new INI file: `HexedMutators.ini`.

Known limitations:
* No skin highlight on Mutant game mode.

# v8.0

This release fixes some issues with v7:
* Fixed an issue that could break the map vote menu for high ping players (map list empty and combo boxes grayed out).
* Fixed an issue with SuperShockRifle's netcode causing the beam to render in the incorrect position (slightly below the crosshair).
* Fixed an issue with 3374 clients that would cause errors when switching from a map with HexedVOTE to a map without it.
* Potentially fixed issue of multiple Instagib tabs.
  * Added additional warnings to help identify what is happening in case multiple Instagib tabs still happens.

# v7.0

This version adds a new package with three mutators:
* HexedARENA:
  * MutHexedCONTROL - provides enhanced control over game mechanics: modify starting values, disable specific combos, disable specific pick-ups, modify movement parameters, and more.
  * MutHexedARENA - similar to the built-in Arena mutator, but allows changing the weapon via URL option.
  * MutHexedINSTAGIB - similar to the built-in Instagib mutator, but provides a custom zoom overlay and an option to change the fire rate.

General changes:
* Added a first run notification to let players know how to access the configuration menu.
* Phased-out old method for automatically copying existing configurations to a new version.
* Converted all user configuration to a version-independent format (using PerObjectConfig). From now on all user configuration will always properly transfer to new versions.
* Tightened up validation of user configuration.

HexedUT changes:
* Added view smoothing option to change the level of view smoothing to reduce the "sinking" effect in ramps.
* Added new (classic) hit sound.
* Recalibrated the default hit effects interpolation curve to better represent single-hit damage values.
* Removed features that were moved to HexedCONTROL.
* Added server actor to enable the mutator.

HexedVOTE changes:
* Added replication of missing map information (friendly names, authors, recommended number of players, and descriptions).
* Added support for custom preview packages to cover for maps missing preview screenshots (see [HexedUT2k4 Map Previews](https://github.com/hexengraf/HexedUT2k4-Map-Previews)).
* Moved list of liked/disliked maps to a separate INI file (`HexedFavorites.ini`).
* Fixed bad map list order when switching game types (it didn't correctly apply the sort of the previous sorting column).

HexedNET changes:
* Removed new EyeHeight algorithm (use the view smoothing option in HexedUT instead).
* Fixed issues with round-based game types.
* Removed counter + timestamp based ping sampling.
* Reworked ping sampler and average ping calculation.
* Added two new user options:
  * PingFrequency: Frequency to send pings, expressed in pings per second.
  * PingSmoothing: Factor to smooth out ping spikes from the average. Use low values for high smoothing (1.0 disables averaging completely).
* Replaced PingFrequency server option with MaxPingFrequency.
* Added option to backport OldUnreal's rubberbanding fix.
* Added support to HexedINSTAGIB's super shock rifle.

> [!WARNING]
> All existing user configuration will not automatically transfer to v7.
> This change is required to guarantee that your configuration will automatically apply to all future versions.
>
> It is possible to manually transfer your map favorites to v7.
>
> As an example, assume you have something like this in `User.ini`:
> ```ini
> [HexedVOTEv6.HxMapFavorites]
> Maps=(Map="DM-1on1-Aerowalk",Tag=HX_TAG_Like)
> Maps=(Map="DM-1on1-Alpu3",Tag=HX_TAG_Dislike)
> Maps=(Map="DM-1on1-Crash",Tag=HX_TAG_Dislike)
> Maps=(Map="DM-1on1-Viridian2k4",Tag=HX_TAG_Dislike)
> Maps=(Map="DM-Contrived",Tag=HX_TAG_Like)
> ```
>
> You need to create a new file called `HexedFavorites.ini` and add add your favorites inside it as follows:
> ```ini
> [Maps HxFavorites]
> List=(Name="DM-1on1-Aerowalk",Tag=HX_TAG_Like)
> List=(Name="DM-1on1-Alpu3",Tag=HX_TAG_Dislike)
> List=(Name="DM-1on1-Crash",Tag=HX_TAG_Dislike)
> List=(Name="DM-1on1-Viridian2k4",Tag=HX_TAG_Dislike)
> List=(Name="DM-Contrived",Tag=HX_TAG_Like)
> ```
>
> To manually transfer other configurations, check the README to get the new section formats.

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
