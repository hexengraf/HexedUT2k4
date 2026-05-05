class HxSPTimerConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config bool bEnabled;
var config bool bUseHUDColor;
var config bool bPulsingDigits;
var config float PosX;
var config float PosY;
var config Color DefaultColor;

function ApplyAllProperties()
{
    class'HxSPTimer'.default.bEnabled = bEnabled;
    class'HxSPTimer'.default.bUseHUDColor = bUseHUDColor;
    class'HxSPTimer'.default.bPulsingDigits = bPulsingDigits;
    class'HxSPTimer'.default.PosX = PosX;
    class'HxSPTimer'.default.PosY = PosY;
    class'HxSPTimer'.default.DefaultColor = DefaultColor;
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
            class'HxSPTimer'.default.DefaultColor = DefaultColor;
            break;
    }
}

defaultproperties
{
    ObjectName="HexedUT"
    Properties(0)=(Name="bEnabled",Type=HX_PROPERTY_Bool)
    Properties(1)=(Name="bUseHUDColor",Type=HX_PROPERTY_Bool)
    Properties(2)=(Name="bPulsingDigits",Type=HX_PROPERTY_Bool)
    Properties(3)=(Name="PosX",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0");
    Properties(4)=(Name="PosY",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0");
    Properties(5)=(Name="DefaultColor",Type=HX_PROPERTY_Color);
    DisplayInfo(0)=(Section="Spawn Protection Timer",Caption="Enable spawn protection timer",Hint="Show timer indicating remaining spawn protection duration.",Dependency="bAllowSpawnProtectionTimer")
    DisplayInfo(1)=(Section="Spawn Protection Timer",Caption="Use HUD's color",Hint="Use the same color as the HUD for the timer's icon.",Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    DisplayInfo(2)=(Section="Spawn Protection Timer",Caption="Use pulsing digits",Hint="Use pulsing digits for the timer.",Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    DisplayInfo(3)=(Section="Spawn Protection Timer",Caption="X position",Hint="Adjust X position.",Step="0.01",Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    DisplayInfo(4)=(Section="Spawn Protection Timer",Caption="Y position",Hint="Adjust Y position.",Step="0.01",Dependency="bAllowSpawnProtectionTimer",bAdvanced=true)
    DisplayInfo(5)=(bHidden=true)

    bEnabled=true
    bUseHUDColor=true
    bPulsingDigits=false
    PosX=0.95
    PosY=0.64
    DefaultColor=(R=239,G=191,B=4,A=255)
}
