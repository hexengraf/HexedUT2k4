class MutHexedUT extends HxMutator;

var config bool bAllowHitSounds;
var config bool bAllowDamageNumbers;
var config int StartingHealth;
var config int StartingShield;
var config int StartingGrenades;

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
    class'GrenadeAmmo'.Default.InitialAmount = StartingGrenades;
    if (StartingGrenades > class'GrenadeAmmo'.Default.MaxAmmo)
    {
        class'GrenadeAmmo'.Default.MaxAmmo = StartingGrenades;
    }
}

function ModifyPlayer(Pawn Other)
{
    Other.Health = Max(1, Min(StartingHealth, Other.SuperHealthMax));
    Other.ShieldStrength = 0;
    Other.AddShieldStrength(StartingShield);
	Super.ModifyPlayer(Other);
}

function SpawnHxAgent(PlayerReplicationInfo PRI)
{
    local HxAgent Agent;

    if (PlayerController(PRI.Owner) != None && MessagingSpectator(PRI.Owner) == None)
    {
        Agent = HxAgent(SpawnLinkedPRI(PRI, class'HxAgent'));
        Agent.bAllowHitSounds = bAllowHitSounds;
        Agent.bAllowDamageNumbers = bAllowDamageNumbers;
        Agent.StartingHealth = StartingHealth;
        Agent.StartingShield = StartingShield;
        Agent.StartingGrenades = StartingGrenades;
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
    ServerState.ServerInfo[i++].Value = ConsoleCommand("getcurrenttickrate");
    ServerState.ServerInfo.Length = i + 1;
    ServerState.ServerInfo[i].Key = "Max Tick Rate";
    ServerState.ServerInfo[i++].Value = ConsoleCommand("getmaxtickrate");
}

simulated function Mutate(string Command, PlayerController Sender)
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
        "HexedUT", "bAllowDamageNumbers", "Allow damage number effects", 0, 2, "Check");
    PlayInfo.AddSetting("HexedUT", "StartingHealth", "Starting health", 0, 3, "Text", "0;1:199");
    PlayInfo.AddSetting("HexedUT", "StartingShield", "Starting shield", 0, 4, "Text", "0;0:150");
    PlayInfo.AddSetting(
        "HexedUT", "StartingGrenades", "Starting AR grenades", 0, 5, "Text", "0;0:99");
}

static event string GetDescriptionText(string PropName)
{
    switch (PropName)
    {
        case "bAllowHitSounds":
            return "Allow clients to enable/disable hit sound effects.";
        case "bAllowDamageNumbers":
            return "Allow clients to enable/disable damage number effects.";
        case "StartingHealth":
            return "Starting health value (between 1 and 199, default is 100).";
        case "StartingShield":
            return "Starting shield value (between 0 and 150, default is 0).";
        case "StartingGrenades":
            return "Starting number of AR grenades (between 0 and 99, default is 4).";
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
    StartingHealth=100
    StartingShield=0
    StartingGrenades=4
    // Normal variables
    MenuClass=class'HxMenu'
}
