class HxUTPlayerConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config HxUTPlayerInteraction.EHxViewSmoothing ViewSmoothing;

function InitializeProperties()
{
    class'HxUTPlayerInteraction'.default.ViewSmoothing = ViewSmoothing;
    UpdateDynamicActors(-1);
}

function ApplyProperty(int Index)
{
    switch (Index)
    {
        case 0:
            class'HxUTPlayerInteraction'.default.ViewSmoothing = ViewSmoothing;
            break;
    }
    UpdateDynamicActors(Index);
}
function bool ResetProperty(int Index)
{
    switch (Index)
    {
        case 0:
            ViewSmoothing = default.ViewSmoothing;
            UpdateDynamicActors(Index);
            return true;
    }
    return false;
}

function UpdateDynamicActors(int Index)
{
    local PlayerController PC;
    local HxUTPlayerInteraction Player;

    if (Level != None)
    {
        PC = Level.GetLocalPlayerController();
        if (PC != None && PC.Player != None)
        {
            Player = class'HxUTPlayerInteraction'.static.Find(PC.Player);
            if (Player != None)
            {
                if (Index < 0)
                {
                    for (Index = 0; Index < Properties.Length; ++Index)
                    {
                        Player.SetPropertyText(
                            Properties[Index].Name, GetPropertyText(Properties[Index].Name));
                    }
                }
                else
                {
                    Player.SetPropertyText(
                        Properties[Index].Name, GetPropertyText(Properties[Index].Name));
                }
            }
        }
    }
}

defaultproperties
{
    ObjectName="HexedUT"
    Properties(0)=(Name="ViewSmoothing",Type=HX_PROPERTY_Enum,UpperLimit="3",EnumType=enum'EHxViewSmoothing')
    DisplayInfo(0)=(Section="Player",Caption="View Smoothing",Hint="Choose which type of view smoothing to apply.",EnumLabels=("Strong (Default)","Weak","Disabled"),Dependency="bAllowCustomViewSmoothing")

    ViewSmoothing=HX_VS_Default
}
