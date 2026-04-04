class HxUTClient extends HxClientReplicationInfo
    config(User);

struct HxDamageInfo
{
    var int Value;
    var float Timestamp;
};

const MIN_VERSION = 4;

const DAMAGE_CLUSTERING_INTERVAL = 0.02;

var config bool bFirstRun;

var HxHitEffects HitEffects;
var HxSpawnProtectionTimer SPTimer;
var HxPlayerModifiers PlayerModifiers;

var private PlayerController PC;
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
        if (bFirstRun)
        {
            RecoverConfigs();
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
            bInitialized = InitializePlayerController() && InitializeHUDOverlays();
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

simulated function bool InitializePlayerController()
{
    if (PC == None)
    {
        PC = PlayerController(Owner);
        if (PC != None)
        {
            PlayerModifiers = Spawn(class'HxPlayerModifiers', PC);
            PlayerModifiers.SetDisabledCombos(Self);
        }
        return PC != None;
    }
    return true;
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

simulated function ConfigureHitEffects()
{
    HitEffects.SetServerProperties(
        GetServerProperty("bAllowHitSounds"), GetServerProperty("bAllowDamageNumbers"));
}

simulated function ServerInfoReady()
{
    if (PlayerModifiers != None)
    {
        PlayerModifiers.SetDisabledCombos(Self);
    }
    if (HitEffects != None)
    {
        ConfigureHitEffects();
    }
}

simulated function ServerPropertyChanged(int Index, string OldValue)
{
    if (HitEffects != None)
    {
        ConfigureHitEffects();
    }
}

simulated function string GetProperty(int Index)
{
    if (Index >= Properties.Length)
    {
        return "";
    }
    if (SPTimer != None)
    {
        return SPTimer.GetPropertyText(Properties[Index].Name);
    }
    switch (Index)
    {
        case 0:
            return string(class'HxSpawnProtectionTimer'.default.bEnabled);
        case 1:
            return string(class'HxSpawnProtectionTimer'.default.bUseHUDColor);
        case 2:
            return string(class'HxSpawnProtectionTimer'.default.bPulsingDigits);
        case 3:
            return string(class'HxSpawnProtectionTimer'.default.PosX);
        case 4:
            return string(class'HxSpawnProtectionTimer'.default.PosY);
    }
    return "";
}

simulated function SetProperty(int Index, string Value)
{
    if (Index < Properties.Length)
    {
        if (SPTimer != None)
        {
            SPTimer.SetPropertyText(Properties[Index].Name, Value);
            SPTimer.SaveConfig();
        }
        else
        {
            switch (Index)
            {
                case 0:
                    class'HxSpawnProtectionTimer'.default.bEnabled = bool(Value);
                    break;
                case 1:
                    class'HxSpawnProtectionTimer'.default.bUseHUDColor = bool(Value);
                    break;
                case 2:
                    class'HxSpawnProtectionTimer'.default.bPulsingDigits = bool(Value);
                    break;
                case 3:
                    class'HxSpawnProtectionTimer'.default.PosX = float(Value);
                    break;
                case 4:
                    class'HxSpawnProtectionTimer'.default.PosY = float(Value);
                    break;
            }
            class'HxSpawnProtectionTimer'.static.StaticSaveConfig();
        }
    }
}

simulated function RecoverConfigs()
{
    class'HxHitEffects'.static.StaticRecoverConfigs(Self);
    class'HxSkinHighlight'.static.StaticRecoverConfigs(Self);
    bFirstRun = false;
    SaveConfig();
}

defaultproperties
{
    bFirstRun=true
    MutatorClass=class'MutHexedUT'
    Properties(0)=(Name="bEnabled",Section="Spawn Protection Timer",Caption="Enable spawn protection timer",Hint="Show timer indicating remaining spawn protection duration.",Type=PIT_Check,Dependency="bAllowSpawnProtectionTimer")
    Properties(1)=(Name="bUseHUDColor",Section="Spawn Protection Timer",Caption="Use HUD's color",Hint="Use the same color as the HUD for the timer's icon.",Type=PIT_Check,Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    Properties(2)=(Name="bPulsingDigits",Section="Spawn Protection Timer",Caption="Use pulsing digits",Hint="Use pulsing digits for the timer.",Type=PIT_Check,Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    Properties(3)=(Name="PosX",Section="Spawn Protection Timer",Caption="X position",Hint="Adjust X position.",Type=PIT_Text,Data="8;0.0:1.0",Step=0.01,Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    Properties(4)=(Name="PosY",Section="Spawn Protection Timer",Caption="Y position",Hint="Adjust Y position.",Type=PIT_Text,Data="8;0.0:1.0",Step=0.01,Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    PanelClasses(0)=class'HxGUIMenuSkinHighlightPanel'
    PanelClasses(1)=class'HxGUIMenuHitEffectsPanel'
    Order=0
}
