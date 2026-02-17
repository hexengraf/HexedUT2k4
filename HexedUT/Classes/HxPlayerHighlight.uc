class HxPlayerHighlight extends Actor
    config(User);

struct HxColor
{
    var string Name;
    var Color Color;
};

struct HxCacheEntry
{
    var string Player;
    var string Highlight;
};

const NO_HIGHLIGHT = "";
const RANDOM_HIGHLIGHT = "*";

var config string YourTeam;
var config string EnemyTeam;
var config string SoloPlayer;
var config bool bDisableOnDeadBodies;
var config bool bForceNormalSkins;
var config array<HxColor> Colors;
var config array<HxCacheEntry> Cache;
var float HighlightFactor;

var private PlayerController PC;
var private array<Material> Materials;
var private array<Material> OriginalSkins;
var private ConstantColor HighlightEffect;
var private Shader HighlightShader;
var private Color HighlightColor;
var private bool bInitialized;
var private bool bSkinUpdated;
var private bool bEnabled;
var private byte LocalPlayerTeam;
var private array<string> RandomPool;
var private array<HxCacheEntry> OldCache;

replication
{
    reliable if (Role == ROLE_Authority)
        HighlightFactor;
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        HighlightEffect = ConstantColor(AllocateMaterial(class'ConstantColor'));
        HighlightShader = Shader(AllocateMaterial(class'Shader'));
        HighlightShader.Specular = HighlightEffect;
        bSkinUpdated = false;
        bEnabled = false;
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
            if (bForceNormalSkins && !bSkinUpdated)
            {
                ForceNormalSkin(Pawn);
            }
            if (bEnabled && Pawn.bAlreadySetup && !Pawn.bInvis && !Pawn.bOldInvis && !Pawn.bDeRes)
            {
                UpdateHighlightOverlay(Pawn);
            }
        }
    }
    super.Tick(DeltaTime);
}

simulated function bool Initialize(xPawn Pawn)
{
    local string Highlight;

    if (HighlightFactor == -1)
    {
        return false;
    }
    if (PC == None)
    {
        PC = Level.GetLocalPlayerController();
    }
    if (Pawn != None && PC != None && Level.GRI != None
        && PC.PlayerReplicationInfo != None && Pawn.PlayerReplicationInfo != None)
    {
        LocalPlayerTeam = GetLocalPlayerTeam();
        if (!Level.GRI.bTeamGame)
        {
            if (default.RandomPool.Length == 0)
            {
                InitializeRandomPool();
            }
            if (SoloPlayer == RANDOM_HIGHLIGHT)
            {
                if (Pawn.PlayerReplicationInfo.PlayerName == "")
                {
                    return false;
                }
                Highlight = GetRandomColor(Pawn.PlayerReplicationInfo.PlayerName);
            }
            else
            {
                Highlight = SoloPlayer;
            }
            bSkinUpdated = true;
        }
        else if (Pawn.GetTeamNum() != LocalPlayerTeam)
        {
            Highlight = EnemyTeam;
        }
        else
        {
            Highlight = YourTeam;
        }
        bEnabled = Highlight != NO_HIGHLIGHT;
        HighlightColor = GetHighlightColor(Highlight);
        return true;
    }
    return false;
}

simulated function Reinitialize()
{
    local xPawn Pawn;
    local int i;

    YourTeam = default.YourTeam;
    EnemyTeam = default.EnemyTeam;
    SoloPlayer = default.SoloPlayer;
    bDisableOnDeadBodies = default.bDisableOnDeadBodies;
    bForceNormalSkins = default.bForceNormalSkins;
    bInitialized = false;
    Pawn = xPawn(Base);
    if (Pawn != None)
    {
        if (IsActive(Pawn))
        {
            Pawn.SetOverlayMaterial(None, 1, true);
        }
        if (!bForceNormalSkins && OriginalSkins.Length > 0)
        {
            for (i = 0; i < OriginalSkins.Length; ++i)
            {
                if (OriginalSkins[i] != None)
                {
                    Pawn.Skins[i] = OriginalSkins[i];
                }
            }
            bSkinUpdated = false;
        }
    }
}

simulated function UpdateHighlightOverlay(xPawn Pawn)
{
    if (Pawn.OverlayMaterial == None)
    {
        HighlightEffect.Color = HighlightColor;
        HighlightShader.Specular = HighlightEffect;
        Pawn.SetOverlayMaterial(HighlightShader, 300, false);
    }
}

simulated function Color GetHighlightColor(string Name)
{
    local Color Color;

    FindColor(Name, Color);
    Color.R = Color.R * HighlightFactor;
    Color.G = Color.G * HighlightFactor;
    Color.B = Color.B * HighlightFactor;
    return Color;
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
        return 0;
    }
    return PC.GetTeamNum();
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

simulated function bool IsActive(xPawn Pawn)
{
    return Pawn.OverlayMaterial == HighlightShader;
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
    local xPawn Pawn;

    if (Level.NetMode != NM_DedicatedServer)
    {
        Pawn = xPawn(Base);
        if (bDisableOnDeadBodies && Pawn != None && IsActive(Pawn))
        {
            Pawn.SetOverlayMaterial(None, 1, true);
            bEnabled = false;
        }
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


static function int AllocateColor(optional out string Name)
{
    local int Index;

    Name = RandomColorName();
    while (FindColor(Name) != -1)
    {
        Name = RandomColorName();
    }
    Index = default.Colors.Length;
    default.Colors.Length = Index + 1;
    default.Colors[Index].Name = Name;
    return Index;
}

static function bool DeleteColor(int Index)
{
    if (Index < 0 || Index >= default.Colors.Length)
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

    if (Name == NO_HIGHLIGHT || Name == RANDOM_HIGHLIGHT
        || Index >= default.Colors.Length || FindColor(Name) != -1)
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

static function int FindColor(string Name, optional out Color Color)
{
    local int i;

    if (Name == NO_HIGHLIGHT || Name == RANDOM_HIGHLIGHT)
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
        default.RandomPool[i] = default.Colors[i].Name;
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
    EnemyTeam=""
    YourTeam=""
    SoloPlayer=""
    bDisableOnDeadBodies=false
    bForceNormalSkins=false
    Colors(0)=(Name="Red",Color=(R=255,G=0,B=0,A=255))
    Colors(1)=(Name="Blue",Color=(R=0,G=0,B=255,A=255))
    Colors(2)=(Name="Green",Color=(R=0,G=255,B=0,A=255))
    Colors(3)=(Name="Pink",Color=(R=255,G=0,B=255,A=255))
    Colors(4)=(Name="Teal",Color=(R=0,G=255,B=255,A=255))
    Colors(5)=(Name="Yellow",Color=(R=255,G=255,B=0,A=255))
    Colors(6)=(Name="Orange",Color=(R=255,G=128,B=0,A=255))
    Colors(7)=(Name="Purple",Color=(R=96,G=0,B=255,A=255))
    Colors(8)=(Name="White",Color=(R=255,G=255,B=255,A=255))
    HighlightFactor=-1

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
