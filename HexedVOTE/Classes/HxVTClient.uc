class HxVTClient extends HxClientReplicationInfo;

var private PlayerController PC;
var private GUIController GC;
var private string CustomMapVoteMenu;
var private bool bReplaceMapVoteMenu;
var private bool bInitialized;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    CustomMapVoteMenu = string(class'HxMapVotingPage');
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
    class'HxMapVotingPage'.default.VoteListBG = GetServerProperty("VoteListBG");
    class'HxMapVotingPage'.default.MapListBG = GetServerProperty("MapListBG");
    class'HxMapVotingPage'.default.PreviewBG = GetServerProperty("PreviewBG");
    class'HxMapVotingPage'.default.ChatBoxBG = GetServerProperty("ChatBoxBG");
}

simulated function ServerInfoReady()
{
    UpdateMapVoteMenuBackgrounds();
}

simulated function ServerPropertyChanged(int Index, string OldValue)
{
    UpdateMapVoteMenuBackgrounds();
}

defaultproperties
{
    MutatorClass=class'MutHexedVOTE'
}
