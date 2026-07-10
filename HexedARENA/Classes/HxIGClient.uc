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

simulated function bool SetProperty(int ConfigIndex, int PropertyIndex, string Value)
{
    local PlayerController PC;
    local Inventory Inv;

    if (Super.SetProperty(ConfigIndex, PropertyIndex, Value))
    {
        PC = Level.GetLocalPlayerController();
        if (PC != None && PC.Pawn != None)
        {
            for (Inv = PC.Pawn.Inventory; Inv != None; Inv = Inv.inventory)
            {
                if (HxZoomSuperShockRifle(Inv) != None)
                {
                    HxZoomSuperShockRifle(Inv).RefreshConfiguration();
                }
            }
        }
        return true;
    }
    return false;
}

defaultproperties
{
    MutatorClass=class'MutHexedINSTAGIB'
    ConfigClasses(0)=class'HxZoomSuperShockRifleConfig'
    PanelClasses(0)=class'HxGUIMenuInstagibPanel'
    Order=126
}
