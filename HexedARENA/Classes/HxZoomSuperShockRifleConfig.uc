class HxZoomSuperShockRifleConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config HxZoomSuperShockRifle.EHxScopeOverlay ScopeOverlay;
var config bool bSoundEffects;
var config bool bShowChargeBar;
var config Color ReticleColor;
var config float ReticleScale;
var config float BackgroundOpacity;
var config bool bCustomZoomCrosshair;
var config int CustomZoomCrosshair;
var config Color CustomZoomCrosshairColor;
var config float CustomZoomCrosshairScale;
var config string CustomZoomCrosshairTextureName;

function ApplyAllProperties()
{
    class'HxZoomSuperShockRifle'.default.ScopeOverlay = ScopeOverlay;
    class'HxZoomSuperShockRifle'.default.bSoundEffects = bSoundEffects;
    class'HxZoomSuperShockRifle'.default.bShowChargeBar = bShowChargeBar;
    class'HxZoomSuperShockRifle'.default.ReticleColor = ReticleColor;
    class'HxZoomSuperShockRifle'.default.ReticleScale = ReticleScale;
    class'HxZoomSuperShockRifle'.default.BackgroundOpacity = BackgroundOpacity;
    class'HxZoomSuperShockRifle'.default.bCustomZoomCrosshair = bCustomZoomCrosshair;
    class'HxZoomSuperShockRifle'.default.CustomZoomCrosshair = CustomZoomCrosshair;
    class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairColor = CustomZoomCrosshairColor;
    class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairScale = CustomZoomCrosshairScale;
    class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairTextureName =
        CustomZoomCrosshairTextureName;
}

function ApplyProperty(int Index)
{
    switch (Index)
    {
        case 0:
            class'HxZoomSuperShockRifle'.default.ScopeOverlay = ScopeOverlay;
        case 1:
            break;
            class'HxZoomSuperShockRifle'.default.bSoundEffects = bSoundEffects;
        case 2:
            break;
            class'HxZoomSuperShockRifle'.default.bShowChargeBar = bShowChargeBar;
        case 3:
            break;
            class'HxZoomSuperShockRifle'.default.ReticleColor = ReticleColor;
        case 4:
            break;
            class'HxZoomSuperShockRifle'.default.ReticleScale = ReticleScale;
        case 5:
            break;
            class'HxZoomSuperShockRifle'.default.BackgroundOpacity = BackgroundOpacity;
        case 6:
            break;
            class'HxZoomSuperShockRifle'.default.bCustomZoomCrosshair = bCustomZoomCrosshair;
        case 7:
            break;
            class'HxZoomSuperShockRifle'.default.CustomZoomCrosshair = CustomZoomCrosshair;
        case 8:
            break;
            class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairColor =
                CustomZoomCrosshairColor;
        case 9:
            break;
            class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairScale =
                CustomZoomCrosshairScale;
        case 10:
            class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairTextureName =
                CustomZoomCrosshairTextureName;
            break;
    }
}

function bool SetProperty(int Index, coerce string Value)
{
    if (Super.SetProperty(Index, Value))
    {
        if (Index == 7)
        {
            SetCustomCrosshair(Value);
        }
        return true;
    }
    return false;
}

function SetCustomCrosshair(coerce int Index)
{
    local array<CacheManager.CrosshairRecord> Crosshairs;

    class'CacheManager'.static.GetCrosshairList(Crosshairs);
    SetProperty(10, string(Crosshairs[Index].CrosshairTexture));
}

// simulated function string GetProperty(int Index)
// {
//     switch (Index)
//     {
//         case 3:
//             return string(ScopeConfig.ReticleColor.R);
//         case 4:
//             return string(ScopeConfig.ReticleColor.G);
//         case 5:
//             return string(ScopeConfig.ReticleColor.B);
//         case 6:
//             return string(ScopeConfig.ReticleColor.A / 255.0);
//         case 11:
//             return string(ScopeConfig.CustomZoomCrosshairColor.R);
//         case 12:
//             return string(ScopeConfig.CustomZoomCrosshairColor.G);
//         case 13:
//             return string(ScopeConfig.CustomZoomCrosshairColor.B);
//         case 14:
//             return string(ScopeConfig.CustomZoomCrosshairColor.A / 255.0);
//         default:
//             return ScopeConfig.GetPropertyText(Properties[Index].Name);
//     }
//     return "";
// }

// simulated function SetProperty(int Index, string Value)
// {
//     switch (Index)
//     {
//         case 3:
//             ReticleColor.R = byte(Value);
//             break;
//         case 4:
//             ReticleColor.G = byte(Value);
//             break;
//         case 5:
//             ReticleColor.B = byte(Value);
//             break;
//         case 6:
//             ReticleColor.A = float(Value) * 255;
//             break;
//         case 10:
//             SetCustomCrosshair(Value);
//             break;
//         case 11:
//             CustomZoomCrosshairColor.R = byte(Value);
//             break;
//         case 12:
//             CustomZoomCrosshairColor.G = byte(Value);
//             break;
//         case 13:
//             CustomZoomCrosshairColor.B = byte(Value);
//             break;
//         case 14:
//             CustomZoomCrosshairColor.A = float(Value) * 255;
//             break;
//         default:
//             SetPropertyText(Properties[Index].Name, Value);
//             break;
//     }
//     ScopeConfig.SaveConfig();
//     ApplyScopeConfiguration();
// }

defaultproperties
{
    ObjectName="HexedARENA"
    Properties(0)=(Name="ScopeOverlay",Type=HX_PROPERTY_Enum,EnumValues=("HX_SCOPE_Default","HX_SCOPE_Custom","HX_SCOPE_Hidden"))
    Properties(1)=(Name="bSoundEffects",Type=HX_PROPERTY_Bool)
    Properties(2)=(Name="bShowChargeBar",Type=HX_PROPERTY_Bool)
    Properties(3)=(Name="ReticleColor",Type=HX_PROPERTY_Color)
    Properties(4)=(Name="ReticleScale",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0")
    Properties(5)=(Name="BackgroundOpacity",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0")
    Properties(6)=(Name="bCustomZoomCrosshair",Type=HX_PROPERTY_Bool)
    Properties(7)=(Name="CustomZoomCrosshair",Type=HX_PROPERTY_Enum)
    Properties(8)=(Name="CustomZoomCrosshairColor",Type=HX_PROPERTY_Color)
    Properties(9)=(Name="CustomZoomCrosshairScale",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="5.0")
    Properties(10)=(Name="CustomZoomCrosshairTextureName",Type=HX_PROPERTY_String)
    // DisplayInfo(0)=(Caption="Scope overlay",Hint="Choose which scope overlay to use.",EnumLabels=("Default","Custom","Hidden"),Dependency="bZoomInstagib")
    // DisplayInfo(1)=(Section="Custom Scope Overlay",Caption="Zoom sound effects",Hint="Enable sound effects when zooming in/out.",Dependency="bZoomInstagib")
    // DisplayInfo(2)=(Section="Custom Scope Overlay",Caption="Show charge bar",Hint="Show charge bar to indicate when it is ready to shoot.",Dependency="bZoomInstagib")
    // DisplayInfo(3)=(Section="Custom Scope Overlay",Hint="reticle",Dependency="bZoomInstagib")
    // DisplayInfo(4)=(Section="Custom Scope Overlay",Caption="Scale",Hint="Change the scale of the reticle.",Step="0.05",Dependency="bZoomInstagib")
    // DisplayInfo(5)=(Section="Custom Scope Overlay",Caption="Background opacity",Hint="Change the opacity of the black background around the scope.",Dependency="bZoomInstagib")
    // DisplayInfo(6)=(Section="Custom Crosshair",Caption="Use custom crosshair",Hint="Use custom crosshair while zooming. Requires custom weapon crosshairs enabled to work.",Dependency="bZoomInstagib")
    // DisplayInfo(7)=(Section="Custom Crosshair",Section="Custom Crosshair",Caption="Custom Crosshair",Hint="Choose which crosshair to use.",EnumLabels=("CROSSHAIRS"),Dependency="bZoomInstagib")
    // DisplayInfo(8)=(Section="Custom Crosshair",Hint="crosshair",Dependency="bZoomInstagib")
    // DisplayInfo(9)=(Section="Custom Crosshair",Caption="Scale",Hint="Change the scale of the crosshair.",Step="0.05",Dependency="bZoomInstagib")
    // DisplayInfo(10)=(bHidden=true)

    ScopeOverlay=HX_SCOPE_Custom
    bSoundEffects=true
    bShowChargeBar=true
    ReticleColor=(R=32,G=32,B=32,A=255)
    ReticleScale=0.5
    BackgroundOpacity=0.35
    bCustomZoomCrosshair=false
    CustomZoomCrosshair=7
    CustomZoomCrosshairColor=(R=255,G=32,B=32,A=230)
    CustomZoomCrosshairScale=1.0
    CustomZoomCrosshairTextureName="Crosshairs.HUD.Crosshair_Cross1"
}
