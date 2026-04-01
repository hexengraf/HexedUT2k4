class HxClientManager extends Actor;

var array<HxClientReplicationInfo> CRIs;

var const private class<HxGUIFloatingWindow> HexedMenuClass;
var const private class<HxGUITheme> HexedThemeClass;

var private PlayerController PC;
var private GUIController GC;
var private bool bInitialized;

simulated event Tick(float DeltaTime)
{
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (!bInitialized)
        {
            bInitialized = InitializePlayerController() && InitializeGUIController();
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
        HexedThemeClass.static.RegisterStyles(GC);
        return true;
    }
    return false;
}

simulated function NotifyServerInfoChanged(HxClientReplicationInfo Sender)
{
    if (Level.NetMode == NM_Client)
    {
        RefreshHexedMenu();
    }
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
    if (GC != None)
    {
        if (HxGUIMenu(GC.ActivePage) != None)
        {
            if (bUpdateTabControl)
            {
                HxGUIMenu(GC.ActivePage).UpdateTabControl();
            }
            HxGUIMenu(GC.ActivePage).Refresh();
        }
        else if (HxGUIServerMenu(GC.ActivePage) != None)
        {
            HxGUIServerMenu(GC.ActivePage).Refresh();
        }
    }
}

simulated function RegisterCRI(HxClientReplicationInfo CRI)
{
    local int i;

    for (i = 0; i < CRIs.Length; ++i)
    {
        if (CRI.Order < CRIs[i].Order)
        {
            break;
        }
    }
    CRIs.Insert(i, 1);
    CRIs[i] = CRI;
    RefreshHexedMenu();
}

simulated function HxClientReplicationInfo Find(class<HxClientReplicationInfo> CRIClass)
{
    local int i;

    for (i = 0; i < CRIs.Length; ++i)
    {
        if (CRIs[i].Class == CRIClass)
        {
            return CRIs[i];
        }
    }
    return None;
}

static function HxClientManager Register(HxClientReplicationInfo CRI)
{
    local HxClientManager Manager;

    ForEach CRI.DynamicActors(class'HxClientManager', Manager) break;
    if (Manager == None)
    {
        Manager = CRI.Spawn(class'HxClientManager', CRI.Level);
    }
    Manager.RegisterCRI(CRI);
    return Manager;
}

defaultproperties
{
    RemoteRole=ROLE_None
    bHidden=True
    HexedMenuClass=class'HxGUIMenu'
    HexedThemeClass=class'HxGUIThemeDefault'
}
