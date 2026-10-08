class HxLinkedReplicationInfo extends ReplicationInfo
    abstract;

var HxPlayerReplicationInfo HexedPRI;
var HxLinkedReplicationInfo PrevReplicationInfo;
var HxLinkedReplicationInfo NextReplicationInfo;

replication
{
    reliable if (Role == ROLE_Authority && bNetInitial)
        HexedPRI, PrevReplicationInfo, NextReplicationInfo;
}

event Destroyed()
{
    if (PrevReplicationInfo != None)
    {
        PrevReplicationInfo.NextReplicationInfo = NextReplicationInfo;
        if (NextReplicationInfo != None)
        {
            NextReplicationInfo.PrevReplicationInfo = PrevReplicationInfo;
        }
    }
    PrevReplicationInfo = None;
    NextReplicationInfo = None;
    HexedPRI = None;
}

defaultproperties
{
    NetUpdateFrequency=1
    bOnlyDirtyReplication=true
}
