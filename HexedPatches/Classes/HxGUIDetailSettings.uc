class HxGUIDetailSettings extends UT2K4Tab_DetailSettings;

var array<DisplayMode> DMs;

function CheckSupportedResolutions()
{
    local PlayerController PC;
    local string CurrentResolution;
    local string NewResolution;
    local bool bOldIgnoreChange;
    local int i;
    local int Index;

    PC = PlayerOwner();
    bOldIgnoreChange = bIgnoreChange;
    bIgnoreChange = true;
	CurrentResolution = co_Resolution.GetText();
    for(i = 0; i < DMs.Length; i++)
    {
        NewResolution = DMs[i].Width$"x"$DMs[i].Height;
        Index = co_Resolution.FindIndex(NewResolution);
        if (bool(PC.ConsoleCommand(GetSupportedResolutionCommand(DMs[i].Width, DMs[i].Height))))
        {
            if (!co_Resolution.MyComboBox.List.IsValidIndex(Index))
            {
                AddNewResolution(NewResolution);
            }
        }
        else if (co_Resolution.MyComboBox.List.IsValidIndex(Index))
        {
            co_Resolution.RemoveItem(Index, 1);
        }
    }
	co_Resolution.SetText(CurrentResolution);
    bIgnoreChange = bOldIgnoreChange;
    Super.CheckSupportedResolutions();
}

static function string GetSupportedResolutionCommand(int W, int H)
{
    return "SUPPORTEDRESOLUTION WIDTH="$W@"HEIGHT="$H@"BITDEPTH=32";
}

defaultproperties
{
    DMs(0)=(Width=1360,Height=768)
    DMs(1)=(Width=1366,Height=768)
    DMs(2)=(Width=1920,Height=1080)
    DMs(3)=(Width=2560,Height=1080)
    DMs(4)=(Width=2560,Height=1440)
    DMs(5)=(Width=3440,Height=1440)
    DMs(6)=(Width=3840,Height=1600)
    DMs(7)=(Width=3840,Height=2160)
    DMs(8)=(Width=5120,Height=1440)
    DMs(9)=(Width=5120,Height=2160)
}
