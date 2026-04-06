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
        if (PlayerModifiers == None)
        {
            PlayerModifiers = Spawn(class'HxPlayerModifiers', PC);
            PlayerModifiers.ApplyServerConfiguration(Self);
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
                SPTimer = Spawn(class'HxSpawnProtectionTimer', PC.myHUD);
                PC.myHUD.AddHudOverlay(SPTimer);
            }
        }
    }
    return PlayerModifiers != None && HitEffects != None && SPTimer != None;
}

simulated function ServerInfoReady()
{
    if (PlayerModifiers != None)
    {
        PlayerModifiers.ApplyServerConfiguration(Self);
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

simulated function string GetProperty(int Index)
{
    switch (Index)
    {
        case 0:
            return string(
                GetEnum(enum'EHxViewSmoothing', class'HxPlayerModifiers'.default.ViewSmoothing));
        case 1:
            return string(class'HxSpawnProtectionTimer'.default.bEnabled);
        case 2:
            return string(class'HxSpawnProtectionTimer'.default.bUseHUDColor);
        case 3:
            return string(class'HxSpawnProtectionTimer'.default.bPulsingDigits);
        case 4:
            return string(class'HxSpawnProtectionTimer'.default.PosX);
        case 5:
            return string(class'HxSpawnProtectionTimer'.default.PosY);
    }
    return "";
}

simulated function SetProperty(int Index, string Value)
{
    if (Index == 0)
    {
        if (PlayerModifiers != None)
        {
            PlayerModifiers.SetPropertyText(Properties[Index].Name, Value);
            PlayerModifiers.SaveConfig();
        }
        else
        {
            class'HxPlayerModifiers'.static.SetViewSmoothing(Value);
            class'HxPlayerModifiers'.static.StaticSaveConfig();
        }
    }
    else if (Index < Properties.Length)
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
                case 1:
                    class'HxSpawnProtectionTimer'.default.bEnabled = bool(Value);
                    break;
                case 2:
                    class'HxSpawnProtectionTimer'.default.bUseHUDColor = bool(Value);
                    break;
                case 3:
                    class'HxSpawnProtectionTimer'.default.bPulsingDigits = bool(Value);
                    break;
                case 4:
                    class'HxSpawnProtectionTimer'.default.PosX = float(Value);
                    break;
                case 5:
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

    Properties(0)=(Name="ViewSmoothing",Section="Camera",Caption="View smoothing",Hint="Choose which type of view smoothing to apply.",Type=PIT_Select,Data="HX_VS_Default;Strong (default);HX_VS_Weak;Weak;HX_VS_Disabled;Disabled",Dependency="bAllowCustomViewSmoothing",bAdvanced=true)
    Properties(1)=(Name="bEnabled",Section="Spawn Protection Timer",Caption="Enable spawn protection timer",Hint="Show timer indicating remaining spawn protection duration.",Type=PIT_Check,Dependency="bAllowSpawnProtectionTimer")
    Properties(2)=(Name="bUseHUDColor",Section="Spawn Protection Timer",Caption="Use HUD's color",Hint="Use the same color as the HUD for the timer's icon.",Type=PIT_Check,Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    Properties(3)=(Name="bPulsingDigits",Section="Spawn Protection Timer",Caption="Use pulsing digits",Hint="Use pulsing digits for the timer.",Type=PIT_Check,Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    Properties(4)=(Name="PosX",Section="Spawn Protection Timer",Caption="X position",Hint="Adjust X position.",Type=PIT_Text,Data="8;0.0:1.0",Step=0.01,Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    Properties(5)=(Name="PosY",Section="Spawn Protection Timer",Caption="Y position",Hint="Adjust Y position.",Type=PIT_Text,Data="8;0.0:1.0",Step=0.01,Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    PanelClasses(0)=class'HxGUIMenuSkinHighlightPanel'
    PanelClasses(1)=class'HxGUIMenuHitEffectsPanel'
    Order=0
}
