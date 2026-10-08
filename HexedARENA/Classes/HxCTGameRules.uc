class HxCTGameRules extends GameRules;

var private MutHexedCONTROL HexedCONTROL;
var private array<float> AccumulatedLeeches;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    HexedCONTROL = MutHexedCONTROL(Owner);
    if (HexedCONTROL != None)
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
    if (Inflictor != None)
    {
        if (Injured.Controller == Inflictor.Controller)
        {
            Damage *= HexedCONTROL.SelfDamageScale;
        }
        else if (HexedCONTROL.HealthLeechLimit != 0 && Damage > 0 && IsEnemy(Injured, Inflictor))
        {
            UpdateHealthLeech(Damage, Inflictor);
        }
    }
    return Damage;
}

function ScoreKill(Controller Killer, Controller Killed)
{
    if (HexedCONTROL.HealthLeechLimit != 0)
    {
        ResetHealthLeech(Killed);
    }
    Super.ScoreKill(Killer, Killed);
}

function UpdateHealthLeech(int Damage, Pawn Inflictor)
{
    local HxPlayerReplicationInfo HexedPRI;
    local float HealthLeechValue;
    local int IntegerValue;

    HexedPRI = class'HxPlayerReplicationInfo'.static.Get(Inflictor.PlayerReplicationInfo);
    if (HexedPRI != None)
    {
        HealthLeechValue = Damage * HexedCONTROL.HealthLeechRatio;
        IntegerValue = int(HealthLeechValue);
        if (AccumulatedLeeches.Length <= HexedPRI.PlayerID)
        {
            AccumulatedLeeches.Length = HexedPRI.PlayerID + 1;
        }
        AccumulatedLeeches[HexedPRI.PlayerID] += HealthLeechValue - float(IntegerValue);
        if (AccumulatedLeeches[HexedPRI.PlayerID] >= 1.0)
        {
            IntegerValue += 1;
            AccumulatedLeeches[HexedPRI.PlayerID] -= 1;
        }
        Inflictor.GiveHealth(IntegerValue, HexedCONTROL.HealthLeechLimit);
    }
}

function ResetHealthLeech(Controller C)
{
    local HxPlayerReplicationInfo HexedPRI;

    HexedPRI = class'HxPlayerReplicationInfo'.static.Get(C.PlayerReplicationInfo);
    if (HexedPRI != None)
    {
        if (AccumulatedLeeches.Length <= HexedPRI.PlayerID)
        {
            AccumulatedLeeches.Length = HexedPRI.PlayerID + 1;
        }
        AccumulatedLeeches[HexedPRI.PlayerID] = 0;
    }
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
