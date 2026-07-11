class HxSkinHighlight extends Actor;

enum EHxSkinVariant
{
    HX_SKIN_RedTeam,
    HX_SKIN_BlueTeam,
    HX_SKIN_Normal,
};

const NO_HIGHLIGHT = "DISABLED";
const DEFAULT_HIGHLIGHT = "DEFAULT";
const HIT_COLOR_MULTIPLIER = 1.75;
const HIT_COLOR_FADE_PERIOD = 0.5;
const HIGHLIGHT_INTERVAL = 12;

var string Teammates;
var string Enemies;
var string ShieldHit;
var string LinkHit;
var string ShockHit;
var string LightningHit;
var EHxSkinVariant TeammateSkin;
var EHxSkinVariant EnemySkin;
var bool bRandomize;
var bool bDisableOnDeadBodies;
var int SpectatorTeam;
var int TeamNumber;
var float HighlightIntensity;
var string TeammateModel;
var bool bForceTeammateModel;
var string EnemyModel;
var bool bForceEnemyModel;

var protected PlayerController PC;
var protected HxUTClient Client;
var protected HxColors Colors;
var protected EHxSkinVariant SkinVariant;
var protected array<Material> Materials;
var protected array<Material> OriginalSkins;
var protected array<Material> BaseSkins;
var protected array<Shader> SkinShaders;
var protected array<Combiner> WorkaroundCombiners;
var protected array<FinalBlend> SkinFinalBlends;
var protected ConstantColor HighlightTint;
var protected ConstantColor WorkaroundTint;
var protected Shader EmptyShader;
var protected Color MainColor;
var protected Color HitColors[4];
var protected Material HitMaterials[4];
var protected byte bDisableHitEffect[4];
var protected int HitIndex;
var protected byte LocalPlayerTeam;
var protected xUtil.PlayerRecord PlayerRecord;

replication
{
    reliable if (Role == ROLE_Authority && bNetInitial)
        TeamNumber;

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
            if (Client != None)
            {
                Colors = Client.GetSkinHighlightColors();
            }
        }
        if (PC == None)
        {
            PC = Level.GetLocalPlayerController();
        }
        if (HighlightIntensity >= 0 && TeamNumber > -1 && Colors != None && PC != None
            && PC.PlayerReplicationInfo != None && Level.GRI != None)
        {
            LocalPlayerTeam = GetLocalPlayerTeam();
            if (ValidateCharacterModel())
            {
                SkinVariant = GetSkinVariant();
                ParseHitEffects();
                if (Colors.Find(GetHighlightColorName(), MainColor) > -1)
                {
                    MainColor = MainColor * HighlightIntensity;
                    MainColor.A = 255;
                    HighlightTint.Color = MainColor;
                    GotoState('Reskin');
                }
                else
                {
                    GotoState('Disabled');
                }
            }
        }
    }

    simulated function ParseHitEffects()
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
    }

    simulated function bool ValidateCharacterModel()
    {
        local xPawn Pawn;
        local string Model;
        local bool bEnemy;

        Pawn = xPawn(Base);
        if (Pawn != None && Pawn.PlayerReplicationInfo != None
            && Pawn.PlayerReplicationInfo.PlayerName != "")
        {
            if (Pawn.bDeRes || Pawn.bSkeletized)
            {
                GotoState('Disabled');
                return false;
            }
            if (Pawn.bOldInvis)
            {
                MakeVisible(Pawn);
            }
            if (!Pawn.bPlayedDeath && Pawn.Health > 0)
            {
                bEnemy = TeamNumber != LocalPlayerTeam;
                if (bEnemy && !bForceEnemyModel || !bEnemy && !bForceTeammateModel)
                {
                    Model = GetExpectedCharacterModel(Pawn);
                    if (PlayerRecord.DefaultName != "" && PlayerRecord.DefaultName != Model)
                    {
                        SetupCharacterModel(Pawn, Model);
                    }
                }
                else
                {
                    Model = Eval(bEnemy, EnemyModel, TeammateModel);
                    if (PlayerRecord.DefaultName != Model)
                    {
                        SetupCharacterModel(Pawn, Model);
                    }
                }
            }
            LoadXanAbdomen();
            if (Pawn.bOldInvis)
            {
                MakeInvisible(Pawn);
            }
            return true;
        }
        return false;
    }

    simulated function SetupCharacterModel(xPawn Pawn, string Model)
    {
        local name Animation;
        local bool bAnimating;
        local float Frame;
        local float Rate;

        PlayerRecord = class'xUtil'.static.FindPlayerRecord(Model);
        if (Pawn.bAlreadySetup)
        {
            if (Pawn.IsAnimating())
            {
                Pawn.GetAnimParams(0, Animation, Frame, Rate);
                bAnimating = true;
            }
        }
        Pawn.bAlreadySetup = false;
        Pawn.TauntAnims.Length = 0;
        Pawn.Skins.Length = 0;
        Pawn.Species = PlayerRecord.Species;
        Pawn.RagdollOverride = PlayerRecord.Ragdoll;
        Pawn.Species.static.Setup(Pawn, PlayerRecord);
        if (bAnimating && Pawn.HasAnim(Animation))
        {
            Pawn.PlayAnim(Animation, Rate);
            Pawn.SetAnimFrame(Frame);
        }
        else
        {
            Pawn.ResetPhysicsBasedAnim();
        }
    }

    simulated function string GetExpectedCharacterModel(xPawn Pawn)
    {
        if (Pawn.ForceDefaultCharacter())
        {
            return Pawn.GetDefaultCharacter();
        }
        return Pawn.PlayerReplicationInfo.CharacterName;
    }

    simulated function LoadXanAbdomen()
    {
        local string SkinName;

        SkinName = string(Base.Skins[0]);
        if (Left(SkinName, 22) ~= "UT2004PlayerSkins.Xan.")
        {
            SkinName = Right(SkinName, Len(SkinName) - 22);
            if (Left(SkinName, 5) ~= "XanM3")
            {
                Base.Skins[2] = Material(
                    DynamicLoadObject("UT2004PlayerSkins.XanM3_abdomen", class'Material'));
            }
            else if (Left(SkinName, 8) ~= "XanMk3V2")
            {
                Base.Skins[2] = Material(
                    DynamicLoadObject("UT2004PlayerSkins.XanMk3V2_abdomen", class'Material'));
            }
        }
    }

}

state Reskin
{
    simulated event BeginState()
    {
        TryReplaceSkins();
    }

    simulated event Tick(float DeltaTime)
    {
        TryReplaceSkins();
    }

    simulated function TryReplaceSkins()
    {
        local xPawn Pawn;

        Pawn = xPawn(Base);
        if (Pawn.bDeRes || Pawn.bSkeletized)
        {
            GotoState('Disabled');
        }
        else if (Pawn.bAlreadySetup)
        {
            if (Pawn.bOldInvis)
            {
                MakeVisible(Pawn);
                ReplaceSkins();
                MakeInvisible(Pawn);
            }
            else
            {
                ReplaceSkins();
            }
        }
    }

    simulated function ReplaceSkins()
    {
        local Texture SkinTexture;
        local Material Skin;
        local int i;

        OriginalSkins = Base.Skins;
        for (i = 0; i < OriginalSkins.Length; ++i)
        {
            Skin = GetSkinReplacement(OriginalSkins[i]);
            if (Skin != None)
            {
                Base.Skins[i] = Skin;
            }
        }
        BaseSkins = Base.Skins;
        AllocateSkinMaterials();
        for (i = 0; i < Base.Skins.Length; ++i)
        {
            SkinTexture = GetTextureFromMaterial(Base.Skins[i]);
            if (SkinTexture != None)
            {
                WorkaroundCombiners[i].Material1 = SkinTexture;
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
        GotoState('Enabled');
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
    simulated function bool ValidateTeams()
    {
        if (Base == None || LocalPlayerTeam != GetLocalPlayerTeam())
        {
            Restart();
            return false;
        }
        return true;
    }

    simulated event Tick(float DeltaTime)
    {
        if (ValidateTeams() && Base.OverlayMaterial != None)
        {
            TryGotoStateOverlayed();
        }
    }

    simulated function TryGotoStateOverlayed()
    {
        local xPawn Pawn;

        Pawn = xPawn(Base);
        if (Pawn.bDeRes || Pawn.bSkeletized)
        {
            GotoState('Disabled');
        }
        else
        {
            HitIndex = GetHitOverlayIndex();
            if (HitIndex < 0 || bDisableHitEffect[HitIndex] == 0)
            {
                GotoState('Overlayed');
            }
        }
    }

    simulated function PawnBaseDied()
    {
        if (bDisableOnDeadBodies)
        {
            if (Base != None)
            {
                ToggleBaseSkins();
            }
            GotoState('Disabled');
        }
    }

    simulated function ToggleBaseSkins()
    {
        local array<Material> TempSkins;
        local xPawn Pawn;
        local int SkinCount;
        local int i;

        Pawn = xPawn(Base);
        if (Pawn.bOldInvis)
        {
            TempSkins.Length = Base.Skins.Length;
            SkinCount = Min(Base.Skins.Length, BaseSkins.Length);
            for (i = 0; i < SkinCount; ++i)
            {
                TempSkins[i] = Pawn.RealSkins[i];
                Pawn.RealSkins[i] = BaseSkins[i];
            }
            BaseSkins = TempSkins;
        }
        else
        {
            TempSkins = Base.Skins;
            Base.Skins = BaseSkins;
            BaseSkins = TempSkins;
        }
    }

    simulated function Restart()
    {
        local xPawn Pawn;
        local int NumSkins;
        local int i;

        Pawn = xPawn(Base);
        LoadDefaults();
        if (Pawn != None)
        {
            if (Pawn.bDeRes || Pawn.bSkeletized)
            {
                GotoState('Disabled');
            }
            else if (Pawn.bOldInvis)
            {
                NumSkins = Min(OriginalSkins.Length, 4);
                for (i = 0; i < NumSkins; ++i)
                {
                    Pawn.RealSkins[i] = OriginalSkins[i];
                }
            }
            else
            {
                Pawn.Skins = OriginalSkins;
            }
        }
        GotoState('Startup');
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

    simulated event Tick(float DeltaTime)
    {
        local float Fade;

        if (ValidateTeams())
        {
            if (Base.OverlayMaterial == None)
            {
                TryGotoStateEnabled();
            }
            else if (HitIndex > -1)
            {
                Fade = FClamp(Base.ClientOverlayCounter / HIT_COLOR_FADE_PERIOD, 0.0, 1.0);
                HighlightTint.Color = (HitColors[HitIndex] * Fade) + (MainColor * (1.0 - Fade));
            }
        }
    }

    simulated function TryGotoStateEnabled()
    {
        local xPawn Pawn;

        Pawn = xPawn(Base);
        if (Pawn.bDeRes || Pawn.bSkeletized)
        {
            GotoState('Disabled');
        }
        else if (HitIndex < 0)
        {
            ToggleBaseSkins();
        }
        else
        {
            HighlightTint.Color = MainColor;
        }
        GotoState('Enabled');
    }

    simulated function PawnBaseDied()
    {
        if (bDisableOnDeadBodies)
        {
            if (Base != None)
            {
                if (Base.OverlayMaterial == EmptyShader)
                {
                    Base.SetOverlayMaterial(None, 0, true);
                }
                if (HitIndex > -1)
                {
                    ToggleBaseSkins();
                }
            }
            GotoState('Disabled');
        }
    }

    simulated function Restart()
    {
        if (HitIndex > -1)
        {
            Base.OverlayMaterial = HitMaterials[HitIndex];
        }
        Super.Restart();
    }
}

simulated function Restart()
{
    LoadDefaults();
    GotoState('Startup');
}

simulated final function LoadDefaults()
{
    Teammates = class'HxSkinHighlight'.default.Teammates;
    Enemies = class'HxSkinHighlight'.default.Enemies;
    ShieldHit = class'HxSkinHighlight'.default.ShieldHit;
    LinkHit = class'HxSkinHighlight'.default.LinkHit;
    ShockHit = class'HxSkinHighlight'.default.ShockHit;
    LightningHit = class'HxSkinHighlight'.default.LightningHit;
    TeammateSkin = class'HxSkinHighlight'.default.TeammateSkin;
    EnemySkin = class'HxSkinHighlight'.default.EnemySkin;
    bRandomize = class'HxSkinHighlight'.default.bRandomize;
    bDisableOnDeadBodies = class'HxSkinHighlight'.default.bDisableOnDeadBodies;
    SpectatorTeam = class'HxSkinHighlight'.default.SpectatorTeam;
    TeammateModel = class'HxSkinHighlight'.default.TeammateModel;
    bForceTeammateModel = class'HxSkinHighlight'.default.bForceTeammateModel;
    EnemyModel = class'HxSkinHighlight'.default.EnemyModel;
    bForceEnemyModel = class'HxSkinHighlight'.default.bForceEnemyModel;
}

simulated final function Material AllocateMaterial(class<Material> MaterialClass)
{
    local Material NewMaterial;

    NewMaterial = Material(Level.ObjectPool.AllocateObject(MaterialClass));
    Materials[Materials.Length] = NewMaterial;
    return NewMaterial;
}

static final function PopulateReservedNames(HxColors Colors)
{
    Colors.Reserve(NO_HIGHLIGHT);
    Colors.Reserve(DEFAULT_HIGHLIGHT);
}

simulated function int GetLocalPlayerTeam()
{
    if (PC.PlayerReplicationInfo.bOnlySpectator)
    {
        return SpectatorTeam;
    }
    return PC.GetTeamNum();
}

simulated function string GetHighlightColorName()
{
    local xPawn Pawn;

    Pawn = xPawn(Base);
    if (bRandomize && !Level.GRI.bTeamGame)
    {
        return Colors.SavedRandom(Pawn.PlayerReplicationInfo.PlayerName);
    }
    return Eval(TeamNumber != LocalPlayerTeam, Enemies, Teammates);
}

simulated function EHxSkinVariant GetSkinVariant()
{
    if (!Level.GRI.bTeamGame || TeamNumber == 255 || TeamNumber != LocalPlayerTeam)
    {
        return EnemySkin;
    }
    return TeammateSkin;
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

simulated function Material GetSkinReplacement(coerce string Name)
{
    local Material Skin;
    local string Suffix;

    Suffix = Right(Name, 3);
    if (Suffix ~= "_0B" || Suffix ~= "_1B")
    {
        Name = Left(Name, Len(Name) - 3);
        if (SkinVariant != HX_SKIN_Normal)
        {
            Name = Name$"_"$int(SkinVariant)$"B";
        }
        else if (StrCmp(Name, "Bright", 6, false) == 0)
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
            if (SkinVariant != HX_SKIN_Normal)
            {
                Name = Name$"_"$int(SkinVariant);
            }
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

static final function int GetTeamNum(xPawn Pawn)
{
    local TeamInfo Team;

    if (Pawn.Controller != None)
    {
        return Pawn.Controller.GetTeamNum();
    }
    if (Pawn.DrivenVehicle != None && Pawn.DrivenVehicle.Controller != None)
    {
        return Pawn.DrivenVehicle.Controller.GetTeamNum();
    }
    if (Pawn.OldController != None)
    {
        return Pawn.OldController.GetTeamNum();
    }
    Team = Pawn.GetTeam();
    if (Team != None)
    {
        return Team.TeamIndex;
    }
    return 255;
}

static final function MakeInvisible(xPawn Pawn)
{
    local int NumSkins;
    local int i;

    NumSkins = Min(Pawn.Skins.Length, ArrayCount(Pawn.RealSkins));
    for (i = 0; i < NumSkins; ++i)
    {
        Pawn.RealSkins[i] = Pawn.Skins[i];
        Pawn.Skins[i] = Pawn.InvisMaterial;
    }
}

static final function MakeVisible(xPawn Pawn)
{
    local int NumSkins;
    local int i;

    NumSkins = Min(Pawn.Skins.Length, ArrayCount(Pawn.RealSkins));
    for (i = 0; i < NumSkins; ++i)
    {
        Pawn.Skins[i] = Pawn.RealSkins[i];
    }
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bHardAttach=true
    bHidden=true
    bOnlyDirtyReplication=true
    NetUpdateFrequency=100
    NetPriority=30
    TeamNumber=-1
    HighlightIntensity=-1
    LocalPlayerTeam=255
}
