class HxUTWeaponStats extends Object;

const FIRE_MODE_COUNT = 2;

var class<Weapon> WeaponClass;
var private class<WeaponFire> FireClass[FIRE_MODE_COUNT];
var private class<Ammunition> AmmoClass[FIRE_MODE_COUNT];
var private int AmmoCount[FIRE_MODE_COUNT];
var private int Hits[FIRE_MODE_COUNT];
var private int Misses[FIRE_MODE_COUNT];
var private int SubHitCount;
var private float LastHitTime;

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

function int GetHits(optional out int AllMisses)
{
    local int AllHits;
    local int i;

    AllMisses = 0;
    for (i = 0; i < FIRE_MODE_COUNT; ++i)
    {
        AllMisses += Misses[i];
        AllHits += Hits[i];
    }
    return AllHits;
}

function TrackHit(int Damage, class<DamageType> DamageType, float HitTime)
{
    switch (DamageType)
    {
        case class'DamTypeShockBall':
        case class'DamTypeRedeemer':
            UpdateRadiusHit(0, HitTime);
            break;
        case class'DamTypeBioGlob':
            UpdateBioGlobHit(Damage, HitTime);
            break;
        case class'DamTypeFlakChunk':
            UpdateFlakChunkHit(HitTime);
            break;
        case class'DamTypeFlakShell':
            UpdateFlakShellHit(HitTime);
            break;
        case class'DamTypeRocket':
        case class'DamTypeRocketHoming':
            UpdateRocketHit(HitTime);
            break;
        case class'DamTypeShockCombo':
            UpdateShockComboHit(HitTime);
            break;
        case class'DamTypeAssaultGrenade':
            UpdateDirectHit(1, HitTime);
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
        default:
            UpdateDirectHit(0, HitTime);
            break;
    }
}

function TrackKill(class<WeaponDamageType> DamageType, float KillTime)
{
    if (DamageType == class'DamTypeFlakChunk'
        && KillTime - LastHitTime > FireClass[0].default.FireRate
        && SubHitCount > 0)
    {
        Hits[0] += SubHitCount;
        Misses[0] -= SubHitCount;
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

private function UpdateDirectHit(int Mode, float HitTime)
{
    UpdateCounters(Mode, FireClass[Mode].default.AmmoPerFire);
    LastHitTime = HitTime;
}

private function UpdateRadiusHit(int Mode, float HitTime)
{
    if (HitTime - LastHitTime > FireClass[Mode].default.FireRate)
    {
        UpdateCounters(Mode, FireClass[Mode].default.AmmoPerFire);
        LastHitTime = HitTime;
    }
}

private function UpdateBioGlobHit(int Damage, float HitTime)
{
    local int Count;

    Count = FireClass[0].default.AmmoPerFire;
    if (Damage <= class'BioGlob'.default.BaseDamage)
    {
        UpdateCounters(0, Count);
    }
    else if (HitTime - LastHitTime > FireClass[0].default.FireRate)
    {
        Count += int((Damage - class'BioGlob'.default.BaseDamage) / class'BioGlob'.default.Damage);
        UpdateCounters(0, Count);
        LastHitTime = HitTime;
    }
}

private function UpdateShockComboHit(float HitTime)
{
    local int ComboCost;

    if (HitTime - LastHitTime > FireClass[0].default.FireRate)
    {
        ComboCost = Min(AmmoCount[0], class'ShockProjectile'.default.ComboAmmoCost);
        AmmoCount[0] -= ComboCost;
        Hits[0] += ComboCost;
        UpdateCounters(0, FireClass[0].default.AmmoPerFire + FireClass[1].default.AmmoPerFire);
        LastHitTime = HitTime;
    }
}

private function UpdateFlakChunkHit(float HitTime)
{
    if (HitTime - LastHitTime > FireClass[0].default.FireRate)
    {
        if (SubHitCount == 0)
        {
            if (Misses[0] > 0)
            {
                SubHitCount = class'Flakfire'.default.ProjPerFire - 1;
                Misses[0] += SubHitCount;
                Hits[0] += 1;
            }
        }
        else
        {
            --SubHitCount;
            UpdateCounters(0, 1);
        }
    }
}

private function UpdateFlakShellHit(float HitTime)
{
    if (HitTime - LastHitTime > FireClass[1].default.FireRate)
    {
        UpdateCounters(0, FireClass[1].default.AmmoPerFire);
    }
    LastHitTime = HitTime;
}

private function UpdateRocketHit(float HitTime)
{
    if (HitTime - LastHitTime > FireClass[0].default.FireRate)
    {
        SubHitCount = 1;
        UpdateCounters(0, FireClass[0].default.AmmoPerFire);
        LastHitTime = HitTime;
    }
    else if (SubHitCount < 3)
    {
        UpdateCounters(0, FireClass[0].default.AmmoPerFire);
        LastHitTime = HitTime;
        ++SubHitCount;
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

private function UpdateCounters(int Mode, int Amount)
{
    local int Count;

    Count = FMin(Misses[Mode], Amount);
    Misses[Mode] -= Count;
    Hits[Mode] += Count;
}

defaultproperties
{
}
