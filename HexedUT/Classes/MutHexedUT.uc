class MutHexedUT extends HxMutator;

var config bool bAllowHitSounds;
var config bool bAllowDamageNumbers;
var config int BonusStartingHealth;
var config int BonusStartingShield;
var config int BonusStartingGrenades;
var config float MaxSpeedMultiplier;
var config float AirControlMultiplier;
var config float BaseJumpMultiplier;
var config float MultiJumpMultiplier;
var config int BonusMultiJumps;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (Level.NetMode != NM_DedicatedServer)
    {
        class'HxServerMenuPanel'.static.AddToMenu();
        class'HxDisplayMenuPanel'.static.AddToMenu();
    }
}

event PostBeginPlay()
{
    local HxGameRules G;

    Super.PostBeginPlay();
    G = Spawn(class'HxGameRules');
    G.HexedUT = self;
    Level.Game.AddGameModifier(G);
    OverrideStartingGrenades();
}

function ModifyPlayer(Pawn Other)
{
    OverrideStartingValues(Other);
    OverrideJumpValues(xPawn(Other));
    Super.ModifyPlayer(Other);
}

function OverrideStartingValues(Pawn Other)
{
    Other.GiveHealth(BonusStartingHealth, Other.SuperHealthMax);
    Other.AddShieldStrength(BonusStartingShield);
}

function OverrideStartingGrenades()
{
    local int TotalGrenades;

    TotalGrenades = Max(0, class'GrenadeAmmo'.default.InitialAmount + BonusStartingGrenades);
    class'GrenadeAmmo'.default.InitialAmount = TotalGrenades;
    if (TotalGrenades > class'GrenadeAmmo'.default.MaxAmmo)
    {
        class'GrenadeAmmo'.default.MaxAmmo = TotalGrenades;
    }
}

function OverrideJumpValues(xPawn Other)
{
    if (Other != None)
    {
        Other.GroundSpeed *= MaxSpeedMultiplier;
        Other.WaterSpeed *= MaxSpeedMultiplier;
        Other.AirSpeed *= MaxSpeedMultiplier;
        Other.AirControl *= AirControlMultiplier;
        Other.JumpZ *= BaseJumpMultiplier;
        Other.MultiJumpBoost *= MultiJumpMultiplier;
        Other.MaxMultiJump += BonusMultiJumps;
        Other.MultiJumpRemaining += BonusMultiJumps;
    }
}

function SpawnHxAgent(PlayerReplicationInfo PRI)
{
    local HxAgent Agent;

    if (PlayerController(PRI.Owner) != None && MessagingSpectator(PRI.Owner) == None)
    {
        Agent = HxAgent(SpawnLinkedPRI(PRI, class'HxAgent'));
        Agent.PC = PlayerController(PRI.Owner);
        Agent.HexedUT = Self;
        UpdateAgent(Agent);
    }
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (PlayerReplicationInfo(Other) != None)
    {
        SpawnHxAgent(PlayerReplicationInfo(Other));
    }
    return true;
}

function UpdateAgent(HxAgent Agent)
{
    Agent.bAllowHitSounds = bAllowHitSounds;
    Agent.bAllowDamageNumbers = bAllowDamageNumbers;
    Agent.BonusStartingHealth = BonusStartingHealth;
    Agent.BonusStartingShield = BonusStartingShield;
    Agent.BonusStartingGrenades = BonusStartingGrenades;
    Agent.MaxSpeedMultiplier = MaxSpeedMultiplier;
    Agent.AirControlMultiplier = AirControlMultiplier;
    Agent.BaseJumpMultiplier = BaseJumpMultiplier;
    Agent.MultiJumpMultiplier = MultiJumpMultiplier;
    Agent.BonusMultiJumps = BonusMultiJumps;
    Agent.NetUpdateTime = Level.TimeSeconds - 1;
}

function UpdateAllClients()
{
    local HxAgent Agent;
    local Controller C;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        Agent = class'HxAgent'.static.GetAgent(C);
        if (Agent != None)
        {
            UpdateAgent(Agent);
        }
    }
}

defaultproperties
{
    FriendlyName="Hexed UT v2dev"
    Description="Central mutator for HexedUT2k4."
    bAlwaysRelevant=true
    RemoteRole=ROLE_SimulatedProxy
    bAddToServerPackages=true
    MutatorGroup="HexedUT"

    PropertyInfoEntries(0)=(Name="bAllowHitSounds",Caption="Allow hit sound effects",Hint="Allow clients to enable/disable hit sound effects.",PIType="Check")
    PropertyInfoEntries(1)=(Name="bAllowDamageNumbers",Caption="Allow damage number effects",Hint="Allow clients to enable/disable damage number effects.",PIType="Check")
    PropertyInfoEntries(2)=(Name="BonusStartingHealth",Caption="Bonus health",Hint="Bonus to add to starting health (between -99 and 99).",PIType="Text",PIExtras="8;-99:99")
    PropertyInfoEntries(3)=(Name="BonusStartingShield",Caption="Bonus shield",Hint="Bonus to add to Starting shield (between 0 and 150).",PIType="Text",PIExtras="8;0:150")
    PropertyInfoEntries(4)=(Name="BonusStartingGrenades",Caption="Bonus AR grenades",Hint="Bonus to add to starting number of AR grenades (between -4 and 99).",PIType="Text",PIExtras="8;-4:99")
    PropertyInfoEntries(5)=(Name="MaxSpeedMultiplier",Caption="Maximum speed multiplier",Hint="Coefficient to multiply maximum movement speed (between -100.0 and 100.0).",PIType="Text",PIExtras="8;-100.0:100.0")
    PropertyInfoEntries(6)=(Name="AirControlMultiplier",Caption="Air control multiplier",Hint="Coefficient to multiply air control (between -10.0 and 10.0).",PIType="Text",PIExtras="8;-10.0:10.0")
    PropertyInfoEntries(7)=(Name="BaseJumpMultiplier",Caption="Base jump multiplier",Hint="Coefficient to multiply base jump acceleration (between -10.0 and 10.0).",PIType="Text",PIExtras="8;-10.0:10.0")
    PropertyInfoEntries(8)=(Name="MultiJumpMultiplier",Caption="Multi-jump multiplier",Hint="Coefficient to multiply multi-jump acceleration boost (between -100.0 and 100.0)",PIType="Text",PIExtras="8;-100.0:100.0")
    PropertyInfoEntries(9)=(Name="BonusMultiJumps",Caption="Bonus multi-jumps",Hint="Bonus to add to base amount of multi-jumps (between -1 and 99).",PIType="Text",PIExtras="8;-1:99")

    // Config variables
    bAllowHitSounds=true
    bAllowDamageNumbers=true
    BonusStartingHealth=0
    BonusStartingShield=0
    BonusStartingGrenades=0
    MaxSpeedMultiplier=1.0
    AirControlMultiplier=1.0
    BaseJumpMultiplier=1.0
    MultiJumpMultiplier=1.0
    BonusMultiJumps=0
}
