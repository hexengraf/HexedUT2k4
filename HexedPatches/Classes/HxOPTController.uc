class HxOPTController extends Interaction
    config(User);

var config int ConfiguredNetSpeed;

event NotifyLevelChange()
{
    if (ViewportOwner.ConfiguredInternetSpeed != ConfiguredNetSpeed
        || ViewportOwner.ConfiguredLanSpeed != ConfiguredNetSpeed)
    {
        ConsoleCommand("NetSpeed"@ConfiguredNetSpeed);
        Log(Name@": Updating NetSpeed to"@ConfiguredNetSpeed);
    }
}

defaultproperties
{
    ConfiguredNetSpeed=1000000
}
