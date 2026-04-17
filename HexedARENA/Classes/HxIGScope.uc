class HxIGScope extends HxConfig
    config(User);

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

static function ApplyConfiguration(class<HxZoomSuperShockRifle> TargetClass)
{
    TargetClass.default.ScopeOverlay = default.ScopeOverlay;
    TargetClass.default.bSoundEffects = default.bSoundEffects;
    TargetClass.default.bShowChargeBar = default.bShowChargeBar;
    TargetClass.default.ReticleColor = default.ReticleColor;
    TargetClass.default.ReticleScale = default.ReticleScale;
    TargetClass.default.BackgroundOpacity = default.BackgroundOpacity;
    TargetClass.default.bCustomZoomCrosshair = default.bCustomZoomCrosshair;
    TargetClass.default.CustomZoomCrosshair = default.CustomZoomCrosshair;
    TargetClass.default.CustomZoomCrosshairColor = default.CustomZoomCrosshairColor;
    TargetClass.default.CustomZoomCrosshairScale = default.CustomZoomCrosshairScale;
    TargetClass.default.CustomZoomCrosshairTextureName = default.CustomZoomCrosshairTextureName;
}

static function SetScopeOverlay(string Value)
{
    switch (Value)
    {
        case "HX_SCOPE_Default":
            class'HxIGScope'.default.ScopeOverlay = HX_SCOPE_Default;
            break;
        case "HX_SCOPE_Custom":
            class'HxIGScope'.default.ScopeOverlay = HX_SCOPE_Custom;
            break;
        case "HX_SCOPE_Hidden":
            class'HxIGScope'.default.ScopeOverlay = HX_SCOPE_Hidden;
            break;
    }
}

static function SetCustomCrosshair(coerce int Index)
{
    local array<CacheManager.CrosshairRecord> Crosshairs;

    class'CacheManager'.static.GetCrosshairList(Crosshairs);
    default.CustomZoomCrosshair = Index;
    default.CustomZoomCrosshairTextureName = string(Crosshairs[Index].CrosshairTexture);
}

defaultproperties
{
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
