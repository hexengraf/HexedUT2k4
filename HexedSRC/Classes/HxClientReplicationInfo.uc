class HxClientReplicationInfo extends ReplicationInfo
    abstract;

var protected const class<HxMutator> MutatorClass;
var protected PlayerController PlayerOwner;
var protected HxMutator MutatorOwner;
var protected HxClientManager ClientManager;
var protected HxMutatorInfo MutatorInfo;
var private bool bDelayedSetupClient;

replication
{
    reliable if (Role == ROLE_Authority && bNetInitial)
        PlayerOwner;
}

simulated function NotifyMutatorInfoReady();
simulated function NotifyMutatorPropertyChanged(int Index);

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
            SetupClient(class'HxClientManager'.static.Get(PlayerOwner.Player));
        }
        else
        {
            bDelayedSetupClient = true;
        }
        bNetNotify = false;
    }
}

simulated event Tick(float DeltaTime)
{
    if (bDelayedSetupClient && PlayerOwner.Player != None)
    {
        SetupClient(class'HxClientManager'.static.Get(PlayerOwner.Player));
        bDelayedSetupClient = false;
    }
}

function SetupServer(HxMutator Mutator)
{
    MutatorOwner = Mutator;
    PlayerOwner = PlayerController(Owner);
}

simulated function SetupClient(HxClientManager Manager)
{
    ClientManager = Manager;
    if (ClientManager.FindMutatorInfo(MutatorClass, MutatorInfo))
    {
        NotifyMutatorInfoReady();
    }
}

simulated function SetMutatorInfo(HxMutatorInfo Info)
{
    MutatorInfo = Info;
    NotifyMutatorInfoReady();
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

simulated final function HxConfig FindConfig(class<HxConfig> ConfigClass)
{
    return ClientManager.FindConfig(MutatorClass, ConfigClass);
}

simulated final function bool IsMutatorInfoReady()
{
    return MutatorInfo != None && MutatorInfo.IsInitialized();
}

simulated final function bool IsAdmin()
{
    return Level.NetMode == NM_Standalone
        || (PlayerOwner != None
            && PlayerOwner.PlayerReplicationInfo != None
            && PlayerOwner.PlayerReplicationInfo.bAdmin);
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
}
