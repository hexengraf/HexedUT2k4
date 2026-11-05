class HxUTWeaponStats extends Object;

const FIRE_MODE_COUNT = 2;

var class<Weapon> WeaponClass;
var private class<WeaponFire> FireClass[FIRE_MODE_COUNT];
var private class<Ammunition> AmmoClass[FIRE_MODE_COUNT];
var private int AmmoCount[FIRE_MODE_COUNT];
var private float Hits[FIRE_MODE_COUNT];
var private float Misses[FIRE_MODE_COUNT];
var private int SubHitCount;

function Setup(Weapon W)
{
    local int i;

    WeaponClass = W.Class;
    for (i = 0; i < FIRE_MODE_COUNT; ++i)
    {
        FireClass[i] = W.FireModeClass[i];
    }
    for (i = 0; i < FIRE_MODE_COUNT; ++i)
    {
        AmmoClass[i] = W.AmmoClass[i];
    }
}

function float GetHits(optional out float AllMisses)
{
    local float AllHits;
    local int i;

    AllMisses = 0;
    for (i = 0; i < FIRE_MODE_COUNT; ++i)
    {
        AllMisses += Misses[i];
        AllHits += Hits[i];
    }
    return AllHits;
}

function TrackHit(int Damage, class<WeaponDamageType> DamageType, float HitTime)
{
    switch (DamageType)
    {
        case class'DamTypeAssaultGrenade':
            UpdateHits(1, FireClass[1].default.AmmoPerFire);
            break;
        case class'DamTypeBioGlob':
            UpdateBioGlobHit(Damage);
            break;
        case class'DamTypeFlakChunk':
            UpdateFlakChunkHit();
            break;
        case class'DamTypeFlakShell':
            UpdateHits(0, FireClass[1].default.AmmoPerFire);
            break;
        case class'DamTypeShockCombo':
            UpdateShockComboHit();
            break;
        // case class'DamTypeClassicSniper':
        // case class'DamTypeClassicHeadshot':
        // case class'DamTypeAssaultBullet':
        // case class'DamTypeMinigunBullet':
        // case class'DamTypeLinkPlasma':
        // case class'DamTypeLinkShaft':
        // case class'DamTypeMinigunAlt':
        // case class'DamTypeShockBeam':
        // case class'DamTypeSniperShot':
        // case class'DamTypeSniperHeadShot':
        // case class'DamTypeShockBall':
        // case class'DamTypeRedeemer':
        // case class'DamTypeRocket':
        // case class'DamTypeRocketHoming':
        // case class'DamTypeONSAVRiLRocket':
        // case class'DamTypeONSGrenade':
        // case class'DamTypeONSMine':
        default:
            UpdateHits(0, FireClass[0].default.AmmoPerFire);
            break;
    }
}

function TrackKill(class<WeaponDamageType> DamageType, float KillTime)
{
    if (DamageType == class'DamTypeFlakChunk' && SubHitCount > 0)
    {
        UpdateHits(0, float(SubHitCount) / class'Flakfire'.default.ProjPerFire);
        SubHitCount = 0;
    }
}

function TrackPickup(Pickup Item)
{
    local WeaponPickup WP;
    local WeaponLocker Locker;
    local int i;

    if (Item.IsA('Ammo'))
    {
        for (i = 0; i < FIRE_MODE_COUNT; ++i)
        {
            if (Item.InventoryType == AmmoClass[i])
            {
                AmmoCount[i] = FMin(
                    AmmoCount[i] + Ammo(Item).AmmoAmount, AmmoClass[i].default.MaxAmmo);
            }
        }
        if (Item.IsA('AssaultAmmoPickup'))
        {
            AmmoCount[0] = FMin(AmmoCount[0] + 50, AmmoClass[0].default.MaxAmmo);
        }
    }
    else if (Item.IsA('WeaponPickup'))
    {
        WP = WeaponPickup(Item);
        if (WP.InventoryType == WeaponClass && WP.AllowRepeatPickup())
        {
            if (AmmoClass[0] == AmmoClass[1])
            {
                AmmoCount[0] = FMin(AmmoCount[0] + WP.AmmoAmount[0], AmmoClass[0].default.MaxAmmo);
            }
            else
            {
                for (i = 0; i < FIRE_MODE_COUNT; ++i)
                {
                    if (AmmoClass[i] != None)
                    {
                        AmmoCount[i] = FMin(
                            AmmoCount[i] + WP.AmmoAmount[i], AmmoClass[i].default.MaxAmmo);
                    }
                }
            }
        }
    }
    else
    {
        Locker = WeaponLocker(Item);
        for (i = 0; i < Locker.Weapons.Length; ++i)
        {
            if (Locker.Weapons[i].WeaponClass == WeaponClass)
            {
                if (AmmoClass[0] != None)
                {
                    AmmoCount[0] = Max(AmmoCount[0], AmmoClass[0].Default.InitialAmount);
                }
                if (AmmoClass[1] != None && AmmoClass[0] != AmmoClass[1])
                {
                    AmmoCount[1] = Max(AmmoCount[1], AmmoClass[1].Default.InitialAmount);
                }
                AmmoCount[0] = FMin(
                    AmmoCount[0] + Locker.Weapons[i].ExtraAmmo, AmmoClass[0].default.MaxAmmo);
                break;
            }
        }
    }
}

function UpdateAmmo(Weapon W)
{
    local int i;

    if (AmmoClass[0] == AmmoClass[1])
    {
        UpdateCurrentAmmo(0, W);
    }
    else
    {
        for (i = 0; i < FIRE_MODE_COUNT; ++i)
        {
            UpdateCurrentAmmo(i, W);
        }
    }
}

function ClearAmmo()
{
    local int i;

    for (i = 0; i < FIRE_MODE_COUNT; ++i)
    {
        AmmoCount[i] = 0;
    }
    SubHitCount = 0;
}

function Clear()
{
    local int i;

    for (i = 0; i < FIRE_MODE_COUNT; ++i)
    {
        AmmoCount[i] = 0;
        Misses[i] = 0;
        Hits[i] = 0;
    }
    SubHitCount = 0;
}

private function UpdateBioGlobHit(int Damage)
{
    local int Count;

    Count = FireClass[0].default.AmmoPerFire;
    if (Damage > class'BioGlob'.default.BaseDamage)
    {
        Count += int((Damage - class'BioGlob'.default.BaseDamage) / class'BioGlob'.default.Damage);
    }
    UpdateHits(0, Count);
}

private function UpdateShockComboHit()
{
    local int ComboCost;

    ComboCost = Min(AmmoCount[0], class'ShockProjectile'.default.ComboAmmoCost);
    AmmoCount[0] -= ComboCost;
    Hits[0] += ComboCost;
    UpdateHits(0, FireClass[0].default.AmmoPerFire + FireClass[1].default.AmmoPerFire);
}

private function UpdateFlakChunkHit()
{
    if (SubHitCount == 0 && Misses[0] >= 1.0)
    {
        SubHitCount = class'Flakfire'.default.ProjPerFire;
    }
    if (SubHitCount > 0)
    {
        UpdateHits(0, 1 / class'Flakfire'.default.ProjPerFire);
        SubHitCount -= 1;
    }
}

private function UpdateCurrentAmmo(int Mode, Weapon W)
{
    if (AmmoCount[Mode] > W.AmmoCharge[Mode])
    {
        Misses[Mode] += AmmoCount[Mode] - W.AmmoCharge[Mode];
        AmmoCount[Mode] = W.AmmoCharge[Mode];
    }
    AmmoCount[Mode] = W.AmmoCharge[Mode];
}

private function UpdateHits(int Mode, float Amount)
{
    Amount = FMin(Misses[Mode], Amount);
    Misses[Mode] -= Amount;
    Hits[Mode] += Amount;
}

defaultproperties
{
}
