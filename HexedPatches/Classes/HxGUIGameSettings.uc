class HxGUIGameSettings extends UT2K4Tab_GameSettings;

var localized string CustomNetSpeedText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    co_Netspeed.AddItem(CustomNetSpeedText);
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    local int Speed;

    if (Sender == co_Netspeed)
    {
        if (PlayerOwner().Player != None)
        {
            Speed = PlayerOwner().Player.ConfiguredInternetSpeed;
        }
        else
        {
            Speed = class'Player'.default.ConfiguredInternetSpeed;
        }
        if (Speed == class'HxNETController'.default.CustomNetSpeed)
        {
            iNetSpeed = 4;
            iNetSpeedD = iNetSpeed;
            co_NetSpeed.SetIndex(iNetSpeed);
            return;
        }
    }
    Super.InternalOnLoadINI(Sender, s);
}

defaultproperties
{
    CustomNetSpeedText="Custom network speed"
}
