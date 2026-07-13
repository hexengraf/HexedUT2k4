class HxIGClient extends HxClientReplicationInfo;

var private bool bPickupBasesDisabled;

simulated function Tick(float DeltaTime)
{
    if (Level.NetMode == NM_Client && !bPickupBasesDisabled)
    {
        class'MutHexedINSTAGIB'.static.HidePickupBases(Self);
        bPickupBasesDisabled = true;
    }
    Super.Tick(DeltaTime);
}

defaultproperties
{
    MutatorClass=class'MutHexedINSTAGIB'
    ConfigClasses(0)=class'HxZoomSuperShockRifleConfig'
    PanelClasses(0)=class'HxGUIMenuInstagibPanel'
    Order=126
}
