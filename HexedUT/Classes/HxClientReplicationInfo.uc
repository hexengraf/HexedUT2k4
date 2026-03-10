class HxClientReplicationInfo extends ReplicationInfo
    abstract;

var protected array<HxClientReplicationInfo> CRIs;

simulated event PreBeginPlay()
{
    if (Level.NetMode == NM_Client)
    {
        RegisterOnClient(Self);
    }
    Super.PreBeginPlay();
}

static function HxClientReplicationInfo SpawnClientReplicationInfo(PlayerController PC)
{
    local HxClientReplicationInfo CRI;

    if (PC != None && MessagingSpectator(PC) == None)
    {
        CRI = PC.Spawn(default.Class, PC);
        default.CRIs[default.CRIs.Length] = CRI;
    }
    return CRI;
}

static function bool DestroyClientReplicationInfo(PlayerController PC)
{
    local int i;

    if (PC != None && MessagingSpectator(PC) == None)
    {
        for (i = 0; i < default.CRIs.Length; ++i)
        {
            if (default.CRIs[i].Owner == PC)
            {
                default.CRIs[i].Destroy();
                default.CRIs.Remove(i, 1);
                return true;
            }
        }
    }
    return false;
}

static function HxClientReplicationInfo GetClientReplicationInfo(PlayerController PC)
{
    local int i;

    for (i = 0; i < default.CRIs.Length; ++i)
    {
        if (default.CRIs[i].Owner == PC)
        {
            return default.CRIs[i];
        }
    }
    return None;
}

static function bool RegisterOnClient(HxClientReplicationInfo CRI)
{
    local int i;

    for (i = 0; i < default.CRIs.Length; ++i)
    {
        if (default.CRIs[i] == CRI)
        {
            return false;
        }
    }
    default.CRIs[default.CRIs.Length] = CRI;
    return true;
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
