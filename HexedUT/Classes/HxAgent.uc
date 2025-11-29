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
var int BonusStartingAdrenaline;
var int BonusAdrenalineOnSpawn;
var float MaxSpeedMultiplier;
var float AirControlMultiplier;
var float BaseJumpMultiplier;
var float MultiJumpMultiplier;
var int BonusMultiJumps;
var float DodgeMultiplier;
var float DodgeSpeedMultiplier;
var bool bCanBoostDodge;
var bool bDisableWallDodge;
var bool bDisableDodgeJump;
var bool bDisableSpeedCombo;
var bool bDisableBerserkCombo;
var bool bDisableBoosterCombo;
var bool bDisableInvisibleCombo;
var bool bDisableUDamage;
var bool bColoredDeathMessages;

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
        bAllowHitSounds, bAllowDamageNumbers,
        BonusStartingHealth, BonusStartingShield, BonusStartingGrenades, BonusStartingAdrenaline,
        BonusAdrenalineOnSpawn,
        MaxSpeedMultiplier, AirControlMultiplier, BaseJumpMultiplier, MultiJumpMultiplier,
        BonusMultiJumps, bCanBoostDodge, bDisableWallDodge, bDisableDodgeJump,
        bDisableSpeedCombo, bDisableBerserkCombo, bDisableBoosterCombo, bDisableInvisibleCombo,
        bColoredDeathMessages;

    reliable if (Role < ROLE_Authority)
        RemoteSetProperty;
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (Level.NetMode != NM_DedicatedServer)
    {
        class'HxServerMenuPanel'.static.AddToMenu();
        class'HxIndicatorsMenuPanel'.static.AddToMenu();
    }
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
        HitEffects.Update(Damage, bAllowHitSounds, bAllowDamageNumbers);
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
        ModifyPlayerCombos(xPlayer(PC));
        return PC != None;
    }
    return true;
}

simulated function bool InitializeHitEffects()
{
    if (HitEffects == None && PC != None && PC.myHUD != None)
    {
        HitEffects = PC.myHUD.Spawn(class'HxHitEffects');
        HitEffects.PC = PC;
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

simulated function ModifyPlayerCombos(xPlayer Other)
{
    local int c;

    if (Other != None)
    {
        for (c = 0; c < ArrayCount(Other.ComboNameList); ++c)
        {
            if (Other.ComboNameList[c] == "")
            {
                break;
            }
            if (ShouldDisableCombo(Other.ComboNameList[c]))
            {
                Other.ComboNameList[c] = string(class'HxComboNull');
                Other.ComboList[c] = class'HxComboNull';
            }
        }
    }
}

simulated function bool ShouldDisableCombo(coerce string Name)
{

    if (Name ~= "XGame.ComboSpeed")
    {
        return bDisableSpeedCombo;
    }
    if (Name ~= "XGame.ComboBerserk")
    {
        return bDisableBerserkCombo;
    }
    if (Name ~= "XGame.ComboDefensive")
    {
        return bDisableBoosterCombo;
    }
    if (Name ~= "XGame.ComboInvis")
    {
        return bDisableInvisibleCombo;
    }
    return false;
}

function RemoteSetProperty(string PropertyName, string PropertyValue)
{
    if (PC.PlayerReplicationInfo.bAdmin && GetPropertyText(PropertyName) != PropertyValue)
    {
        HexedUT.SetProperty(PropertyName, PropertyValue);
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
