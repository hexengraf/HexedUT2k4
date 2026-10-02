class HxUTClient extends HxClientReplicationInfo;

struct HxHitSoundInfo
{
    var int Value;
    var float Timestamp;
};

const HIT_SOUND_INTERVAL = 0.02;

var private HxHitEffects HitEffects;
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

simulated function bool InitializeClient()
{
    if (PlayerOwner != None && PlayerOwner.GameReplicationInfo != None && PlayerOwner.myHUD != None)
    {
        if (IsMutatorInfoReady())
        {
            HxScoreBoardConfig(FindConfig(class'HxScoreBoardConfig')).UpdateScoreBoard();
        }
        HitEffects = HxHitEffects(SpawnOverlay(PlayerOwner.myHUD, class'HxHitEffects'));
        SPTimer = HxSPTimer(SpawnOverlay(PlayerOwner.myHUD, class'HxSPTimer'));
        return true;
    }
    return false;
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
    if (SPTimer != None)
    {
        SPTimer.SetProtected(SpawnProtectionTime);
    }
}

defaultproperties
{
    MutatorClass=class'MutHexedUT'
}
