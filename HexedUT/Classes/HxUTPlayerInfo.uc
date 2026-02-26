class HxUTPlayerInfo extends HxLinkedReplicationInfo;

var MutHexedUT HexedUT;

var private float AccumulatedLeech;

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
    local HxUTPlayerInfo Info;

    Info = HxUTPlayerInfo(Find(Inflictor.PlayerReplicationInfo, default.Class));
    if (Info != None)
    {
        Info.UpdateHealthLeech(Damage, Inflictor);
    }
}

static function RegisterKill(Controller Killer, Controller Killed)
{
    local HxUTPlayerInfo Info;

    Info = HxUTPlayerInfo(Find(Killed.PlayerReplicationInfo, default.Class));
    if (Info != None)
    {
        Info.AccumulatedLeech = 0;
    }
}

defaultproperties
{
}
