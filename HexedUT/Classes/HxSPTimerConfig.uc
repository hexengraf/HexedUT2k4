class HxSPTimerConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config bool bEnabled;
var config bool bUseHUDColor;
var config bool bPulsingDigits;
var config float PosX;
var config float PosY;
var config Color CustomColor;

function InitializeProperties()
{
    class'HxSPTimer'.default.bEnabled = bEnabled;
    class'HxSPTimer'.default.bUseHUDColor = bUseHUDColor;
    class'HxSPTimer'.default.bPulsingDigits = bPulsingDigits;
    class'HxSPTimer'.default.PosX = PosX;
    class'HxSPTimer'.default.PosY = PosY;
    class'HxSPTimer'.default.CustomColor = CustomColor;
    UpdateDynamicActors(-1);
}

function ApplyProperty(int Index)
{
    switch (Index)
    {
        case 0:
            class'HxSPTimer'.default.bEnabled = bEnabled;
            break;
        case 1:
            class'HxSPTimer'.default.bUseHUDColor = bUseHUDColor;
            break;
        case 2:
            class'HxSPTimer'.default.bPulsingDigits = bPulsingDigits;
            break;
        case 3:
            class'HxSPTimer'.default.PosX = PosX;
            break;
        case 4:
            class'HxSPTimer'.default.PosY = PosY;
            break;
        case 5:
            class'HxSPTimer'.default.CustomColor = CustomColor;
            break;
    }
    UpdateDynamicActors(Index);
}

function bool ResetProperty(int Index)
{
    switch (Index)
    {
        case 0:
            bEnabled = default.bEnabled;
            class'HxSPTimer'.default.bEnabled = bEnabled;
            return true;
        case 1:
            bUseHUDColor = default.bUseHUDColor;
            class'HxSPTimer'.default.bUseHUDColor = bUseHUDColor;
            return true;
        case 2:
            bPulsingDigits = default.bPulsingDigits;
            class'HxSPTimer'.default.bPulsingDigits = bPulsingDigits;
            return true;
        case 3:
            PosX = default.PosX;
            class'HxSPTimer'.default.PosX = PosX;
            return true;
        case 4:
            PosY = default.PosY;
            class'HxSPTimer'.default.PosY = PosY;
            return true;
        case 5:
            CustomColor = default.CustomColor;
            class'HxSPTimer'.default.CustomColor = CustomColor;
            return true;
    }
    return false;
}

function UpdateDynamicActors(int Index)
{
    local HxSPTimer SPTimer;

    SPTimer = HxSPTimer(FindHudOverlay(class'HxSPTimer'));
    if (SPTimer != None)
    {
        if (Index < 0)
        {
            for (Index = 0; Index < Properties.Length; ++Index)
            {
                SPTimer.SetPropertyText(
                    Properties[Index].Name, GetPropertyText(Properties[Index].Name));
            }
        }
        else
        {
            SPTimer.SetPropertyText(
                Properties[Index].Name, GetPropertyText(Properties[Index].Name));
        }
    }
}

defaultproperties
{
    Properties(0)=(Name="bEnabled",Type=HX_PROPERTY_Bool)
    Properties(1)=(Name="bUseHUDColor",Type=HX_PROPERTY_Bool)
    Properties(2)=(Name="bPulsingDigits",Type=HX_PROPERTY_Bool)
    Properties(3)=(Name="PosX",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0");
    Properties(4)=(Name="PosY",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0");
    Properties(5)=(Name="CustomColor",Type=HX_PROPERTY_Color);

    bEnabled=true
    bUseHUDColor=true
    bPulsingDigits=false
    PosX=0.95
    PosY=0.64
    CustomColor=(R=239,G=191,B=4,A=255)
}
