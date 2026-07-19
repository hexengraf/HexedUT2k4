class HxSkinHighlight extends Actor;

enum EHxHighlightMode
{
    HX_SHM_RoleBased,
    HX_SHM_TeamBased,
};

enum EHxSkinType
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
var EHxSkinType TeammateSkin;
var EHxSkinType EnemySkin;
var bool bRandomize;
var bool bDisableOnDeadBodies;
var EHxHighlightMode HighlightMode;
var int SpectatorTeam;
var string TeammateModel;
var bool bForceTeammateModel;
var string EnemyModel;
var bool bForceEnemyModel;
var float HighlightIntensity;
var int TeamNumber;
var bool bCanForceModels;

var protected PlayerController PC;
var protected HxUTClient Client;
var protected HxColors Colors;
var protected EHxSkinType SkinType;
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
        TeamNumber, bCanForceModels;

    reliable if (Role == ROLE_Authority)
        HighlightIntensity;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

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
        ResetMaterial(Materials[i]);
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
                SkinType = GetSkinType();
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
                bEnemy = IsEnemy();
                if (!bCanForceModels || (bEnemy && !bForceEnemyModel)
                    || (!bEnemy && !bForceTeammateModel))
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
            class'HxGUIModelSelect'.static.LoadXanAbdomen(Base);
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
    HighlightMode = class'HxSkinHighlight'.default.HighlightMode;
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
    ResetMaterial(NewMaterial);
    return NewMaterial;
}

static final function ResetMaterial(Material M)
{
    local ConstantColor CC;
    local Combiner C;
    local Shader S;
    local FinalBlend FB;

    switch (M.Class)
    {
        case class'ConstantColor':
            CC = ConstantColor(M);
            CC.FallbackMaterial = class'ConstantColor'.default.FallbackMaterial;
            CC.DefaultMaterial = class'ConstantColor'.default.DefaultMaterial;
            CC.Color = class'ConstantColor'.default.Color;
            break;
        case class'Combiner':
            C = Combiner(M);
            C.FallbackMaterial = class'Combiner'.default.FallbackMaterial;
            C.DefaultMaterial = class'Combiner'.default.DefaultMaterial;
            C.CombineOperation = class'Combiner'.default.CombineOperation;
            C.AlphaOperation = class'Combiner'.default.AlphaOperation;
            C.Material1 = class'Combiner'.default.Material1;
            C.Material2 = class'Combiner'.default.Material2;
            C.Mask = class'Combiner'.default.Mask;
            C.InvertMask = class'Combiner'.default.InvertMask;
            C.Modulate2X = class'Combiner'.default.Modulate2X;
            C.Modulate4X = class'Combiner'.default.Modulate4X;
            break;
        case class'Shader':
            S = Shader(M);
            S.FallbackMaterial = class'Shader'.default.FallbackMaterial;
            S.DefaultMaterial = class'Shader'.default.DefaultMaterial;
            S.Diffuse = class'Shader'.default.Diffuse;
            S.Opacity = class'Shader'.default.Opacity;
            S.Specular = class'Shader'.default.Specular;
            S.SpecularityMask = class'Shader'.default.SpecularityMask;
            S.SelfIllumination = class'Shader'.default.SelfIllumination;
            S.SelfIlluminationMask = class'Shader'.default.SelfIlluminationMask;
            S.Detail = class'Shader'.default.Detail;
            S.DetailScale = class'Shader'.default.DetailScale;
            S.OutputBlending = class'Shader'.default.OutputBlending;
            S.TwoSided = class'Shader'.default.TwoSided;
            S.Wireframe = class'Shader'.default.Wireframe;
            S.ModulateStaticLighting2X = class'Shader'.default.ModulateStaticLighting2X;
            S.PerformLightingOnSpecularPass = class'Shader'.default.PerformLightingOnSpecularPass;
            S.ModulateSpecular2X = class'Shader'.default.ModulateSpecular2X;
            break;
        case class'FinalBlend':
            FB = FinalBlend(M);
            FB.FallbackMaterial = class'FinalBlend'.default.FallbackMaterial;
            FB.DefaultMaterial = class'FinalBlend'.default.DefaultMaterial;
            FB.Material = class'FinalBlend'.default.Material;
            FB.FrameBufferBlending = class'FinalBlend'.default.FrameBufferBlending;
            FB.ZWrite = class'FinalBlend'.default.ZWrite;
            FB.ZTest = class'FinalBlend'.default.ZTest;
            FB.AlphaTest = class'FinalBlend'.default.AlphaTest;
            FB.TwoSided = class'FinalBlend'.default.TwoSided;
            FB.AlphaRef = class'FinalBlend'.default.AlphaRef;
            break;
    }
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
    if (IsEnemy())
    {
        if (bRandomize && !Level.GRI.bTeamGame)
        {
            return Colors.SavedRandom(xPawn(Base).PlayerReplicationInfo.PlayerName);
        }
        return Enemies;
    }
    return Teammates;
}

simulated function EHxSkinType GetSkinType()
{
    if (IsEnemy())
    {
        return EnemySkin;
    }
    return TeammateSkin;
}

simulated function bool IsEnemy()
{
    if (!Level.GRI.bTeamGame)
    {
        return xPawn(Base).PlayerReplicationInfo != PC.PlayerReplicationInfo;
    }
    if (HighlightMode == HX_SHM_TeamBased)
    {
        return TeamNumber != 0;
    }
    return TeamNumber != LocalPlayerTeam;
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
        if (SkinType != HX_SKIN_Normal)
        {
            Name = Name$"_"$int(SkinType)$"B";
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
            if (SkinType != HX_SKIN_Normal)
            {
                Name = Name$"_"$int(SkinType);
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

    Teammates="DISABLED"
    Enemies="DISABLED"
    ShieldHit="DEFAULT"
    LinkHit="DEFAULT"
    ShockHit="DEFAULT"
    LightningHit="DEFAULT"
    TeammateSkin=HX_SKIN_Normal
    EnemySkin=HX_SKIN_Normal
    bRandomize=false
    bDisableOnDeadBodies=false
    HighlightMode=HX_SHM_RoleBased
    SpectatorTeam=0
    TeammateModel="Jakob"
    bForceTeammateModel=false
    EnemyModel="Jakob"
    bForceEnemyModel=false
}
