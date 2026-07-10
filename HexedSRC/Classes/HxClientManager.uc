class HxClientManager extends Actor
    config(User);

var config bool bFirstRun;
var config string MenuKeybind;

var array<HxClientReplicationInfo> CRIs;
var array<class<HxClientReplicationInfo> > CRIClasses;

var const private class<HxGUIFloatingWindow> MenuClass;
var const private class<HxGUITheme> ThemeClass;

var private PlayerController PC;
var private GUIController GC;
var private array<HxConfig> ConfigPool;
var private array<Object> ObjectPool;
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
        RefreshConfigurationMenu();
    }
}

simulated function OpenConfigurationMenu(optional HxClientReplicationInfo Sender)
{
    if (bInitialized)
    {
        PC.ClientOpenMenu(string(MenuClass));
    }
}

simulated function RefreshConfigurationMenu()
{
    if (GC != None)
    {
        if (HxGUIMenu(GC.ActivePage) != None)
        {
            HxGUIMenu(GC.ActivePage).UpdateTabControl();
            HxGUIMenu(GC.ActivePage).Refresh();
        }
        else if (HxGUIServerMenu(GC.ActivePage) != None)
        {
            HxGUIServerMenu(GC.ActivePage).Refresh();
        }
    }
}

simulated function bool Register(HxClientReplicationInfo CRI)
{
    local int i;

    for (i = 0; i < CRIs.Length; ++i)
    {
        if (CRIClasses[i] == CRI.Class)
        {
            Warn(Name$": Repeated attempt to register"$CRIClasses[i]$"! Severe packet loss?");
            if (CRIs[i] == None)
            {
                Warn(Name$": Local "$CRIClasses[i]$" reference is None on re-register!");
                // One refresh with None to purge stale panels...
                RefreshConfigurationMenu();
            }
            else if (CRIs[i] != CRI)
            {
                Warn(Name$": Two "$CRIClasses[i]$" references found, this should never happen!");
            }
            CRIs[i] = CRI;
            // ...and one refresh with fixed reference to add the panels back.
            RefreshConfigurationMenu();
            return false;
        }
    }
    for (i = 0; i < CRIs.Length; ++i)
    {
        if (CRI.Order < CRIs[i].Order)
        {
            break;
        }
    }
    CRIs.Insert(i, 1);
    CRIClasses.Insert(i, 1);
    CRIs[i] = CRI;
    CRIClasses[i] = CRI.Class;
    RefreshConfigurationMenu();
    return true;
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

simulated function HxConfig LoadConfig(class<HxConfig> ConfigClass)
{
    local int i;

    for (i = 0; i < ConfigPool.Length; ++i)
    {
        if (ConfigPool[i].Class == ConfigClass)
        {
            return ConfigPool[i];
        }
    }
    ConfigPool[i] = ConfigClass.static.Load();
    return ConfigPool[i];
}

simulated function Object LoadObject(class<Object> ObjectClass, optional string Name)
{
    local int i;

    for (i = 0; i < ObjectPool.Length; ++i)
    {
        if (ObjectPool[i].Class == ObjectClass)
        {
            if (Name == "" || Name ~= string(ObjectPool[i].Name))
            {
                return ObjectPool[i];
            }
        }
    }
    ObjectPool[i] = new (None, Name) ObjectClass;
    return ObjectPool[i];
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

simulated function int EncodeTag(int CRIIndex, int PropertyIndex, optional int ConfigIndex)
{
    return ((CRIIndex & 0x3ff) << 20) | ((ConfigIndex & 0x3ff) << 10) | (PropertyIndex & 0x3ff);
}

simulated function bool DecodeTag(int Tag,
                                  out int CRIIndex,
                                  out int PropertyIndex,
                                  optional out int ConfigIndex)
{
    if (Tag >= 0)
    {
        PropertyIndex = Tag & 0x3ff;
        ConfigIndex = (Tag >> 10) & 0x3ff;
        CRIIndex = (Tag >> 20) & 0x3ff;
        return CRIs[CRIIndex] != None;
    }
    return false;
}

simulated event Destroyed()
{
    CRIs.Remove(0, CRIs.Length);
    CRIClasses.Remove(0, CRIClasses.Length);
    ConfigPool.Remove(0, ConfigPool.Length);
    ObjectPool.Remove(0, ObjectPool.Length);
    Super.Destroyed();
}

static function HxClientManager Get(HxClientReplicationInfo Requester)
{
    local HxClientManager Manager;

    ForEach Requester.DynamicActors(class'HxClientManager', Manager) break;
    if (Manager == None)
    {
        Manager = Requester.Spawn(class'HxClientManager');
    }
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
