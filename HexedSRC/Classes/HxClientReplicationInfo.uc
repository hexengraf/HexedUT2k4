class HxClientReplicationInfo extends ReplicationInfo
    abstract
    DependsOn(HxTypes)
    DependsOn(PlayInfo);

enum EHxReplicationMessageType
{
    HX_RMSG_ServerProperty,
    HX_RMSG_ArrayElement,
    HX_RMSG_Custom,
};

struct HxReplicationMessage
{
    var EHxReplicationMessageType Type;
    var int Index;
    var string Value;
};

const PKG_STR_LIMIT = 480;
const MESSAGES_PER_TICK = 16;

var const class<HxMutator> MutatorClass;
var const array<class<HxConfig> > ConfigClasses;
var const array<class<HxGUIMenuPanel> > PanelClasses;
var const byte Order;

var PlayInfo ServerInfo;
var array<HxConfig> Configs;

var protected HxClientManager Manager;
var protected HxMutator MutatorOwner;
var protected PlayerController PlayerOwner;
var private array<HxReplicationMessage> MessageQueue;
var private array<string> ReplicatedArrayProperty;
var private bool bServerPropertiesRequested;
var private bool bServerPropertiesReady;

replication
{
    reliable if (Role == ROLE_Authority && bNetInitial)
        PlayerOwner;

    reliable if (Role == ROLE_Authority)
        ClientReceiveMessage,
        ClientOpenConfigurationMenu;

    reliable if (Role < ROLE_Authority)
        ServerRequestProperties,
        ServerUpdateProperty;
}

simulated function NotifyServerPropertiesReady();
simulated function NotifyServerPropertyChanged(int Index, string OldValue);
simulated function NotifyUserPropertyChanged(HxConfig Config, int Index, string OldValue);
simulated function ParseArrayProperty(int Index, array<string> Values);
simulated function ReceiveCustomMessage(HxReplicationMessage Message);

simulated event PostBeginPlay()
{
    local int i;

    Super.PostBeginPlay();
    ServerInfo = new(None) class'PlayInfo';
    MutatorClass.static.FillPlayInfo(ServerInfo);
    if (Level.NetMode != NM_DedicatedServer)
    {
        Manager = class'HxClientManager'.static.Get(Self);
        for (i = 0; i < ConfigClasses.Length; ++i)
        {
            Configs[i] = Manager.LoadConfig(ConfigClasses[i]);
            Configs[i].Setup(Self);
        }
        Manager.Register(Self);
    }
}

simulated event PostNetReceive()
{
    if (PlayerOwner != None)
    {
        if (Owner == None)
        {
            SetOwner(PlayerOwner);
        }
        bNetNotify = false;
    }
}

function SetupServer(HxMutator Mutator)
{
    MutatorOwner = Mutator;
    MutatorOwner.UpdateServerInfo(ServerInfo);
    PlayerOwner = PlayerController(Owner);
    bServerPropertiesRequested = (Level.NetMode == NM_DedicatedServer);
    bServerPropertiesReady = bServerPropertiesRequested;
}

simulated event Tick(float DeltaTime)
{
    if (!bServerPropertiesRequested)
    {
        ServerRequestProperties();
        bServerPropertiesRequested = true;
    }
    ProcessMessageQueue();
}

function ProcessMessageQueue()
{
    local int Limit;
    local int i;

    if (MessageQueue.Length > 0)
    {
        Limit = Min(MESSAGES_PER_TICK, MessageQueue.Length);
        for (i = 0; i < Limit; ++i)
        {
            ClientReceiveMessage(MessageQueue[i]);
        }
        MessageQueue.Remove(0, Limit);
    }
}

function SetServerProperty(int Index, string Value)
{
    ServerInfo.StoreSetting(Index, Value);
    EnqueueServerPropertyUpdate(Index);
}

function ServerUpdateProperty(int Index, string Value)
{
    if (IsAdmin() && ServerInfo.Settings[Index].Value != Value)
    {
        MutatorOwner.SetProperty(Index, Value);
    }
}

function ServerRequestProperties()
{
    local int i;

    for (i = 0; i < ServerInfo.Settings.Length; ++i)
    {
        EnqueueServerPropertyUpdate(i);
    }
}

function EnqueueServerPropertyUpdate(int Index)
{
    local HxReplicationMessage Message;
    local array<string> ArrayProperty;
    local int i;

    if (MutatorClass.default.Properties[Index].Type == HX_PROPERTY_Array)
    {
        ArrayProperty = MutatorOwner.GetArrayProperty(Index);
        Message.Type = HX_RMSG_ArrayElement;
        for (i = 0; i < ArrayProperty.Length; ++i)
        {
            Message.Index = i;
            Message.Value = ArrayProperty[i];
            MessageQueue[MessageQueue.Length] = Message;
        }
        Message.Value = string(ArrayProperty.Length);
    }
    else
    {
        Message.Value = ServerInfo.Settings[Index].Value;
    }
    Message.Type = HX_RMSG_ServerProperty;
    Message.Index = Index;
    MessageQueue[MessageQueue.Length] = Message;
}

simulated function ClientReceiveMessage(HxReplicationMessage Message)
{
    local string OldValue;

    switch (Message.Type)
    {
        case HX_RMSG_ServerProperty:
            if (MutatorClass.default.Properties[Message.Index].Type == HX_PROPERTY_Array)
            {
                ParseArrayProperty(Message.Index, ReplicatedArrayProperty);
                ReplicatedArrayProperty.Remove(0, ReplicatedArrayProperty.Length);
            }
            else
            {
                OldValue = ServerInfo.Settings[Message.Index].Value;
                ServerInfo.StoreSetting(Message.Index, Message.Value);
            }
            if (bServerPropertiesReady)
            {
                NotifyServerPropertyChanged(Message.Index, OldValue);
            }
            else if (Message.Index == ServerInfo.Settings.Length - 1)
            {
                bServerPropertiesReady = true;
                NotifyServerPropertiesReady();
            }
            Manager.NotifyServerPropertyChanged(Self);
            break;
        case HX_RMSG_ArrayElement:
            ReplicatedArrayProperty[ReplicatedArrayProperty.Length] = Message.Value;
            break;
        case HX_RMSG_Custom:
            ReceiveCustomMessage(Message);
            break;
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

simulated function bool ShouldHideServerPropertyFromStatus(int Index)
{
    return false;
}

simulated function ClientOpenConfigurationMenu()
{
    Manager.OpenConfigurationMenu(Self);
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

simulated final function bool IsAdmin()
{
    return Level.NetMode == NM_Standalone
        || (PlayerOwner != None
            && PlayerOwner.PlayerReplicationInfo != None
            && PlayerOwner.PlayerReplicationInfo.bAdmin);
}

simulated function Actor SpawnUnique(class<Actor> ActorClass, Actor Owner)
{
    local Actor Spawned;

    ForEach DynamicActors(ActorClass, Spawned) break;
    if (Spawned == None)
    {
        Spawned = Spawn(ActorClass, Owner);
    }
    else
    {
        Spawned.SetOwner(Owner);
    }
    return Spawned;
}

simulated function HudOverlay SpawnOverlay(HUD HUD, class<HudOverlay> OverlayClass)
{
    local HudOverlay Overlay;
    local int i;

    for (i = 0; i < HUD.Overlays.Length; ++i)
    {
        if (HUD.Overlays[i].Class == OverlayClass)
        {
            return HUD.Overlays[i];
        }
    }
    Overlay = Spawn(OverlayClass, HUD);
    HUD.AddHudOverlay(Overlay);
    return Overlay;
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
    bOnlyDirtyReplication=true
    NetUpdateFrequency=10
    bNetNotify=true
    Order=255
}
