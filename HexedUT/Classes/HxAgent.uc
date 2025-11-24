class HxAgent extends LinkedReplicationInfo;

struct DamageInfo
{
    var int Value;
    var float Timestamp;
};

const DAMAGE_CLUSTERING_INTERVAL = 0.015;

var bool bAllowHitSounds;
var bool bAllowDamageNumbers;
var int BonusStartingHealth;
var int BonusStartingShield;
var int BonusStartingGrenades;
var float MaxSpeedMultiplier;
var float AirControlMultiplier;
var float BaseJumpMultiplier;
var float MultiJumpMultiplier;
var int BonusMultiJumps;

var MutHexedUT HexedUT;
var PlayerController PC;
var HxHitEffects HitEffects;
var HxSpawnProtectionTimer SpawnProtectionTimer;
var DamageInfo Damage;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientUpdateHitEffects;

    reliable if (Role == ROLE_Authority)
        bAllowHitSounds, bAllowDamageNumbers, BonusStartingHealth, BonusStartingShield,
        BonusStartingGrenades, MaxSpeedMultiplier, AirControlMultiplier, BaseJumpMultiplier,
        MultiJumpMultiplier, BonusMultiJumps;

    reliable if (Role < ROLE_Authority)
        ServerSetAllowHitSounds, ServerSetAllowDamageNumbers, ServerSetBonusStartingHealth,
        ServerSetBonusStartingShield, ServerSetBonusStartingGrenades, ServerSetMaxSpeedMultiplier,
        ServerSetAirControlMultiplier, ServerSetBaseJumpMultiplier, ServerSetBonusMultiJumps,
        ServerSetMultiJumpMultiplier;
}

simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);
    if (Level.NetMode != NM_DedicatedServer && InitializeClient())
    {
        if (Level.NetMode == NM_Client)
        {
            Disable('Tick');
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
    if (IsEnemy(Injured, Inflictor))
    {
        Damage.Timestamp = Level.TimeSeconds;
        Damage.Value += Value;
    }
}

simulated function ClientUpdateHitEffects(int Damage)
{
    if (Level.NetMode != NM_DedicatedServer && HitEffects != None)
    {
        HitEffects.Update(Damage);
    }
}

simulated function bool InitializeClient()
{
    return InitializePlayerController()
        && InitializeHitEffects()
        && InitializeSpawnProtectionTimer();
}

simulated function bool InitializePlayerController()
{
    if (PC == None)
    {
        PC = Level.GetLocalPlayerController();
    }
    return PC != None;
}

simulated function bool InitializeHitEffects()
{
    if (HitEffects == None && PC != None && PC.myHUD != None)
    {
        HitEffects = PC.myHUD.Spawn(class'HxHitEffects');
        HitEffects.PC = PC;
        HitEffects.bAllowHitSounds = bAllowHitSounds;
        HitEffects.bAllowDamageNumbers = bAllowDamageNumbers;
        PC.myHUD.AddHudOverlay(HitEffects);
    }
    return HitEffects != None;
}

simulated function bool InitializeSpawnProtectionTimer()
{
    if (SpawnProtectionTimer == None && PC != None && PC.myHUD != None)
    {
        SpawnProtectionTimer = PC.myHUD.Spawn(class'HxSpawnProtectionTimer');
        PC.myHUD.AddHudOverlay(SpawnProtectionTimer);
    }
    return SpawnProtectionTimer != None;
}

simulated function bool IsSynchronized()
{
    return bAllowHitSounds ==  HitEffects.bAllowHitSounds
        && bAllowDamageNumbers == HitEffects.bAllowDamageNumbers;
}

simulated function bool SetAllowHitSounds(bool bValue)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        HitEffects.bAllowHitSounds = bValue;
        ServerSetAllowHitSounds(bValue);
        return true;
    }
    return false;
}

simulated function bool SetAllowDamageNumbers(bool bValue)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        HitEffects.bAllowDamageNumbers = bValue;
        ServerSetAllowDamageNumbers(bValue);
        return true;
    }
    return false;
}

function ServerSetAllowHitSounds(bool bValue)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        bAllowHitSounds = bValue;
        HexedUT.bAllowHitSounds = bValue;
        HexedUT.SaveConfig();
    }
}

function ServerSetAllowDamageNumbers(bool bValue)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        bAllowDamageNumbers = bValue;
        HexedUT.bAllowDamageNumbers = bValue;
        HexedUT.SaveConfig();
    }
}

function ServerSetBonusStartingHealth(int Value)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        BonusStartingHealth = Value;
        HexedUT.BonusStartingHealth = Value;
        HexedUT.SaveConfig();
    }
}

function ServerSetBonusStartingShield(int Value)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        BonusStartingShield = Value;
        HexedUT.BonusStartingShield = Value;
        HexedUT.SaveConfig();
    }
}

function ServerSetBonusStartingGrenades(int Value)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        BonusStartingGrenades = Value;
        HexedUT.BonusStartingGrenades = Value;
        HexedUT.SaveConfig();
    }
}

function ServerSetMaxSpeedMultiplier(float Value)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        MaxSpeedMultiplier = Value;
        HexedUT.MaxSpeedMultiplier = Value;
        HexedUT.SaveConfig();
    }
}

function ServerSetAirControlMultiplier(float Value)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        AirControlMultiplier = Value;
        HexedUT.AirControlMultiplier = Value;
        HexedUT.SaveConfig();
    }
}

function ServerSetBaseJumpMultiplier(float Value)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        BaseJumpMultiplier = Value;
        HexedUT.BaseJumpMultiplier = Value;
        HexedUT.SaveConfig();
    }
}

function ServerSetMultiJumpMultiplier(float Value)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        MultiJumpMultiplier = Value;
        HexedUT.MultiJumpMultiplier = Value;
        HexedUT.SaveConfig();
    }
}

function ServerSetBonusMultiJumps(int Value)
{
    if (PC.PlayerReplicationInfo.bAdmin)
    {
        BonusMultiJumps = Value;
        HexedUT.BonusMultiJumps = Value;
        HexedUT.SaveConfig();
    }
}

static function RegisterDamage(PlayerController PC,
                               int Damage,
                               Pawn Injured,
                               Pawn Inflictor,
                               class<DamageType> Type)
{
    local HxAgent Agent;

    if (PC != None && PC.ViewTarget == Inflictor && Injured != Inflictor)
    {
        Agent = GetAgent(PC);
        if (Agent != None)
        {
            Agent.UpdateDamage(Damage, Injured, Inflictor, Type);
        }
    }
}

static simulated function HxAgent GetAgent(Controller C)
{
    local LinkedReplicationInfo LinkedPRI;

    if (C.PlayerReplicationInfo != None)
    {
        LinkedPRI = C.PlayerReplicationInfo.CustomReplicationInfo;
        while (LinkedPRI != None && HxAgent(LinkedPRI) == None)
        {
            LinkedPRI = LinkedPRI.NextReplicationInfo;
        }
    }
    return HxAgent(LinkedPRI);
}

static function bool IsEnemy(Pawn Injured, Pawn Inflictor)
{
    local int TeamNum;

    TeamNum = Injured.GetTeamNum();
    return TeamNum == 255 || TeamNum != Inflictor.GetTeamNum();
}

defaultproperties
{
    NetUpdateFrequency=10
    bOnlyDirtyReplication=true
}
