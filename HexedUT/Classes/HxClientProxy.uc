class HxClientProxy extends ReplicationInfo;

struct DamageInfo
{
    var int Value;
    var float Timestamp;
};

const DAMAGE_CLUSTERING_INTERVAL = 0.015;

var bool bAllowHitSounds;
var bool bAllowDamageNumbers;
var bool bAllowSkinHighlight;
var float SkinHighlightIntensity;
var bool bColoredDeathMessages;
var float HealthLeechRatio;
var int HealthLeechLimit;
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
var bool bDisableWallDodge;
var bool bDisableDodgeJump;
var bool bDisableSpeedCombo;
var bool bDisableBerserkCombo;
var bool bDisableBoosterCombo;
var bool bDisableInvisibleCombo;
var bool bDisableUDamage;

var MutHexedUT HexedUT;
var HxHitEffects HitEffects;

var private PlayerController PC;
var private DamageInfo Damage;
var private array<HxClientProxy> Proxies;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientUpdateHitEffects;

    reliable if (Role == ROLE_Authority)
        bAllowHitSounds,
        bAllowDamageNumbers,
        bAllowSkinHighlight,
        SkinHighlightIntensity,
        bColoredDeathMessages,
        HealthLeechRatio,
        HealthLeechLimit,
        BonusStartingHealth,
        BonusStartingShield,
        BonusStartingGrenades,
        BonusStartingAdrenaline,
        BonusAdrenalineOnSpawn,
        MaxSpeedMultiplier,
        AirControlMultiplier,
        BaseJumpMultiplier,
        MultiJumpMultiplier,
        BonusMultiJumps,
        DodgeMultiplier,
        DodgeSpeedMultiplier,
        bDisableWallDodge,
        bDisableDodgeJump,
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
        class'HxMenuServerPanel'.static.AddToMenu();
        class'HxMenuSkinHighlightPanel'.static.AddToMenu();
        class'HxMenuHitEffectsPanel'.static.AddToMenu();
    }
}

simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);
    if (Level.NetMode != NM_DedicatedServer && InitializeClient())
    {
        Register(Self);
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
        PC = PlayerController(Owner);
        ModifyPlayerCombos(xPlayer(PC));
        return PC != None;
    }
    return true;
}

simulated function bool InitializeHitEffects()
{
    if (HitEffects == None && PC != None && PC.myHUD != None)
    {
        HitEffects = PC.myHUD.Spawn(class'HxHitEffects', PC.myHUD);
        PC.myHUD.AddHudOverlay(HitEffects);
    }
    return HitEffects != None;
}

simulated function ModifyPlayerCombos(xPlayer Other)
{
    local int Combo;

    if (Other != None)
    {
        for (Combo = 0; Combo < ArrayCount(Other.ComboNameList); ++Combo)
        {
            if (Other.ComboNameList[Combo] == "")
            {
                break;
            }
            if (ShouldDisableCombo(Other.ComboNameList[Combo]))
            {
                Other.ComboNameList[Combo] = string(class'HxComboNull');
                Other.ComboList[Combo] = class'HxComboNull';
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
    bAllowSkinHighlight = HexedUT.bAllowSkinHighlight;
    SkinHighlightIntensity = HexedUT.SkinHighlightIntensity;
    bColoredDeathMessages = HexedUT.bColoredDeathMessages;
    HealthLeechRatio = HexedUT.HealthLeechRatio;
    HealthLeechLimit = HexedUT.HealthLeechLimit;
    BonusStartingHealth = HexedUT.BonusStartingHealth;
    BonusStartingShield = HexedUT.BonusStartingShield;
    BonusStartingGrenades = HexedUT.BonusStartingGrenades;
    BonusStartingAdrenaline = HexedUT.BonusStartingAdrenaline;
    BonusAdrenalineOnSpawn = HexedUT.BonusAdrenalineOnSpawn;
    MaxSpeedMultiplier = HexedUT.MaxSpeedMultiplier;
    AirControlMultiplier = HexedUT.AirControlMultiplier;
    BaseJumpMultiplier = HexedUT.BaseJumpMultiplier;
    MultiJumpMultiplier = HexedUT.MultiJumpMultiplier;
    BonusMultiJumps = HexedUT.BonusMultiJumps;
    DodgeMultiplier = HexedUT.DodgeMultiplier;
    DodgeSpeedMultiplier = HexedUT.DodgeSpeedMultiplier;
    bDisableWallDodge = HexedUT.bDisableWallDodge;
    bDisableDodgeJump = HexedUT.bDisableDodgeJump;
    bDisableSpeedCombo = HexedUT.bDisableSpeedCombo;
    bDisableBerserkCombo = HexedUT.bDisableBerserkCombo;
    bDisableBoosterCombo = HexedUT.bDisableBoosterCombo;
    bDisableInvisibleCombo = HexedUT.bDisableInvisibleCombo;
    bDisableUDamage = HexedUT.bDisableUDamage;
    NetUpdateTime = Level.TimeSeconds - 1;
}

static function RegisterDamage(int Damage, Pawn Injured, Pawn Inflictor, class<DamageType> Type)
{
    local PlayerController PC;
    local int i;

    for (i = 0; i < default.Proxies.Length; ++i)
    {
        PC = PlayerController(default.Proxies[i].Owner);
        if (PC != None && PC.ViewTarget == Inflictor && Injured != Inflictor
            && IsEnemy(Injured, Inflictor))
        {
            default.Proxies[i].UpdateDamage(Damage, Injured, Inflictor, Type);
        }
    }
}

static function bool IsEnemy(Pawn Injured, Pawn Inflictor)
{
    local int TeamNum;

    TeamNum = Injured.GetTeamNum();
    return TeamNum == 255 || TeamNum != Inflictor.GetTeamNum();
}

static function HxClientProxy New(PlayerController PC, MutHexedUT HexedUT)
{
    local HxClientProxy Proxy;

    Proxy = PC.Spawn(class'HxClientProxy', PC);
    Proxy.PC = PC;
    Proxy.HexedUT = HexedUT;
    default.Proxies[default.Proxies.Length] = Proxy;
    Proxy.Update();
    return Proxy;
}

static function bool Delete(PlayerController PC)
{
    local int i;

    for (i = 0; i < default.Proxies.Length; ++i)
    {
        if (default.Proxies[i].Owner == PC)
        {
            default.Proxies.Remove(i, 1);
            return true;
        }
    }
    return false;
}

static function bool Register(HxClientProxy Proxy)
{
    local int i;

    for (i = 0; i < default.Proxies.Length; ++i)
    {
        if (default.Proxies[i] == Proxy)
        {
            return false;
        }
    }
    default.Proxies[default.Proxies.Length] = Proxy;
    return true;
}

static function HxClientProxy GetClientProxy(PlayerController PC)
{
    local int i;

    for (i = 0; i < default.Proxies.Length; ++i)
    {
        if (default.Proxies[i].Owner == PC)
        {
            return default.Proxies[i];
        }
    }
    return None;
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bHidden=true
    bAlwaysRelevant=true
    bStatic=false
    bSkipActorPropertyReplication=false
    bOnlyDirtyReplication=true
    NetUpdateFrequency=10
}
