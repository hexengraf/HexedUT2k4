class HxClientReplicationInfo extends ReplicationInfo
    abstract;

var HxMutator MutatorOwner;
var protected class<FloatingWindow> MenuClass;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientOpenMenu;

    reliable if (Role < ROLE_Authority)
        RemoteSetProperty;
}

function UpdateAll();
function UpdateProperty(string PropertyName, String PropertyValue);

simulated function ClientOpenMenu()
{
    local PlayerController PC;

    PC = Level.GetLocalPlayerController();
    if (PC != None)
    {
        PC.ClientOpenMenu(string(MenuClass));
    }
}

function RemoteSetProperty(string PropertyName, string PropertyValue)
{
    local PlayerController PC;

    PC = PlayerController(Owner);
    if ((Level.NetMode == NM_Standalone || PC.PlayerReplicationInfo.bAdmin)
        && GetPropertyText(PropertyName) != PropertyValue)
    {
        MutatorOwner.SetProperty(PropertyName, PropertyValue);
    }
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bOnlyRelevantToOwner=true
    bAlwaysRelevant=false
    bSkipActorPropertyReplication=false
    bOnlyDirtyReplication=true
    NetUpdateFrequency=10
    MenuClass=class'HxGUIMenu'
}
