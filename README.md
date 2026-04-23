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

### User INI options

The following sections are saved in `User.ini`:
```ini
[HexedUTv6.HxHitEffects]
; Play hit sounds.
bHitSounds=True
; Name of the hit sound to use.
; Default hit sounds can be specified without the package name,
; while external hit sounds require the fully qualified name: "PackedName.SoundName".
HitSoundName=HxHitSound1
; Hit sound volume.
HitSoundVolume=1.000000
; Pitch mode for the hit sounds:
;   HX_PITCH_Disabled - constant pitch regardless of damage.
;   HX_PITCH_Low2High - low pitch for low damage, high pitch for high damage.
;   HX_PITCH_High2Low - high pitch for low damage, low pitch for high damage.
PitchMode=HX_PITCH_High2Low
; Show damage numbers.
bDamageNumbers=True
; Display mode for the damage numbers:
;   HX_DISPLAY_Static - shows the damage of a single hit.
;   HX_DISPLAY_StaticTotal - shows accumulated damage of hits with less than a second a part.
;   HX_DISPLAY_StaticDual - shows the information of the two modes above at the same time.
;   HX_DISPLAY_Float - shows the damage of every hit, animating it to float towards the top of the screen.
;   HX_DISPLAY_FloatDual - same as Float, but adds an accumulated damage number at the end of the animation path.
DisplayMode=HX_DISPLAY_StaticDual
; Font name to be used to render the damage numbers. Custom fonts are supported.
DisplayFontName=UT2003Fonts.FontEurostile37
; X position of the damage numbers on the screen (between 0.0 and 1.0).
DisplayPosX=0.500000
; Y position of the damage numbers on the screen (between 0.0 and 1.0).
DisplayPosY=0.450000
; All hit effects are interpolated according to the damage dealt by the hit.
; A linear interpolation is done between the values of two of the points listed below.
; ZeroDamage's Value is always 0, regardless of any changes made here.
; The meaning of Pitch varies according to the PitchMode, so 0 could be either high or low pitch.
; Scale refers to the scale of the damage number, and Color to the color of the damage number.
ZeroDamage=(Value=0,Pitch=0.000000,Scale=0.000000,Color=(B=255,G=255,R=255,A=255))
LowDamage=(Value=30,Pitch=0.300000,Scale=0.300000,Color=(B=32,G=255,R=255,A=255))
MediumDamage=(Value=70,Pitch=0.550000,Scale=0.550000,Color=(B=32,G=119,R=255,A=255))
HighDamage=(Value=120,Pitch=0.750000,Scale=0.750000,Color=(B=32,G=32,R=255,A=255))
ExtremeDamage=(Value=180,Pitch=1.000000,Scale=1.000000,Color=(B=245,G=32,R=143,A=255))
; List of fonts to display as selectable options in the configuration menu.
; You can add all your custom fonts here.
FontNames=UT2003Fonts.FontEurostile29
FontNames=UT2003Fonts.FontEurostile37
FontNames=UT2003Fonts.FontNeuzeit29
FontNames=UT2003Fonts.FontNeuzeit37
FontNames=2K4Fonts.Verdana28
FontNames=2K4Fonts.Verdana30
FontNames=2K4Fonts.Verdana32
FontNames=2K4Fonts.Verdana34
; List of custom hit sounds to display as selectable options in the configuration menu.
; You can add all your custom hit sounds here.
; Remember to use the "PackageName.HitSoundName" syntax.
CustomHitSounds=

[HexedUTv6.HxSkinHighlight]
; DEFAULT = normal game effects.
; Color of your team in team games.
YourTeam=DEFAULT
; Color of the enemy team in team games.
EnemyTeam=DEFAULT
; Color of other players in solo games.
; Use RANDOM to automatically assign random colors for each player.
SoloPlayer=DEFAULT
; Color to flash when hit when armor is active. Also used as spawn protection indicator.
ShieldHit=DEFAULT
; Color to flash when hit by link gun (and bio rifle, maybe others?).
LinkHit=DEFAULT
; Color to flash when hit by shock rifle.
ShockHit=DEFAULT
; Color to flash when hit by lightning gun.
LightningHit=DEFAULT
; Remove skin highlight from dead bodies.
bDisableOnDeadBodies=False
; Force normal skins in team games (i.e. don't use the variant with team colors baked-in).
bForceNormalSkins=True
; While spectating, assume this team's perspective to decide which colors to use:
;   0: red team.
;   1: blue team.
SpectatorTeam=0
; List of colors. Set bRandom to false if you don't want a color to be used on RANDOM.
Colors=(Name="Red",Color=(B=0,G=0,R=255,A=255),bRandom=True)
Colors=(Name="Blue",Color=(B=255,G=0,R=0,A=255),bRandom=True)
Colors=(Name="Green",Color=(B=0,G=255,R=0,A=255),bRandom=True)
Colors=(Name="Pink",Color=(B=255,G=0,R=255,A=255),bRandom=True)
Colors=(Name="Teal",Color=(B=255,G=255,R=0,A=255),bRandom=True)
Colors=(Name="Yellow",Color=(B=0,G=255,R=255,A=255),bRandom=True)
Colors=(Name="Purple",Color=(B=255,G=0,R=64,A=255),bRandom=False)

[HexedUTv6.HxSpawnProtectionTimer]
; Show spawn protection timer.
bEnabled=True
; Paint the spawn protection timer with the same color as the HUD.
bUseHUDColor=True
; Use pulsing digits for the counter.
bPulsingDigits=False
; X position of the spawn protection timer on the screen (between 0.0 and 1.0).
PosX=0.950000
; Y position of the spawn protection timer on the screen (between 0.0 and 1.0).
PosY=0.640000
; Color to use if bUseHUDColor=false.
DefaultColor=(B=4,G=191,R=239,A=255)
```

### Server INI options

The following sections are saved in `UT2004.ini`:
```ini
[HexedUTv6.MutHexedUT]
; Allow clients to enable/disable hit sound effects.
bAllowHitSounds=True
; Allow clients to enable/disable damage number effects.
bAllowDamageNumbers=True
; Allow clients to enable/disable skin highlights.
bAllowSkinHighlight=True
; Factor to multiply RGB values (between 0.0 and 1.0).
SkinHighlightIntensity=0.300000
; Allow clients to enable/disable the spawn protection timer.
bAllowSpawnProtectionTimer=True
; Use team colors in death messages (blue = killer and red = victim if no teams).
bColoredDeathMessages=True
```

## HexedVOTE

HexedVOTE does not replace xVoting, it builds on top of it, so you need to first enable and configure xVoting (UT2004's default voting system).
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

### User INI options

Map filters are saved in a separate file called `HexedFilters.ini` with the following structure:
```ini
[FilterName HxMapFilter]
; Pattern to filter maps by name.
MapName=
; Pattern to filter maps by their author name(s).
AuthorName=
; Pattern to filter maps by the number of players.
NumPlayers=
; Pattern to filter maps by the number of times played.
TimesPlayed=
; Filter maps by their source:
;   HX_MAP_SOURCE_Any - no filter, any source is allowed.
;   HX_MAP_SOURCE_Official - only official maps are selected.
;   HX_MAP_SOURCE_Custom - only custom maps are selected.
MapSource=HX_MAP_SOURCE_Any
; Filter maps by their tag:
;   HX_TAG_Any - no filter, any tag is allowed.
;   HX_TAG_Like - only liked maps are selected.
;   HX_TAG_None - only maps with no tag are selected.
;   HX_TAG_Dislike - only disliked maps are selected.
MapTag=HX_TAG_Any
; How the explicit filter list should be used:
;   HX_FILTER_MODE_Include - include the listed maps in the result.
;   HX_FILTER_MODE_Exclude - exclude the listed maps from the result.
FilterListMode=HX_FILTER_MODE_Include
; Explicit filter list, each entry should contain a valid map name.
FilterList=
```

### Server INI options

The following sections are saved in `UT2004.ini`:
```ini
[HexedVOTEv6.MutHexedVOTE]
; Background for the votes list (upper list). Use ~16:3 images.
VoteListCustomBG=
; Background for the maps list (lower list). Use ~9:5 images.
MapListCustomBG=
; Background for the map preview banner. Use ~9:10 images.
PreviewCustomBG=
; Background for the chat box. Use ~22:7 images.
ChatBoxCustomBG=
```

Each custom background should contain the fully qualified `PackageName.TextureName` string of the texture to be used.
If the texture doesn't match the proportions of the background, it will be **centered and scaled** to fit.
Make sure to include the package containing the custom backgrounds to your `ServerPackages` configuration.

> [!TIP]
> The textures are alpha-blended with the default background, so you can rely on transparency to create subtle logos/watermarks.

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
