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

var class<FloatingWindow> MenuClass;

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();
    class'HxGeneralPanel'.static.AddToMenu();
    class'HxHitEffectsPanel'.static.AddToMenu();
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
        Agent.PC = PlayerController(PRI.Owner);
        Agent.HexedUT = Self;
        Agent.NetUpdateTime = Level.TimeSeconds - 1;
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

function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
    local int i;

    super.GetServerDetails(ServerState);

    i = ServerState.ServerInfo.Length;
    ServerState.ServerInfo.Length = i + 1;
    ServerState.ServerInfo[i].Key = "Current Tick Rate";
    ServerState.ServerInfo[i++].Value = ConsoleCommand("GetCurrentTickRate");
    ServerState.ServerInfo.Length = i + 1;
    ServerState.ServerInfo[i].Key = "Max Tick Rate";
    ServerState.ServerInfo[i++].Value = ConsoleCommand("GetMaxTickRate");
}

function Mutate(string Command, PlayerController Sender)
{
    if (Command ~= "HexedUT")
    {
        Sender.ClientOpenMenu(string(MenuClass));
    }
	else if (NextMutator != None)
    {
		NextMutator.Mutate(Command, Sender);
    }
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
    super.FillPlayInfo(PlayInfo);

    PlayInfo.AddSetting("HexedUT", "bAllowHitSounds", "Allow hit sound effects", 0, 1, "Check");
    PlayInfo.AddSetting(
        "HexedUT", "bAllowDamageNumbers", "Allow damage number effects", 0, 1, "Check");
    PlayInfo.AddSetting(
        "HexedUT", "BonusStartingHealth", "Bonus starting health", 0, 1, "Text", "3;-99:99");
    PlayInfo.AddSetting(
        "HexedUT", "BonusStartingShield", "Bonus starting shield", 0, 1, "Text", "3;0:150");
    PlayInfo.AddSetting(
        "HexedUT", "BonusStartingGrenades", "Bonus starting AR grenades", 0, 1, "Text", "3;-4:99");
    PlayInfo.AddSetting(
        "HexedUT", "MaxSpeedMultiplier", "Maximum speed multiplier", 0, 1, "Text", "8;-100.0:100.0");
    PlayInfo.AddSetting(
        "HexedUT", "AirControlMultiplier", "Air control multiplier", 0, 1, "Text", "8;-10.0:10.0");
    PlayInfo.AddSetting(
        "HexedUT", "BaseJumpMultiplier", "Base jump multiplier", 0, 1, "Text", "8;-10.0:10.0");
    PlayInfo.AddSetting(
        "HexedUT", "MultiJumpMultiplier", "Multi-jump multiplier", 0, 1, "Text", "8;-100.0:100.0");
    PlayInfo.AddSetting("HexedUT", "BonusMultiJumps", "Bonus multi-jumps", 0, 1, "Text", "3;-1:99");
}

static event string GetDescriptionText(string PropName)
{
    switch (PropName)
    {
        case "bAllowHitSounds":
            return "Allow clients to enable/disable hit sound effects.";
        case "bAllowDamageNumbers":
            return "Allow clients to enable/disable damage number effects.";
        case "BonusStartingHealth":
            return "Bonus to add to starting health (between -99 and 99).";
        case "BonusStartingShield":
            return "Bonus to add to Starting shield (between 0 and 150).";
        case "BonusStartingGrenades":
            return "Bonus to add to starting number of AR grenades (between -4 and 99).";
        case "MaxSpeedMultiplier":
            return "Coefficient to multiply maximum movement speed (between -100.0 and 100.0).";
        case "AirControlMultiplier":
            return "Coefficient to multiply air control (between -10.0 and 10.0).";
        case "BaseJumpMultiplier":
            return "Coefficient to multiply base jump acceleration (between -10.0 and 10.0).";
        case "MultiJumpMultiplier":
            return "Coefficient to multiply multi-jump acceleration boost (between -100.0 and 100.0).";
        case "BonusMultiJumps":
            return "Bonus to add to base amount of multi-jumps (between -1 and 99).";
    }
    return Super.GetDescriptionText(PropName);
}

defaultproperties
{
    // Inherited variables
    FriendlyName="Hexed UT v2dev"
    Description="Central mutator for HexedUT2k4."
    bAlwaysRelevant=true
    RemoteRole=ROLE_SimulatedProxy
    bAddToServerPackages=true
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
    // Normal variables
    MenuClass=class'HxMenu'
}
