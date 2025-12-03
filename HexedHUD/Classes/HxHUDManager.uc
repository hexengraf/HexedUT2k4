class HxHUDManager extends Interaction
    config(User);

struct HxHUDReplacement
{
    var string HUDType;
    var class<HudBase> ReplaceWith;
};

struct HxWeaponProperties
{
    var class<Weapon> WeaponClass;
    var float AspectRatio;
};

const DEFAULT_ASPECT_RATIO = 1.3333333333333333;
const TO_RADIANS = 0.017453292519943295;
const TO_DEGREES = 57.29577951308232;

var config bool bReplaceHUDs;
var config bool bScaleWeapons;
var config array<HxHUDReplacement> HUDReplacements;

var HUD CurrentHUD;
var HxWeaponProperties DisplayedWeapon;

simulated event Initialized() {
    bRequiresTick = !TryReplaceHUD();
}

simulated event NotifyLevelChange()
{
    bRequiresTick = !TryReplaceHUD();
}

simulated event Tick(float DeltaTime)
{
    bRequiresTick = !TryReplaceHUD();
}

simulated function bool TryReplaceHUD()
{
    if (ViewportOwner.Actor != None
        && ViewportOwner.Actor.myHUD != None
        && ViewportOwner.Actor.myHUD != CurrentHUD
        && ViewportOwner.Actor.myHUD.Class != class'HUD')
    {
        ReplaceHUD(ViewportOwner.Actor);
        return true;
    }
    return false;
}

simulated function ReplaceHUD(PlayerController PC)
{
    local int i;
    local int j;
    local array<HudOverlay> Overlays;

    if (bReplaceHUDs)
    {
        for (i = 0; i < HUDReplacements.Length; ++i)
        {
            if (HUDReplacements[i].HUDType ~= string(PC.myHUD.Class))
            {
                Overlays = PC.myHUD.Overlays;
                PC.ClientSetHUD(HUDReplacements[i].ReplaceWith, PC.myHUD.ScoreBoard.Class);
                for (j = 0; j < Overlays.Length; ++j)
                {
                    PC.myHUD.AddHudOverlay(Overlays[j]);
                }
                break;
            }
        }
    }
    CurrentHUD = PC.myHUD;
}

simulated function RestoreHUD(PlayerController PC)
{
    local int i;
    local int j;
    local array<HudOverlay> Overlays;
    local class<HUD> HudClass;

    for (i = 0; i < HUDReplacements.Length; ++i)
    {
        if (HUDReplacements[i].ReplaceWith == PC.myHUD.Class)
        {
            HudClass = class<HUD>(DynamicLoadObject(HUDReplacements[i].HUDType, class'Class'));
            Overlays = PC.myHUD.Overlays;
            PC.ClientSetHUD(HudClass, PC.myHUD.ScoreBoard.Class);
            for (j = 0; j < Overlays.Length; ++j)
            {
                PC.myHUD.AddHudOverlay(Overlays[j]);
            }
            break;
        }
    }
    CurrentHUD = PC.myHUD;
}

static simulated function ScaleWeapon(Weapon W, float AspectRatio)
{
    if (ShouldScale(W, AspectRatio))
    {
        default.DisplayedWeapon.WeaponClass = W.default.Class;
        default.DisplayedWeapon.AspectRatio = AspectRatio;
        W.DisplayFOV = GetScaledFOV(W.default.DisplayFOV, AspectRatio / DEFAULT_ASPECT_RATIO);
    }
}

static simulated function bool ShouldScale(Weapon W, float AspectRatio)
{
    return default.bScaleWeapons && AspectRatio != DEFAULT_ASPECT_RATIO
        && (default.DisplayedWeapon.WeaponClass != W.default.Class
            || default.DisplayedWeapon.AspectRatio != AspectRatio);
}

static simulated function float GetScaledFOV(float FOV, float Scale)
{
    return FClamp(TO_DEGREES * (2 * ATan(Scale * Tan(FOV / 2 * TO_RADIANS), 1)), 1, 170);
}

defaultproperties
{
    bReplaceHUDs=true
    bScaleWeapons=true
    HUDReplacements(0)=(HUDType="UT2k4Assault.HUD_Assault",ReplaceWith=class'HxHUDAssault')
    HUDReplacements(1)=(HUDType="XInterface.HudCBombingRun",ReplaceWith=class'HxHUDBombingRun')
    HUDReplacements(2)=(HUDType="XInterface.HudCCaptureTheFlag",ReplaceWith=class'HxHUDCaptureTheFlag')
    HUDReplacements(3)=(HUDType="XInterface.HudCDeathMatch",ReplaceWith=class'HxHUDDeathMatch')
    HUDReplacements(4)=(HUDType="XInterface.HudCDoubleDomination",ReplaceWith=class'HxHUDDoubleDomination')
    HUDReplacements(5)=(HUDType="XInterface.HudCTeamDeathMatch",ReplaceWith=class'HxHUDTeamDeathMatch')
    HUDReplacements(6)=(HUDType="Skaarjpack.HUDInvasion",ReplaceWith=class'HxHUDInvasion')
    HUDReplacements(7)=(HUDType="BonusPack.HudLMS",ReplaceWith=class'HxHUDLastManStanding')
    HUDReplacements(8)=(HUDType="BonusPack.HudMutant",ReplaceWith=class'HxHUDMutant')
    HUDReplacements(9)=(HUDType="Onslaught.ONSHUDOnslaught",ReplaceWith=class'HxHUDOnslaught')
}
