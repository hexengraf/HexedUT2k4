class HxVTMenuConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config bool bDisableMapVoteMenu;

defaultproperties
{
    ObjectName="HexedUT"
    Properties(0)=(Name="bDisableMapVoteMenu",Type=HX_PROPERTY_Bool)
    DisplayInfo(0)=(Caption="Disable enhanced map vote menu",Hint="Fallback to the native map vote menu. Use this option if facing issues blocking you from voting.")

    bDisableMapVoteMenu=false
}
