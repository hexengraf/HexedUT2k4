class HxClientManager extends Actor;

var array<HxClientReplicationInfo> CRIs;

var const private class<HxGUIFloatingWindow> HexedMenuClass;
var const private array<class<GUIStyles> > CustomStyleClasses;

var private PlayerController PC;
var private GUIController GC;
var private string CustomMapVoteMenu;
var private bool bReplaceMapVoteMenu;
var private bool bInitialized;

simulated event Tick(float DeltaTime)
{
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
        RegisterStyles();
        SetCustomMapVoteMenu(CustomMapVoteMenu);
        return true;
    }
    return false;
}

simulated function SetCustomMapVoteMenu(string MapVoteMenu, optional bool bDisable)
{
    if (bDisable && CustomMapVoteMenu ~= MapVoteMenu)
    {
        CustomMapVoteMenu = "";
    }
    else
    {
        CustomMapVoteMenu = MapVoteMenu;
    }
    if (GC != None)
    {
        bReplaceMapVoteMenu = CustomMapVoteMenu != ""
            && !GC.SetPropertyText("CustomMapVotingMenu", CustomMapVoteMenu);
    }
    else
    {
        bReplaceMapVoteMenu = false;
    }
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

simulated function NotifyServerInfoChanged(HxClientReplicationInfo Sender)
{
    RefreshHexedMenu();
}

simulated function OpenHexedMenu(HxClientReplicationInfo Sender)
{
    if (bInitialized)
    {
        PC.ClientOpenMenu(string(HexedMenuClass));
    }
}

simulated function RefreshHexedMenu(optional bool bUpdateTabControl)
{
    if (GC != None && GC.ActivePage != None && GC.ActivePage.IsA('HxGUIMenu'))
    {
        if (bUpdateTabControl)
        {
            HxGUIMenu(GC.ActivePage).UpdateTabControl();
        }
        HxGUIMenu(GC.ActivePage).Refresh();
    }
}

simulated function RegisterStyles()
{
    local int i;

    for (i = 0; i < CustomStyleClasses.Length; ++i)
    {
        GC.RegisterStyle(CustomStyleClasses[i]);
    }
}

static function HxClientManager Register(HxClientReplicationInfo CRI)
{
    local HxClientManager Manager;

    ForEach CRI.DynamicActors(class'HxClientManager', Manager) break;
    if (Manager == None)
    {
        Manager = CRI.Spawn(class'HxClientManager', CRI.Level);
    }
    Manager.CRIs[Manager.CRIs.Length] = CRI;
    Manager.RefreshHexedMenu();
    return Manager;
}

defaultproperties
{
	RemoteRole=ROLE_None

    HexedMenuClass=class'HxGUIMenu'
    CustomStyleClasses(0)=class'HxSTYSmallList'
    CustomStyleClasses(1)=class'HxSTYSmallListSelection'
    CustomStyleClasses(2)=class'HxSTYSmallText'
    CustomStyleClasses(3)=class'HxSTYScrollGrip'
    CustomStyleClasses(4)=class'HxSTYScrollZone'
    CustomStyleClasses(5)=class'HxSTYEditBox'
    CustomStyleClasses(6)=class'HxSTYListHeader'
    CustomStyleClasses(7)=class'HxSTYSquareButton'
    CustomStyleClasses(8)=class'HxSTYCloseButton'
    CustomStyleClasses(9)=class'HxSTYMenuHeader'
    CustomStyleClasses(10)=class'HxSTYMenuBackground'
    CustomStyleClasses(11)=class'HxSTYOptionList'
}
