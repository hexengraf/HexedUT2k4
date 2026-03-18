class HxUTClient extends HxClientReplicationInfo
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

var HxHitEffects HitEffects;
var HxSpawnProtectionTimer SPTimer;

var private PlayerController PC;
var private GUIController GUIController;
var private DamageInfo Damage;
var private bool bInitialized;
var private bool bReplaceMapVoteMenu;

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
        if (bFirstRun)
        {
            RecoverConfigs();
        }
        class'HxGUIMenuSkinHighlightPanel'.static.AddToMenu();
        class'HxGUIMenuHitEffectsPanel'.static.AddToMenu();
        class'HxGUIMenuGeneralPanel'.static.AddToMenu();
    }
    InitializePlayerController();
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
        else if (bReplaceMapVoteMenu)
        {
            TryReplaceMapVoteMenu();
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
            ConfigureHitEffects();
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
        return bool(GetProperty("bDisableSpeedCombo"));
    }
    if (Name ~= "XGame.ComboBerserk")
    {
        return bool(GetProperty("bDisableBerserkCombo"));
    }
    if (Name ~= "XGame.ComboDefensive")
    {
        return bool(GetProperty("bDisableBoosterCombo"));
    }
    if (Name ~= "XGame.ComboInvis")
    {
        return bool(GetProperty("bDisableInvisibleCombo"));
    }
    return false;
}

simulated function ConfigureHitEffects()
{
    HitEffects.SetServerProperties(
        GetProperty("bAllowHitSounds"), GetProperty("bAllowDamageNumbers"));
}

simulated function SetMapVoteMenu(bool bValue)
{
    bMapVoteMenu = bValue;
    if (bMapVoteMenu)
    {
        bReplaceMapVoteMenu = GUIController != None
            && GUIController.MapVotingMenu != string(class'HxMapVotingPage')
            && !GUIController.SetPropertyText("CustomMapVotingMenu", string(class'HxMapVotingPage'));
        if (bReplaceMapVoteMenu)
        {
            Enable('Tick');
        }
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
            GUIController.ReplaceMenu(string(class'HxMapVotingPage'));
        }
        else if (GUIController.ActivePage.ParentPage != None
                 && GUIController.ActivePage.ParentPage.Class == class'MapVotingPage')
        {
            if (GUIController.CloseMenu(true))
            {
                GUIController.ReplaceMenu(string(class'HxMapVotingPage'));
            }
        }
    }
}

simulated function ServerInfoReady()
{
    if (PC != None)
    {
        ModifyPlayerCombos(xPlayer(PC));
    }
    if (HitEffects != None)
    {
        ConfigureHitEffects();
    }
}

simulated function PropertyChanged(int Index, string OldValue)
{
    if (HitEffects != None)
    {
        ConfigureHitEffects();
    }
}

simulated function RecoverConfigs()
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

static function HxUTClient GetClient(PlayerController PC)
{
    local HxUTClient Client;

    ForEach PC.DynamicActors(class'HxUTClient', Client)
    {
        if (Client.Owner == PC)
        {
            return Client;
        }
    }
    return None;
}

defaultproperties
{
    MutatorClass=class'MutHexedUT'
    bFirstRun=true
    bMapVoteMenu=true
}
