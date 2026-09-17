class HxARClient extends HxClientReplicationInfo;

var private bool bWeaponLockersDisabled;

simulated function Tick(float DeltaTime)
{
    if (Level.NetMode == NM_Client && !bWeaponLockersDisabled)
    {
        class'MutHexedARENA'.static.DisableWeaponLockers(Self);
        bWeaponLockersDisabled = true;
    }
    Super.Tick(DeltaTime);
}

defaultproperties
{
    MutatorClass=class'MutHexedARENA'
}
