class HxZoomSuperShockRifle extends ZoomSuperShockRifle
    HideDropDown
    CacheExempt;

enum EHxScopeOverlay
{
    HX_SCOPE_Default,
    HX_SCOPE_Custom,
    HX_SCOPE_Hidden,
};

const EVEN_MASK = 0x7ffffffe;

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

simulated event DrawDefaultScopeOverlay(Canvas C, float Scale)
{
    local int SizeX;
    local int SizeY;
    local int PosX;
    local int PosY;

    SizeX = int(focusX * Scale * 2) & EVEN_MASK;
    SizeY = int(focusY * Scale * 2) & EVEN_MASK;
    PosX = (C.SizeX - SizeX) / 2;
    PosY = (C.SizeY - SizeY) / 2;
    C.Style = 255;
    SetZoomBlendColor(C);
    C.DrawColor.A = 255;
    C.SetPos(0, 0);
    C.DrawTile(Material'ZoomFB', C.SizeX, PosY, 0, 0, 512, 144);
    C.SetPos(0, PosY);
    C.DrawTile(Material'ZoomFB', PosX, SizeY, 0, 144, 148, 224);
    C.DrawTile(Material'ZoomFB', SizeX, SizeY, 148, 144, 216, 224);
    C.DrawTile(Material'ZoomFB', PosX, SizeY, 364, 144, 148, 224);
    C.SetPos(0, PosY + SizeY);
    C.DrawTile(Material'ZoomFB', C.SizeX, PosY, 0, 368, 512, 144);

    C.Style = ERenderStyle.STY_Alpha;
    C.DrawColor = FocusColor;
    C.DrawColor.A = 255;
    C.SetPos(PosX, PosY);
    C.DrawTile(
        Texture'SniperFocus',
        SizeX,
        SizeY,
        0,
        0,
        Texture'SniperFocus'.USize,
        Texture'SniperFocus'.VSize);

    SizeX = int(innerArrowsX * Scale * 2) & EVEN_MASK;
    SizeY = int(innerArrowsY * Scale * 2) & EVEN_MASK;
    C.DrawColor = ArrowColor;
    C.SetPos((C.SizeX - SizeX) / 2, (C.SizeY - SizeY) / 2);
    C.DrawTileJustified(Texture'SniperArrows', 1, SizeX, SizeY);
}

simulated function DrawCustomScopeOverlay(Canvas C)
{
    local int Size;
    local int PosX;
    local int PosY;

    C.Style = ERenderStyle.STY_Alpha;
    Size = int(ReticleScale * C.SizeY) & EVEN_MASK;
    PosX = (C.SizeX - Size) / 2;
    PosY = (C.SizeY - Size) / 2;
    if (BackgroundOpacity > 0.001)
    {
        SetZoomBlendColor(C);
        C.SetPos(PosX, PosY);
        C.DrawColor.A = 255;
        C.DrawTileJustified(Texture'HxScopeLense', 1, Size, Size);
        C.DrawColor.A = 255 * BackgroundOpacity;
        C.DrawTileJustified(Texture'HxScopeBG', 1, Size, Size);
        C.SetPos(0, 0);
        C.DrawTileStretched(Texture'Engine.BlackTexture', C.SizeX, PosY);
        C.SetPos(0, PosY);
        C.DrawTileStretched(Texture'Engine.BlackTexture', PosX, Size);
        C.SetPos(PosX + Size, PosY);
        C.DrawTileStretched(Texture'Engine.BlackTexture', PosX, Size);
        C.SetPos(0, PosY + Size);
        C.DrawTileStretched(Texture'Engine.BlackTexture', C.SizeX, PosY);
    }
    C.DrawColor = ReticleColor;
    C.SetPos(PosX, PosY);
    C.DrawTileJustified(Texture'HxScopeReticle', 1, Size, Size);
}

simulated function DrawChargeBar(Canvas C, float Scale)
{
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
    C.SetPos(C.ClipX - ((640 - RechargeOrigin.X) * Scale), RechargeOrigin.Y * Scale);
    C.DrawTile(
        Texture'Engine.WhiteTexture',
        RechargeSize.X * Scale,
        RechargeSize.Y * Scale * ChargeBar,
        0,
        0,
        Texture'Engine.WhiteTexture'.USize,
        Texture'Engine.WhiteTexture'.VSize * ChargeBar);
}

simulated event RenderOverlays(Canvas C)
{
    local PlayerController PC;
    local bool bLastZoomed;
    local float Scale;

    bLastZoomed = Zoomed;
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
        Scale = FMin(C.SizeX / 640.0f, C.SizeY / 480.0f);
        switch (ScopeOverlay)
        {
            case HX_SCOPE_Default:
                DrawDefaultScopeOverlay(C, Scale);
                break;
            case HX_SCOPE_Custom:
                DrawCustomScopeOverlay(C);
                break;
        }
        if (bShowChargeBar)
        {
            DrawChargeBar(C, Scale);
        }
        Zoomed = true;
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
