class HxUTClient extends HxClientReplicationInfo;

struct HxHitSoundInfo
{
    var int Value;
    var float Timestamp;
};

const HIT_SOUND_INTERVAL = 0.02;

var array<string> ModelList;

var private HxHitEffects HitEffects;
var private HxColors SkinHighlightColors;
var private HxUTPlayer Player;
var private HxSPTimer SPTimer;
var private HxHitSoundInfo HitSound;
var private bool bInitialized;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientPlayHitSound,
        ClientDisplayDamageNumber,
        ClientNotifySpawn;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (Level.NetMode != NM_DedicatedServer)
    {
        SkinHighlightColors = HxColors(Manager.LoadObject(class'HxColors', "HxSkinHighlight"));
        class'HxSkinHighlight'.static.PopulateReservedNames(SkinHighlightColors);
        HxSkinHighlightConfig(FindConfig(
            class'HxSkinHighlightConfig')).ValidateColors(SkinHighlightColors);
        if (Manager.IsFirstRun())
        {
            // TODO: remove this in v10
            HxHitEffectsConfig(FindConfig(class'HxHitEffectsConfig')).TemporaryFirstRunFix();
        }
    }
}

simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (!bInitialized)
        {
            bInitialized = InitializeClient();
        }
    }
    ServerTick(DeltaTime);
}

function ServerTick(float DeltaTime)
{
    if (HitSound.Value > 0 && Level.TimeSeconds - HitSound.Timestamp >= HIT_SOUND_INTERVAL)
    {
        ClientPlayHitSound(HitSound.Value);
        HitSound.Value = 0;
    }
}

function QueueHitSound(int Value)
{
    HitSound.Timestamp = Level.TimeSeconds;
    HitSound.Value += Value;
}

simulated function ClientPlayHitSound(int Damage)
{
    if (HitEffects != None)
    {
        HitEffects.PlayHitSound(Damage);
    }
}

simulated function ClientDisplayDamageNumber(int Damage)
{
    if (HitEffects != None)
    {
        HitEffects.DisplayDamageNumber(Damage);
    }
}

simulated function PlayHitSoundPreview(int Index)
{
    if (HitEffects != None)
    {
        HitEffects.PlayHitSoundPreview(Index);
    }
}

simulated function DrawDamageNumberPreview(Canvas C, int Index)
{
    if (HitEffects != None)
    {
        HitEffects.DrawPreview(C, Index);
    }
}

function NotifySpawn(Pawn Spawned)
{
    if (DeathMatch(Level.Game) != None)
    {
        ClientNotifySpawn(DeathMatch(Level.Game).SpawnProtectionTime);
    }
}

simulated function ClientNotifySpawn(float SpawnProtectionTime)
{
    if (Level.NetMode != NM_DedicatedServer && SPTimer != None)
    {
        SPTimer.SetProtected(SpawnProtectionTime);
    }
}

simulated function bool InitializeClient()
{
    if (PlayerOwner != None && PlayerOwner.GameReplicationInfo != None)
    {
        if (Player == None)
        {
            Player = HxUTPlayer(SpawnUnique(class'HxUTPlayer', PlayerOwner));
            Player.ApplyServerConfiguration(Self);
        }
        if (PlayerOwner.myHUD != None)
        {
            UpdateScoreBoardConfig();
            if (HitEffects == None)
            {
                HitEffects = HxHitEffects(SpawnOverlay(PlayerOwner.myHUD, class'HxHitEffects'));
            }
            if (SPTimer == None)
            {
                SPTimer = HxSPTimer(SpawnOverlay(PlayerOwner.myHUD, class'HxSPTimer'));
            }
        }
    }
    return Player != None && HitEffects != None && SPTimer != None;
}

simulated function NotifyServerPropertiesReady()
{
    if (Player != None)
    {
        Player.ApplyServerConfiguration(Self);
    }
    UpdateScoreBoardConfig();
    UpdateSkinHighlightConfig();
}

simulated function NotifyServerPropertyChanged(int Index, string OldValue)
{
    switch (MutatorClass.default.Properties[Index].Name)
    {
        case "AllowForcedModels":
        case "ModelList":
            UpdateSkinHighlightConfig();
            break;
        case "bAllowCustomViewSmoothing":
            if (Player != None)
            {
                Player.ApplyServerConfiguration(Self);
            }
            break;
        case "bAllowEnhancedScoreBoards":
            UpdateScoreBoardConfig();
            break;
    }
}

simulated function bool ShouldHideServerPropertyFromStatus(int Index)
{
    if (bool(GetServerProperty("bHideDisabledFeatures")))
    {
        switch (MutatorClass.default.Properties[Index].Name)
        {
            case "bRequireLOS":
                return !bool(GetServerProperty("bAllowHitSounds"))
                    && !bool(GetServerProperty("bAllowDamageNumbers"));
            case "SkinHighlightIntensity":
            case "SkinOverlayIntensity":
                return !bool(GetServerProperty("bAllowSkinHighlight"));
            case "AllowForcedModels":
                return !bool(GetServerProperty("bAllowSkinHighlight")) || !IsForcedModelAllowed();
            case "ModelList":
            case "bHideDisabledFeatures":
                return true;
        }
        return !bool(GetServerPropertyByIndex(Index));;
    }
    return Super.ShouldHideServerPropertyFromStatus(Index);
}

simulated function bool IsForcedModelAllowed()
{
    local HxSkinHighlightConfig Config;

    Config = HxSkinHighlightConfig(FindConfig(class'HxSkinHighlightConfig'));
    return config.AllowForcedModels != HX_FM_None;
}

simulated function UpdateSkinHighlightConfig()
{
    local HxSkinHighlightConfig Config;

    Config = HxSkinHighlightConfig(FindConfig(class'HxSkinHighlightConfig'));
    Config.ApplyServerConfiguration(Self);
}

simulated function UpdateScoreBoardConfig()
{
    local HxScoreBoardConfig Config;

    Config = HxScoreBoardConfig(FindConfig(class'HxScoreBoardConfig'));
    Config.SetAllowed(GetServerProperty("bAllowEnhancedScoreBoards"));
}

simulated function ParseArrayProperty(int Index, array<string> Values)
{
    if (MutatorClass.default.Properties[Index].Name == "ModelList")
    {
        ModelList = Values;
    }
}

simulated function HxColors GetSkinHighlightColors()
{
    return SkinHighlightColors;
}

defaultproperties
{
    MutatorClass=class'MutHexedUT'
    ConfigClasses(0)=class'HxHitEffectsConfig'
    ConfigClasses(1)=class'HxSkinHighlightConfig'
    ConfigClasses(2)=class'HxUTPlayerConfig'
    ConfigClasses(3)=class'HxScoreBoardConfig'
    ConfigClasses(4)=class'HxSPTimerConfig'
    PanelClasses(0)=class'HxGUIMenuHUDPanel'
    PanelClasses(1)=class'HxGUIMenuHitEffectsPanel'
    PanelClasses(2)=class'HxGUIMenuSkinHighlightPanel'
    Order=0
}
