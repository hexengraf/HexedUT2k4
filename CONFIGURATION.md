# HexedUT

## User options

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
;   HX_DMGNUM_LastHit - shows the damage of the last hit.
;   HX_DMGNUM_Total - shows accumulated damage of hits with less than a second a part.
;   HX_DMGNUM_LastHitAndTotal - shows the information of the two modes above at the same time.
DisplayMode=HX_DMGNUM_LastHitAndTotal
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
;   HX_VS_Moderate - disable view smoothing when walking on any surfaces with more than ~16 degrees of inclination.
;   HX_VS_Weak - disable view smoothing when walking on any surfaces with more than ~8 degrees of inclination.
;   HX_VS_Disabled - no view smoothing at all, prepare for a bumpy ride.
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

## Server options

The following section is saved in `HexedMutators.ini`:
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
SkinOverlayIntensity=0.55
; Control which kinds of hit overlays are allowed when highlight is enabled.
; Possible values:
;   HX_HO_UserControlled - allows each player to decide the colors for each hit overlay.
;   HX_HO_ForceDefault - force all hit overlays to use the default colors.
;   HX_HO_ForceNative - force all hit overlays to use the native game effects.
;   HX_HO_IntensityOnly - force all hit overlays to use the same color as the highlight, only changing the intensity applied.
;   HX_HO_Disabled - force all hit overlays to be disabled.
AllowHitOverlays=HX_HO_UserControlled
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
; Hide disabled features from the server status list.
bHideDisabledFeatures=False
```

# HexedVOTE

## User options

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

## Server options

The following section is saved in `HexedMutators.ini`:
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

# HexedCONTROL

## Server options

The following section is saved in `HexedMutators.ini`:
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

# HexedARENA

## Server options

The following section is saved in `HexedMutators.ini`:
```ini
[HexedARENAv9.MutHexedCONTROL]
; Determines which weapon will be used in the arena match.
ArenaWeaponClassName="XWeapons.RocketLauncher"
```

# HexedINSTAGIB

## User options

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

## Server options

The following section is saved in `HexedMutators.ini`:
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

# HexedNET

## User options

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

## Server options

The following section is saved in `HexedMutators.ini`:
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

> [!TIP]
> Compatibility with other mods should be somewhat improved, since `xPlayer` and `xPawn` are no longer replaced.
> Beware that `xPlayer` will be replaced if you enable `bRubberbandingFix`.
