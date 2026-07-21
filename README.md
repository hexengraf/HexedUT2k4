# HexedUT2k4 - Hexed Unreal Tournament 2004

This is a collection of mutators for Unreal Tournament 2004:
* **HexedUT** (`HexedUTv9.MutHexedUT`) - provides hit sounds, damage numbers, skin highlights, enhanced scoreboards, and more.
* **HexedVOTE** (`HexedVOTEv9.MutHexedVOTE`) - provides an enhanced map vote menu on top of xVoting.
* **HexedCONTROL** (`HexedARENAv9.MutHexedCONTROL`) - provides enhanced control over game mechanics: modify starting values, disable specific combos, disable specific pick-ups, modify movement parameters, and more.
* **HexedARENA** (`HexedARENAv9.MutHexedARENA`) - similar to the built-in Arena mutator, but allows changing the weapon via URL option.
* **HexedINSTAGIB** (`HexedARENAv9.MutHexedINSTAGIB`) - similar to the built-in Instagib mutator, but provides a custom zoom overlay and an option to change the fire rate.
* **HexedNET** (`HexedNETv9.MutHexedNET`) - provides a modified version of WSUTComp's enhanced netcode (NewNet weapons).

Additionally, some QoL improvements are provided in the form of a client-only package called HexedPatches.
With the launch of OldUnreal patches, most of the features of this package are deprecated.
Better font scaling for higher than 1080p resolutions is the only remaining feature for OldUnreal installations.

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

See additional configuration guidelines for each mutator in the sections below.

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

#### User options

The following sections are saved in `User.ini`:
```ini
[HexedUT HxHitEffectsConfig]
; Play hit sounds.
bHitSounds=True
; Name of the hit sound to use.
; Default hit sounds can be specified without the package name,
; while external hit sounds require the fully qualified name: "PackedName.SoundName".
HitSoundName=HxHitSound0
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
; AUTOSELECT chooses a font adequate for your current resolution.
DisplayFontName=AUTOSELECT
; X position of the damage numbers on the screen (between 0.0 and 1.0).
DisplayPosX=0.500000
; Y position of the damage numbers on the screen (between 0.0 and 1.0).
DisplayPosY=0.450000
; All hit effects are interpolated according to the damage dealt by the hit.
; A linear interpolation is done between the values of two of the points listed below.
; ZeroDamage's Value is always 0, regardless of any changes made here.
; The meaning of Pitch varies according to the PitchMode, so 0 could be either high or low pitch.
; Scale refers to the scale of the damage number, and Color to the color of the damage number.
ZeroDamage=(Value=0,Pitch=0.000000,Scale=0.000000,Color=(B=255,G=255,R=255,A=0))
LowDamage=(Value=20,Pitch=0.400000,Scale=0.250000,Color=(B=32,G=255,R=255,A=0))
MediumDamage=(Value=45,Pitch=0.600000,Scale=0.500000,Color=(B=32,G=119,R=255,A=0))
HighDamage=(Value=75,Pitch=0.820000,Scale=0.750000,Color=(B=32,G=32,R=255,A=0))
ExtremeDamage=(Value=110,Pitch=1.000000,Scale=1.000000,Color=(B=245,G=32,R=143,A=0))
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

[HexedUT HxSkinHighlightConfig]
; Highlight color for you and your teammates.
; DISABLED = don't use skin highlights. All overlay options are ignored when disabled.
Teammates=DISABLED
; Highlight color for your enemies.
Enemies=DISABLED
; Highlight color to use when a shielded player is hit.
; DEFAULT = use a pre-defined color for each type of hit (or spawn protection).
; NATIVE = apply native game effects.
ShieldHit=DEFAULT
; Highlight color to use when a player is hit with a link gun.
LinkHit=DEFAULT
; Highlight color to use when a player is hit with a shock rifle.
ShockHit=DEFAULT
; Highlight color to use when a player is hit with a lightning gun.
LightningHit=DEFAULT
; Spawn protection color for you and your teammates when highlight is enabled.
TeammateProtected=DEFAULT
; Spawn protection color for your enemies when highlight is enabled.
EnemyProtected=DEFAULT
; Skin type to use below the highlight color for teammates.
;   HX_SKIN_RedTeam - red color tinting.
;   HX_SKIN_BlueTeam - blue color tinting.
;   HX_SKIN_Normal - no team color tinting.
TeammateSkin=HX_SKIN_Normal
; Skin type to use below the highlight color for enemies.
EnemySkin=HX_SKIN_Normal
; If true, enemy colors will be randomly selected in DM and other game modes with no team.
bRandomize=False
; Remove skin highlight from dead bodies.
bDisableOnDeadBodies=False
; While spectating, assume this team's perspective to decide which colors to use:
;   0: red team.
;   1: blue team.
SpectatorTeam=0
; Preferred teammate character model.
PreferredTeammateModel=Jakob
; Current teammate character model (after applying server-specific restrictions).
CurrentTeammateModel=Jakob
; If true, teammates will be forced to use the current teammate character model.
bForceTeammateModel=False
; Preferred enemy character model.
PreferredEnemyModel=Jakob
; Current enemy character model (after applying server-specific restrictions).
CurrentEnemyModel=Jakob
; If true, enemies will be forced to use the current enemy character model.
bForceEnemyModel=False

[HxSkinHighlight HxColors]
; List of colors. Set bRandom to false if you don't want a color to be used on RANDOM.
ColorList=(Name="Red",Color=(B=0,G=0,R=255,A=255),bRandom=True)
ColorList=(Name="Blue",Color=(B=255,G=0,R=0,A=255),bRandom=False)
ColorList=(Name="Green",Color=(B=0,G=255,R=0,A=255),bRandom=True)
ColorList=(Name="Pink",Color=(B=255,G=0,R=255,A=255),bRandom=True)
ColorList=(Name="Teal",Color=(B=255,G=255,R=0,A=255),bRandom=True)
ColorList=(Name="Yellow",Color=(B=0,G=255,R=255,A=255),bRandom=True)
ColorList=(Name="Purple",Color=(B=255,G=0,R=64,A=255),bRandom=False)

[HexedUT HxUTPlayerConfig]
; Select the type of view smoothing:
;   HX_VS_Default - use the game's default view smoothing.
;   HX_VS_Weak - greatly reduces view smoothing, similar to UTComp's new EyeHeight algorithm.
;   HX_VS_Disabled - no view smoothing at all, very hard to play with.
ViewSmoothing=HX_VS_Default

[HexedUT HxSPTimerConfig]
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
CustomColor=(B=4,G=191,R=239,A=255)
```

#### Server options

The following section is saved in `UT2004.ini`:
```ini
[HexedUTv9.MutHexedUT]
; Allow clients to enable/disable hit sound effects.
bAllowHitSounds=True
; Allow clients to enable/disable damage number effects.
bAllowDamageNumbers=True
; Require line of sight between player and target to trigger hit effects.
bRequireLOS=False
; Allow clients to enable/disable skin highlights.
bAllowSkinHighlight=True
; Factor to multiply the RGB values of highlights (between 0.0 and 1.0).
SkinHighlightIntensity=0.42
; Factor to multiply the RGB values of overlays (between 0.0 and 1.0).
SkinHighlightIntensity=0.55
; Allow client-side forced character models. Requires bAllowSkinHighlight=True to work.
; Possible values:
;   HX_FM_None - don't allow forced models.
;   HX_FM_OfficialOnly - only allow official character models.
;   HX_FM_FromList - only allow character models from the list.
;   HX_FM_Any - allow any character models.
AllowForcedModels=HX_FM_OfficialOnly
; Character model list to use with the HX_FM_FromList option.
; Default list contains all models allowed by the native game mechanism to force models.
ModelList=Jakob
ModelList=Gorge
ModelList=Malcolm
ModelList=Xan
ModelList=Brock
ModelList=Gaargod
ModelList=Axon
ModelList=Tamika
ModelList=Sapphire
ModelList=Enigma
ModelList=Cathode
ModelList=Rylisa
ModelList=Ophelia
ModelList=Zarina
; Allow clients to select different types of view smoothing.
bAllowCustomViewSmoothing=True
; Allow clients to enable/disable the enhanced scoreboards.
; Set this to false if your server is using another mutator for scoreboard replacements.
bAllowEnhancedScoreBoards=True
; Allow clients to enable/disable the spawn protection timer.
bAllowSpawnProtectionTimer=True
; Use team colors in death messages (blue = killer and red = victim if no teams).
bColoredDeathMessages=True
```

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

#### User options

Liked and disliked maps are saved in a separate file `HexedFavorites.ini` with the following structure:
```ini
[Maps HxFavorites]
; Each entry to the list should specify a valid map name in the Name field and either HX_TAG_Like or HX_TAG_Dislike in the Tag field.
List=(Name="DM-1on1-Albatross",Tag=HX_TAG_Like)
List=(Name="DM-1on1-Crash",Tag=HX_TAG_Dislike)
```

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
FilterList="DM-1on1-Albatross"
```

#### Server options

The following section is saved in `UT2004.ini`:
```ini
[HexedVOTEv9.MutHexedVOTE]
; Background for the votes list (upper list). Use ~16:3 images.
VoteListCustomBG=
; Background for the maps list (lower list). Use ~9:5 images.
MapListCustomBG=
; Background for the map preview banner. Use ~9:10 images.
PreviewCustomBG=
; Background for the chat box. Use ~22:7 images.
ChatBoxCustomBG=
; List of map preview loaders
MapPreviewLoaders=
```

Each custom background should contain the fully qualified `PackageName.TextureName` string of the texture to be used.
If the texture doesn't match the proportions of the background, it will be **centered and scaled** to fit.
Make sure to include the package containing the custom backgrounds to your `ServerPackages` configuration.

> [!TIP]
> The textures are alpha-blended with the default background, so you can rely on transparency to create subtle logos/watermarks.

Map preview loaders allow you to specify custom loader classes to provide missing map previews.
For more information on how to configure it check out [HexedUT2k4 Map Previews](https://github.com/hexengraf/HexedUT2k4-Map-Previews), a separate repository exclusively dedicated for map preview loaders.

### HexedCONTROL

HexedCONTROL provides enhanced control over existing game mechanics and is compatible with other Arena mutators.

List of features:
* Starting values modifiers: add/remove health, shield, number of Assault Rifle grenades, adrenaline, etc.
* Self-damage scale: control how much damage you can do to yourself.
* Health leech: part of damage dealt restores health, similar to the Vampire mutator, but with more customization.
* Disable specific adrenaline combos or the adrenaline system entirely.
* Disable specific pick-ups (health, shield, vials, pills, ammo).
* Movement modifiers: change movement speed, jump acceleration, number of jumps, etc.

#### Server options

The following section is saved in `UT2004.ini`:
```ini
[HexedARENAv9.MutHexedCONTROL]
; Bonus to starting health (between -99 and 99).
BonusHealth=0
; Bonus to starting shield (between 0 and 150).
BonusShield=0
; Bonus to starting number of AR grenades (between -4 and 99).
BonusARGrenades=0
; Bonus to starting adrenaline (between 0 and 100).
BonusAdrenaline=0
; Bonus to adrenaline on spawn (between -100 and 100).
BonusAdrenalineOnSpawn=0
; How much damage you do to yourself.
SelfDamageScale=1
; Ratio to leech health from damage dealt (between 0.0 and 5.0).
HealthLeechRatio=0
; Limit up to how much health can be filled with leech (between 0 and 199).
HealthLeechLimit=0
; Disable speed combo (up, up, up, up).
bNoSpeedCombo=False
; Disable berserk combo (up, up, down, down).
bNoBerserkCombo=False
; Disable booster combo (down, down, down, down).
bNoBoosterCombo=False
; Disable invisible combo (right, right, left, left).
bNoInvisibleCombo=False
; Disable adrenaline pills.
bNoAdrenalinePills=False
; Disable health vials.
bNoHealthVials=False
; Disable health packs.
bNoHealthPacks=False
; Disable super health packs.
bNoSuperHealthPacks=False
; Disable shield packs.
bNoShieldPacks=False
; Disable super shield packs.
bNoSuperShieldPacks=False
; Disable UDamage packs.
bNoUDamagePacks=False
; Disable ammo packs.
bNoAmmoPacks=False
; Coefficient to multiply maximum movement speed (between -100.0 and 100.0).
MaxSpeedMultiplier=1.0
; Coefficient to multiply air control (between -10.0 and 10.0).
AirControlMultiplier=1.0
; Coefficient to multiply base jump acceleration (between -10.0 and 10.0).
BaseJumpMultiplier=1.0
; Coefficient to multiply multi-jump acceleration boost (between -100.0 and 100.0).
MultiJumpMultiplier=1.0
; Bonus to add to base amount of multi-jumps (between -1 and 99).
BonusMultiJumps=0
; Coefficient to multiply dodge acceleration (Z-axis, between -10.0 and 10.0).
DodgeMultiplier=1.0
; Coefficient to multiply dodge speed factor (between -10.0 and 10.0).
DodgeSpeedMultiplier=1.0
; Disable wall dodge (UT Classic).
bNoWallDodge=False
; Disable dodge jump (UT Classic).
bNoDodgeJump=False
```

### HexedARENA

The main point of this mutator is to provide a way to define different Arenas using separate `GameConfig` entries in the `[xVoting.xVotingHandler]` section. For instance:
```ini
GameConfig=(GameClass="XGame.xDeathMatch",Prefix="DM",Acronym="RADM",GameName="RocketArena DeathMatch",Mutators="HexedARENAv9.MutHexedARENA",Options="ArenaWeaponClassName=XWeapons.RocketLauncher")
GameConfig=(GameClass="XGame.xDeathMatch",Prefix="DM",Acronym="FADM",GameName="FlakArena DeathMatch",Mutators="HexedARENAv9.MutHexedARENA",Options="ArenaWeaponClassName=XWeapons.FlakCannon")
```

All HexedUT2k4 mutators consume their URL options, so they're not "sticky" as it would usually be when passing options in the `GameConfig` entries, so you don't need to clean up options in unrelated entries.

#### Server options

The following section is saved in `UT2004.ini`:
```ini
[HexedARENAv9.MutHexedCONTROL]
; Determines which weapon will be used in the arena match.
ArenaWeaponClassName="XWeapons.RocketLauncher"
```

### HexedINSTAGIB

This mutator is a drop-in replacement for `MutInstagib` and `MutZoomInstaGib`, adding a new scope overlay and customizable fire rate.

#### User options

The following section is saved in `User.ini`:
```ini
[HexedARENA HxZoomSuperShockRifleConfig]
; Choose which scope overlay to use:
;   HX_SCOPE_Default - use the default scope overlay (same as lightning gun).
;   HX_SCOPE_Custom - use the custom scope overlay.
;   HX_SCOPE_Hidden - hide the scope overlay.
ScopeOverlay=HX_SCOPE_Custom
; Enable sound effects when zooming in/out.
bSoundEffects=True
; Show charge bar to indicate when it is ready to shoot.
bShowChargeBar=True
; Color of the scope reticle.
ReticleColor=(R=32,G=32,B=32,A=255)
; Scale the size of the scope reticle.
ReticleScale=0.5
; Opacity of black background around the scope.
BackgroundOpacity=0.3
; Use custom crosshair while zooming. Requires custom weapon crosshairs enabled to work.
bCustomZoomCrosshair=False
; Choose which crosshair to use.
CustomZoomCrosshair=7
CustomZoomCrosshairTextureName="Crosshairs.HUD.Crosshair_Cross1"
; Color of the crosshair.
CustomZoomCrosshairColor=(R=255,G=32,B=32,A=230)
; Scale the size of the crosshair.
CustomZoomCrosshairScale=1.0
```

#### Server options

The following section is saved in `UT2004.ini`:
```ini
[HexedARENAv9.MutHexedINSTAGIB]
; Players get a Translocator in their inventory.
bAllowTranslocator=False
; Teammates get a big boost when shot by the instagib rifle.
bAllowBoost=False
; Instagib rifles have sniper scopes.
bZoomInstagib=False
; Change the default fire rate of shock rifles (0 = default).
FireRate=0.0
```

### HexedNET

[HexedNET](https://github.com/hexengraf/HexedNET) is a fork of [WSUTComp](https://github.com/zenakuten/WSUTComp) that extracts the enhanced netcode from the myriad of features inside UTComp.
For the sake of a streamlined building process, releases of HexedNET are bundled together with HexedUT here.

> [!TIP]
> Compatibility with other mods should be somewhat improved, since `xPlayer` and `xPawn` are no longer replaced.
> Beware that `xPlayer` will be replaced if you enable `bRubberbandingFix`.

### User options

The following section is saved in `User.ini`:
```ini
[HexedNET HxNetcodeConfig]
; Enable enhanced netcode on weapons.
bEnhancedNetcode=True
; Frequency to send pings (pings/second).
PingFrequency=2.000000
; Factor to smooth out ping spikes from the average. Use low values for high smoothing (1.0 disables averaging completely).
PingSmoothing=0.300000
```

> [!TIP]
> Higher values of `PingFrequency` and `PingSmoothing` _might_ help if your ping is very unstable/spiky.
> There is not enough data yet to give an accurate recommendation.

#### Server options

The following section is saved in `UT2004.ini`:
```ini
[HexedNETv9.MutHexedNET]
; Maximum frequency to send pings (pings/second), between 0.2 and 20.
MaxPingFrequency=10.0
; Global ping compensation limit (in milliseconds) applied to all weapon types.
PingCompensationLimit=350
; Ping compensation limit (in milliseconds) applied to projectiles.
; Handle this option as experimental, it might bring unforeseen consequences.
; In testing, values above ~130 caused weird behavior in flak chunks on high ping (~250).
ProjectileCompensationLimit=75
; Backport OldUnreal's rubberbanding fix.
; Enable this option if your server has players using an unpatched version of the game.
bRubberbandingFix=False
; Link meshes for collision detection. Disable this if experiencing crashes. Helps with hit detection in vehicles.
bLinkMeshes=True
```

### HexedPatches

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

## Credits

Some of the hit sounds used by HexedUT are edited versions of audio samples taken from [freesound.org](https://freesound.org):
* `HxHitSound1.wav`: Bell at Daitokuji temple,kyoto.wav by kaonaya -- https://freesound.org/s/131348/ -- License: Creative Commons 0
* `HxHitSound5.wav`: af002 metal cowbell1 high.wav by Robinhood76 -- https://freesound.org/s/70057/ -- License: Attribution NonCommercial 4.0

## Troubleshooting

If you find any bugs, feel free to [open an issue](https://github.com/hexengraf/HexedUT2k4/issues/new/choose).
