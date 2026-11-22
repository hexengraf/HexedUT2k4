class HxSPStrictEnforcer extends Actor;

var private Pawn Tracked;
var private float Duration;

event PostBeginPlay()
{
    Tracked = Pawn(Owner);
    Duration = DeathMatch(Level.Game).SpawnProtectionTime;
}

event Tick(float DeltaTime)
{
    if (Tracked == None || (Level.TimeSeconds - Tracked.SpawnTime) >= Duration)
    {
        Destroy();
        Disable('Tick');
    }
    else if (Tracked.IsFiring())
    {
        Tracked.DeactivateSpawnProtection();
        Destroy();
        Disable('Tick');
    }
}

event Destroyed()
{
    Tracked = None;
}

defaultproperties
{
    RemoteRole=ROLE_None
	bHidden=true
}
