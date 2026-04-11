class HxIGClient extends HxClientReplicationInfo;

var private bool bPickupBasesDisabled;

simulated function Tick(float DeltaTime)
{
    if (Level.NetMode == NM_Client && !bPickupBasesDisabled)
    {
        class'MutHexedINSTAGIB'.static.DisablePickupBases(Self);
        bPickupBasesDisabled = true;
    }
    Super.Tick(DeltaTime);
}

defaultproperties
{
    MutatorClass=class'MutHexedINSTAGIB'
}
