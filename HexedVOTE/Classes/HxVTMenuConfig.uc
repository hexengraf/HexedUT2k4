class HxVTMenuConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config bool bDisableMapVoteMenu;

var private HxVTClient Client;

function ApplyProperty(int Index)
{
    if (Client == None)
    {
        foreach Level.DynamicActors(class'HxVTClient', Client) break;
    }
    if (Client != None)
    {
        Client.SetReplaceMapVoteMenu(bDisableMapVoteMenu);
    }
}

defaultproperties
{
    Properties(0)=(Name="bDisableMapVoteMenu",Type=HX_PROPERTY_Bool)
    DisplayInfo(0)=(Caption="Disable enhanced map vote menu",Hint="Fallback to the native map vote menu. Use this option if facing issues blocking you from voting.")

    bDisableMapVoteMenu=false
}
