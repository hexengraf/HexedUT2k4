class HxGIBClient extends HxClientReplicationInfo;

var private bool bPickupBasesDisabled;

simulated function Tick(float DeltaTime)
{
    if (Level.NetMode == NM_Client && !bPickupBasesDisabled)
    {
        class'MutHexedGIB'.static.DisablePickupBases(Self);
        bPickupBasesDisabled = true;
    }
    Super.Tick(DeltaTime);
}

defaultproperties
{
    MutatorClass=class'MutHexedGIB'
}
