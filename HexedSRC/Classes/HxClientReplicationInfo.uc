class HxClientReplicationInfo extends ReplicationInfo
    abstract
    DependsOn(HxTypes)
    DependsOn(PlayInfo);

struct HxPendingUpdate
{
    var int Index;
    var string Value;
};

const PKG_STR_LIMIT = 480;
const REQUESTS_PER_TICK = 16;

var const class<HxMutator> MutatorClass;
var const array<class<HxConfig> > ConfigClasses;
var const array<class<HxGUIMenuPanel> > PanelClasses;
var const byte Order;

var PlayInfo ServerInfo;
var array<HxConfig> Configs;

var protected HxClientManager Manager;
var protected HxMutator MutatorOwner;
var private int PropertyIndex;
var private int ReceivedCount;
var private array<HxPendingUpdate> PendingUpdates;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientReceiveServerProperty,
        ClientUpdateServerProperty,
        ClientOpenConfigurationMenu;

    reliable if (Role < ROLE_Authority)
        ServerRequestProperty,
        ServerUpdateProperty;
}

simulated function ServerInfoReady();
simulated function ServerPropertyChanged(int Index, string OldValue);

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    ServerInfo = new(None) class'PlayInfo';
    MutatorClass.static.FillPlayInfo(ServerInfo);
    if (Level.NetMode != NM_DedicatedServer)
    {
        LoadConfigs();
        Manager = class'HxClientManager'.static.Register(Self);
    }
}

simulated function LoadConfigs()
{
    local int i;

    for (i = 0; i < ConfigClasses.Length; ++i)
    {
        Configs[i] = ConfigClasses[i].static.Load();
        Configs[i].Index = i;
    }
}

function SetupServer(HxMutator Mutator)
{
    MutatorOwner = Mutator;
    MutatorOwner.UpdateServerInfo(ServerInfo);
    PropertyIndex = ServerInfo.Settings.Length;
    ReceivedCount = ServerInfo.Settings.Length;
    if (Level.NetMode != NM_DedicatedServer)
    {
        ServerInfoReady();
    }
}

simulated event Tick(float DeltaTime)
{
    if (Level.NetMode == NM_Client)
    {
        if (PropertyIndex < ServerInfo.Settings.Length)
        {
            RequestServerInfo();
        }
    }
}

simulated function string GetConfigProperty(int ConfigIndex, int PropertyIndex)
{
    if (IsValidConfigIndex(ConfigIndex))
    {
        return Configs[ConfigIndex].GetProperty(PropertyIndex);
    }
    return "";
}

simulated function bool SetConfigProperty(int ConfigIndex, int PropertyIndex, string Value)
{
    if (IsValidConfigIndex(ConfigIndex) && Configs[ConfigIndex].SetProperty(PropertyIndex, Value))
    {
        Configs[ConfigIndex].SaveConfig();
        return true;
    }
    return false;
}

simulated final function HxConfig FindConfig(class<HxConfig> ConfigClass)
{
    local int i;

    for (i = 0; i < ConfigClasses.Length; ++i)
    {
        if (ConfigClasses[i] == ConfigClass)
        {
            return Configs[i];
        }
    }
    return None;
}

simulated final function bool IsValidConfigIndex(int Index)
{
    return Index > -1 && Index < Configs.Length;
}

function SetServerProperty(int Index, string Value)
{
    ClientUpdateServerProperty(Index, Value);
    ServerInfo.StoreSetting(Index, Value);
}

function ServerUpdateProperty(int Index, string Value)
{
    if (IsAdmin() && ServerInfo.Settings[Index].Value != Value)
    {
        MutatorOwner.SetProperty(Index, Value);
    }
}

function ServerRequestProperty(int Index)
{
    if (Index < ServerInfo.Settings.Length)
    {
        ClientReceiveServerProperty(Index, ServerInfo.Settings[Index].Value);
    }
}

simulated function string GetServerPropertyByIndex(int Index)
{
    if (Index < ServerInfo.Settings.Length)
    {
        return ServerInfo.Settings[Index].Value;
    }
    return "";
}

simulated function string GetServerProperty(string Name)
{
    return GetServerPropertyByIndex(ServerInfo.FindIndex(Name));
}

simulated function string GetServerPropertyName(int Index)
{
    if (Index < ServerInfo.Settings.Length)
    {
        return GetItemName(ServerInfo.Settings[Index].SettingName);
    }
    return "";
}

simulated function RequestServerInfo()
{
    local int Limit;
    local int i;

    Limit = Min(PropertyIndex + REQUESTS_PER_TICK, ServerInfo.Settings.Length);
    for (i = PropertyIndex; i < Limit; ++i)
    {
        if (MutatorClass.default.Properties[i].Type != HX_PROPERTY_Array)
        {
            ServerRequestProperty(i);
        }
        else
        {
            ++ReceivedCount;
        }
    }
    PropertyIndex = Limit;
}

simulated function ClientReceiveServerProperty(int Index, string Value)
{
    ServerInfo.StoreSetting(Index, Value);
    ++ReceivedCount;
    if (IsServerInfoReady())
    {
        ServerInfoReady();
        Manager.NotifyServerInfoChanged(Self);
        ProcessPendingUpdates();
    }
}

simulated function ClientUpdateServerProperty(int Index, string Value)
{
    if (IsServerInfoReady())
    {
        DoUpdateServerProperty(Index, Value);
    }
    else
    {
        PendingUpdates.Insert(PendingUpdates.Length, 1);
        PendingUpdates[PendingUpdates.Length - 1].Index = Index;
        PendingUpdates[PendingUpdates.Length - 1].Value = Value;
    }
}

simulated function ProcessPendingUpdates()
{
    local int i;

    for (i = 0; i < PendingUpdates.Length; ++i)
    {
        DoUpdateServerProperty(PendingUpdates[i].Index, PendingUpdates[i].Value);
    }
    PendingUpdates.Remove(0, PendingUpdates.Length);
}

simulated function ClientOpenConfigurationMenu()
{
    if (Manager != None)
    {
        Manager.OpenConfigurationMenu(Self);
    }
    else
    {
        Warn("HxClientManager is None! This should not happen!");
    }
}

simulated function bool IsAdmin()
{
    return Level.NetMode == NM_Standalone
        || (PlayerController(Owner) != None
            && PlayerController(Owner).PlayerReplicationInfo != None
            && PlayerController(Owner).PlayerReplicationInfo.bAdmin);
}

simulated function bool IsServerInfoReady()
{
    return ReceivedCount == ServerInfo.Settings.Length;
}

simulated private function DoUpdateServerProperty(int Index, string Value)
{
    local string OldValue;

    OldValue = ServerInfo.Settings[Index].Value;
    ServerInfo.StoreSetting(Index, Value);
    ServerPropertyChanged(Index, OldValue);
    Manager.NotifyServerInfoChanged(Self);
}

static final function int StringByteSize(string S)
{
    local int Size;
    local int i;

    for (i = 0; i < Len(S); ++i)
    {
        if (Asc(Mid(S, i, 1)) > 255)
        {
            Size += 4;
        }
        else
        {
            Size += 1;
        }
    }
    return Size;
}

static final function string ExtractBytes(out string S, int ByteCount)
{
    local string Output;
    local int Length;
    local int i;

    Length = Len(S);
    for (i = 0; i < Length; ++i)
    {
        if (Asc(Mid(S, i, 1)) > 255)
        {
            ByteCount -= 4;
        }
        else
        {
            ByteCount -= 1;
        }
        if (ByteCount < 0)
        {
            if (i == 0)
            {
                return "";
            }
            break;
        }
    }
    Output = Left(S, i);
    S = Right(S, Length - i);
    return Output;
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bOnlyRelevantToOwner=true
    bAlwaysRelevant=false
    bSkipActorPropertyReplication=false
    bOnlyDirtyReplication=true
    NetUpdateFrequency=10
    Order=255
}
