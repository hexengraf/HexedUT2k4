class HxClientChannel extends ReplicationInfo
    DependsOn(HxTypes)
    DependsOn(PlayInfo);

enum EHxReplicationMessageType
{
    HX_PROXY_MSG_MutatorClass,
    HX_PROXY_MSG_MutatorProperty,
    HX_PROXY_MSG_ArrayElement,
};

struct HxReplicationMessage
{
    var EHxReplicationMessageType Type;
    var int Tag;
    var string Value;
    var HxClientReplicationInfo CRI;
};

const PKG_STR_LIMIT = 480;
const MESSAGES_PER_TICK = 16;

var PlayerController PlayerOwner;
var private HxClientManager ClientManager;
var private array<HxMutator> Mutators;
var private array<HxClientReplicationInfo> CRIs;
var private array<HxReplicationMessage> S2CQueue;
var private array<HxReplicationMessage> C2SQueue;
var private bool bDelayedSetupClient;

replication
{
    reliable if (Role == ROLE_Authority && bNetInitial)
        PlayerOwner;

    reliable if (Role == ROLE_Authority)
        ClientReceiveMessage, ClientOpenConfigurationMenu;

    reliable if (Role < ROLE_Authority)
        ServerRequestMutatorInfo, ServerReceiveMessage;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (Role == ROLE_Authority)
    {
        PlayerOwner = PlayerController(Owner);
        if (Level.NetMode != NM_DedicatedServer)
        {
            ServerRequestMutatorInfo();
        }
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
        if (PlayerOwner.Player != None)
        {
            SetupClient();
        }
        else
        {
            bDelayedSetupClient = true;
        }
        bNetNotify = false;
    }
}

simulated function SetupClient()
{
    ClientManager = class'HxClientManager'.static.Get(PlayerOwner.Player);
    ClientManager.Setup(Self);
    ServerRequestMutatorInfo();
}

function LocalPostNetReceive()
{
    local int UID;

    PostNetReceive();
    for (UID = 0; UID < CRIs.Length; ++UID)
    {
        if (CRIs[UID] != None)
        {
            CRIs[UID].PostNetReceive();
        }
    }
}

function int AddMutator(HxMutator Mutator)
{
    local int UID;
    local int i;

    for (UID = 0; UID < Mutators.Length; ++UID)
    {
        if (Mutator.Priority < Mutators[UID].Priority)
        {
            break;
        }
    }
    for (i = UID; i < Mutators.Length; ++i)
    {
        ++Mutators[i].UID;
    }
    Mutators.Insert(UID, 1);
    CRIs.Insert(UID, 1);
    Mutators[UID] = Mutator;
    Mutator.UID = UID;
    if (Mutator.ClientReplicationInfoClass != None)
    {
        CRIs[UID] = Spawn(Mutator.ClientReplicationInfoClass, Owner,, Owner.Location);
        CRIs[UID].SetupServer(Mutator);
    }
    return UID;
}

simulated event Tick(float DeltaTime)
{
    if (bDelayedSetupClient && PlayerOwner.Player != None)
    {
        SetupClient();
        bDelayedSetupClient = false;
    }
    DispatchMessages();
}

simulated function ClientReceiveMessage(HxReplicationMessage Message)
{
    local class<HxMutator> MutatorClass;
    local int ElementIndex;
    local int Index;
    local int UID;

    switch (Message.Type)
    {
        case HX_PROXY_MSG_MutatorClass:
            MutatorClass = class<HxMutator>(DynamicLoadObject(Message.Value, class'Class'));
            if (MutatorClass != None)
            {
                ClientManager.ReceiveMutatorClass(MutatorClass, Message.Tag >>> 16);
            }
            break;
        case HX_PROXY_MSG_MutatorProperty:
            if (DecodeTag(Message.Tag, UID, Index))
            {
                ClientManager.ReceiveMutatorProperty(UID, Index, Message.Value, Message.CRI);
            }
            break;
        case HX_PROXY_MSG_ArrayElement:
            if (DecodeTag(Message.Tag, UID, Index, ElementIndex))
            {
                ClientManager.ReceiveMutatorArrayElement(UID, Index, ElementIndex, Message.Value);
            }
            break;
    }
}

simulated function ClientOpenConfigurationMenu()
{
    if (ClientManager != None)
    {
        ClientManager.HexedMenu();
    }
}

function ServerReceiveMessage(HxReplicationMessage Message)
{
    local int UID;
    local int Index;

    switch (Message.Type)
    {
        case HX_PROXY_MSG_MutatorProperty:
            if (IsAdmin() && DecodeTag(Message.Tag, UID, Index))
            {
                Mutators[UID].SetProperty(Index, Message.Value);
            }
            break;
    }
}

function ServerRequestMutatorInfo()
{
    local HxReplicationMessage Message;
    local int UID;
    local int i;

    for (UID = 0; UID < Mutators.Length; ++UID)
    {
        Message.Type = HX_PROXY_MSG_MutatorClass;
        Message.Tag = UID;
        Message.Value = string(Mutators[UID].Class);
        S2CQueue[S2CQueue.Length] = Message;
    }
    S2CQueue[S2CQueue.Length - 1].Tag = (UID - 1) | 1 << 16;
    for (UID = 0; UID < Mutators.Length; ++UID)
    {
        for (i = 0; i < Mutators[UID].Properties.Length; ++i)
        {
            EnqueueMutatorPropertyUpdate(UID, i);
        }
    }
}

function EnqueueMutatorPropertyUpdate(int UID, int Index)
{
    local HxReplicationMessage Message;
    local array<string> ArrayProperty;
    local int i;

    if (Mutators[UID].Properties[Index].Type == HX_PROPERTY_Array)
    {
        ArrayProperty = Mutators[UID].GetArrayProperty(Index);
        Message.Type = HX_PROXY_MSG_ArrayElement;
        for (i = 0; i < ArrayProperty.Length; ++i)
        {
            Message.Tag = EncodeTag(UID, Index, i);
            Message.Value = ArrayProperty[i];
            S2CQueue[S2CQueue.Length] = Message;
        }
        Message.Value = string(ArrayProperty.Length);
    }
    else
    {
        Message.Value = Mutators[UID].GetPropertyText(Mutators[UID].Properties[Index].Name);
    }
    Message.Type = HX_PROXY_MSG_MutatorProperty;
    Message.Tag = EncodeTag(UID, Index);
    Message.CRI = CRIs[UID];
    S2CQueue[S2CQueue.Length] = Message;
}

simulated function RequestMutatorPropertyUpdate(int Tag, string Value)
{
    local int i;

    i = C2SQueue.Length;
    C2SQueue.Insert(i, 1);
    C2SQueue[i].Type = HX_PROXY_MSG_MutatorProperty;
    C2SQueue[i].Tag = Tag;
    C2SQueue[i].Value = Value;
}

simulated event Destroyed()
{
    local int i;

    Mutators.Remove(0, Mutators.Length);
    for (i = 0; i < CRIs.Length; ++i)
    {
        if (CRIs[i] != None)
        {
            CRIs[i].Destroy();
        }
    }
    CRIs.Remove(0, CRIs.Length);
    S2CQueue.Remove(0, S2CQueue.Length);
    C2SQueue.Remove(0, C2SQueue.Length);
    Super.Destroyed();
}

final function HxClientReplicationInfo GetClientReplicationInfo(int UID)
{
    return CRIs[UID];
}

simulated final function bool IsAdmin()
{
    return Level.NetMode == NM_Standalone
        || (PlayerOwner != None
            && PlayerOwner.PlayerReplicationInfo != None
            && PlayerOwner.PlayerReplicationInfo.bAdmin);
}

simulated private function DispatchMessages()
{
    local int Limit;
    local int i;

    if (S2CQueue.Length > 0)
    {
        Limit = Min(MESSAGES_PER_TICK, S2CQueue.Length);
        for (i = 0; i < Limit; ++i)
        {
            ClientReceiveMessage(S2CQueue[i]);
        }
        S2CQueue.Remove(0, Limit);
    }
    if (C2SQueue.Length > 0)
    {
        Limit = Min(MESSAGES_PER_TICK, C2SQueue.Length);
        for (i = 0; i < Limit; ++i)
        {
            ServerReceiveMessage(C2SQueue[i]);
        }
        C2SQueue.Remove(0, Limit);
    }
}

static final function int EncodeTag(int UID, int Index, optional int ExtraIndex)
{
    return ((UID & 0x3ff) << 20) | ((ExtraIndex & 0x3ff) << 10) | (Index & 0x3ff);
}

static final function bool DecodeTag(int Tag,
                                     out int UID,
                                     out int Index,
                                     optional out int ExtraIndex)
{
    if (Tag >= 0)
    {
        Index = Tag & 0x3ff;
        ExtraIndex = (Tag >>> 10) & 0x3ff;
        UID = (Tag >>> 20) & 0x3ff;
        return true;
    }
    return false;
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bOnlyRelevantToOwner=true
    bAlwaysRelevant=false
    bOnlyDirtyReplication=true
    NetUpdateFrequency=10
    bNetNotify=true
}
