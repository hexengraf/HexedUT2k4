class HxUTGameRules extends GameRules;

var MutHexedUT HexedUT;

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
    if (Damage > 0 && Inflictor != None && Injured != None)
    {
        if (HexedUT.bAllowHitSounds || HexedUT.bAllowDamageNumbers)
        {
           class'HxUTClient'.static.RegisterDamage(Damage, Injured, Inflictor, Type);
        }
        if (HexedUT.HealthLeechLimit != 0)
        {
            class'HxPlayerReplicationInfo'.static.RegisterDamage(Damage, Injured, Inflictor, Type);
        }
    }
    return Damage;
}

function ScoreKill(Controller Killer, Controller Killed)
{
    if (HexedUT.HealthLeechLimit != 0)
    {
        class'HxPlayerReplicationInfo'.static.RegisterKill(Killer, Killed);
    }
    Super.ScoreKill(Killer, Killed);
}

defaultproperties
{
}
