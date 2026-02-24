class HxSkinHighlight extends Actor
    config(User);

struct HxColorEntry
{
    var string Name;
    var Color Color;
    var bool bRandom;
};

struct HxCacheEntry
{
    var string Player;
    var string Highlight;
};

const NO_HIGHLIGHT = "DISABLED";
const RANDOM_HIGHLIGHT = "RANDOM";
const DEFAULT_HIGHLIGHT = "DEFAULT";
const HIT_COLOR_MULTIPLIER = 1.75;
const HIT_COLOR_FADE_PERIOD = 0.5;

var config string YourTeam;
var config string EnemyTeam;
var config string SoloPlayer;
var config string ShieldHit;
var config string LinkHit;
var config string ShockHit;
var config string LightningHit;
var config bool bDisableOnDeadBodies;
var config bool bForceNormalSkins;
var config int SpectatorTeam;
var config array<HxColorEntry> Colors;
var config array<HxCacheEntry> Cache;
var float HighlightIntensity;

var private PlayerController PC;
var private array<Material> OriginalSkins;
var private array<Material> Materials;
var private ConstantColor HighlightEffect;
var private Shader HighlightShader;
var private Color MainColor;
var private Color HitColors[4];
var private Material HitMaterials[4];
var private byte bDisableHitEffect[4];
var private int HitIndex;
var private bool bInitialized;
var private bool bEnabled;
var private bool bSkinUpdated;
var private bool bOnSpawnProtection;
var private byte LocalPlayerTeam;
var private array<string> RandomPool;
var private array<HxCacheEntry> OldCache;

replication
{
    reliable if (Role == ROLE_Authority)
        HighlightIntensity;
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        HighlightEffect = ConstantColor(AllocateMaterial(class'ConstantColor'));
        HighlightShader = Shader(AllocateMaterial(class'Shader'));
        HighlightShader.Specular = HighlightEffect;
        LocalPlayerTeam = 255;
        bInitialized = Initialize(xPawn(Base));
    }
}

simulated event Destroyed()
{
    local int i;

    for (i = 0; i < Materials.Length; ++i)
    {
        Level.ObjectPool.FreeObject(Materials[i]);
    }
    Super.Destroyed();
}

simulated event Tick(float DeltaTime)
{
    local xPawn Pawn;

    if (Level.NetMode != NM_DedicatedServer)
    {
        Pawn = xPawn(Base);
        if (!bInitialized || LocalPlayerTeam != GetLocalPlayerTeam())
        {
            bInitialized = Initialize(Pawn);
        }
        else if (Pawn != None)
        {
            if (bEnabled && Pawn.bAlreadySetup && !Pawn.bInvis && !Pawn.bOldInvis && !Pawn.bDeRes)
            {
                if (bForceNormalSkins && !bSkinUpdated)
                {
                    ForceNormalSkin(Pawn);
                }
                UpdateOverlay(Pawn);
            }
        }
    }
    super.Tick(DeltaTime);
}

simulated function bool Initialize(xPawn Pawn)
{
    if (HighlightIntensity == -1)
    {
        return false;
    }
    if (PC == None)
    {
        PC = Level.GetLocalPlayerController();
    }
    if (Pawn != None && PC != None && Level.GRI != None
        && PC.PlayerReplicationInfo != None && Pawn.PlayerReplicationInfo != None
        && Pawn.PlayerReplicationInfo.PlayerName != "")
    {
        LocalPlayerTeam = GetLocalPlayerTeam();
        InitializeHighlight(Pawn);
        InitializeHitEffects(Pawn);
        InitializeSkins(Pawn);
        return true;
    }
    return false;
}

simulated function InitializeHighlight(xPawn Pawn)
{
    local string Name;

    if (!Level.GRI.bTeamGame)
    {
        if (default.RandomPool.Length == 0)
        {
            InitializeRandomPool();
        }
        if (SoloPlayer == RANDOM_HIGHLIGHT)
        {
            Name = GetRandomColor(Pawn.PlayerReplicationInfo.PlayerName);
        }
        else
        {
            Name = SoloPlayer;
        }
        bSkinUpdated = true;
    }
    else
    {
        Name = Eval(Pawn.GetTeamNum() != LocalPlayerTeam, EnemyTeam, YourTeam);
    }
    bEnabled = !IsReservedColorName(Name);
    if (bEnabled)
    {
        FindColor(Name, MainColor);
        MainColor.R = MainColor.R * HighlightIntensity;
        MainColor.G = MainColor.G * HighlightIntensity;
        MainColor.B = MainColor.B * HighlightIntensity;
    }
}

simulated function InitializeHitEffects(xPawn Pawn)
{
    local int i;

    for (i = 0; i < ArrayCount(HitColors); ++i)
    {
        HitMaterials[i] = None;
    }
    if (ShieldHit != DEFAULT_HIGHLIGHT)
    {
        HitColors[0] = GetHitColor(ShieldHit);
        HitMaterials[0] = Pawn.ShieldHitMat;
        bDisableHitEffect[0] = byte(ShieldHit == NO_HIGHLIGHT);
    }
    if (LinkHit != DEFAULT_HIGHLIGHT)
    {
        HitColors[1] = GetHitColor(LinkHit);
        HitMaterials[1] = Shader'XGameShaders.PlayerShaders.LinkHit';
        bDisableHitEffect[1] = byte(LinkHit == NO_HIGHLIGHT);
    }
    if (ShockHit != DEFAULT_HIGHLIGHT)
    {
        HitColors[2] = GetHitColor(ShockHit);
        HitMaterials[2] = Shader'UT2004Weapons.Shaders.ShockHitShader';
        bDisableHitEffect[2] = byte(ShockHit == NO_HIGHLIGHT);
    }
    if (LightningHit != DEFAULT_HIGHLIGHT)
    {
        HitColors[3] = GetHitColor(LightningHit);
        HitMaterials[3] = Shader'XGameShaders.PlayerShaders.LightningHit';
        bDisableHitEffect[3] = byte(LightningHit == NO_HIGHLIGHT);
    }
    HitIndex = -1;
}

simulated function InitializeSkins(xPawn Pawn)
{
    local int i;

    if ((!bForceNormalSkins || !bEnabled) && OriginalSkins.Length > 0)
    {
        for (i = 0; i < OriginalSkins.Length; ++i)
        {
            if (OriginalSkins[i] != None)
            {
                Pawn.Skins[i] = OriginalSkins[i];
            }
        }
        OriginalSkins.Remove(0, OriginalSkins.Length);
        bSkinUpdated = false;
    }
}

simulated function Reinitialize()
{
    YourTeam = default.YourTeam;
    EnemyTeam = default.EnemyTeam;
    SoloPlayer = default.SoloPlayer;
    bDisableOnDeadBodies = default.bDisableOnDeadBodies;
    bForceNormalSkins = default.bForceNormalSkins;
    SpectatorTeam = default.SpectatorTeam;
    bInitialized = false;
    DisableHighlight();
}

simulated function UpdateOverlay(xPawn Pawn)
{
    local float Fade;
    local int i;

    if (Pawn.OverlayMaterial == None || (bOnSpawnProtection && Pawn.bSpawnDone))
    {
        HighlightEffect.Color = MainColor;
        Pawn.SetOverlayMaterial(HighlightShader, 300, true);
        bOnSpawnProtection = false;
        HitIndex = -1;
    }
    else
    {
        for (i = 0; i < ArrayCount(HitMaterials); ++i)
        {
            if (Pawn.OverlayMaterial == HitMaterials[i])
            {
                Pawn.OverlayMaterial = HighlightShader;
                bOnSpawnProtection = !Pawn.bSpawnDone;
                HitIndex = i;
                break;
            }
        }
    }
    if (HitIndex > -1)
    {
        if (bDisableHitEffect[HitIndex] > 0)
        {
            HighlightEffect.Color = MainColor;
        }
        else
        {
            Fade = FClamp(Pawn.ClientOverlayCounter / HIT_COLOR_FADE_PERIOD, 0.0, 1.0);
            HighlightEffect.Color = (HitColors[HitIndex] * Fade) + (MainColor * (1.0 - Fade));
        }
    }
}

simulated function ForceNormalSkin(xPawn Pawn)
{
    local Material Skin;
    local int i;

    for (i = 0; i < Pawn.Skins.Length; ++i)
    {
        Skin = GetNormalSkin(Pawn.Skins[i]);
        if (Skin != None)
        {
            OriginalSkins.Length = i + 1;
            OriginalSkins[i] = Pawn.Skins[i];
            Pawn.Skins[i] = Skin;
            Skin = None;
        }
    }
    bSkinUpdated = true;
}

simulated function int GetLocalPlayerTeam()
{
    if (PC.PlayerReplicationInfo.bOnlySpectator)
    {
        SpectatorTeam = Clamp(SpectatorTeam, 0, 1);
        return SpectatorTeam;
    }
    return PC.GetTeamNum();
}

simulated function Color GetHitColor(string Name)
{
    local Color Color;

    FindColor(Name, Color);
    Color.R = Min(Color.R * HighlightIntensity * HIT_COLOR_MULTIPLIER, 255);
    Color.G = Min(Color.G * HighlightIntensity * HIT_COLOR_MULTIPLIER, 255);
    Color.B = Min(Color.B * HighlightIntensity * HIT_COLOR_MULTIPLIER, 255);
    return Color;
}

simulated function string GetRandomColor(string Player)
{
    local int i;

    for (i = 0; i < default.Cache.Length; ++i)
    {
        if (default.Cache[i].Player == Player)
        {
            return default.Cache[i].Highlight;
        }
    }
    for (i = 0; i < default.OldCache.Length; ++i)
    {
        if (default.OldCache[i].Player == Player)
        {
            default.Cache[default.Cache.Length] = default.OldCache[i];
            RemoveFromRandomPool(default.OldCache[i].Highlight);
            StaticSaveConfig();
            return default.OldCache[i].Highlight;
        }
    }
    i = default.Cache.Length;
    default.Cache.Length = i + 1;
    default.Cache[i].Player = Player;
    default.Cache[i].Highlight = GetFromRandomPool();
    StaticSaveConfig();
    return default.Cache[i].Highlight;
}

simulated function string GetFromRandomPool()
{
    local int Index;
    local string Name;

    Index = Rand(default.RandomPool.Length);
    Name = default.RandomPool[Index];
    default.RandomPool.Remove(Index, 1);
    if (default.RandomPool.Length == 0)
    {
        PopulateRandomPool();
    }
    return Name;
}

simulated function DisableHighlight()
{
    local xPawn Pawn;

    Pawn = xPawn(Base);
    if (Pawn != None && Pawn.OverlayMaterial == HighlightShader)
    {
        Pawn.SetOverlayMaterial(None, 1, true);
    }
    bEnabled = false;
}

simulated function Material AllocateMaterial(class<Material> MaterialClass)
{
    local Material NewMaterial;

    NewMaterial = Material(Level.ObjectPool.AllocateObject(MaterialClass));
    Materials[Materials.Length] = NewMaterial;
    return NewMaterial;
}

simulated function PawnBaseDied()
{
    if (Level.NetMode != NM_DedicatedServer && bDisableOnDeadBodies)
    {
        DisableHighlight();
    }
}

static function Material GetNormalSkin(coerce string Name)
{
    local Material Skin;
    local string Suffix;

    Suffix = Right(Name, 3);
    if (Suffix ~= "_0B" || Suffix ~= "_1B")
    {
        Name = Left(Name, Len(Name) - 3);
        if (StrCmp(Name, "Bright", 6, false) == 0)
        {
            Name = Right(Name, Len(Name) - 6);
        }
        Skin = Material(DynamicLoadObject(Name, class'Material', true));
    }
    else
    {
        Suffix = Right(Suffix, 2);
        if (Suffix == "_0" || Suffix == "_1")
        {
            Name = Left(Name, Len(Name) - 2);
            Skin = Material(DynamicLoadObject(Name, class'Material', true));
        }
    }
    return Skin;
}

static function bool IsValidColorIndex(int Index)
{
    return Index >= 0 && Index < default.Colors.Length;
}

static function bool IsReservedColorName(string Name)
{
    return Name == ""
        || Name == NO_HIGHLIGHT
        || Name == RANDOM_HIGHLIGHT
        || Name == DEFAULT_HIGHLIGHT;
}

static function bool IsValidColorName(string Name)
{
    return !IsReservedColorName(Name) && FindColor(Name) == -1;
}

static function int AllocateColor(string Name, optional bool bRandom)
{
    local int Index;

    if (!IsValidColorName(Name))
    {
        return -1;
    }
    Index = default.Colors.Length;
    default.Colors.Length = Index + 1;
    default.Colors[Index].Name = Name;
    default.Colors[Index].bRandom = bRandom;
    return Index;
}

static function bool DeleteColor(int Index)
{
    if (!IsValidColorIndex(Index))
    {
        return false;
    }
    if (default.YourTeam == default.Colors[Index].Name)
    {
        default.YourTeam = NO_HIGHLIGHT;
    }
    if (default.EnemyTeam == default.Colors[Index].Name)
    {
        default.EnemyTeam = NO_HIGHLIGHT;
    }
    if (default.SoloPlayer == default.Colors[Index].Name)
    {
        default.SoloPlayer = NO_HIGHLIGHT;
    }
    ValidateCache(default.Cache);
    ValidateCache(default.OldCache);
    RemoveFromRandomPool(default.Colors[Index].Name);
    default.Colors.Remove(Index, 1);
    return true;
}

static function bool ChangeColorName(int Index, string Name)
{
    local int i;

    if (!IsValidColorName(Name) || !IsValidColorIndex(Index))
    {
        return false;
    }
    if (default.YourTeam == default.Colors[Index].Name)
    {
        default.YourTeam = Name;
    }
    if (default.EnemyTeam == default.Colors[Index].Name)
    {
        default.EnemyTeam = Name;
    }
    if (default.SoloPlayer == default.Colors[Index].Name)
    {
        default.SoloPlayer = Name;
    }
    for (i = 0; i < default.OldCache.Length; ++i)
    {
        if (default.OldCache[i].Highlight == default.Colors[Index].Name)
        {
            default.OldCache[i].Highlight = Name;
        }
    }
    for (i = 0; i < default.Cache.Length; ++i)
    {
        if (default.Cache[i].Highlight == default.Colors[Index].Name)
        {
            default.Cache[i].Highlight = Name;
        }
    }
    for (i = 0; i < default.RandomPool.Length; ++i)
    {
        if (default.RandomPool[i] == default.Colors[Index].Name)
        {
            default.RandomPool[i] = Name;
        }
    }
    default.Colors[Index].Name = Name;
    return true;
}

static function bool SetColorRandom(int Index, bool bRandom)
{
    local int i;

    if (!IsValidColorIndex(Index))
    {
        return false;
    }
    if (default.Colors[Index].bRandom ^^ bRandom)
    {
        for (i = 0; i < default.OldCache.Length; ++i)
        {
            if (default.OldCache[i].Highlight == default.Colors[Index].Name)
            {
                default.OldCache.Remove(i, 1);
                --i;
            }
        }
        for (i = 0; i < default.Cache.Length; ++i)
        {
            if (default.Cache[i].Highlight == default.Colors[Index].Name)
            {
                default.Cache.Remove(i, 1);
                --i;
            }
        }
        for (i = 0; i < default.RandomPool.Length; ++i)
        {
            if (default.RandomPool[i] == default.Colors[Index].Name)
            {
                default.RandomPool.Remove(i, 1);
                break;
            }
        }
    }
    default.Colors[Index].bRandom = bRandom;
    return true;
}

static function int FindColor(string Name, optional out Color Color)
{
    local int i;

    if (IsReservedColorName(Name))
    {
        return -1;
    }
    for (i = 0; i < default.Colors.Length; ++i)
    {
        if (default.Colors[i].Name == Name)
        {
            Color = default.Colors[i].Color;
            return i;
        }
    }
    return -1;
}

static function int FindColorEntry(string Name, optional out HxColorEntry ColorEntry)
{
    local int i;

    if (IsReservedColorName(Name))
    {
        return -1;
    }
    for (i = 0; i < default.Colors.Length; ++i)
    {
        if (default.Colors[i].Name == Name)
        {
            ColorEntry = default.Colors[i];
            return i;
        }
    }
    return -1;
}

static function string RandomColorName()
{
    return "Color#"$Rand(999999);
}

static function InitializeRandomPool()
{
    ValidateCache(default.Cache);
    default.OldCache = default.Cache;
    default.Cache.Remove(0, default.Cache.Length);
    PopulateRandomPool();
}

static function ValidateCache(out array<HxCacheEntry> Cache)
{
    local int i;
    local int j;

    i = 0;
    while (i < Cache.Length)
    {
        for (j = 0; j < default.Colors.Length; ++j)
        {
            if (Cache[i].Highlight == default.Colors[j].Name)
            {
                break;
            }
        }
        if (j < default.Colors.Length)
        {
            ++i;
        }
        else
        {
            Cache.Remove(i, 1);
        }
    }
}

static function PopulateRandomPool()
{
    local int i;

    for (i = 0; i < default.Colors.Length; ++i)
    {
        if (default.Colors[i].bRandom)
        {
            default.RandomPool[default.RandomPool.Length] = default.Colors[i].Name;
        }
    }
}

static function RemoveFromRandomPool(string Name)
{
    local int i;

    for (i = 0; i < default.RandomPool.Length; ++i)
    {
        if (default.RandomPool[i] == Name)
        {
            default.RandomPool.Remove(i, 1);
            break;
        }
    }
    if (default.RandomPool.Length == 0)
    {
        PopulateRandomPool();
    }
}

defaultproperties
{
    EnemyTeam="DISABLED"
    YourTeam="DISABLED"
    SoloPlayer="DISABLED"
    ShieldHit="DEFAULT"
    LinkHit="DEFAULT"
    ShockHit="DEFAULT"
    LightningHit="DEFAULT"
    bDisableOnDeadBodies=false
    bForceNormalSkins=true
    SpectatorTeam=0
    Colors(0)=(Name="Red",Color=(R=255,G=0,B=0,A=255),bRandom=true)
    Colors(1)=(Name="Blue",Color=(R=0,G=0,B=255,A=255),bRandom=true)
    Colors(2)=(Name="Green",Color=(R=0,G=255,B=0,A=255),bRandom=true)
    Colors(3)=(Name="Pink",Color=(R=255,G=0,B=255,A=255),bRandom=true)
    Colors(4)=(Name="Teal",Color=(R=0,G=255,B=255,A=255),bRandom=true)
    Colors(5)=(Name="Yellow",Color=(R=255,G=255,B=0,A=255),bRandom=true)
    Colors(6)=(Name="Purple",Color=(R=64,G=0,B=255,A=255),bRandom=false)
    HighlightIntensity=-1

    RemoteRole=ROLE_SimulatedProxy
    bHardAttach=true
    bHidden=true
    bStatic=false
    bNoDelete=false
    bAlwaysRelevant=false
    bSkipActorPropertyReplication=false
    bOnlyDirtyReplication=false
    NetUpdateFrequency=10
    NetPriority=2
}
