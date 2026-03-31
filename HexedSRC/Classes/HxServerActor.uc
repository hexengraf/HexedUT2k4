class HxServerActor extends Info
    abstract;

var protected const class<HxMutator> MutatorClass;

event PreBeginPlay()
{
    local HxMutator M;

    Super.PreBeginPlay();
    if (MutatorClass != None)
    {
        Level.Game.AddMutator(string(MutatorClass));
        M = FindMutator();
        if (M != None)
        {
            M.ValidateClientReplicationInfos();
        }
    }
}

function HxMutator FindMutator()
{
    local Mutator M;

    if (MutatorClass != None)
    {
        for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
        {
            if (M.IsA(MutatorClass.default.Name))
            {
                return HxMutator(M);
            }
        }
    }
    return None;
}

defaultproperties
{
    MutatorClass=None
}
