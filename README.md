# HexedUT2k4 - Hexed Unreal Tournament 2004

This is a collection of mutators and packages providing a variety of features and QoL improvements for Unreal Tournament 2004.
The following game packages are provided:
* **HexedUT**: mutator providing hit sounds, damage numbers, colored death messages, skin highlights, and more.
* **HexedVOTE**: mutator providing an enhanced map vote menu on top of xVoting.
* **HexedNET**: (WS)UTComp's enhanced netcode (NewNet weapons) and new eye height algorithm.
* **HexedSRC**: package containing classes and resources used by HexedUT, HexedVOTE and HexedNET.
* **HexedPatches**: client-side package providing QoL improvements (only font scaling is still relevant for OldUnreal installations).

## Installation

Download the [latest release](https://github.com/hexengraf/HexedUT2k4/releases/latest) and extract it inside the root directory of your UT2004 installation, merging the `System` directory when asked.
Files with the `.uz2` extension are safe to delete (you only need them if configuring your own download redirect server).

> [!NOTE]
> **PLAYERS**: when upgrading to a new version keep the previous version in you system folder to allow HexedUT/HexedVOTE to automatically copy your configuration to the new version.
> If you don't do this, your liked/disliked maps will not transfer over to the new version of HexedVOTE.

> [!NOTE]
> **SERVER ADMINS**: when upgrading to a new version add the **mutator packages** of the previous version to your `ServerPackages` to allow players that don't have it locally installed to automatically copy their configuration to the new version.

## Configuration

HexedUT, HexedVOTE and HexedNET can be enabled as mutators (`MutHexedUT`, `MutHexedVOTE` and `MutHexedNET`), while HexedVOTE also provides a ServerActor (`HxVTServerActor`) to load it.

When one or more mutators are active, an in-game configuration menu is provided via the `mutate HexedMenu` command.
This menu gives access to all configurations (both user and server), so it is highly recommended to tweak your initial setup through it.

> [!TIP]
> Binding the menu to a key is strongly recommended. Execute `set input F5 mutate HexedMenu` in the console, replacing F5 with the desired key.

See additional configuration guidelines for each mutator in the sections below.

## HexedUT

HexedUT is a completely new implementation of some of the features commonly offered by mutators like UTComp.
While it is possible to enable HexedUT and UTComp at the same time, you probably want to disable equivalent features from one of the two mutators.
To disable all equivalent features from HexedUT, use the following configuration:
```ini
[HexedUTv6.MutHexedUT]
bAllowHitSounds=False
bAllowDamageNumbers=False
bColoredDeathMessages=False
bAllowSkinHighlight=False
```

Keep in mind that disabling all of these features greatly reduces the utility of HexedUT.
If possible, consider replacing UTComp entirely by combining HexedUT and HexedNET.

List of features:
* Hit sounds: pings and pongs to know when you hit someone.
* Damage numbers: pop-up numbers to know how much damage you've dealt.
* Skin highlights: can't see your enemy? Paint him radioactive green.
* Spawn protection timer: a timer to keep track of spawn protection duration.
* Colored death messages: easily identify from which team is the killer and the victim.
* Health leech: part of damage dealt restores health, similar to the Vampire mutator, but with more customization.
* Movement modifiers: change movement speed, jump acceleration, number of jumps, etc.
* Starting values modifiers: add/remove health, shield, number of Assault Rifle grenades, adrenaline, etc.
* Disable specific combos and/or UDamage on maps.

In case there are more features you wish to see on HexedUT, open an issue so we can evaluate the viability of implementing them.

## HexedVOTE

HexedVOTE does not replace xVoting, it builds on top of it.
In order to use it, you need to first enable and configure xVoting (UT2004's default voting system).
Enable HexedVOTE and it will replace the map vote menu automatically, no additional configuration needed.

Servers may configure custom backgrounds to add their own flair to the map vote menu. The following backgrounds can be set:
* `VoteListCustomBG`: background for the votes list (upper list). Use ~16:3 images.
* `MapListCustomBG`: background for the maps list (lower list). Use ~9:5 images.
* `PreviewCustomBG`: background for the map preview banner. Use ~9:10 images.
* `ChatBoxCustomBG`: background for the chat box. Use ~22:7 images.

Each variable should contain the fully qualified `PackageName.TextureName` string of the texture to be used.
If the texture doesn't match the proportions of the background, it will be **centered and scaled** to fit.
Make sure to include the package containing the custom backgrounds to your `ServerPackages` configuration.

> [!TIP]
> The textures are alpha-blended with the default background, so you can rely on transparency to create subtle logos/watermarks.

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

## HexedNET

[HexedNET](https://github.com/hexengraf/HexedNET) is a fork of [WSUTComp](https://github.com/zenakuten/WSUTComp) that extracts the enhanced netcode from the myriad of features inside UTComp.
For the sake of a streamlined building process, releases of HexedNET are bundled together with HexedUT here.

List of features:
* NewNet Weapons (a.k.a. enhanced netcode): ping compensation implementation.
* New eye height algorithm: fixes where your aim position on uneven terrain (such as ramps).

> [!TIP]
> Compatibility with other mods should be somewhat improved, since `xPlayer` is no longer replaced.
> `xPawn` is still replaced to provide the EyeHeight algorithm, disable this feature server-side if you have issues with this replacement.
> Default weapons are replaced in order to provide the enhanced netcode.

## HexedPatches

To enable HexedPatches, open `System/UT2004.ini` and replace the default value of `GUIController` with `HexedPatches.HxGUIController`:
```ini
; GUIController=GUI2K4.UT2K4GUIController
GUIController=HexedPatches.HxGUIController
```

> [!CAUTION]
> **DO NOT** change the `GUIController` if you plan to join servers running AntiTCC, otherwise you will most likely be **BANNED**.

All configuration can be changed through a new tab called "HexedPatches" in the settings.

The following QoL improvements are provided (any game version):
* Better font scaling for higher resolutions (may cause some font cropping/overflow, since some background elements are not properly scaled).

The following QoL improvements are provided for the legacy 3369 version of the game:
* Modern resolutions available in the settings menu.
* Small cursor to compensate absurd scaling when using high resolutions.
* Correct widescreen scaling for default HUDs.
* Higher FOV limit in the settings menu.
* Player models are no longer cropped in the settings menu (when using a widescreen resolution).
* Persistent custom network speed (applied on every level change).
* Master server selector (either 333network or OpenSpy).

## Troubleshooting

If you find any bugs, feel free to [open an issue](https://github.com/hexengraf/HexedUT2k4/issues/new/choose).

### Some characters have semi-transparent parts when skin highlight is enabled

This is an issue with the game. Maybe one day it will be [solved](https://github.com/OldUnreal/UT2004Patches/issues/182).
The best you can do is to avoid using such characters and/or force default models that don't have this issue.

### My map vote menu is gone!

You've been using `HexedPatches` since a long time, I see. Open your `User.ini` and search for `MapVotingMenu`.
Make sure **all** occurrences of this keyword have the following value:
```ini
MapVotingMenu=xVoting.MapVotingPage
```

When the enhanced map vote menu was part of `HexedPatches`, it was directly set to be the `MapVotingMenu`.
With the migration to HexedVOTE, this leftover configuration will unfortunately break your map vote menu and require this manual intervention.

### Fonts are too big or too small

Font size is automatically determined based on the current resolution.
You can override the font size in the Patches tab (a restart is required). Try different values (between 0 and 6) to find the one that suites your needs.

### HUD options are grayed out

You have foxWSFix enabled. In order to use HexedPatches's HUDs, you need to disable foxWSFix.
Restore all `InputClass` values in `System/User.ini` to the default value:
```ini
InputClass=Class'Engine.PlayerInput'
```

### Server Options buttons is grayed-out

You need to log-in as administrator first. You may need to wait a bit before reopening the configuration menu for it to detect you have admin privileges.
