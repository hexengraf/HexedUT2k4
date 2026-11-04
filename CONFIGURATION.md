# HexedUT2k4 - Configuration Guide

Using the in-game configuration menu (`HexedMenu` command and/or `H` keybind when available) is the recommended way of performing the first time configuration.
For server configuration, using either WebAdmin or the official in-game configuration menu also works fine (restart the map once if using WebAdmin to ensure all options are properly applied).

Most user options are saved in `User.ini`, while all server options are saved in `HexedMutators.ini`.
Additionally, map favorites are saved in `HexedFavorites.ini` and map list filters are saved in `HexedFilters.ini`.
A reference `HexedMutators.ini` with the default values is provided inside the `Help` folder of each release if you prefer to edit everything directly.

Server options can also be supplied as URL options, so you can create custom game types with different combinations of options.

The rest of this document details all the available options for each mutator.

## General options

General options are common to all mutators, mostly related to shared interface behavior.

### `[HexedSRCv10.HxMutator]`

This section contains all general server options, saved in `HexedMutators.ini`.

#### `MaxNotifyDuration`

Notifications are displayed in the upper center of the screen, inside a blue box, and remain on the screen for a duration calculated based on the size of the message.
This option puts an upper limit to how long they can be displayed.

Default value is 10 seconds, with valid values between 1 and 30.

#### `NotifyRunning`

This is the only notification currently implemented.
It is a simple message letting the player know that HexedUT2k4 mutators are active and can be configured via the `HexedMenu` command and/or `H` keybind (when available).
Possible values:
* `HX_NRUN_Never`: never notify.
* `HX_NRUN_PerVersion`: notify first time running a new version.
* `HX_NRUN_PerSession`: notify every new session (i.e. once per server join).
* `HX_NRUN_Always`: always notify (i.e. at the start of every map).

Default value is `HX_NRUN_PerVersion`.

#### `StatusVerbosity`

The general tab of the configuration menu has a section called "Server Status", displaying a list of the active mutators and their corresponding configurations.
This allows players to get an idea of how the server is configured and what to expect, but some server admins may prefer to keep some information hidden.
Use this option to control how much information about the server configuration is displayed. Possible values:
* `HX_VERB_Lowest`: hides everything except which mutators are loaded and the platform version.
* `HX_VERB_Low`: hides even more options than medium, but still show the most important ones.
* `HX_VERB_Medium`: hides boolean options that are set to false and some detailed options.
* `HX_VERB_High`: shows everything.

Default value is `HX_VERB_Medium`.
You need to test which verbosity level matches your expectations, since each mutator defines the required level for each of its server options.

## HexedUT

The mutator that provides hit sounds, damage numbers, enhanced scoreboards, additional player stats, skin highlights (a.k.a. brightskins), forced player models, (reduced) view smoothing, spawn protection timer, and colored death messages.
You can freely select which of these features are allowed on the server, so don't be discouraged if you only want a small subset of them: you can easily toggle everything else off!

### `[HexedUTv10.MutHexedUT]`

This section contains all server options for HexedUT, saved in `HexedMutators.ini`.

#### `bAllowHitSounds`, `bAllowDamageNumbers` and `bRequireLOS`

Controls if hit sounds and damage numbers are allowed, and if line of sight is required for triggering them.

Default values are `True`, `True`, and `False`.

#### `bAllowSkinHighlight`

Controls if skin highlights are allowed. Keep in mind that forced models require this option set to `True`.

Default value is `True`.

#### `SkinHighlightIntensity` and `SkinOverlayIntensity`

Controls the intensity of skin highlights and additional overlay effects.
It is recommended to keep `SkinOverlayIntensity` at a higher value than `SkinHighlightIntensity` to make it more discernible when the highlight color is similar to the effect color.

Default values are 0.42 and 0.55, with valid values between 0.0 and 1.0.

#### `AllowHitOverlays`

Controls which kinds of [hit overlay effects](#shieldhit-linkhit-shockhit-and-lightninghit) are allowed when the player has skin highlights enabled.
Possible values:
* `HX_HO_UserControlled`: allows each player to decide the colors for each hit overlay.
* `HX_HO_ForceDefault`: forces all hit overlays to use the default colors.
* `HX_HO_ForceNative`: forces all hit overlays to use the native game effects.
* `HX_HO_IntensityOnly`: forces all hit overlays to use the same color as the highlight, only changing the intensity applied.
* `HX_HO_Disabled`: forces all hit overlays to be disabled.

Default value is `HX_HO_UserControlled`.

#### `AllowForcedModels` and `ModelList`

Controls which [forced models](#preferredteammatemodelcurrentteammatemodel-and-preferredenemymodelcurrentenemymodel) players are allowed to use on the server.
Possible values:
* `HX_FM_None`: disables forced models.
* `HX_FM_OfficialOnly`: only allows official (and CBP) character models.
* `HX_FM_FromList`: only allows character models from the `ModelList`.
* `HX_FM_Any`: allows any character models.

Default value is `HX_FM_OfficialOnly`.

The default `ModelList` is:
```ini
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
```

This list corresponds to the models allowed by the native game mechanism to forced models.

#### `bAllowCustomViewSmoothing`

Controls if players are allowed to change the [view smoothing](#viewsmoothing).

#### `bAllowEnhancedScoreBoards`

Controls if players can enable/disable the enhanced scoreboards.
Disable this option if your server is using another mutator for scoreboard replacements.

Default value is `True`.

##### Enabling rank information in the scoreboard

The enhanced scoreboards support showing a rank number for each player, as long as an external mutator provides the expected ranks.
For instance, you can write a mutator that calls the following function in a timer (or when a player spawns):
```
function UpdateRanks()
{
    local LinkedReplicationInfo LinkedPRI;
    local Controller C;
    local int Rank;

    for (C = Level.ControllerList; C != None; C = C.nextController)
    {
        if (C.IsA('PlayerController') && !C.IsA('MessagingSpectator'))
        {
            if (C.PlayerReplicationInfo != None)
            {
                LinkedPRI = C.PlayerReplicationInfo.CustomReplicationInfo;
                while (LinkedPRI != None)
                {
                    if (GetItemName(string(LinkedPRI.Class)) ~= "HxPlayerReplicationInfo")
                    {
                        // Populate Rank with the appropriate value
                        // Rank = ...;
                        // and execute:
                        LinkedPRI.SetPropertyText("Rank", string(Rank));
                        break;
                    }
                    LinkedPRI = LinkedPRI.NextReplicationInfo;
                }
            }
        }
    }
}
```

The mutator itself doesn't require any dependency thanks to `SetPropertyText` and the string comparison to find the `HxPlayerReplicationInfo` actor.

#### `bExtraStats`

Enables tracking of extra player stats that can be displayed in the enhanced scoreboard.
Currently supported stats: overall accuracy, team kills, and highest killing spree (max spree).

Default value is `True`.

#### `bAllowSpawnProtectionTimer`

Controls if players can enable/disable the [spawn protection timer](#hexedut-hxsptimerconfig).

Default value is `True`.

#### `bColoredDeathMessages`

Enables team colors in death messages.
In game modes with no teams, blue is used for the killer and red for the victim.

Default value is `True`.

### `[HexedUT HxHitEffectsConfig]`

This section contains all user options for hit effects, saved in `User.ini`.
They can be changed in the Hit Effects tab of the configuration menu.

#### `bHitSounds`

Toggle hit sounds on/off if the server allows them.
Hit sounds are played every time you hit an enemy and it causes damage.

Default value is `True`.

#### `HitSoundName`

Name of the hit sound to use.
You can set this option to a custom hit sound of your own (e.g. `PackageName.CustomHitSound`).
Hit sounds shipped with the mutator are specified without the package name.

Default value is `HxHitSound0`.

#### `HitSoundVolume`

Hit sounds volume, allows you to control it separately from the rest of the sound effects.

Default value is 1.0.

#### `PitchMode`

Controls how the hit sound pitches depending the amount of damage done by the hit.
Possible values:
* `HX_PITCH_Disabled`: constant pitch regardless of damage.
* `HX_PITCH_Low2High`: low pitch for low damage, high pitch for high damage.
* `HX_PITCH_High2Low`: high pitch for low damage, low pitch for high damage.

Default value is `HX_PITCH_High2Low`.

#### `bDamageNumbers`

Toggle damage numbers on/off if the server allows them.
Damage numbers show the raw amount of damage done by each hit.

Default value is `True`.

#### `DisplayMode`

Defines how damage numbers are displayed.
Possible values:
* `HX_DMGNUM_LastHit`: shows the damage of the last hit.
* `HX_DMGNUM_Total`: shows accumulated damage of hits. Resets after 1 second without hits.
* `HX_DMGNUM_LastHitAndTotal`: shows the information of the two modes above at the same time.

Default value is `HX_DMGNUM_LastHitAndTotal`.

#### `DisplayFontName`

You can set this option to a custom font of your own (e.g. `PackageName.CustomFontName`).
Fonts shipped with the mutator are specified without the package name.

Default value is `AUTOSELECT`, which makes the mutator automatically select the font most adequate for your resolution.

#### `DisplayPosX` and `DisplayPosY`

Defines the position of the damage numbers on the screen, with values between 0.0 and 1.0, where 0.0 is left/top and 1.0 is right/bottom.

Default values are 0.5 and 0.45, putting the damage numbers slightly above your crosshair.

#### `ZeroDamage`, `LowDamage`, `MediumDamage`, `HighDamage` and `ExtremeDamage`

All hit effects are interpolated according to the damage dealt by the hit, deciding the exact pitch (if not using `HX_PITCH_Disabled`), and the color/size of the damage number.

Default values are:
```ini
ZeroDamage=(Value=0,Pitch=0.000000,Scale=0.000000,Color=(R=255,G=255,B=255,A=255))
LowDamage=(Value=20,Pitch=0.400000,Scale=0.250000,Color=(R=255,G=255,B=32,A=255))
MediumDamage=(Value=45,Pitch=0.600000,Scale=0.500000,Color=(R=255,G=119,B=32,A=255))
HighDamage=(Value=75,Pitch=0.820000,Scale=0.750000,Color=(R=255,G=32,B=32,A=255))
ExtremeDamage=(Value=110,Pitch=1.000000,Scale=1.000000,Color=(R=143,G=32,B=245,A=255))
```

Keep in mind that:
* The `Value` of `ZeroDamage` will always be 0, even if you try to change it.
* `Pitch` must be between 0.0 an 1.0, with the exact meaning of each value depending what is the `PitchMode`.
* `Scale` controls the size of the damage numbers and must be between 0.0 an 1.0.
* `Color` is specified as RGBA, but A is actually ignored.

#### `FontNames`

This is the list of selectable fonts that appear in the configuration menu.

Default value is:
```ini
FontNames=UT2003Fonts.FontEurostile9
FontNames=UT2003Fonts.FontEurostile12
FontNames=UT2003Fonts.FontEurostile14
FontNames=UT2003Fonts.FontEurostile17
FontNames=HxFontEurostile18
FontNames=UT2003Fonts.FontEurostile21
FontNames=HxFontEurostile22
FontNames=UT2003Fonts.FontEurostile24
FontNames=HxFontEurostile27
FontNames=HxFontEurostile28
FontNames=UT2003Fonts.FontEurostile29
FontNames=HxFontEurostile32
FontNames=HxFontEurostile35
FontNames=UT2003Fonts.FontEurostile37
FontNames=HxFontEurostile42
```

You can add your own fonts following the syntax `PackageName.CustomFontName`.
Note that some custom fonts shipped with HexedUT2k4 don't use the package name (e.g. `HxFontEurostile18`).
This is to make sure your user configuration is always valid, since the package name constantly changes every new version.

#### `CustomHitSounds`

In addition to the default hit sounds, you can add custom hit sounds as selectable options in the configuration menu by specifying them here.
For instance:
```ini
CustomHitSounds=PackageName1.HitSoundName1
CustomHitSounds=PackageName1.HitSoundName2
CustomHitSounds=PackageName2.HitSoundName1
```

### `[HxSkinHighlight HxColors]`

This section defines the colors that can be used for skin highlights, saved in `User.ini`.
To manage the colors via the configuration menu, go to the Skin Highlight tab, click on the "Customize Colors" button, and it will open a separate window.

#### `ColorList`

List of colors that can be used for skin highlights.

Default value is:
```ini
ColorList=(Name="Blue",Color=(R=0,G=0,B=255,A=255),bRandom=True)
ColorList=(Name="Green",Color=(R=0,G=255,B=0,A=255),bRandom=True)
ColorList=(Name="Orange",Color=(R=255,G=100,B=0,A=255),bRandom=True)
ColorList=(Name="Pink",Color=(R=255,G=0,B=255,A=255),bRandom=True)
ColorList=(Name="Red",Color=(R=255,G=0,B=0,A=255),bRandom=True)
ColorList=(Name="Teal",Color=(R=0,G=255,B=255,A=255),bRandom=True)
ColorList=(Name="Yellow",Color=(R=255,G=255,B=0,A=255),bRandom=True)
```

Each color has a name, its RGBA value, and a flag `bRandom` that defines if it can be used as part of a random pool of colors.

### `[HexedUT HxSkinHighlightConfig]`

This section contains all user options for skin highlights and forced models, saved in `User.ini`.
They can be changed in the Skin Highlight tab of the configuration menu.

#### `Teammates` and `Enemies`

Specify the name of the color for highlighting you/teammates and enemies.
It should either match one of the color names in your `ColorList`, or the special value `DISABLED`, which disables skin highlight.
Default value is `DISABLED`.

#### `ShieldHit`, `LinkHit`, `ShockHit` and `LightningHit`

When you hit an enemy with certain weapons, the game shows a special overlay effect on the skin of the enemy to indicate the hit.
These are the link hit (link gun/bio rifle), shock hit (shock rifle), and lightning hit (lightning gun).
Additionally, the game also has a special overlay effect when hitting enemies with armor (shield hit).

When skin highlights are enabled, you can control which color is used to display these effects.
Just like `Teammates` and `Enemies`, valid values are any color names from your `ColorList`.
In addition to `DISABLED`, there are two more special values:
* `DEFAULT`: uses a pre-defined default color, trying to resemble the color of the original effect.
* `NATIVE`: uses the original effect. Because skin highlight and the effect can't be enabled together, players will appear to temporarily loose the highlight for a short moment at the end of the effect.

Default value is `DEFAULT`.

#### `TeammateProtected` and `EnemyProtected`

Very similar to the options described in the [previous section](#teammateprotected-and-enemyprotected), they control the color to show when a player is protected by the spawn protection mechanism.

Default value is `DEFAULT`.

#### `TeammateSkin` and `EnemySkin`

The game has three variants for each player skin: a red-tinted variant for the red team, a blue-tinted one for the blue team, and a normal variant for DeathMatch-like game types.
When you enable skin highlights, you can also specify which skin variant should be used: `HX_SKIN_RedTeam`, `HX_SKIN_BlueTeam`, or `HX_SKIN_Normal`.

Default value is `HX_SKIN_Normal`.

#### `bRandomize`

Enables randomized colors for enemies (see `bRandom` in [`ColorList`](#colorlist)) in game types with no teams.
For this option to take effect, you need a color selected as highlight for enemies.

Default value is `False`.

#### `bDisableOnDeadBodies`

Controls if the skin highlight should be immediately disabled on dead bodies.

Default value is `False`.

#### `bDisableOnHeads`

Disables the skin highlight on player heads.
This is a compatibility option for players that prefer the way UTComp implements brightskins.

Default value is `False`.

#### `HighlightMode`

Controls how to decide which color to use. Possible values:
* `HX_SHM_RoleBased`: assign `Teammates` color to teammates and `Enemies` color to enemies. If you change teams, your teammates and enemies are re-colored accordingly.
* `HX_SHM_TeamBased`: assign `Teammates` to the red team and `Enemies` to the blue team. Colors are fixed, regardless of which team you're part of.

Default value is `HX_SHM_RoleBased`.

#### `SpectatorTeam`

If your `HighlightMode` is `HX_SHM_RoleBased`, this option controls which team you're "part of" while spectating to decide the color assignment.
Possible values:
* 0: red team.
* 1: blue team.

Default value is 0.

#### `bForceTeammateModel` and `bForceEnemyModel`

Controls if a specific player model should be forced on teammates and enemies. See the section below for more details.

Default value is `False`.

#### `PreferredTeammateModel`/`CurrentTeammateModel` and `PreferredEnemyModel`/`CurrentEnemyModel`

Specifies the name of the player models to be used when forcing models.
The "preferred" options specify the models you want when there are no server restrictions on usable models.
The "current" options specify the models being used in the current server with the current restrictions.

In general, avoid changing these options directly and use the configuration menu instead.
They work in a way to try to remember your preferred option, while still respecting the server restrictions.

When you join a server with higher restrictions that exclude your preferred model, it will not be used.
If you change the model in the configuration menu while connected to this server, it will change the current model and keep the preferred one untouched.
This way, if you join another server that allows your preferred model, it automatically changes back to it.

Default value is `Jakob`.

### `[HexedUT HxUTPlayerConfig]`

This section contains all user options for player camera and movement, saved in `User.ini`.
They can be changed in the General tab of the configuration menu, under User Options.

#### `ViewSmoothing`

Controls how your view is smoothed when walking over irregular terrain, stairs and ramps.
Possible values:
* `HX_VS_Default`: uses the game's default view smoothing.
* `HX_VS_Moderate`: disables view smoothing when walking on any surfaces with more than ~16 degrees of inclination.
* `HX_VS_Weak`: disables view smoothing when walking on any surfaces with more than ~8 degrees of inclination.
* `HX_VS_Disabled`: no view smoothing at all, prepare for a bumpy ride.

Default value is `HX_VS_Default`.

### `[HexedUT HxSPTimerConfig]`

This section contains all user options for the spawn protection timer, saved in `User.ini`.
They can be changed in the HUD tab of the configuration menu.

#### `bEnabled`

Toggles the spawn protection timer on/off.
The spawn protection timer tracks how much time left of spawn protection you have.

Default is `True`.

#### `bUseHUDColor` and `CustomColor`

If `bUseHUDColor` is set to true, the timer will use the same color as the rest of the HUD.
Otherwise, the color specified in `CustomColor`.

Defaults are `True` for `bUseHUDColor` and `(R=239,G=191,B=4,A=255)` for `CustomColor`.

#### `bPulsingDigits`

Toggle pulsing digits on/off. Might help you notice it easier.

Default is `False`.

#### `PosX` and `PosY`

Defines the position of the timer on the screen, with values between 0.0 and 1.0, where 0.0 is left/top and 1.0 is right/bottom.

Default values are 0.95 and 0.64, which puts it at the right edge of the screen, close to the position where UDamage duration is displayed.

## HexedVOTE

The mutator that provides an enhanced map vote menu.

### `[HexedVOTEv10.MutHexedVOTE]`

This section contains all server options for HexedVOTE.

#### `VoteListCustomBG`, `MapListCustomBG`, `PreviewCustomBG` and `ChatBoxCustomBG`

Custom background textures for the votes list (~16:3 aspect ratio), maps list (~9:5 aspect ratio), map preview banner (~9:10 aspect ratio), and chat box (~22:7 aspect ratio).
Each custom background should contain the fully qualified `PackageName.TextureName` string of the texture to be used.

If the texture doesn't match the proportions of the background, it will be **centered and scaled** to fit.
Make sure to include the package containing the custom backgrounds to your `ServerPackages` configuration.
The textures are alpha-blended with the default background, so you can rely on transparency to create subtle logos/watermarks.

Default value is empty (no custom background).

#### `MapPreviewLoaders`

Map preview loaders allow you to specify custom loader classes to provide missing map previews.
For more information on how to configure it check out [HexedUT2k4 Map Previews](https://github.com/hexengraf/HexedUT2k4-Map-Previews), a separate repository exclusively dedicated for map preview loaders.

Example configuration:
```ini
MapPreviewLoaders=HexedPreviewsBASEv2.HxLoader
MapPreviewLoaders=HexedPreviewsUCMPv2.HxLoader
```

### `[Maps HxFavorites]`

This section contains all map favorites, saved in `HexedFavorites.ini`.
Map favorites can be defined directly in the map vote menu, by right clicking a map and selecting if you like or dislike it.

#### `List`

List of the map favorites, e.g.:
```ini
List=(Name="DM-1on1-Albatross",Tag=HX_TAG_Like)
List=(Name="DM-1on1-Crash",Tag=HX_TAG_Dislike)
```

Each entry has the map name and a tag specifying if the map is liked or disliked.

### Map list filters

Map list filters can be created, modified, and deleted directly via the map vote menu, by clicking the Manage Filters button which opens up a separate window.
Everything is saved in a file called `HexedFilters.ini` with the following structure:
```ini
[FilterName HxMapFilter]
MapName=
AuthorName=
NumPlayers=
TimesPlayed=
MapSource=HX_MAP_SOURCE_Any
MapTag=HX_TAG_Any
FilterListMode=HX_FILTER_MODE_Include
FilterList=
```

Where `FilterName` is the name of the filter.
See the following sections for a explanation of each filter option.

#### `MapName`

Pattern to filter maps by name (e.g. "1-on-1" to get all maps with 1-on-1 in the name).

#### `AuthorName`

Pattern to filter maps by their author name(s).

#### `NumPlayers`

Pattern to filter maps by the number of players (e.g. "8" for maps recommended for 8 players, or "<5" for maps recommended for up to 4 players).

#### `TimesPlayed`

Pattern to filter maps by the number of times played (e.g. ">100" for maps played more than 100 times).

#### `MapSource`

Filter maps by their source:
* `HX_MAP_SOURCE_Any`: no filter, any source is allowed.
* `HX_MAP_SOURCE_Official`: only official maps are selected.
* `HX_MAP_SOURCE_Custom`: only custom maps are selected.

#### `MapTag`

Filter maps by their tag:
* `HX_TAG_Any`: no filter, any tag is allowed.
* `HX_TAG_Like`: only liked maps are selected.
* `HX_TAG_None`: only maps with no tag are selected.
* `HX_TAG_Dislike`: only disliked maps are selected.

#### `FilterListMode`

How the explicit filter list should be used:
* `HX_FILTER_MODE_Include`: include the listed maps in the result.
* `HX_FILTER_MODE_Exclude`: exclude the listed maps from the result.

#### `FilterList`

Explicit filter list, each entry should contain a valid map name, e.g.:
```ini
FilterList="DM-1on1-Albatross"
FilterList="DM-Deck17"
FilterList="DM-Gestalt"
```

## HexedCONTROL

The mutator that provides enhanced control over existing game mechanics and map resources.

### `[HexedARENAv10.MutHexedCONTROL]`

This section contains all server options for HexedCONTROL, saved in `HexedMutators.ini`.

#### `BonusHealth`, `BonusShield` and `BonusARGrenades`

Defines a bonus amount to add to health, shield and assault rifle's grenades when a player spawns.
Valid bonus health values are between -99 and 99, shield values between 0 and 150, and grenades between -4 and 99.

Default value is 0.

#### `BonusAdrenaline` and `BonusAdrenalineOnSpawn`

Defines a bonus amount to add to adrenaline when the match starts and at every spawn.
Valid bonus adrenaline values are between 0 and 100, while at spawn it can be anything between -100 and 100.

Default value is 0.

#### `SelfDamageScale`

Defines the self-inflicted damage scale, between 0.0 (no damage) and 1.0 (full damage).

Default value is 1.0.

#### `HealthLeechRatio` and `HealthLeechLimit`

Similar to the vampire mutator, but here you can control the exact ratio that damage is converted to health, and up to how much health can be recovered this way.
Valid ratio value is between 0.0 and 1.0, and limit is between 0 and 199.

Default values are 0.0 and 0.

#### `bNoSpeedCombo`, `bNoBerserkCombo`, `bNoBoosterCombo` and `bNoInvisibleCombo`

Disables specific adrenaline combos (speed, berserk, booster, and invisible).

Default value is `False`.

#### `bNoAdrenalinePills`, `bNoHealthVials`, `bNoHealthPacks`, `bNoSuperHealthPacks`, `bNoShieldPacks`, `bNoSuperShieldPacks`, `bNoUDamagePacks`, `bNoAmmoPacks`

Removes specific pick-ups from the map (adrenaline pills, health vials, health packs, super health packs, shield packs, super shield packs, UDamage packs, and ammo packs).

Default value is `False`.

#### `AirControlMultiplier` and `BaseJumpMultiplier`

Multiplies the default air control and initial jump acceleration.

Default value is 1.0, valid values between -10.0 and 10.0.

#### `MaxSpeedMultiplier` and `MultiJumpMultiplier`

Multiplies the default maximum speed and multi-jump acceleration boost.

Default value is 1.0, valid values between -100.0 and 100.0.

#### `BonusMultiJumps`

Defines a bonus to add to base amount of multi-jumps.

Default is 0, valid values between -1 and 99.

#### `DodgeMultiplier` and `DodgeSpeedMultiplier`

Multiplies the default dodge acceleration (Z-axis) and dodge speed factor.

Default value is 1.0, valid values between -10.0 and 10.0.

#### `bNoWallDodge` and `bNoDodgeJump`

Disables wall dodge and dodge jump (UT Classic settings).

Default is `False`.

## HexedARENA

The mutator for Arena games (replace all weapons with a specific weapon), with support for URL options to create different game modes.

### `[HexedARENAv10.MutHexedARENA]`

This section contains all server options for HexedARENA, saved in `HexedMutators.ini`.

#### `ArenaWeaponClassName`

Determines which weapon will be used in the arena match.

Default value is `"XWeapons.RocketLauncher`.

## HexedINSTAGIB

The mutator for instagib, supporting custom fire rates and custom zoom overlay.

### `[HexedARENAv10.MutHexedINSTAGIB]`

This section contains all server options for HexedINSTAGIB, saved in `HexedMutators.ini`.

#### `bAllowTranslocator`

Players spawn with the Translocator in their inventory.

Default is `False`.

#### `bAllowBoost`

Teammates get a big boost when shot by the instagib rifle.

Default is `False`.

#### `bZoomInstagib`

Enable instagib rifles with sniper scopes.

Default is `False`.

#### `FireRate`

Controls the fire rate of instagib rifle. If set to 0, it uses the original fire rate.

Default value is `0.0`.

### `[HexedARENA HxZoomSuperShockRifleConfig]`

This section contains all user options for scope overlay and crosshair, saved in `User.ini`.
They can be changed in the Instagib tab of the configuration menu.

#### `ScopeOverlay`

Defines which scope overlay to use. Possible values:
* `HX_SCOPE_Default`: the default scope overlay, same as lightning gun.
* `HX_SCOPE_Custom`: the custom scope overlay provided by the mutator.
* `HX_SCOPE_Hidden`: no scope overlay.

Default is `HX_SCOPE_Custom`.

#### `bSoundEffects`

Enables sound effects when zooming in/out.

Default is `True`.

#### `bShowChargeBar`

Shows a charge bar to indicate when the weapon is ready to shoot.

Default is `True`.

#### `ReticleColor` and `ReticleScale`

The color and scale of the scope reticle.

Default values are `(R=32,G=32,B=32,A=255)` and 0.5.

#### `BackgroundOpacity`

The opacity of black background around the scope.

Default value is 0.3.

#### `bCustomZoomCrosshair`

Enables a different custom crosshair while zooming.
Only works if custom weapon crosshairs are enabled.

Default is `False`.

#### `CustomZoomCrosshair` and `CustomZoomCrosshairTextureName`

Which custom crosshair to use while zooming if `bCustomZoomCrosshair` is true.

Default values are 7 and `Crosshairs.HUD.Crosshair_Cross1`.

#### `CustomZoomCrosshairColor` and `CustomZoomCrosshairScale`

The color and scale of the custom crosshair used while zooming if `bCustomZoomCrosshair` is true.

Default values are `(R=255,G=32,B=32,A=230)` and 1.0.

## HexedNET

The mutator for lag compensation.

### `[HexedNETv10.MutHexedNET]`

This section contains all server options for HexedNET, saved in `HexedMutators.ini`.

#### `PingFrequency`

Controls how many times per second a connected player and the server exchange packets to determine the player's average ping.

In general, there is no reason to change the default value, but if your server is having bandwidth issues, you can drop this value to 1 ping per second.

Default value is 2.0 pings/second.

#### `LagCompensationLimit`

Global upper limit of how much ping can be compensated. E.g. if a player has 350 ms ping and the limit is 300 ms, it will only compensate 300 ms ping.

Default value is 300 milliseconds.

#### `ProjectileCompensationLimit`

Upper limit of how much ping can be compensated for weapon projectiles.
This limit is still bound by `LagCompensationLimit`, so configuring it higher than `LagCompensationLimit` doesn't have any effect.

Projectiles are forwarded by the server to compensate ping, so other players see them appearing in the middle of their trajectory instead of starting at the shooter's position.
How far in the trajectory depends how high the ping of the shooter is and how fast is the projectile.
This is why the default limit for projectiles is lower, otherwise players might get hit by "invisible" projectiles from high ping players.

Default value is 125 milliseconds.

#### `MaxCollisionCheckRate`

Controls the maximum rate to check for projectile collisions during server-side forwarding.

When the server forwards projectiles to compensate ping, it performs collision checks to determine if the projectile hits a player in a past position.
The actual check frequency is the minimum between the server's tick rate and this option.
The default value should be optimal, but if your server is struggling to keep a stable tick rate, you might want to reduce this value or reduce the tick rate.

Default value is 60 checks/second.

#### `bBoostedAimSynchronization`

Enables Boosted Aim Synchronization (BAS).

When you press the left/right mouse button to fire a weapon, the game sends a message to the server saying "start fire" with the corresponding fire mode (primary or secondary).
When you release the mouse button, the game sends another message to the server saying "stop fire" with the corresponding fire mode.
The messages are short and only happen when you click/release the buttons, which was great for the limited internet bandwidth of the early 2000s.
The downside is: your location and camera rotation when you press fire might not match what the server considers your current location and camera rotation.

In practical terms, your shots might lag behind your aim instead of happening precisely at the point you were aiming when you pressed fire.
This problem can happen regardless how high or low your ping is, and that is why shooting in the middle of fast camera movements (flick shots) have lower precision and are harder to hit.

BAS changes the "start fire" and "stop fire" messages to include additional information that helps synchronize the server to match your aim.
It sends the your location and camera rotation at the moment you press fire, so the server can use them instead of the (potentially) lagged location/rotation.

Keep in mind: BAS can't be applied to minigun and link gun's alt fire due to their wind up mechanics.

Default value is `True`.

#### `LocationErrorTolerance`

Controls the maximum acceptable difference between the BAS location and the current server location.

If the difference is bigger than the configured tolerance, BAS information is rejected and the server uses it's own location/rotation to determine the start point of the shot.
It is important to have an error limit to prevent cheaters exploiting BAS to implement aim bots.

Default value is 36 unreal units, which is close to the ~35.35 unreal units used by UTComp.

#### `AngleErrorTolerance`

Controls the maximum acceptable difference between the BAS rotation and the current server rotation.

Same logic as `LocationErrorTolerance`, but for the camera rotation instead.
Values range between -1.0 and 1.0, where -1.0 accepts any rotation, 0.0 is a tolerance of 90 degrees, and 1.0 requires the rotations to be perfectly aligned.
For refernce, UTComp doesn't check this difference (equivalent to -1.0).

Default value is -0.5, which accepts up to 120 degrees of difference.

#### `bForceStartFireRPCs`

Forces a new start fire RPC for every shot while holding the fire button.

As explained [above](#bboostedaimsynchronization), a message is sent to the server every time you click/release the fire button.
But what happens when you hold the button and to fire multiple shots?
BAS information can only be added to the first shot, all the other shots have to rely on the server information instead.

When this option is enabled, the weapon automatically sends a "stop fire" to the server, even if you're still holding the button, to simulate several clicks.
This way, every shot receives the corresponding BAS information.

There are side-effects if this option is enabled.
For instance, when you hold shock rifle's secondary and then hold primary, it starts shooting primary shots.
The normal behavior is to keep shooting secondary shots and ignore the primary fire being hold.

If your server changes the fire rates of weapons to be much higher (sub 0.3), you may want to disable this option.
There might be other unforeseen side-effects when operating weapons with super high fire rates.

Default value is `True`.

#### `bClientSideCollisions`

Enhances BAS information with the result of client-side collision detection for hitscan weapons.

Lag compensation attempts to align all player positions to the match exactly what the shooter sees on their screen the moment they fire a hitscan weapon.
To do so, it keeps track of the shooter's average ping and uses this value to rewind the position of all other players.
However, this rewind based on average ping might miss the mark, leading to either unregistered hits or ghost hits (a visible miss that still hits).
It usually happens due to ping spikes and/or simulation mismatches.

Enabling this option mitigates the problem: now the server knows if the shooter saw their shot landing on someone, so it can try to correct the rewinding to match it.
Ultimately it is the server who decides to accept or reject what the client sent, and that is controlled by the option below.

Default value is `True`.

#### `PingSpikeTolerance`

Controls the maximum acceptable ping spike when validating client-side collisions.

When the initial rewind doesn't match what the collision information sent by the client, the server tries to find another moment in the past that matches it.
In very simple terms, this option controls how far from the average ping the server can search for a matching collision.

Higher tolerances accommodate higher ping spikes, but also put a bigger burden on the server who has to search a bigger time window to validate the collision.
There is also a cheating angle to be careful of, since the client could be spoofing the collision information, so avoid increasing this tolerance too much.

Default value is 60 milliseconds.

#### `bRubberbandingFix`

Enables backport of OldUnreal's rubberbanding fix.

Use this option if your server has players with an unpatched version of the game.
Just beware that enabling this option causes `xPlayer` to be replaced, potentially creating conflict with other mutators that replace `xPlayer`.

Default value is `False`.

#### `bLinkMeshes`

Controls if meshes are linked for collision detection during rewinding.

The only reason this option exists is because one of WSUTComp's developers mentioned crashes when the linking is enabled.
If future investigation concludes there is no risks of crash, this option will be removed.

Default value is `True`.

### `[HexedNET HxNetcodeConfig]`

This section contains all user options for lag compensation, saved in `User.ini`.
They can be changed in the General tab of the configuration menu, under User Options.

#### `bLagCompensation`

Enables the lag compensation.

Default value is `True`.
