class HxUTGameRules extends GameRules;

var private MutHexedUT HexedUT;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    HexedUT = MutHexedUT(Owner);
    if (HexedUT != None)
    {
        Level.Game.AddGameModifier(Self);
    }
    else
    {
        Destroy();
    }
}

function int NetDamage(int Original,
                       int Damage,
                       Pawn Injured,
                       Pawn Inflictor,
                       Vector Location,
                       out Vector Momentum,
                       class<DamageType> Type)
{
    if (NextGameRules != None)
    {
        Damage = NextGameRules.NetDamage(
            Original, Damage, Injured, Inflictor, Location, Momentum, Type);
    }
    if (Inflictor != None && Injured != None && Inflictor != Injured && IsEnemy(Injured, Inflictor))
    {
        HexedUT.RegisterDamage(Original, Damage, Injured, Inflictor, Type);
    }
    return Damage;
}

function bool PreventDeath(Pawn Killed,
                           Controller Killer,
                           class<DamageType> DamageType,
                           Vector Location)
{
    if (!Super.PreventDeath(Killed, Killer, DamageType, Location))
    {
        if (ClassIsChildOf(DamageType, class'WeaponDamageType'))
        {
            HexedUT.RegisterWeaponKill(Killed, Killer, class<WeaponDamageType>(DamageType));
        }
        return false;
    }
    return true;
}

function ScoreKill(Controller Killer, Controller Killed)
{
    Super.ScoreKill(Killer, Killed);
    HexedUT.ScoreKill(Killer, Killed);
}

function bool OverridePickupQuery(Pawn Other, Pickup Item, out byte bAllowPickup)
{
    local bool bOverride;

    bOverride = Super.OverridePickupQuery(Other, Item, bAllowPickup);
    if ((!bOverride || bAllowPickup == 1))
    {
        HexedUT.RegisterPickup(Other, Item);
    }
    return bOverride;
}

static function bool IsEnemy(Pawn Injured, Pawn Inflictor)
{
    local int TeamNum;

    TeamNum = Injured.GetTeamNum();
    return TeamNum == 255 || TeamNum != Inflictor.GetTeamNum();
}

defaultproperties
{
}
