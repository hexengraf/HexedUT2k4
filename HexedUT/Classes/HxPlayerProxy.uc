class HxPlayerProxy extends HxLinkedReplicationInfo;

struct DamageInfo
{
    var int Value;
    var float Timestamp;
};

const DAMAGE_CLUSTERING_INTERVAL = 0.015;

var bool bAllowHitSounds;
var bool bAllowDamageNumbers;
var bool bColoredDeathMessages;
var float HealthLeechRatio;
var int HealthLeechLimit;
var float MaxSpeedMultiplier;
var float AirControlMultiplier;
var float BaseJumpMultiplier;
var float MultiJumpMultiplier;
var int BonusMultiJumps;
var float DodgeMultiplier;
var float DodgeSpeedMultiplier;
var bool bDisableWallDodge;
var bool bDisableDodgeJump;
var int BonusStartingHealth;
var int BonusStartingShield;
var int BonusStartingGrenades;
var int BonusStartingAdrenaline;
var int BonusAdrenalineOnSpawn;
var bool bDisableSpeedCombo;
var bool bDisableBerserkCombo;
var bool bDisableBoosterCombo;
var bool bDisableInvisibleCombo;
var bool bDisableUDamage;

var MutHexedUT HexedUT;
var PlayerController PC;
var HxHitEffects HitEffects;
var DamageInfo Damage;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientUpdateHitEffects;

    reliable if (Role == ROLE_Authority)
        bAllowHitSounds,
        bAllowDamageNumbers,
        bColoredDeathMessages,
        HealthLeechRatio,
        HealthLeechLimit,
        MaxSpeedMultiplier,
        AirControlMultiplier,
        BaseJumpMultiplier,
        MultiJumpMultiplier,
        BonusMultiJumps,
        DodgeMultiplier,
        DodgeSpeedMultiplier,
        bDisableWallDodge,
        bDisableDodgeJump,
        BonusStartingHealth,
        BonusStartingShield,
        BonusStartingGrenades,
        BonusStartingAdrenaline,
        BonusAdrenalineOnSpawn,
        bDisableSpeedCombo,
        bDisableBerserkCombo,
        bDisableBoosterCombo,
        bDisableInvisibleCombo,
        bDisableUDamage;

    reliable if (Role < ROLE_Authority)
        RemoteSetProperty;
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (Level.NetMode != NM_DedicatedServer)
    {
        class'HxServerMenuPanel'.static.AddToMenu();
        class'HxHitEffectsMenuPanel'.static.AddToMenu();
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
    Damage.Timestamp = Level.TimeSeconds;
    Damage.Value += Value;
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
        && InitializeHitEffects();
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
    if ((Level.NetMode == NM_Standalone || PC.PlayerReplicationInfo.bAdmin)
        && GetPropertyText(PropertyName) != PropertyValue)
    {
        HexedUT.SetProperty(PropertyName, PropertyValue);
    }
}

function Update()
{
    bAllowHitSounds = HexedUT.bAllowHitSounds;
    bAllowDamageNumbers = HexedUT.bAllowDamageNumbers;
    bColoredDeathMessages = HexedUT.bColoredDeathMessages;
    HealthLeechRatio = HexedUT.HealthLeechRatio;
    HealthLeechLimit = HexedUT.HealthLeechLimit;
    MaxSpeedMultiplier = HexedUT.MaxSpeedMultiplier;
    AirControlMultiplier = HexedUT.AirControlMultiplier;
    BaseJumpMultiplier = HexedUT.BaseJumpMultiplier;
    MultiJumpMultiplier = HexedUT.MultiJumpMultiplier;
    BonusMultiJumps = HexedUT.BonusMultiJumps;
    DodgeMultiplier = HexedUT.DodgeMultiplier;
    DodgeSpeedMultiplier = HexedUT.DodgeSpeedMultiplier;
    bDisableWallDodge = HexedUT.bDisableWallDodge;
    bDisableDodgeJump = HexedUT.bDisableDodgeJump;
    BonusStartingHealth = HexedUT.BonusStartingHealth;
    BonusStartingShield = HexedUT.BonusStartingShield;
    BonusStartingGrenades = HexedUT.BonusStartingGrenades;
    BonusStartingAdrenaline = HexedUT.BonusStartingAdrenaline;
    BonusAdrenalineOnSpawn = HexedUT.BonusAdrenalineOnSpawn;
    bDisableSpeedCombo = HexedUT.bDisableSpeedCombo;
    bDisableBerserkCombo = HexedUT.bDisableBerserkCombo;
    bDisableBoosterCombo = HexedUT.bDisableBoosterCombo;
    bDisableInvisibleCombo = HexedUT.bDisableInvisibleCombo;
    bDisableUDamage = HexedUT.bDisableUDamage;
    NetUpdateTime = Level.TimeSeconds - 1;
}

static function RegisterDamage(PlayerController PC,
                               int Damage,
                               Pawn Injured,
                               Pawn Inflictor,
                               class<DamageType> Type)
{
    local HxPlayerProxy Proxy;

    if (PC != None && PC.ViewTarget == Inflictor && Injured != Inflictor)
    {
        Proxy = GetAgent(PC);
        if (Proxy != None && IsEnemy(Injured, Inflictor))
        {
            Proxy.UpdateDamage(Damage, Injured, Inflictor, Type);
        }
    }
}

static function HxPlayerProxy GetAgent(Controller C)
{
    return HxPlayerProxy(Find(C.PlayerReplicationInfo, class'HxPlayerProxy'));
}

static function bool IsEnemy(Pawn Injured, Pawn Inflictor)
{
    local int TeamNum;

    TeamNum = Injured.GetTeamNum();
    return TeamNum == 255 || TeamNum != Inflictor.GetTeamNum();
}

defaultproperties
{
}
