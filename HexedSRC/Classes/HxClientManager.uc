class HxClientManager extends Actor
    config(User);

var config bool bFirstRun;
var config string MenuKeybind;

var array<HxClientReplicationInfo> CRIs;

var const private class<HxGUIFloatingWindow> MenuClass;
var const private class<HxGUITheme> ThemeClass;

var private PlayerController PC;
var private GUIController GC;
var private bool bInitialized;
var private bool bShowFirstRunNotification;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (bFirstRun)
    {
        bShowFirstRunNotification = true;
        bFirstRun = false;
        SaveConfig();
    }
}

simulated event Tick(float DeltaTime)
{
    if (!bInitialized)
    {
        bInitialized = InitializeClient();
    }
}

simulated function bool InitializeClient()
{
    if (PC == None)
    {
        PC = Level.GetLocalPlayerController();
    }
    if (PC != None && PC.Player != None)
    {
        GC = GUIController(PC.Player.GUIController);
        ThemeClass.static.RegisterStyles(GC);
        ValidateMenuKeybind();
        if (bShowFirstRunNotification)
        {
            ShowFirstTimeNotification(MenuKeybind);
        }
    }
    return PC != None && GC != None;
}

simulated function NotifyServerInfoChanged(HxClientReplicationInfo Sender)
{
    if (Level.NetMode == NM_Client)
    {
        RefreshHexedMenu();
    }
}

simulated function OpenConfigurationMenu(optional HxClientReplicationInfo Sender)
{
    if (bInitialized)
    {
        PC.ClientOpenMenu(string(MenuClass));
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

simulated function ShowFirstTimeNotification(string KeyName)
{
    local string MenuKey;
    local string MenuKeyName;

    if (KeyName != "")
    {
        MenuKey = PC.ConsoleCommand("KEYNUMBER"@KeyName);
        MenuKeyName = PC.ConsoleCommand("LOCALIZEDKEYNAME"@MenuKey);
    }
    if (GC.OpenMenu(string(class'HxGUIFirstRunNotification'), MenuKey, MenuKeyName))
    {
        HxGUIFirstRunNotification(GC.ActivePage).ClientManager = Self;
    }
    bShowFirstRunNotification = false;
}

simulated private function ValidateMenuKeybind()
{
    local string KeyName;
    local int i;

    if (MenuKeybind == "" || (!IsMenuKeybind(MenuKeybind) && !TrySetKeybind(MenuKeybind)))
    {
        MenuKeybind = "";
        for (i = 0; i < 255; ++i)
        {
            KeyName = PC.ConsoleCommand("KEYNAME"@i);
            if (IsMenuKeybind(KeyName))
            {
                MenuKeybind = KeyName;
                break;
            }
        }
        SaveConfig();
    }
}

simulated private function bool IsMenuKeybind(string KeyName)
{
    return InStr(Caps(PC.ConsoleCommand("KEYBINDING"@KeyName)), "HEXEDMENU") > -1;
}

simulated private function bool TrySetKeybind(string Keybind)
{
    if (PC.ConsoleCommand("KEYBINDING"@Keybind) == "")
    {
        PC.ConsoleCommand("SET INPUT"@Keybind@"mutate HexedMenu");
        return true;
    }
    return false;
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
    bHidden=true
    MenuClass=class'HxGUIMenu'
    ThemeClass=class'HxGUIThemeDefault'

    bFirstRun=true
    MenuKeybind="H"
}
