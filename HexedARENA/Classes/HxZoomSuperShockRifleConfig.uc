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

function InitializeProperties()
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
    UpdateDynamicActors();
}

function ApplyProperty(int Index)
{
    switch (Index)
    {
        case 0:
            class'HxZoomSuperShockRifle'.default.ScopeOverlay = ScopeOverlay;
            break;
        case 1:
            class'HxZoomSuperShockRifle'.default.bSoundEffects = bSoundEffects;
            break;
        case 2:
            class'HxZoomSuperShockRifle'.default.bShowChargeBar = bShowChargeBar;
            break;
        case 3:
            class'HxZoomSuperShockRifle'.default.ReticleColor = ReticleColor;
            break;
        case 4:
            class'HxZoomSuperShockRifle'.default.ReticleScale = ReticleScale;
            break;
        case 5:
            class'HxZoomSuperShockRifle'.default.BackgroundOpacity = BackgroundOpacity;
            break;
        case 6:
            class'HxZoomSuperShockRifle'.default.bCustomZoomCrosshair = bCustomZoomCrosshair;
            break;
        case 7:
            class'HxZoomSuperShockRifle'.default.CustomZoomCrosshair = CustomZoomCrosshair;
            break;
        case 8:
            class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairColor =
                CustomZoomCrosshairColor;
            break;
        case 9:
            class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairScale =
                CustomZoomCrosshairScale;
            break;
        case 10:
            class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairTextureName =
                CustomZoomCrosshairTextureName;
            break;
    }
    UpdateDynamicActors();
}

function bool ResetProperty(int Index)
{
    local bool bReset;

    switch (Index)
    {
        case 0:
            ScopeOverlay = default.ScopeOverlay;
            bReset = true;
            break;
        case 1:
            bSoundEffects = default.bSoundEffects;
            bReset = true;
            break;
        case 2:
            bShowChargeBar = default.bShowChargeBar;
            bReset = true;
            break;
        case 3:
            ReticleColor = default.ReticleColor;
            bReset = true;
            break;
        case 4:
            ReticleScale = default.ReticleScale;
            bReset = true;
            break;
        case 5:
            BackgroundOpacity = default.BackgroundOpacity;
            bReset = true;
            break;
        case 6:
            bCustomZoomCrosshair = default.bCustomZoomCrosshair;
            bReset = true;
            break;
        case 7:
            CustomZoomCrosshair = default.CustomZoomCrosshair;
            bReset = true;
            break;
        case 8:
            CustomZoomCrosshairColor = default.CustomZoomCrosshairColor;
            bReset = true;
            break;
        case 9:
            CustomZoomCrosshairScale = default.CustomZoomCrosshairScale;
            bReset = true;
            break;
        case 10:
            CustomZoomCrosshairTextureName = default.CustomZoomCrosshairTextureName;
            bReset = true;
            break;
    }
    if (bReset)
    {
        UpdateDynamicActors();
    }
    return bReset;
}

function bool SetProperty(int Index, coerce string Value)
{
    local array<CacheManager.CrosshairRecord> Crosshairs;

    if (Index == 7)
    {
        class'CacheManager'.static.GetCrosshairList(Crosshairs);
        SetProperty(10, string(Crosshairs[int(ValidateProperty(Index, Value))].CrosshairTexture));
    }
    return Super.SetProperty(Index, Value);
}

function UpdateDynamicActors()
{
    local PlayerController PC;
    local Inventory Inv;

    if (Level != None)
    {
        PC = Level.GetLocalPlayerController();
        if (PC != None && PC.Pawn != None)
        {
            for (Inv = PC.Pawn.Inventory; Inv != None; Inv = Inv.inventory)
            {
                if (HxZoomSuperShockRifle(Inv) != None)
                {
                    HxZoomSuperShockRifle(Inv).RefreshConfiguration();
                }
            }
        }
    }
}

defaultproperties
{
    ObjectName="HexedARENA"
    Properties(0)=(Name="ScopeOverlay",Type=HX_PROPERTY_Enum,UpperLimit="3",EnumType=enum'EHxScopeOverlay')
    Properties(1)=(Name="bSoundEffects",Type=HX_PROPERTY_Bool)
    Properties(2)=(Name="bShowChargeBar",Type=HX_PROPERTY_Bool)
    Properties(3)=(Name="ReticleColor",Type=HX_PROPERTY_Color)
    Properties(4)=(Name="ReticleScale",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0")
    Properties(5)=(Name="BackgroundOpacity",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0")
    Properties(6)=(Name="bCustomZoomCrosshair",Type=HX_PROPERTY_Bool)
    Properties(7)=(Name="CustomZoomCrosshair",Type=HX_PROPERTY_Enum)
    Properties(8)=(Name="CustomZoomCrosshairColor",Type=HX_PROPERTY_Color)
    Properties(9)=(Name="CustomZoomCrosshairScale",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="2.0")
    Properties(10)=(Name="CustomZoomCrosshairTextureName",Type=HX_PROPERTY_String)

    ScopeOverlay=HX_SCOPE_Custom
    bSoundEffects=true
    bShowChargeBar=true
    ReticleColor=(R=32,G=32,B=32,A=255)
    ReticleScale=0.45
    BackgroundOpacity=0.3
    bCustomZoomCrosshair=false
    CustomZoomCrosshair=7
    CustomZoomCrosshairColor=(R=255,G=32,B=32,A=230)
    CustomZoomCrosshairScale=1.0
    CustomZoomCrosshairTextureName="Crosshairs.HUD.Crosshair_Cross1"
}
