class MutHexedARENA extends HxMutator;

var config string ArenaWeaponClassName;

var private class<Pickup> AmmoPickupClass;

event PreBeginPlay()
{
    Super.PreBeginPlay();
    DefaultWeaponName = ArenaWeaponClassName;
    DefaultWeapon = class<Weapon>(DynamicLoadObject(DefaultWeaponName, class'Class'));
    DisableWeaponLockers(Self);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (Other.IsA('xWeaponBase'))
    {
        xWeaponBase(Other).WeaponType = DefaultWeapon;
    }
    else if (Other.IsA('Weapon'))
    {
        if (Other.Class != DefaultWeapon && !Weapon(Other).bNoInstagibReplace)
        {
            return false;
        }
    }
    else if (Other.IsA('WeaponPickup'))
    {
        if (Other.Class != DefaultWeapon.default.PickupClass)
        {
            ReplaceWith(Other, string(DefaultWeapon.default.PickupClass));
            return false;
        }
    }
    else if (Other.IsA('Ammo'))
    {
        if (AmmoPickupClass == None)
        {
            FindAmmoPickupClass();
        }
        if (Other.Class != AmmoPickupClass)
        {
            ReplaceWith(Other, string(AmmoPickupClass));
            return false;
        }
    }
    else if (Other.IsA('WeaponLocker'))
    {
        Other.GotoState('Disabled');
    }
    return Super.CheckReplacement(Other, bSuperRelevant);
}

function FindAmmoPickupClass()
{
    local int i;

    for (i = 0; i < ArrayCount(DefaultWeapon.default.FireModeClass); ++i)
    {
        if (DefaultWeapon.default.FireModeClass[i] != None
            && DefaultWeapon.default.FireModeClass[i].default.AmmoClass != None
            && DefaultWeapon.default.FireModeClass[i].default.AmmoClass.default.PickupClass != None)
        {
            AmmoPickupClass =
                DefaultWeapon.default.FireModeClass[i].default.AmmoClass.default.PickupClass;
            break;
        }
    }
}

static function DisableWeaponLockers(Actor Requester)
{
    local WeaponLocker L;

    foreach Requester.AllActors(class'WeaponLocker', L)
    {
        L.GotoState('Disabled');
    }
}

defaultproperties
{
    FriendlyName="HexedARENA v7T1"
    Description="Replace weapons and ammo in the map with the configured weapon."
    GroupName="Arena"
    bAddToServerPackages=true
    CRIClass=class'HxARClient'
    Properties(0)=(Name="ArenaWeaponClassName",Caption="Arena Weapon",Hint="Determines which weapon will be used in the arena match. Applied on restart/map change.",Type="Text",Data="1024")
    bDisableTick=true

    ArenaWeaponClassName="XWeapons.RocketLauncher"
}
