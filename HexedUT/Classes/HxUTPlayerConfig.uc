class HxUTPlayerConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config HxUTPlayerInteraction.EHxViewSmoothing ViewSmoothing;

var private HxUTPlayerInteraction Player;

function InitializeProperties()
{
    local int i;

    class'HxUTPlayerInteraction'.default.ViewSmoothing = ViewSmoothing;
    Player = HxUTPlayerInteraction(ClientManager.LoadInteraction(class'HxUTPlayerInteraction'));
    for (i = 0; i < Properties.Length; ++i)
    {
        Player.SetPropertyText(Properties[i].Name, GetPropertyText(Properties[i].Name));
    }
}

function Destroy()
{
    Player = None;
    Super.Destroy();
}

function ApplyProperty(int Index)
{
    switch (Index)
    {
        case 0:
            class'HxUTPlayerInteraction'.default.ViewSmoothing = ViewSmoothing;
            Player.SetPropertyText(Properties[Index].Name, GetPropertyText(Properties[Index].Name));
            break;
    }
}

function bool ResetProperty(int Index)
{
    switch (Index)
    {
        case 0:
            ViewSmoothing = default.ViewSmoothing;
            Player.SetPropertyText(Properties[Index].Name, GetPropertyText(Properties[Index].Name));
            return true;
    }
    return false;
}

function NotifyMutatorInfoReady()
{
    Player.SetPropertyText(
        "bAllowCustomViewSmoothing", MutatorInfo.Get("bAllowCustomViewSmoothing"));
}

function NotifyMutatorPropertyChanged(int Index)
{
    switch (MutatorInfo.GetName(Index))
    {
        case "bAllowCustomViewSmoothing":
            Player.SetPropertyText("bAllowCustomViewSmoothing", MutatorInfo.GetByIndex(Index));
            break;
    }
}

defaultproperties
{
    Properties(0)=(Name="ViewSmoothing",Type=HX_PROPERTY_Enum,UpperLimit="4",EnumType=enum'EHxViewSmoothing')
    DisplayInfo(0)=(Caption="View Smoothing",Hint="Choose which type of view smoothing to apply.",EnumLabels=("Strong (Default)","Moderate","Weak","Disabled"),Dependency="bAllowCustomViewSmoothing")

    ViewSmoothing=HX_VS_Default
}
