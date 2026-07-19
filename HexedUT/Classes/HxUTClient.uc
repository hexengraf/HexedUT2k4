class HxUTClient extends HxClientReplicationInfo;

struct HxDamageInfo
{
    var int Value;
    var float Timestamp;
};

const DAMAGE_CLUSTERING_INTERVAL = 0.02;

var private HxHitEffects HitEffects;
var private HxColors SkinHighlightColors;
var private HxUTPlayer Player;
var private HxSPTimer SPTimer;
var private HxDamageInfo Damage;
var private bool bInitialized;
var private array<string> ModelList;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientUpdateHitEffects,
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
    if (Damage.Value > 0 && Level.TimeSeconds - Damage.Timestamp >= DAMAGE_CLUSTERING_INTERVAL)
    {
        ClientUpdateHitEffects(Damage.Value);
        Damage.Value = 0;
    }
}

function UpdateDamage(int Value, Pawn Injured, Pawn Inflictor, class<DamageType> Type)
{
    Damage.Timestamp = Level.TimeSeconds;
    Damage.Value += Value;
}

simulated function ClientUpdateHitEffects(int Damage)
{
    if (Level.NetMode != NM_DedicatedServer && HitEffects != None)
    {
        HitEffects.Update(Damage);
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
                HitEffects.ApplyServerConfiguration(Self);
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
    if (HitEffects != None)
    {
        HitEffects.ApplyServerConfiguration(Self);
    }
    UpdateScoreBoardConfig();
    UpdateSkinHighlightConfig();
}

simulated function NotifyServerPropertyChanged(int Index, string OldValue)
{
    NotifyServerPropertiesReady();
}

simulated function UpdateSkinHighlightConfig()
{
    local HxSkinHighlightConfig Config;

    Config = HxSkinHighlightConfig(FindConfig(class'HxSkinHighlightConfig'));
    Config.SetAllowed(GetServerProperty("AllowForcedModels"), ModelList);
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
