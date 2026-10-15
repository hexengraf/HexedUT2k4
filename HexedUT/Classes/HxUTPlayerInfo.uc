class HxUTPlayerInfo extends Info;

struct HxWeaponStatsGroup
{
    var array<HxUTWeaponStats> Stats;
};

// BallLauncher's InventoryGroup is 15
const WEAPON_GROUP_COUNT = 16;

var private HxPlayerReplicationInfo HexedPRI;
var private Controller Controller;
var private HxWeaponStatsGroup WeaponGroups[WEAPON_GROUP_COUNT];
var private bool bActive;

function Setup(HxPlayerReplicationInfo HexedPRI, Controller Controller)
{
    Self.HexedPRI = HexedPRI;
    Self.Controller = Controller;
}

function SetActive(bool bValue)
{
    bActive = bValue && HexedPRI != None && Controller != None;
    if (bActive)
    {
        SetTimer(Level.TimeDilation * 2.0 + Level.TimeDilation * (FRand() - 0.5) * 0.5, true);
    }
    else
    {
        SetTimer(0.0, false);
    }
    if (HexedPRI != None)
    {
        HexedPRI.SetWeaponStatsAvailability(bValue);
        HexedPRI.SetKillStatsAvailability(bValue);
    }
}

event Timer()
{
    if (HexedPRI == None)
    {
        SetTimer(0.0, false);
    }
    else if (bActive)
    {
        UpdateReplicationInfo();
    }
}

function Tick(float DeltaTime)
{
    local Weapon W;

    if (bActive && HasPawn() && Controller.Pawn.Weapon != None)
    {
        W = Controller.Pawn.Weapon;
        if (!W.IsA('ShieldGun') && !W.IsA('TransLauncher') && !W.IsA('SuperShockRifle'))
        {
            GetWeaponStats(W).UpdateAmmo(W);
        }
    }
}

function TrackAmmoPickup(Pickup Item)
{
    local int i;
    local int j;

    if (Item.IsA('Ammo') || Item.IsA('WeaponPickup') || Item.IsA('WeaponLocker'))
    {
        for (i = 0; i < WEAPON_GROUP_COUNT; ++i)
        {
            for (j = 0; j < WeaponGroups[i].Stats.Length; ++j)
            {
                WeaponGroups[i].Stats[j].TrackPickup(Item);
            }
        }
    }
}

function TrackAmmoOnHit(int Damage, class<WeaponDamageType> DamageType)
{
    local HxUTWeaponStats Stats;
    local Inventory Inv;

    if (DamageType.default.WeaponClass != None)
    {
        Stats = FindWeaponStats(DamageType.default.WeaponClass);
        if (Stats != None && HasPawn())
        {
            for (Inv = Controller.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
            {
                if (ClassIsChildOf(Inv.Class, DamageType.default.WeaponClass))
                {
                    Stats.UpdateAmmo(Weapon(Inv));
                    break;
                }
            }
            Stats.TrackHit(Damage, DamageType, Level.TimeSeconds);
        }
    }
}

function TrackWeaponKill(class<WeaponDamageType> DamageType, Pawn Killed)
{
    local HxUTWeaponStats Stats;

    if (DamageType.default.WeaponClass != None)
    {
        Stats = FindWeaponStats(DamageType.default.WeaponClass);
        if (Stats != None && IsEnemyPawn(Killed))
        {
            Stats.TrackKill(DamageType, Level.TimeSeconds);
        }
    }
}

function ScoreKill(Controller Killed)
{
    if (Controller.Pawn != None)
    {
       HexedPRI.MaxSpree = Max(HexedPRI.MaxSpree, Controller.Pawn.GetSpree());
    }
    if (Killed != None && !IsEnemy(Killed))
    {
        HexedPRI.TeamKills += 1;
    }
}

function ClearAmmo()
{
    local int i;
    local int j;

    for (i = 0; i < WEAPON_GROUP_COUNT; ++i)
    {
        for (j = 0; j < WeaponGroups[i].Stats.Length; ++j)
        {
            WeaponGroups[i].Stats[j].ClearAmmo();
        }
    }
}

function ClearStats()
{
    local int i;
    local int j;

    for (i = 0; i < WEAPON_GROUP_COUNT; ++i)
    {
        for (j = 0; j < WeaponGroups[i].Stats.Length; ++j)
        {
            WeaponGroups[i].Stats[j].Clear();
        }
    }
}

private final function HxUTWeaponStats GetWeaponStats(Weapon W)
{
    local int i;

    for (i = 0; i < WeaponGroups[W.InventoryGroup].Stats.Length; ++i)
    {
        if (WeaponGroups[W.InventoryGroup].Stats[i].WeaponClass == W.Class)
        {
            return WeaponGroups[W.InventoryGroup].Stats[i];
        }
    }
    WeaponGroups[W.InventoryGroup].Stats[i] = new (None) class'HxUTWeaponStats';
    WeaponGroups[W.InventoryGroup].Stats[i].Setup(W);
    return WeaponGroups[W.InventoryGroup].Stats[i];
}

private final function HxUTWeaponStats FindWeaponStats(class<Weapon> WeaponClass)
{
    local int GroupIndex;
    local int i;

    GroupIndex = WeaponClass.default.InventoryGroup;
    for (i = 0; i < WeaponGroups[GroupIndex].Stats.Length; ++i)
    {
        if (ClassIsChildOf(WeaponGroups[GroupIndex].Stats[i].WeaponClass, WeaponClass))
        {
            return WeaponGroups[GroupIndex].Stats[i];
        }
    }
    return None;
}

private final function UpdateReplicationInfo()
{
    local int Index;
    local int Hits;
    local int Misses;
    local int i;
    local int j;

    for (i = 0; i < WEAPON_GROUP_COUNT; ++i)
    {
        for (j = 0; j < WeaponGroups[i].Stats.Length; ++j)
        {
            if (HexedPRI.ValidateWeaponStats(WeaponGroups[i].Stats[j].WeaponClass, Index))
            {
                Hits = WeaponGroups[i].Stats[j].GetHits(Misses);
                HexedPRI.WeaponStats[Index].Hits = Hits;
                HexedPRI.WeaponStats[Index].Total = Hits + Misses;
                ++Index;
            }
        }
    }
}

private final function bool HasPawn()
{
    return Controller != None && Controller.Pawn != None;
}

private final function bool IsEnemy(Controller Killed)
{
    local int TeamNum;

    TeamNum = Killed.GetTeamNum();
    return TeamNum == 255 || TeamNum != Controller.GetTeamNum();
}

private final function bool IsEnemyPawn(Pawn Killed)
{
    local int TeamNum;

    TeamNum = Killed.GetTeamNum();
    return TeamNum == 255 || TeamNum != Controller.GetTeamNum();
}

defaultproperties
{
}
