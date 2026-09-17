class HxGUIMenu extends HxGUIFloatingWindow;

var automated GUITabControl t_TabControl;

var private HxClientManager ClientManager;
var private array<HxGUIMenuPanel> Panels;
var private byte MenuKey;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    local PlayerController PC;

    Super.InitComponent(MyController, MyComponent);
    t_WindowTitle.DockedTabs = t_TabControl;
    t_WindowTitle.DockAlign = PGA_Top;
    PC = PlayerOwner();
    ForEach PC.DynamicActors(class'HxClientManager', ClientManager) break;
    MenuKey = byte(PC.ConsoleCommand("KEYNUMBER"@ClientManager.MenuKeybind));
    AddPanel(class'HxGUIMenuGeneralPanel', 0);
}

event Opened(GUIComponent Sender)
{
    Refresh();
    Super.Opened(Sender);
}

function Refresh()
{
    local int i;

    for (i = 0; i < ClientManager.CRIs.Length; ++i)
    {
        UpdatePanels(ClientManager.CRIs[i]);
    }
    for (i = 0; i < Panels.Length; ++i)
    {
        Panels[i].Refresh();
    }
}

function UpdatePanels(HxClientReplicationInfo CRI)
{
    local class<HxMutator> MC;
    local int i;

    MC = CRI.MutatorClass;
    for (i = 0; i < MC.default.PanelClasses.Length; ++i)
    {
        if (!MC.default.PanelClasses[i].static.CheckDependencies(CRI))
        {
            RemovePanel(FindPanel(MC.default.PanelClasses[i]));
        }
        else if (FindPanel(MC.default.PanelClasses[i]) < 0)
        {
            AddPanel(MC.default.PanelClasses[i], (MC.default.UIPriority << 8 | i));
        }
    }
}

function PurgePanels(class<HxMutator> MC)
{
    local int i;

    for (i = 0; i < MC.default.PanelClasses.Length; ++i)
    {
        RemovePanel(FindPanel(MC.default.PanelClasses[i]));
    }
}

function AddPanel(class<HxGUIMenuPanel> PanelClass, int Order)
{
    local int Position;
    local int i;

    Position = Panels.Length;
    for (i = 1; i < Panels.Length; ++i)
    {
        if (Order < Panels[i].Order)
        {
            Position = i;
            break;
        }
    }
    Panels.Insert(Position, 1);
    Panels[Position] = HxGUIMenuPanel(t_TabControl.InsertTab(
        Position,
        PanelClass.default.PanelCaption,
        string(PanelClass),,
        PanelClass.default.PanelHint));
    Panels[Position].Order = Order;
}

function RemovePanel(int Index)
{
    if (Index > -1 && Index < Panels.Length)
    {
        t_TabControl.RemoveTab(Panels[Index].PanelCaption);
        Panels.Remove(Index, 1);
    }
}

function int FindPanel(class<HxGUIMenuPanel> PanelClass)
{
    local int i;

    for (i = 1; i < Panels.Length; ++i)
    {
        if (Panels[i].Class == PanelClass)
        {
            return i;
        }
    }
    return -1;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    if (Key == MenuKey && EInputAction(State) == IST_Release
        && (GUIEditBox(Controller.FocusedControl) == None
            || GUIEditBox(Controller.FocusedControl).bReadOnly)
        && (GUIFloatEdit(Controller.FocusedControl) == None
            || GUIFloatEdit(Controller.FocusedControl).bReadOnly)
        && (GUINumericEdit(Controller.FocusedControl) == None
            || GUINumericEdit(Controller.FocusedControl).bReadOnly))
    {
        Controller.CloseMenu(False);
        return true;
    }
    return false;
}

function TabControlOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (HxGUIMenuPanel(NewComp) != None)
    {
        HxGUIMenuPanel(NewComp).ClientManager = ClientManager;
    }
}

function LevelChanged()
{
    ClientManager = None;
    Panels.Remove(0, Panels.Length);
    Super.LevelChanged();
}

defaultproperties
{
    Begin Object class=GUITabControl Name=TabControl
        WinWidth=0.97
        WinHeight=0.055
        WinLeft=0.015
        TabHeight=0.0375
        bAcceptsInput=true
        bDockPanels=true
        bScaleToParent=true
        bFillSpace=true
        TabOrder=0
        BackgroundStyleName="TabBackground"
        OnCreateComponent=TabControlOnCreateComponent
    End Object
    t_TabControl=TabControl

    WindowName="HexedMenu"
    WinLeft=0.1
    WinTop=0.16
    WinWidth=0.8
    WinHeight=0.68
    OnKeyEvent=InternalOnKeyEvent
}
