class HxClientReplicationInfo extends ReplicationInfo
    abstract;

const PARALLEL_REQUESTS = 16;

var HxMutator MutatorOwner;
var PlayInfo ServerInfo;
var protected class<HxMutator> MutatorClass;
var protected class<FloatingWindow> MenuClass;
var private int PropertyIndex;
var private int ReceivedCount;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientReceiveProperty,
        ClientSetProperty,
        ClientOpenMenu;

    reliable if (Role < ROLE_Authority)
        ServerRequestProperty,
        ServerSetProperty;
}

simulated function ServerInfoReady();
simulated function PropertyChanged(int Index, string OldValue);

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    ServerInfo = new(None) class'PlayInfo';
    MutatorClass.static.FillPlayInfo(ServerInfo);
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

simulated function SetProperty(int Index, string Value)
{
    local string OldValue;

    OldValue = ServerInfo.Settings[Index].Value;
    ServerInfo.StoreSetting(Index, Value);
    PropertyChanged(Index, OldValue);
}

function ServerSetProperty(int Index, string Value)
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
        ClientReceiveProperty(Index, ServerInfo.Settings[Index].Value);
    }
}

function bool IsAdmin()
{
    return Level.NetMode == NM_Standalone || PlayerController(Owner).PlayerReplicationInfo.bAdmin;
}

simulated function string GetPropertyByIndex(int Index)
{
    if (Index < ServerInfo.Settings.Length)
    {
        return ServerInfo.Settings[Index].Value;
    }
    return "";
}

simulated function string GetProperty(string Name)
{
    return GetPropertyByIndex(ServerInfo.FindIndex(Name));
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

simulated function bool IsServerInfoReady()
{
    return ReceivedCount == ServerInfo.Settings.Length;
}

simulated function ClientReceiveProperty(int Index, string Value)
{
    ServerInfo.StoreSetting(Index, Value);
    ++ReceivedCount;
    if (IsServerInfoReady())
    {
        ServerInfoReady();
    }
}

simulated function ClientSetProperty(int Index, string Value)
{
    SetProperty(Index, Value);
}

simulated function ClientOpenMenu()
{
    local PlayerController PC;

    PC = Level.GetLocalPlayerController();
    if (PC != None)
    {
        PC.ClientOpenMenu(string(MenuClass));
    }
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bOnlyRelevantToOwner=true
    bAlwaysRelevant=false
    bSkipActorPropertyReplication=false
    bOnlyDirtyReplication=true
    NetUpdateFrequency=10
    MenuClass=class'HxGUIMenu'
}
