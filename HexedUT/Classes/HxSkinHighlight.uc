class HxSkinHighlight extends Actor
    config(User);

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
var private array<Material> Materials;
var private array<Material> OriginalSkins;
var private array<Material> BaseSkins;
var private array<Shader> SkinShaders;
var private array<Combiner> WorkaroundCombiners;
var private array<FinalBlend> SkinFinalBlends;
var private ConstantColor HighlightTint;
var private ConstantColor WorkaroundTint;
var private Shader EmptyShader;
var private Color MainColor;
var private Color HitColors[4];
var private Material HitMaterials[4];
var protected byte bDisableHitEffect[4];
var protected int HitIndex;
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
        HighlightTint = ConstantColor(AllocateMaterial(class'ConstantColor'));
        WorkaroundTint = ConstantColor(AllocateMaterial(class'ConstantColor'));
        EmptyShader = Shader(AllocateMaterial(class'Shader'));
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

auto state Startup
{
    simulated event BeginState()
    {
        if (Level.NetMode != NM_DedicatedServer)
        {
            Initialize();
        }
        else
        {
            GotoState('Disabled');
        }
    }

    simulated event Tick(float DeltaTime)
    {
        Initialize();
    }

    simulated function Initialize()
    {
        if (Client == None)
        {
            foreach DynamicActors(class'HxUTClient', Client) break;
        }
        if (PC == None)
        {
            PC = Level.GetLocalPlayerController();
        }
        if (IsReplicated() && IsSetupFinished())
        {
            if (Colors == None)
            {
                Colors = Client.GetSkinHighlightColors();
            }
            LocalPlayerTeam = GetLocalPlayerTeam();
            InitializeHitEffects();
            if (Colors.Find(GetHighlightColorName(), MainColor) > -1)
            {
                MainColor.R = MainColor.R * HighlightIntensity;
                MainColor.G = MainColor.G * HighlightIntensity;
                MainColor.B = MainColor.B * HighlightIntensity;
                HighlightTint.Color = MainColor;
                ReplaceSkins();
                GotoState('Enabled');
            }
            else
            {
                GotoState('Disabled');
            }
        }
    }

    simulated function InitializeHitEffects()
    {
        local int i;

        for (i = 0; i < ArrayCount(HitColors); ++i)
        {
            HitMaterials[i] = None;
            bDisableHitEffect[i] = 0;
        }
        if (ShieldHit != DEFAULT_HIGHLIGHT)
        {
            HitColors[0] = GetHitColor(ShieldHit);
            HitMaterials[0] = Shader'XGameShaders.PlayerShaders.PlayerShieldSh';
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

    simulated function ReplaceSkins()
    {
        local Texture SkinTexture;
        local int i;

        OriginalSkins = Base.Skins;
        if (bForceNormalSkins)
        {
            ReplaceTeamSkins();
        }
        BaseSkins = Base.Skins;
        AllocateSkinMaterials();
        for (i = 0; i < SkinShaders.Length; ++i)
        {
            SkinTexture = GetTextureFromMaterial(Base.Skins[i]);
            if (SkinTexture != None)
            {
                WorkaroundCombiners[i].Material1 = SkinTexture;
                // SkinShaders[i].Diffuse = SkinTexture;
                if (SkinTexture.bAlphaTexture || SkinTexture.bMasked)
                {
                    SkinShaders[i].Opacity = SkinTexture;
                    SkinShaders[i].SpecularityMask = SkinTexture;
                    Base.Skins[i] = SkinFinalBlends[i];
                }
                else
                {
                    SkinShaders[i].Opacity = None;
                    SkinShaders[i].SpecularityMask = None;
                    Base.Skins[i] = SkinShaders[i];
                }
            }
        }
    }

    simulated function ReplaceTeamSkins()
    {
        local int i;
        local Material Skin;

        for (i = 0; i < Base.Skins.Length; ++i)
        {
            Skin = GetNormalSkin(Base.Skins[i]);
            if (Skin != None)
            {
                Base.Skins[i] = Skin;
            }
        }
    }

    simulated function AllocateSkinMaterials()
    {
        local int i;

        if (SkinShaders.Length < Base.Skins.Length)
        {
            i = SkinShaders.Length;
            SkinShaders.Length = Base.Skins.Length;
            SkinFinalBlends.Length = Base.Skins.Length;
            WorkaroundCombiners.Length = Base.Skins.Length;
            for (i = i; i < Base.Skins.Length; ++i)
            {
                WorkaroundCombiners[i] = Combiner(AllocateMaterial(class'Combiner'));
                WorkaroundCombiners[i].CombineOperation = CO_Add;
                WorkaroundCombiners[i].AlphaOperation = AO_Use_Alpha_From_Material1;
                WorkaroundCombiners[i].Material2 = WorkaroundTint;
                SkinShaders[i] = Shader(AllocateMaterial(class'Shader'));
                SkinShaders[i].Specular = HighlightTint;
                SkinShaders[i].Diffuse = WorkaroundCombiners[i];
                SkinShaders[i].OutputBlending = OB_Normal;
                SkinFinalBlends[i] = FinalBlend(AllocateMaterial(class'FinalBlend'));
                SkinFinalBlends[i].FrameBufferBlending = FB_AlphaBlend;
                SkinFinalBlends[i].Material = SkinShaders[i];
                SkinFinalBlends[i].AlphaTest = true;
                SkinFinalBlends[i].TwoSided = true;
            }
        }
    }
}

state Disabled
{
    simulated event Tick(float DeltaTime)
    {
        Disable('Tick');
    }
}

state Enabled
{
    simulated event Tick(float DeltaTime)
    {
        if (LocalPlayerTeam != GetLocalPlayerTeam())
        {
            Reinitialize();
        }
        else if (Base.OverlayMaterial != None && IsHighlightable())
        {
            HitIndex = GetHitOverlayIndex();
            if (xPawn(Base) != None && !xPawn(Base).bSpawnDone)
            {
                GotoState('SpawnProtected');
            }
            else if (HitIndex < 0 || bDisableHitEffect[HitIndex] == 0)
            {
                GotoState('Overlayed');
            }
        }
    }

    simulated function Reinitialize()
    {
        Global.Reinitialize();
        if (OriginalSkins.Length > 0)
        {
            Base.Skins = OriginalSkins;
            OriginalSkins.Length = 0;
            BaseSkins.Length = 0;
        }
    }

    simulated function PawnBaseDied()
    {
        if (bDisableOnDeadBodies)
        {
            if (Base != None)
            {
                ToggleBaseSkins();
                if (Base.OverlayMaterial == EmptyShader)
                {
                    Base.SetOverlayMaterial(None, 0, true);
                }
            }
            GotoState('Disabled');
        }
    }

    simulated function ToggleBaseSkins()
    {
        local array<Material> TempSkins;

        TempSkins = Base.Skins;
        Base.Skins = BaseSkins;
        BaseSkins = TempSkins;
    }
}

state Overlayed extends Enabled
{
    simulated event BeginState()
    {
        if (HitIndex > -1)
        {
            Base.OverlayMaterial = EmptyShader;
        }
        else
        {
            ToggleBaseSkins();
        }
    }
    simulated event EndState()
    {
        if (HitIndex < 0)
        {
            ToggleBaseSkins();
        }
        HighlightTint.Color = MainColor;
    }

    simulated event Tick(float DeltaTime)
    {
        local float Fade;

        if (LocalPlayerTeam != GetLocalPlayerTeam())
        {
            Reinitialize();
        }
        else if (Base.OverlayMaterial == None)
        {
            if (IsHighlightable())
            {
                GotoState('Enabled');
            }
        }
        else if (HitIndex > -1)
        {
            Fade = FClamp(Base.ClientOverlayCounter / HIT_COLOR_FADE_PERIOD, 0.0, 1.0);
            HighlightTint.Color = (HitColors[HitIndex] * Fade) + (MainColor * (1.0 - Fade));
        }
    }
}

state SpawnProtected extends Overlayed
{
    simulated event Tick(float DeltaTime)
    {
        if (xPawn(Base).bSpawnDone && Base.OverlayMaterial != None)
        {
            Base.SetOverlayMaterial(None, 0, true);
        }
        Super.Tick(DeltaTime);
    }
}

simulated function Reinitialize()
{
    YourTeam = default.YourTeam;
    EnemyTeam = default.EnemyTeam;
    SoloPlayer = default.SoloPlayer;
    ShieldHit = default.ShieldHit;
    LinkHit = default.LinkHit;
    ShockHit = default.ShockHit;
    LightningHit = default.LightningHit;
    bDisableOnDeadBodies = default.bDisableOnDeadBodies;
    bForceNormalSkins = default.bForceNormalSkins;
    SpectatorTeam = default.SpectatorTeam;
    GotoState('Startup');
}

simulated function Material AllocateMaterial(class<Material> MaterialClass)
{
    local Material NewMaterial;

    NewMaterial = Material(Level.ObjectPool.AllocateObject(MaterialClass));
    Materials[Materials.Length] = NewMaterial;
    return NewMaterial;
}

static function PopulateReservedNames(HxColors Colors)
{
    Colors.Reserve(NO_HIGHLIGHT);
    Colors.Reserve(RANDOM_HIGHLIGHT);
    Colors.Reserve(DEFAULT_HIGHLIGHT);
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

simulated function string GetHighlightColorName()
{

    if (!Level.GRI.bTeamGame)
    {
        if (SoloPlayer == RANDOM_HIGHLIGHT)
        {
            return Colors.SavedRandom(xPawn(Base).PlayerReplicationInfo.PlayerName);
        }
        return SoloPlayer;
    }
    return Eval(xPawn(Base).GetTeamNum() != LocalPlayerTeam, EnemyTeam, YourTeam);
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

simulated function int GetHitOverlayIndex()
{
    local int i;

    for (i = 0; i < ArrayCount(HitMaterials); ++i)
    {
        if (Base.OverlayMaterial == HitMaterials[i])
        {
            return i;
        }
    }
    return -1;
}

simulated function bool IsReplicated()
{
    return HighlightIntensity >= 0
        && Base != None
        && Client != None
        && PC != None
        && PC.PlayerReplicationInfo != None;
}

simulated function bool IsSetupFinished()
{
    return xPawn(Base) != None
        && xPawn(Base).bAlreadySetup
        && xPawn(Base).PlayerReplicationInfo != None
        && xPawn(Base).PlayerReplicationInfo.PlayerName != ""
        && Level.GRI != None
        && IsHighlightable();
}

simulated function bool IsHighlightable()
{
    return !xPawn(Base).bInvis
        && !xPawn(Base).bOldInvis
        && !xPawn(Base).bDeRes;
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

static final function Texture GetTextureFromMaterial(Material Material)
{
    if (Texture(Material) != None)
    {
        return Texture(Material);
    }
    if (FinalBlend(Material) != None)
    {
        return GetTextureFromMaterial(FinalBlend(Material).Material);
    }
    if (Shader(Material) != None)
    {
        return GetTextureFromMaterial(Shader(Material).Diffuse);
    }
    if (Combiner(Material) != None)
    {
        return GetTextureFromMaterial(Combiner(Material).Material2);
    }
    return None;
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bHardAttach=true
    bHidden=true
    NetUpdateFrequency=100
    NetPriority=3
    HighlightIntensity=-1
    LocalPlayerTeam=255
}
