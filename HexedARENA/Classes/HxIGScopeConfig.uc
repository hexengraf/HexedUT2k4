class HxIGScopeConfig extends HxConfig
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

function ApplyConfiguration(class<HxZoomSuperShockRifle> TargetClass)
{
    TargetClass.default.ScopeOverlay = ScopeOverlay;
    TargetClass.default.bSoundEffects = bSoundEffects;
    TargetClass.default.bShowChargeBar = bShowChargeBar;
    TargetClass.default.ReticleColor = ReticleColor;
    TargetClass.default.ReticleScale = ReticleScale;
    TargetClass.default.BackgroundOpacity = BackgroundOpacity;
    TargetClass.default.bCustomZoomCrosshair = bCustomZoomCrosshair;
    TargetClass.default.CustomZoomCrosshair = CustomZoomCrosshair;
    TargetClass.default.CustomZoomCrosshairColor = CustomZoomCrosshairColor;
    TargetClass.default.CustomZoomCrosshairScale = CustomZoomCrosshairScale;
    TargetClass.default.CustomZoomCrosshairTextureName = CustomZoomCrosshairTextureName;
}

function SetCustomCrosshair(coerce int Index)
{
    local array<CacheManager.CrosshairRecord> Crosshairs;

    class'CacheManager'.static.GetCrosshairList(Crosshairs);
    CustomZoomCrosshair = Index;
    CustomZoomCrosshairTextureName = string(Crosshairs[Index].CrosshairTexture);
}

defaultproperties
{
    ObjectName="HexedARENA"

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
