# HexedUT2k4 - Hexed Unreal Tournament 2004

This is a collection of mutators for Unreal Tournament 2004:
* **HexedUT** (`HexedUTv9.MutHexedUT`) - provides hit sounds, damage numbers, skin highlights, enhanced scoreboards, and more.
* **HexedVOTE** (`HexedVOTEv9.MutHexedVOTE`) - provides an enhanced map vote menu on top of xVoting.
* **HexedCONTROL** (`HexedARENAv9.MutHexedCONTROL`) - provides enhanced control over game mechanics: modify starting values, disable specific combos, disable specific pick-ups, modify movement parameters, and more.
* **HexedARENA** (`HexedARENAv9.MutHexedARENA`) - similar to the built-in Arena mutator, but allows changing the weapon via URL option.
* **HexedINSTAGIB** (`HexedARENAv9.MutHexedINSTAGIB`) - similar to the built-in Instagib mutator, but provides a custom zoom overlay and an option to change the fire rate.
* **HexedNET** (`HexedNETv9.MutHexedNET`) - provides lag compensation.

HexedPatches has been moved to its own [repository](https://github.com/hexengraf/HexedUT2k4-Patches).

## Installation

Download the [latest release](https://github.com/hexengraf/HexedUT2k4/releases/latest) and extract it inside the root directory of your UT2004 installation, merging the `System` directory when asked.
Files with the `.uz2` extension are safe to delete (you only need them if configuring your own download redirect server).

> [!NOTE]
> HexedSRC is a package dependency for all mutators provided here. If you're only using a subset of the mutators, make sure you have `HexedSRCv9.u` inside your `System` directory.
> You don't need to explicitly add it to `ServerPackages`, the game automatically detects the dependency and downloads `HexedSRCv9.u` together with the mutators.

## Configuration

There is no dependency between mutators, so you are free to decide which ones you want to enable.
Some of the mutators can also be enabled through server actors:
* `HexedUTv9.HxUTServerActor` - enables HexedUT.
* `HexedVOTEv9.HxVTServerActor` - enables HexedVOTE.
* `HexedARENAv9.HxCTServerActor` - enables HexedCONTROL.

When one or more mutators are active, an in-game configuration menu is provided via the `mutate HexedMenu` command (if the letter `H` is available it will be automatically bound to this command).
This menu gives access to all configurations (both user and server), so it is highly recommended to tweak your initial setup through it.

> [!TIP]
> **SERVER ADMINS**: all mutators support URL options to modify their configurations (use the same name as the configuration you want to modify).

Check out [CONFIGURATION.md](Configuration.md) for detailed descriptions of all available configuration options.

### HexedUT

HexedUT is a completely new implementation of some of the features commonly offered by mutators like UTComp.
While it is possible to enable HexedUT and UTComp at the same time, you probably want to disable equivalent features from one of the two mutators.
To disable all equivalent features from HexedUT, use the following configuration:
```ini
[HexedUTv9.MutHexedUT]
bAllowHitSounds=False
bAllowDamageNumbers=False
bColoredDeathMessages=False
bAllowSkinHighlight=False
bAllowCustomViewSmoothing=False
```

Keep in mind that disabling all of these features greatly reduces the utility of HexedUT.
If possible, consider replacing UTComp entirely by combining HexedUT and HexedNET.

List of features:
* Hit sounds: pings and pongs to know when you hit someone.
* Damage numbers: pop-up numbers to know how much damage you've dealt.
* Skin highlights: can't see your enemy? Paint him radioactive green.
  * Forced models: force teammates and enemies to use specific character models.
* View smoothing: change the level of view smoothing to reduce the "sinking" effect in ramps.
* Enhanced scoreboards: replace default scoreboards with a more complete alternative.
* Spawn protection timer: a timer to keep track of spawn protection duration.
* Colored death messages: easily identify from which team is the killer and the victim.

In case there are more features you wish to see on HexedUT, open an issue so we can evaluate the viability of implementing them.

### HexedVOTE

HexedVOTE does not replace xVoting, it builds on top of it, so you need to first enable and configure [xVoting](https://wiki.unrealadmin.org/MapVote_(UT2004)) (UT2004's default voting system).
Enable HexedVOTE and it will replace the map vote menu automatically, no additional configuration needed.

List of features:
* Enhanced map voting page:
  * On-screen map previews: screenshots, number of players, author and description.
  * Liked/disliked map classification.
  * New column with the recommended minimum/maximum of players.
  * Search bar for each column of the map list.
  * New button to select a random map.
  * Map filters: create custom filters to quickly sort through the map list.
  * Several improvements to font size, line spacing, alignments, backgrounds and colors.
  * Server-defined custom backgrounds to add flair.

### HexedCONTROL

HexedCONTROL provides enhanced control over existing game mechanics and is compatible with other Arena mutators.

List of features:
* Starting values modifiers: add/remove health, shield, number of Assault Rifle grenades, adrenaline, etc.
* Self-damage scale: control how much damage you can do to yourself.
* Health leech: part of damage dealt restores health, similar to the Vampire mutator, but with more customization.
* Disable specific adrenaline combos or the adrenaline system entirely.
* Disable specific pick-ups (health, shield, vials, pills, ammo).
* Movement modifiers: change movement speed, jump acceleration, number of jumps, etc.

### HexedARENA

The main point of this mutator is to provide a way to define different Arenas using separate `GameConfig` entries in the `[xVoting.xVotingHandler]` section. For instance:
```ini
GameConfig=(GameClass="XGame.xDeathMatch",Prefix="DM",Acronym="RADM",GameName="RocketArena DeathMatch",Mutators="HexedARENAv9.MutHexedARENA",Options="ArenaWeaponClassName=XWeapons.RocketLauncher")
GameConfig=(GameClass="XGame.xDeathMatch",Prefix="DM",Acronym="FADM",GameName="FlakArena DeathMatch",Mutators="HexedARENAv9.MutHexedARENA",Options="ArenaWeaponClassName=XWeapons.FlakCannon")
```

All HexedUT2k4 mutators consume their URL options, so they're not "sticky" as it would usually be when passing options in the `GameConfig` entries, so you don't need to clean up options in unrelated entries.

### HexedINSTAGIB

This mutator is a drop-in replacement for `MutInstagib` and `MutZoomInstaGib`, adding a new scope overlay and customizable fire rate.

### HexedNET

[HexedNET](https://github.com/hexengraf/HexedNET) is a standalone implementation of lag compensation, originally forked from [WSUTComp](https://github.com/zenakuten/WSUTComp).

## Troubleshooting

If you find any bugs, feel free to [open an issue](https://github.com/hexengraf/HexedUT2k4/issues/new/choose).

## Credits

Some of the hit sounds used by HexedUT are edited versions of audio samples taken from [freesound.org](https://freesound.org):
* `HxHitSound1.wav`: Bell at Daitokuji temple,kyoto.wav by kaonaya -- https://freesound.org/s/131348/ -- License: Creative Commons 0
* `HxHitSound5.wav`: af002 metal cowbell1 high.wav by Robinhood76 -- https://freesound.org/s/70057/ -- License: Attribution NonCommercial 4.0

## Similar projects

If for one reason or another HexedUT2k4 doesn't fit your needs, you might be interested in one of the following:
* [UTComp](https://github.com/Deaod/UTComp) - the original UTComp in all its glory, not updated for quite a while.
* [WSUTComp](https://github.com/zenakuten/WSUTComp) - an UTComp fork that has received a lot of updates and new features.
* [3SPNv3223](https://github.com/mGm-Lizard/3SPNv3223) - (possibly) the last stable version of the original 3SPN (shares a lot of code with UTComp - or maybe the other way around?).
* [3SPNv3225PIG](https://github.com/ukpiglet/3SPNv3225PIG) - MiASMA's fork of 3SPN.
* [3SPNvSoL](https://github.com/zenakuten/3SPNvSoL) - SoL's fork of 3SPN.
