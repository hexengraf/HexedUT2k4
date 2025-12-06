class HxOPTController extends Interaction
    config(User);

var config int ConfiguredNetSpeed;
var config bool bForceGarbageCollection;

event NotifyLevelChange()
{
    if (ViewportOwner.ConfiguredInternetSpeed != ConfiguredNetSpeed)
    {
        ConsoleCommand("NetSpeed"@ConfiguredNetSpeed);
        Log(Name@": Updating NetSpeed to"@ConfiguredNetSpeed);
    }
    if (bForceGarbageCollection)
    {
        ConsoleCommand("obj garbage");
    }
}

defaultproperties
{
    ConfiguredNetSpeed=1000000
    bForceGarbageCollection=false
}
