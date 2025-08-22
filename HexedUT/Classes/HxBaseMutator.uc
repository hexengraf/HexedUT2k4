class HxBaseMutator extends Mutator
    abstract;

static function LinkedReplicationInfo SpawnLinkedPRI(PlayerReplicationInfo PRI,
                                                     class<LinkedReplicationInfo> LinkedPRIClass)
{
    local LinkedReplicationInfo LinkedPRI;

    if (PRI.CustomReplicationInfo == None)
    {
        PRI.CustomReplicationInfo = PRI.Owner.Spawn(LinkedPRIClass, PRI.Owner);
        PRI.NetUpdateTime = PRI.Level.TimeSeconds - 1;
        return PRI.CustomReplicationInfo;
    }
    LinkedPRI = PRI.CustomReplicationInfo;
    while (LinkedPRI.NextReplicationInfo != None)
    {
        LinkedPRI = LinkedPRI.NextReplicationInfo;
    }
    LinkedPRI.NextReplicationInfo = PRI.Owner.Spawn(LinkedPRIClass, PRI.Owner);
    LinkedPRI.NetUpdateTime = PRI.Level.TimeSeconds - 1;
    LinkedPRI.NextReplicationInfo.NetUpdateTime = PRI.Level.TimeSeconds - 1;
    return LinkedPRI.NextReplicationInfo;
}

defaultproperties
{
}
