class HxUTPlayerConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config HxUTPlayer.EHxViewSmoothing ViewSmoothing;

function ApplyAllProperties()
{
    class'HxUTPlayer'.default.ViewSmoothing = ViewSmoothing;
}

function ApplyProperty(int Index)
{
    switch (Index)
    {
        case 0:
            class'HxUTPlayer'.default.ViewSmoothing = ViewSmoothing;
            break;
    }
}
function bool ResetProperty(int Index)
{
    switch (Index)
    {
        case 0:
            ViewSmoothing = default.ViewSmoothing;
            return true;
    }
    return false;
}

defaultproperties
{
    ObjectName="HexedUT"
    Properties(0)=(Name="ViewSmoothing",Type=HX_PROPERTY_Enum,EnumValues=("HX_VS_Default","HX_VS_Weak","HX_VS_Disabled"))
    DisplayInfo(0)=(Section="Player",Caption="View smoothing",Hint="Choose which type of view smoothing to apply.",EnumLabels=("Strong (default)","Weak","Disabled"),Dependency="bAllowCustomViewSmoothing")

    ViewSmoothing=HX_VS_Default
}
