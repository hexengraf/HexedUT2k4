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
var private bool bIsFirstRun;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (bFirstRun)
    {
        bShowFirstRunNotification = true;
        bIsFirstRun = true;
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

simulated function NotifyServerPropertyChanged(HxClientReplicationInfo Sender)
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
            Warn(Name$": Repeated attempt to register "$CRIClasses[i]$"! Saturated connection?");
            if (CRIs[i] != None)
            {
                if (CRIs[i] == CRI)
                {
                    return false;
                }
                Warn(Name$": Two "$CRIClasses[i]$" instances found!");
                Warn(Name$": Previous "$CRIClasses[i]$" instance: "$CRIs[i].Name);
                Warn(Name$": New "$CRIClasses[i]$" instance: "$CRI.Name);
                CRIs[i] = None;
            }
            else
            {
                Warn(Name$": Local "$CRIClasses[i]$" reference is None on re-register!");
            }
            // One refresh with None to purge stale panels...
            RefreshConfigurationMenu();
            CRIs[i] = CRI;
            // ...and one refresh with the new instance to add the panels back.
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

simulated function int EncodeTag(int CRINumber, int Index, optional int ConfigNumber)
{
    return ((CRINumber & 0x3ff) << 20) | ((ConfigNumber & 0x3ff) << 10) | (Index & 0x3ff);
}

simulated function int DecodeServerTag(int Tag,
                                       optional out HxClientReplicationInfo CRI,
                                       optional out int Index)
{
    local int CRINumber;

    if (Tag >= 0)
    {
        Index = Tag & 0x3ff;
        CRINumber = (Tag >> 20) & 0x3ff;
        CRI = CRIs[CRINumber];
        if (CRI != None)
        {
            return CRINumber;
        }
    }
    return -1;
}

simulated function bool DecodeUserTag(int Tag, out HxConfig Config, out int Index)
{
    local int CRINumber;
    local int ConfigNumber;

    if (Tag >= 0)
    {
        Index = Tag & 0x3ff;
        ConfigNumber = (Tag >> 10) & 0x3ff;
        CRINumber = (Tag >> 20) & 0x3ff;
        if (CRIs[CRINumber] != None)
        {
            Config = CRIs[CRINumber].Configs[ConfigNumber];
            return Config != None;
        }
    }
    return false;
}

simulated function bool IsFirstRun()
{
    return bIsFirstRun;
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
