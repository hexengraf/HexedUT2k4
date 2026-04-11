class HxCTGameRules extends GameRules;

var private MutHexedCONTROL HexedControl;

event PreBeginPlay()
{
    Super.PreBeginPlay();
    HexedControl = MutHexedCONTROL(Owner);
    if (HexedControl != None)
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
                       vector Location,
                       out vector Momentum,
                       class<DamageType> Type)
{
    if (NextGameRules != None)
    {
        Damage = NextGameRules.NetDamage(
            Original, Damage, Injured, Inflictor, Location, Momentum, Type);
    }
    if (HexedControl.HealthLeechLimit != 0 && Damage > 0 && Inflictor != None && Injured != None
        && Injured != Inflictor && IsEnemy(Injured, Inflictor))
    {
        class'HxCTPlayerInfo'.static.RegisterDamage(Damage, Injured, Inflictor, Type);
    }
    return Damage;
}

function ScoreKill(Controller Killer, Controller Killed)
{
    if (HexedControl.HealthLeechLimit != 0)
    {
        class'HxCTPlayerInfo'.static.RegisterKill(Killer, Killed);
    }
    Super.ScoreKill(Killer, Killed);
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
