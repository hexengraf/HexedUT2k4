class HxLinkedReplicationInfo extends LinkedReplicationInfo;

static function HxLinkedReplicationInfo Find(PlayerReplicationInfo PRI,
                                             class<HxLinkedReplicationInfo> TargetClass)
{
    local LinkedReplicationInfo LinkedPRI;

    if (PRI != None)
    {
        LinkedPRI = PRI.CustomReplicationInfo;
        while (LinkedPRI != None && !LinkedPRI.IsA(TargetClass.Name))
        {
            LinkedPRI = LinkedPRI.NextReplicationInfo;
        }
    }
    return HxLinkedReplicationInfo(LinkedPRI);
}

defaultproperties
{
    NetUpdateFrequency=10
    bOnlyDirtyReplication=true
}
