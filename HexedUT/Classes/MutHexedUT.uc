class MutHexedUT extends HxMutator;

var config bool bAllowHitSounds;
var config bool bAllowDamageNumbers;

var class<FloatingWindow> MenuClass;

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();
    class'HxGeneralPanel'.static.AddToMenu();
    class'HxEffectsPanel'.static.AddToMenu();
}

event PostBeginPlay()
{
    local HxGameRules G;

    Super.PostBeginPlay();
    G = Spawn(class'HxGameRules');
    G.HexedUT = self;
    Level.Game.AddGameModifier(G);
    StaticSaveConfig();
}

function SpawnHxAgent(PlayerReplicationInfo PRI)
{
    local HxAgent Agent;

    if (PlayerController(PRI.Owner) != None && MessagingSpectator(PRI.Owner) == None)
    {
        Agent = HxAgent(SpawnLinkedPRI(PRI, class'HxAgent'));
        Agent.bAllowHitSounds = bAllowHitSounds;
        Agent.bAllowDamageNumbers = bAllowDamageNumbers;
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

    PlayInfo.AddSetting("HexedUT", "bAllowHitSounds", "Allow hit sound effects", 0, 10, "Check");
    PlayInfo.AddSetting("HexedUT", "bAllowDamageNumbers", "Allow damage number effects", 0, 10, "Check");
}

static event string GetDescriptionText(string PropName)
{
    switch (PropName)
    {
        case "bAllowHitSounds":
            return "Allow clients to enable/disable hit sound effects.";
        case "bAllowDamageNumbers":
            return "Allow clients to enable/disable damage number effects.";
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
    // Normal variables
    MenuClass=class'HxMenu'
}
