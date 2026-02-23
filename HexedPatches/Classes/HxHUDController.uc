class HxHUDController extends Interaction
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

var config bool bReplaceHUDs;
var config bool bScaleWeapons;
var config array<HxHUDReplacement> HUDReplacements;

var HUD CurrentHUD;
var HxWeaponProperties DisplayedWeapon;

event Initialized() {
    CheckConflictingPackages();
    UpdateHUD();
}

event NotifyLevelChange()
{
    ResetDisplayedWeapon();
    UpdateHUD();
}

event Tick(float DeltaTime)
{
    UpdateHUD();
}

function bool TryReplaceHUD()
{
    if (ViewportOwner.Actor != None
        && ViewportOwner.Actor.myHUD != None
        && ViewportOwner.Actor.myHUD != CurrentHUD
        && ViewportOwner.Actor.myHUD.Class != class'HUD')
    {
        SetupSpawnProtectionTimer(ViewportOwner.Actor);
        ReplaceHUD(ViewportOwner.Actor);
        return true;
    }
    return false;
}

function SetupSpawnProtectionTimer(PlayerController PC)
{
    local int i;

    for (i = 0; i < PC.myHUD.Overlays.Length; ++i)
    {
        if (HxHUDSpawnProtectionTimer(PC.myHUD.Overlays[i]) != None)
        {
            return;
        }
    }
    PC.myHUD.AddHudOverlay(PC.myHUD.Spawn(class'HxHUDSpawnProtectionTimer', PC.myHUD));
}

function ReplaceHUD(PlayerController PC)
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

function RestoreHUD(PlayerController PC)
{
    local int i;
    local int j;
    local array<HudOverlay> Overlays;
    local class<HUD> HudClass;

    if (PC != None && PC.myHUD != None)
    {
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
    }
    CurrentHUD = PC.myHUD;
}

function bool CheckConflictingPackages()
{
    if (string(class'PlayerController'.default.InputClass) ~= "foxWSFix.foxPlayerInput")
    {
        if (bReplaceHUDs)
        {
            Warn("Forcing bReplaceHUDs to false because foxWSFix is enabled.");
            bReplaceHUDs = false;
        }
        return true;
    }
    return false;
}

function UpdateHUD()
{
    bRequiresTick = !TryReplaceHUD();
}

function SetReplaceHUDs(bool bValue)
{
    if (!bValue)
    {
        if (bReplaceHUDs)
        {
            bReplaceHUDs = bValue;
            RestoreHUD(ViewportOwner.Actor);
        }
    }
    else
    {
        bReplaceHUDs = bValue;
        CurrentHUD = None;
        UpdateHUD();
    }
}

function SetScaleWeapons(bool bValue)
{
    bScaleWeapons = bValue;
    default.bScaleWeapons = bValue;
    ResetDisplayedWeapon();
}

static function ResetDisplayedWeapon()
{
    default.DisplayedWeapon.WeaponClass = None;
    default.DisplayedWeapon.AspectRatio = 0;
}

static function ScaleWeapon(Weapon W, float AspectRatio)
{
    if (HasChanges(W, AspectRatio))
    {
        default.DisplayedWeapon.WeaponClass = W.default.Class;
        default.DisplayedWeapon.AspectRatio = AspectRatio;
        if (!default.bScaleWeapons)
        {
            W.DisplayFOV = W.default.DisplayFOV;
            return;
        }
        W.DisplayFOV = class'HxAspectRatio'.static.GetScaledFOV(W.default.DisplayFOV, AspectRatio);
    }
}

static function bool HasChanges(Weapon W, float AspectRatio)
{
    return default.DisplayedWeapon.WeaponClass != W.default.Class
        || default.DisplayedWeapon.AspectRatio != AspectRatio;
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
