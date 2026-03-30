class HxVTClient extends HxClientReplicationInfo;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (Level.NetMode != NM_DedicatedServer)
    {
        Manager.SetCustomMapVoteMenu(string(class'HxMapVotingPage'));
    }
}

defaultproperties
{
    MutatorClass=class'MutHexedVOTE'
}
