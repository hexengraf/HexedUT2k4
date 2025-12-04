class HxNETController extends Interaction
    config(User);

var config int ClientNetSpeed;

event NotifyLevelChange()
{
    if(class'Engine.Player'.default.ConfiguredInternetSpeed != ClientNetSpeed)
    {
        ConsoleCommand("netspeed"@ClientNetSpeed);
        Log(Name@": Updating netspeed to"@ClientNetSpeed);
    }
}

defaultproperties
{
    ClientNetSpeed=10000000
}
