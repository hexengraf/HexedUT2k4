class HxPlayerHighlight extends Actor
    config(User);

struct HxHighlightColor
{
    var string Name;
    var Color Color;
};

const NO_HIGHLIGHT = "";
const RANDOM_HIGHLIGHT = "*";

var config string YourTeam;
var config string EnemyTeam;
var config string SoloPlayer;
var config bool bDisableOnDeadBodies;
var config bool bForceNormalSkins;
var config array<HxHighlightColor> Colors;
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
var private bool bRandomColor;
var private byte LocalPlayerTeam;

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
        bEnabled = false;
        bSkinUpdated = false;
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
    if (Pawn != None && PC != None && Level.GRI != None && PC.PlayerReplicationInfo != None)
    {
        LocalPlayerTeam = GetLocalPlayerTeam();
        if (!Level.GRI.bTeamGame)
        {
            Highlight = SoloPlayer;
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
        bRandomColor = Highlight == RANDOM_HIGHLIGHT;
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
    bRandomColor = false;
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

simulated function Color GetHighlightColor(string ColorName)
{
    local Color C;

    C = FindColor(ColorName);
    C.R = C.R * HighlightFactor;
    C.G = C.G * HighlightFactor;
    C.B = C.B * HighlightFactor;
    return C;
}

simulated function ForceNormalSkin(xPawn Pawn)
{
    local Material Skin;
    local string Name;
    local string Suffix;
    local int i;

    for (i = 0; i < Pawn.Skins.Length; ++i)
    {
        Name = string(Pawn.Skins[i]);
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

static function bool ChangeColorName(int Index, string Name)
{
    local int i;

    if (Name == NO_HIGHLIGHT || name == RANDOM_HIGHLIGHT || Index >= default.Colors.Length)
    {
        return false;
    }
    for (i = 0; i < default.Colors.Length; ++i)
    {
        if (default.Colors[i].Name == Name)
        {
            return false;
        }
    }
    if (default.YourTeam == default.Colors[Index].Name)
    {
        default.YourTeam = Name;
    }
    if (default.EnemyTeam == default.Colors[Index].Name)
    {
        default.EnemyTeam = Name;
    }
    default.Colors[Index].Name = Name;
    return true;
}

static function Color FindColor(string ColorName)
{
    local Color C;
    local int i;

    if (ColorName == NO_HIGHLIGHT || ColorName == RANDOM_HIGHLIGHT)
    {
        return C;
    }
    for (i = 0; i < default.Colors.Length; ++i)
    {
        if (default.Colors[i].Name == ColorName)
        {
            C = default.Colors[i].Color;
            break;
        }
    }
    return C;
}

defaultproperties
{
    EnemyTeam=""
    YourTeam=""
    bDisableOnDeadBodies=false
    bForceNormalSkins=false
    Colors(0)=(Name="Red",Color=(R=255,G=0,B=0,A=255))
    Colors(1)=(Name="Blue",Color=(R=0,G=0,B=255,A=255))
    Colors(2)=(Name="Green",Color=(R=0,G=255,B=0,A=255))
    Colors(3)=(Name="Pink",Color=(R=255,G=0,B=255,A=255))
    Colors(4)=(Name="Teal",Color=(R=0,G=255,B=255,A=255))
    Colors(5)=(Name="Yellow",Color=(R=255,G=255,B=0,A=255))
    Colors(6)=(Name="Orange",Color=(R=255,G=128,B=0,A=255))
    Colors(7)=(Name="White",Color=(R=255,G=255,B=255,A=255))
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
