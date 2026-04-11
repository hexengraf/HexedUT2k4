class HxCTPlayerInfo extends HxLinkedReplicationInfo;

var MutHexedCONTROL HexedControl;

var private float AccumulatedLeech;

event PreBeginPlay()
{
    Super.PreBeginPlay();
    HexedControl = MutHexedCONTROL(Owner);
}

function UpdateHealthLeech(int Value, Pawn Inflictor)
{
    local float HealthLeechValue;
    local int IntegerValue;

    HealthLeechValue = Value * HexedControl.HealthLeechRatio;
    IntegerValue = int(HealthLeechValue);
    AccumulatedLeech += HealthLeechValue - float(IntegerValue);
    if (AccumulatedLeech >= 1.0)
    {
        IntegerValue += 1;
        AccumulatedLeech -= 1;
    }
    Inflictor.GiveHealth(IntegerValue, HexedControl.HealthLeechLimit);
}

static function RegisterDamage(int Damage, Pawn Injured, Pawn Inflictor, class<DamageType> Type)
{
    local HxCTPlayerInfo Info;

    Info = HxCTPlayerInfo(Find(Inflictor.PlayerReplicationInfo, default.Class));
    if (Info != None)
    {
        Info.UpdateHealthLeech(Damage, Inflictor);
    }
}

static function RegisterKill(Controller Killer, Controller Killed)
{
    local HxCTPlayerInfo Info;

    Info = HxCTPlayerInfo(Find(Killed.PlayerReplicationInfo, default.Class));
    if (Info != None)
    {
        Info.AccumulatedLeech = 0;
    }
}

defaultproperties
{
}
