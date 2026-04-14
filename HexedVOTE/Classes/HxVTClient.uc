class HxVTClient extends HxClientReplicationInfo;

const MIN_VERSION = 6;

var config bool bFirstRun;

var HxFavorites MapFavorites;

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
        MapFavorites = new(None, "Maps") class'HxFavorites';
        if (bFirstRun)
        {
            RecoverConfigs();
        }
    }
}

simulated event Destroyed()
{
    MapFavorites = None;
    Super.Destroyed();
}

simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (!bInitialized)
        {
            bInitialized = InitializePlayerController() && InitializeGUIController();
        }
        else if (bReplaceMapVoteMenu)
        {
            TryReplaceMapVoteMenu();
        }
    }
}

simulated function bool InitializePlayerController()
{
    if (PC == None)
    {
        PC = Level.GetLocalPlayerController();
        return PC != None;
    }
    return true;
}

simulated function bool InitializeGUIController()
{
    if (PC.Player != None)
    {
        GC = GUIController(PC.Player.GUIController);
        bReplaceMapVoteMenu = !GC.SetPropertyText("CustomMapVotingMenu", CustomMapVoteMenu);
        return true;
    }
    return false;
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
        MapFavorites.Save(NewObject.Maps[i].Map, NewObject.Maps[i].Tag, true);
    }
    MapFavorites.SaveConfig();
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
