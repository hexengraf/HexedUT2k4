class HxClientReplicationInfo extends ReplicationInfo
    abstract
    DependsOn(PlayInfo);

struct HxClientProperty
{
    var const string Name;
    var const localized string Section;
    var const localized string Caption;
    var const localized string Hint;
    var const PlayInfo.EPlayInfoType Type;
    var const string Data;
    var const float Step;
    var const string Dependency;
    var const bool bAdvanced;
};

const PARALLEL_REQUESTS = 16;

var const array<HxClientProperty> Properties;
var array<class<HxGUIMenuPanel> > PanelClasses;
var const protected class<HxMutator> MutatorClass;

var HxMutator MutatorOwner;
var PlayInfo ServerInfo;

var protected HxClientManager Manager;
var private int PropertyIndex;
var private int ReceivedCount;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientReceiveServerProperty,
        ClientUpdateServerProperty,
        ClientOpenHexedMenu;

    reliable if (Role < ROLE_Authority)
        ServerRequestProperty,
        ServerUpdateProperty;
}

simulated function string GetProperty(int Index);
simulated function SetProperty(int Index, string Value);
simulated function ServerInfoReady();
simulated function ServerPropertyChanged(int Index, string OldValue);

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    ServerInfo = new(None) class'PlayInfo';
    MutatorClass.static.FillPlayInfo(ServerInfo);
    if (Level.NetMode != NM_DedicatedServer)
    {
        Manager = class'HxClientManager'.static.Register(Self);
    }
    SetupServer();
}

function SetupServer()
{
    PropertyIndex = ServerInfo.Settings.Length;
    ReceivedCount = ServerInfo.Settings.Length;
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

simulated function RequestServerInfo()
{
    local int Limit;
    local int i;

    Limit = Min(PropertyIndex + PARALLEL_REQUESTS, ServerInfo.Settings.Length);
    for (i = PropertyIndex; i < Limit; ++i)
    {
        ServerRequestProperty(i);
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
    }
}

simulated function ClientUpdateServerProperty(int Index, string Value)
{
    local string OldValue;

    OldValue = ServerInfo.Settings[Index].Value;
    ServerInfo.StoreSetting(Index, Value);
    ServerPropertyChanged(Index, OldValue);
    Manager.NotifyServerInfoChanged(Self);
}

simulated function ClientOpenHexedMenu()
{
    Manager.OpenHexedMenu(Self);
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

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bOnlyRelevantToOwner=true
    bAlwaysRelevant=false
    bSkipActorPropertyReplication=false
    bOnlyDirtyReplication=true
    NetUpdateFrequency=10
}
