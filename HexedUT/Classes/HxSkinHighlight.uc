class HxSkinHighlight extends Actor
    config(User);

const MIN_VERSION = 3;

const NO_HIGHLIGHT = "DISABLED";
const RANDOM_HIGHLIGHT = "RANDOM";
const DEFAULT_HIGHLIGHT = "DEFAULT";
const HIT_COLOR_MULTIPLIER = 1.75;
const HIT_COLOR_FADE_PERIOD = 0.5;
const HIGHLIGHT_INTERVAL = 12;

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
var float HighlightIntensity;

var private PlayerController PC;
var private HxUTClient Client;
var private HxColors Colors;
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
            if (bEnabled && Pawn.bAlreadySetup)
            {
                if (!Pawn.bInvis && !Pawn.bOldInvis && !Pawn.bDeRes)
                {
                    if (bForceNormalSkins && !bSkinUpdated)
                    {
                        ForceNormalSkin(Pawn);
                    }
                    UpdateOverlay(Pawn);
                }
                else if (Pawn.OverlayMaterial == HighlightShader)
                {
                    Pawn.SetOverlayMaterial(None, 0, true);
                }
            }
        }
    }
}

simulated function bool Initialize(xPawn Pawn)
{
    if (Client == None)
    {
        foreach DynamicActors(class'HxUTClient', Client) break;
    }
    if (HighlightIntensity < 0 || Client == None)
    {
        return false;
    }
    if (Colors == None)
    {
        Colors = Client.GetSkinHighlightColors();
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
        if (SoloPlayer == RANDOM_HIGHLIGHT)
        {
            Name = Colors.SavedRandom(Pawn.PlayerReplicationInfo.PlayerName);
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
    bEnabled = !Colors.IsReservedName(Name);
    if (bEnabled)
    {
        Colors.Find(Name, MainColor);
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
        Pawn.SetOverlayMaterial(HighlightShader, HIGHLIGHT_INTERVAL, true);
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

    Colors.Find(Name, Color);
    Color.R = Min(Color.R * HighlightIntensity * HIT_COLOR_MULTIPLIER, 255);
    Color.G = Min(Color.G * HighlightIntensity * HIT_COLOR_MULTIPLIER, 255);
    Color.B = Min(Color.B * HighlightIntensity * HIT_COLOR_MULTIPLIER, 255);
    return Color;
}

simulated function DisableHighlight()
{
    local xPawn Pawn;

    Pawn = xPawn(Base);
    if (Pawn != None && Pawn.OverlayMaterial == HighlightShader)
    {
        Pawn.SetOverlayMaterial(None, 0, true);
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

static function PopulateReservedNames(HxColors Colors)
{
    Colors.Reserve(NO_HIGHLIGHT);
    Colors.Reserve(RANDOM_HIGHLIGHT);
    Colors.Reserve(DEFAULT_HIGHLIGHT);
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bHardAttach=true
    bHidden=true
    NetUpdateFrequency=100
    NetPriority=3
    HighlightIntensity=-1
}
