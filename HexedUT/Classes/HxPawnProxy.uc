class HxPawnProxy extends HxLinkedReplicationInfo;

var MutHexedUT HexedUT;
var xPawn Pawn;

var private float AccumulatedLeech;

function SetPawn(xPawn P)
{
    Pawn = P;
    AccumulatedLeech = 0;
}

function UpdateHealthLeech(int Value, Pawn Inflictor)
{
    local float HealthLeechValue;
    local int IntegerValue;

    HealthLeechValue = Value * HexedUT.HealthLeechRatio;
    IntegerValue = int(HealthLeechValue);
    AccumulatedLeech += HealthLeechValue - float(IntegerValue);
    if (AccumulatedLeech >= 1.0)
    {
        IntegerValue += 1;
        AccumulatedLeech -= 1;
    }
    Inflictor.GiveHealth(IntegerValue, HexedUT.HealthLeechLimit);
}

static function RegisterDamage(int Damage, Pawn Injured, Pawn Inflictor, class<DamageType> Type)
{
    local HxPawnProxy Proxy;

    Proxy = class'HxPawnProxy'.static.GetPawnProxy(Inflictor);
    if (Proxy != None)
    {
        Proxy.UpdateHealthLeech(Damage, Inflictor);
    }
}

static function HxPawnProxy GetPawnProxy(Pawn P)
{
    return HxPawnProxy(Find(P.PlayerReplicationInfo, class'HxPawnProxy'));
}

defaultproperties
{
}
