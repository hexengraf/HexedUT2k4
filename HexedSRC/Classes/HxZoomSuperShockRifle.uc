class HxZoomSuperShockRifle extends ZoomSuperShockRifle
    HideDropDown
    CacheExempt;

enum EHxScopeOverlay
{
    HX_SCOPE_Default,
    HX_SCOPE_Custom,
    HX_SCOPE_Hidden,
};

var EHxScopeOverlay ScopeOverlay;
var bool bSoundEffects;
var bool bShowChargeBar;
var Color ReticleColor;
var float ReticleScale;
var float BackgroundOpacity;
var bool bCustomZoomCrosshair;
var int CustomZoomCrosshair;
var color CustomZoomCrosshairColor;
var float CustomZoomCrosshairScale;
var string CustomZoomCrosshairTextureName;

#include Classes\Include\MutableFireRateSuperShockRIfle.uci

delegate Test();

simulated function DrawCustomScopeOverlay(Canvas C)
{
    local float X;
    local float Y;
    local float W;
    local float H;

    C.Style = ERenderStyle.STY_Alpha;
    H = ReticleScale * C.SizeY;
    W = H;
    X = (C.SizeX - W) / 2;
    Y = (C.SizeY - H) / 2;
    if (BackgroundOpacity > 0.001)
    {
        SetZoomBlendColor(C);
        C.SetPos(X, Y);
        C.DrawColor.A = 255;
        C.DrawTileJustified(Texture'HxScopeLense', 1, W, H);
        C.DrawColor.A = 255 * BackgroundOpacity;
        C.DrawTileJustified(Texture'HxScopeBG', 1, W, H);
        C.SetPos(0, 0);
        C.DrawTileStretched(Texture'Engine.BlackTexture', C.SizeX, Y);
        C.SetPos(0, Y);
        C.DrawTileStretched(Texture'Engine.BlackTexture', X, H);
        C.SetPos(X + W, Y);
        C.DrawTileStretched(Texture'Engine.BlackTexture', X, H);
        C.SetPos(0, Y + H);
        C.DrawTileStretched(Texture'Engine.BlackTexture', C.SizeX, Y);
    }
    C.DrawColor = ReticleColor;
    C.SetPos(X, Y);
    C.DrawTileJustified(Texture'HxScopeReticle', 1, W, H);
}

simulated function DrawChargeBar(Canvas C)
{
    local float ScaleX;
    local float ScaleY;
    local float ChargeBar;

    C.DrawColor = ChargeColor;
    ChargeBar = 1.0;
    if (FireMode[0].NextFireTime > Level.TimeSeconds)
    {
        ChargeBar -= (FireMode[0].NextFireTime - Level.TimeSeconds) / FireMode[0].FireRate;
    }
    if (ChargeBar < 1)
    {
        C.DrawColor.R = 255 * ChargeBar;
        C.DrawColor.G = 0;
    }
    else
    {
        C.DrawColor.R = 0;
        C.DrawColor.G = 255;
        C.DrawColor.B = 0;
    }
    ScaleX = C.SizeX / 640.0f;
    ScaleY = C.SizeY / 480.0f;
    C.SetPos(RechargeOrigin.X * ScaleX, RechargeOrigin.Y * ScaleY);
    C.DrawTile(
        Texture'Engine.WhiteTexture',
        RechargeSize.X * ScaleX,
        RechargeSize.Y * ScaleY * ChargeBar,
        0,
        0,
        Texture'Engine.WhiteTexture'.USize,
        Texture'Engine.WhiteTexture'.VSize * ChargeBar);
}

simulated event RenderOverlays(Canvas C)
{
    local PlayerController PC;
    local bool bLastZoomed;

    bLastZoomed = Zoomed;
    if (ScopeOverlay == HX_SCOPE_Default)
    {
        Super.RenderOverlays(C);
    }
    else
    {
        PC = PlayerController(Instigator.Controller);
        if (bSoundEffects)
        {
            if (LastFOV > PC.DesiredFOV)
            {
                PlaySound(Sound'WeaponSounds.LightningGun.LightningZoomIn', SLOT_Misc,,,,, false);
            }
            else if (LastFOV < PC.DesiredFOV)
            {
                PlaySound(Sound'WeaponSounds.LightningGun.LightningZoomOut', SLOT_Misc,,,,, false);
            }
        }
        LastFOV = PC.DesiredFOV;
        if (PC.DesiredFOV == PC.DefaultFOV)
        {
            Super(SuperShockRifle).RenderOverlays(C);
            Zoomed = false;
        }
        else
        {
            if (ScopeOverlay == HX_SCOPE_Custom)
            {
                DrawCustomScopeOverlay(C);
            }
            if (bShowChargeBar)
            {
                DrawChargeBar(C);
            }
            Zoomed = true;
        }
    }
    if (bCustomZoomCrosshair && (bLastZoomed ^^ Zoomed))
    {
        if (Zoomed)
        {
            CustomCrosshair = CustomZoomCrosshair;
            CustomCrosshairColor = CustomZoomCrosshairColor;
            CustomCrosshairScale = CustomZoomCrosshairScale;
            CustomCrosshairTextureName = CustomZoomCrosshairTextureName;
        }
        else
        {
            CustomCrosshair = default.CustomCrosshair;
            CustomCrosshairColor = default.CustomCrosshairColor;
            CustomCrosshairScale = default.CustomCrosshairScale;
            CustomCrosshairTextureName = default.CustomCrosshairTextureName;
        }
        CustomCrossHairTexture = None;
    }
}

simulated function RefreshConfiguration()
{
    ScopeOverlay = class'HxZoomSuperShockRifle'.default.ScopeOverlay;
    bSoundEffects = class'HxZoomSuperShockRifle'.default.bSoundEffects;
    bShowChargeBar = class'HxZoomSuperShockRifle'.default.bShowChargeBar;
    ReticleColor = class'HxZoomSuperShockRifle'.default.ReticleColor;
    ReticleScale = class'HxZoomSuperShockRifle'.default.ReticleScale;
    BackgroundOpacity = class'HxZoomSuperShockRifle'.default.BackgroundOpacity;
    bCustomZoomCrosshair = class'HxZoomSuperShockRifle'.default.bCustomZoomCrosshair;
    CustomZoomCrosshair = class'HxZoomSuperShockRifle'.default.CustomZoomCrosshair;
    CustomZoomCrosshairColor = class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairColor;
    CustomZoomCrosshairScale = class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairScale;
    CustomZoomCrosshairTextureName =
        class'HxZoomSuperShockRifle'.default.CustomZoomCrosshairTextureName;
    CustomCrosshairTexture = None;
}

defaultproperties
{
    BaseClass=class'ZoomSuperShockRifle'
}
