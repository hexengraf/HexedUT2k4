class HxUTClient extends HxClientReplicationInfo
    config(User);

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

replication
{
    reliable if (Role == ROLE_Authority)
        ClientUpdateHitEffects,
        ClientNotifySpawn;
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (Level.NetMode != NM_DedicatedServer)
    {
        SkinHighlightColors = new (None, "HxSkinHighlight") class'HxColors';
        class'HxSkinHighlight'.static.PopulateReservedNames(SkinHighlightColors);
        HxSkinHighlightConfig(Configs[1]).ValidateColors(SkinHighlightColors);
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
    local PlayerController PC;

    PC = PlayerController(Owner);
    if (PC != None)
    {
        if (Player == None)
        {
            Player = Spawn(class'HxUTPlayer', PC);
            Player.ApplyServerConfiguration(Self);
        }
        if (PC.myHUD != None)
        {
            if (HitEffects == None)
            {
                HitEffects = Spawn(class'HxHitEffects', PC.myHUD);
                PC.myHUD.AddHudOverlay(HitEffects);
                HitEffects.ApplyServerConfiguration(Self);
            }
            if (SPTimer == None)
            {
                SPTimer = Spawn(class'HxSPTimer', PC.myHUD);
                PC.myHUD.AddHudOverlay(SPTimer);
            }
        }
    }
    return Player != None && HitEffects != None && SPTimer != None;
}

simulated function ServerInfoReady()
{
    if (Player != None)
    {
        Player.ApplyServerConfiguration(Self);
    }
    if (HitEffects != None)
    {
        HitEffects.ApplyServerConfiguration(Self);
    }
}

simulated function ServerPropertyChanged(int Index, string OldValue)
{
    ServerInfoReady();
}

simulated function bool SetConfigProperty(int ConfigIndex, int PropertyIndex, string Value)
{
    if (Super.SetConfigProperty(ConfigIndex, PropertyIndex, Value))
    {
        switch (ConfigClasses[ConfigIndex])
        {
            case class'HxHitEffectsConfig':
                if (HitEffects != None)
                {
                    HitEffects.SetProperty(
                        Configs[ConfigIndex].Properties[PropertyIndex].Name, Value);
                }
                break;
            case class'HxUTPlayerConfig':
                if (Player != None)
                {
                    Player.SetPropertyText(
                        Configs[ConfigIndex].Properties[PropertyIndex].Name, Value);
                }
                break;
            case class'HxSPTimerConfig':
                if (SPTimer != None)
                {
                    SPTimer.SetPropertyText(
                        Configs[ConfigIndex].Properties[PropertyIndex].Name, Value);
                }
                break;
        }
        return true;
    }
    return false;
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
    ConfigClasses(3)=class'HxSPTimerConfig'
    PanelClasses(0)=class'HxGUIMenuSkinHighlightPanel'
    PanelClasses(1)=class'HxGUIMenuHitEffectsPanel'
    Order=0
}
