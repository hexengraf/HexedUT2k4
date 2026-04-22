class HxVTClient extends HxClientReplicationInfo
    config(User);

const MIN_VERSION = 6;

var config bool bFirstRun;

var HxFavorites Favorites;
var VotingReplicationInfo VRI;

var private PlayerController PC;
var private GUIController GC;
var private string CustomMapVoteMenu;
var private bool bReplaceMapVoteMenu;
var private bool bInitialized;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    CustomMapVoteMenu = string(class'HxMapVotingPage');
    if (Level.NetMode != NM_DedicatedServer)
    {
        Favorites = new(None, "Maps") class'HxFavorites';
        if (bFirstRun)
        {
            RecoverConfigs();
        }
    }
}

simulated event Destroyed()
{
    Favorites = None;
    Super.Destroyed();
}

simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (!bInitialized)
        {
            bInitialized = InitializeClient();
        }
        else if (bReplaceMapVoteMenu)
        {
            TryReplaceMapVoteMenu();
        }
    }
}

simulated function bool InitializeClient()
{
    if (PC == None)
    {
        PC = Level.GetLocalPlayerController();
    }
    if (PC != None)
    {
        if (PC.Player != None)
        {
            GC = GUIController(PC.Player.GUIController);
            bReplaceMapVoteMenu = !GC.SetPropertyText("CustomMapVotingMenu", CustomMapVoteMenu);
        }
        VRI = VotingReplicationInfo(PC.VoteReplicationInfo);
    }
    return PC != None && GC != None;
}

simulated function TryReplaceMapVoteMenu()
{
    if (GC.ActivePage != None)
    {
        if (GC.ActivePage.Class == class'MapVotingPage')
        {
            GC.ReplaceMenu(CustomMapVoteMenu);
        }
        else if (GC.ActivePage.ParentPage != None
            && GC.ActivePage.ParentPage.Class == class'MapVotingPage')
        {
            if (GC.CloseMenu(true))
            {
                GC.ReplaceMenu(CustomMapVoteMenu);
            }
        }
    }
}

simulated function UpdateMapVoteMenuBackgrounds()
{
    class'HxMapVotingPage'.default.VoteListCustomBG = GetServerProperty("VoteListCustomBG");
    class'HxMapVotingPage'.default.MapListCustomBG = GetServerProperty("MapListCustomBG");
    class'HxMapVotingPage'.default.PreviewCustomBG = GetServerProperty("PreviewCustomBG");
    class'HxMapVotingPage'.default.ChatBoxCustomBG = GetServerProperty("ChatBoxCustomBG");
}

simulated function ServerInfoReady()
{
    UpdateMapVoteMenuBackgrounds();
}

simulated function ServerPropertyChanged(int Index, string OldValue)
{
    UpdateMapVoteMenuBackgrounds();
}

simulated function bool SendMapVote(int GameType, int Map)
{
    if (VRI.MapList[Map].bEnabled || PC.PlayerReplicationInfo.bAdmin)
    {
        VRI.SendMapVote(Map, GameType);
        return true;
    }
    return false;
}

simulated function string GetGameTypePrefix(int GameType)
{
    return VRI.GameConfig[GameType].Prefix;
}

simulated function string GetGameTypeName(int GameType)
{
    return VRI.GameConfig[GameType].GameName;
}

simulated function int GetGameTypeCount()
{
    return VRI.GameConfig.Length;
}

simulated function int GetCurrentGameType()
{
    return VRI.CurrentGameConfig;
}

simulated function byte GetMapVoteMode()
{
    return VRI.Mode;
}

simulated function string GetLoadingStatus()
{
    return VRI.MapList.Length$"/"$VRI.MapCount;
}

simulated function bool IsInitialized()
{
    return bInitialized && VRI != None;
}

simulated function bool IsLoadingMapData()
{
    return VRI.GameConfig.Length < VRI.GameConfigCount
        || VRI.MapList.Length < VRI.MapCount;
}

simulated function bool IsMapVoteEnabled()
{
    return VRI.bMapVote;
}

// TODO: delete this function in v8
simulated function RecoverConfigs()
{
    local HxMapFavorites NewObject;
    local Object OldObject;
    local int i;

    NewObject = new() class'HxMapFavorites';
    OldObject = NewObject.FindOldVersionObject(class'HxMapFavorites', MIN_VERSION);
    if (OldObject != None)
    {
        NewObject.CopyPropertyFrom(OldObject, "Maps");
    }
    for (i = 0; i < NewObject.Maps.Length; ++i)
    {
        Favorites.Save(NewObject.Maps[i].Map, NewObject.Maps[i].Tag, true);
    }
    Favorites.SaveConfig();
    NewObject = None;
    OldObject = None;
    bFirstRun = false;
    SaveConfig();
}

defaultproperties
{
    MutatorClass=class'MutHexedVOTE'
    bFirstRun=true
}
