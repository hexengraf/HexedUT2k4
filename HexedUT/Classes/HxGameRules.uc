class HxGameRules extends GameRules;

var MutHexedUT HexedUT;

function int NetDamage(int Original,
                       int Damage,
                       Pawn Injured,
                       Pawn Inflictor,
                       vector Location,
                       out vector Momentum,
                       class<DamageType> Type)
{
    local Controller C;

    if (NextGameRules != None)
    {
		Damage = NextGameRules.NetDamage(
            Original, Damage, Injured, Inflictor, Location, Momentum, Type);
    }
    if ((HexedUT.bAllowHitSounds || HexedUT.bAllowDamageNumbers)
        && Damage > 0 && Inflictor != None && Injured != None)
    {
        for (C = Level.ControllerList; C != None; C = C.NextController)
        {
            if (MessagingSpectator(C) == None)
            {
                class'HxAgent'.static.RegisterDamage(
                    PlayerController(C), Damage, Injured, Inflictor, Type);
            }
        }
    }
	return Damage;
}

defaultproperties
{
}
