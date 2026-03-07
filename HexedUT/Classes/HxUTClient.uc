class HxUTClient extends ReplicationInfo
    config(User);

struct DamageInfo
{
    var int Value;
    var float Timestamp;
};

const MIN_VERSION = 4;

const DAMAGE_CLUSTERING_INTERVAL = 0.02;

var config bool bFirstRun;
var config bool bMapVoteMenu;

var bool bAllowHitSounds;
var bool bAllowDamageNumbers;
var bool bAllowSpawnProtectionTimer;
var bool bColoredDeathMessages;
var bool bAllowSkinHighlight;
var float SkinHighlightIntensity;
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
var float MaxSpeedMultiplier;
var float AirControlMultiplier;
var float BaseJumpMultiplier;
var float MultiJumpMultiplier;
var int BonusMultiJumps;
var float DodgeMultiplier;
var float DodgeSpeedMultiplier;
var bool bDisableWallDodge;
var bool bDisableDodgeJump;
var float HealthLeechRatio;
var int HealthLeechLimit;

var MutHexedUT HexedUT;
var HxHitEffects HitEffects;
var HxSpawnProtectionTimer SPTimer;

var private PlayerController PC;
var private GUIController GUIController;
var private DamageInfo Damage;
var private array<HxUTClient> Clients;
var private bool bInitialized;
var private bool bReplaceMapVoteMenu;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientUpdateHitEffects,
        ClientNotifySpawn;

    reliable if (Role == ROLE_Authority)
        bAllowHitSounds,
        bAllowDamageNumbers,
        bAllowSpawnProtectionTimer,
        bColoredDeathMessages,
        bAllowSkinHighlight,
        SkinHighlightIntensity,
        BonusStartingHealth,
        BonusStartingShield,
        BonusStartingGrenades,
        BonusStartingAdrenaline,
        BonusAdrenalineOnSpawn,
        bDisableSpeedCombo,
        bDisableBerserkCombo,
        bDisableBoosterCombo,
        bDisableInvisibleCombo,
        bDisableUDamage,
        MaxSpeedMultiplier,
        AirControlMultiplier,
        BaseJumpMultiplier,
        MultiJumpMultiplier,
        BonusMultiJumps,
        DodgeMultiplier,
        DodgeSpeedMultiplier,
        bDisableWallDodge,
        bDisableDodgeJump,
        HealthLeechRatio,
        HealthLeechLimit;

    reliable if (Role < ROLE_Authority)
        RemoteSetProperty;
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (bFirstRun)
        {
            RecoverConfigs();
        }
        class'HxGUIMenuModifiersPanel'.static.AddToMenu();
        class'HxGUIMenuSkinHighlightPanel'.static.AddToMenu();
        class'HxGUIMenuHitEffectsPanel'.static.AddToMenu();
        class'HxGUIMenuGeneralPanel'.static.AddToMenu();
    }
}

simulated event Tick(float DeltaTime)
{
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (!bInitialized)
        {
            bInitialized = InitializeClient();
        }
        else if (bReplaceMapVoteMenu)
        {
            TryReplaceMapVoteMenu();
        }
        else if (Level.NetMode == NM_Client)
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
    if (InitializePlayerController() && InitializeGUIController() && InitializeHUDOverlays())
    {
        Register(Self);
        SetMapVoteMenu(bMapVoteMenu);
        return true;
    }
    return false;
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

simulated function bool InitializeGUIController()
{
    if (PC.Player != None)
    {
        GUIController = GUIController(PC.Player.GUIController);
        return true;
    }
    return false;
}

simulated function bool InitializeHUDOverlays()
{
    if (PC.myHUD != None)
    {
        if (HitEffects == None)
        {
            HitEffects = PC.myHUD.Spawn(class'HxHitEffects', PC.myHUD);
            PC.myHUD.AddHudOverlay(HitEffects);
        }
        if (SPTimer == None)
        {
            SPTimer = PC.myHUD.Spawn(class'HxSpawnProtectionTimer', PC.myHUD);
            PC.myHUD.AddHudOverlay(SPTimer);
        }
    }
    return HitEffects != None && SPTimer != None;
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

simulated function SetMapVoteMenu(bool bValue)
{
    bMapVoteMenu = bValue;
    if (bMapVoteMenu)
    {
        bReplaceMapVoteMenu = GUIController != None
            && GUIController.MapVotingMenu != string(class'HxGUIVotingPage')
            && !GUIController.SetPropertyText("CustomMapVotingMenu", string(class'HxGUIVotingPage'));
    }
    else
    {
        bReplaceMapVoteMenu = false;
        GUIController.SetPropertyText("CustomMapVotingMenu", "");
    }
}

simulated function TryReplaceMapVoteMenu()
{
    if (GUIController.ActivePage != None)
    {
        if (GUIController.ActivePage.Class == class'MapVotingPage')
        {
            GUIController.ReplaceMenu(string(class'HxGUIVotingPage'));
        }
        else if (GUIController.ActivePage.ParentPage != None
                 && GUIController.ActivePage.ParentPage.Class == class'MapVotingPage')
        {
            if (GUIController.CloseMenu(true))
            {
                GUIController.ReplaceMenu(string(class'HxGUIVotingPage'));
            }
        }
    }
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
    bAllowSpawnProtectionTimer = HexedUT.bAllowSpawnProtectionTimer;
    bColoredDeathMessages = HexedUT.bColoredDeathMessages;
    bAllowSkinHighlight = HexedUT.bAllowSkinHighlight;
    SkinHighlightIntensity = HexedUT.SkinHighlightIntensity;
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
    MaxSpeedMultiplier = HexedUT.MaxSpeedMultiplier;
    AirControlMultiplier = HexedUT.AirControlMultiplier;
    BaseJumpMultiplier = HexedUT.BaseJumpMultiplier;
    MultiJumpMultiplier = HexedUT.MultiJumpMultiplier;
    BonusMultiJumps = HexedUT.BonusMultiJumps;
    DodgeMultiplier = HexedUT.DodgeMultiplier;
    DodgeSpeedMultiplier = HexedUT.DodgeSpeedMultiplier;
    bDisableWallDodge = HexedUT.bDisableWallDodge;
    bDisableDodgeJump = HexedUT.bDisableDodgeJump;
    HealthLeechRatio = HexedUT.HealthLeechRatio;
    HealthLeechLimit = HexedUT.HealthLeechLimit;
    NetUpdateTime = Level.TimeSeconds - 1;
}

function RecoverConfigs()
{
    local Actor OldActor;

    OldActor = class'HxConfig'.static.FindOldVersionActor(Self, Class, MIN_VERSION);
    if (OldActor != None)
    {
        class'HxConfig'.static.CopyProperty(Self, OldActor, "bMapVoteMenu");
        OldActor.Destroy();
    }
    class'HxHitEffects'.static.StaticRecoverConfigs(Self);
    class'HxSkinHighlight'.static.StaticRecoverConfigs(Self);
    bFirstRun = false;
    SaveConfig();
}

static function RegisterDamage(int Damage, Pawn Injured, Pawn Inflictor, class<DamageType> Type)
{
    local PlayerController PC;
    local int i;

    for (i = 0; i < default.Clients.Length; ++i)
    {
        PC = PlayerController(default.Clients[i].Owner);
        if (PC != None && PC.ViewTarget == Inflictor && Injured != Inflictor
            && IsEnemy(Injured, Inflictor))
        {
            default.Clients[i].UpdateDamage(Damage, Injured, Inflictor, Type);
        }
    }
}

static function RegisterSpawn(Pawn Spawned)
{
    local PlayerController PC;
    local int i;

    for (i = 0; i < default.Clients.Length; ++i)
    {
        PC = PlayerController(default.Clients[i].Owner);
        if (PC != None && PC.ViewTarget == Spawned)
        {
            default.Clients[i].NotifySpawn(Spawned);
        }
    }
}

static function bool IsEnemy(Pawn Injured, Pawn Inflictor)
{
    local int TeamNum;

    TeamNum = Injured.GetTeamNum();
    return TeamNum == 255 || TeamNum != Inflictor.GetTeamNum();
}

static function HxUTClient New(PlayerController PC, MutHexedUT HexedUT)
{
    local HxUTClient Client;

    Client = PC.Spawn(class'HxUTClient', PC);
    Client.HexedUT = HexedUT;
    default.Clients[default.Clients.Length] = Client;
    Client.Update();
    Client.InitializePlayerController();
    return Client;
}

static function bool Delete(PlayerController PC)
{
    local int i;

    for (i = 0; i < default.Clients.Length; ++i)
    {
        if (default.Clients[i].Owner == PC)
        {
            default.Clients.Remove(i, 1);
            return true;
        }
    }
    return false;
}

static function bool Register(HxUTClient Client)
{
    local int i;

    for (i = 0; i < default.Clients.Length; ++i)
    {
        if (default.Clients[i] == Client)
        {
            return false;
        }
    }
    default.Clients[default.Clients.Length] = Client;
    return true;
}

static function HxUTClient GetClient(PlayerController PC)
{
    local int i;

    for (i = 0; i < default.Clients.Length; ++i)
    {
        if (default.Clients[i].Owner == PC)
        {
            return default.Clients[i];
        }
    }
    return None;
}

defaultproperties
{
    bFirstRun=true
    bMapVoteMenu=true
    RemoteRole=ROLE_SimulatedProxy
    bHidden=true
    bAlwaysRelevant=true
    bStatic=false
    bSkipActorPropertyReplication=false
    bOnlyDirtyReplication=true
    NetUpdateFrequency=10
}
