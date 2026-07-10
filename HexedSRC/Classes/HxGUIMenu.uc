class HxGUIMenu extends HxGUIFloatingWindow;

var automated GUITabControl t_TabControl;

var HxClientManager ClientManager;
var private array<HxGUIMenuPanel> Panels;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    t_WindowTitle.DockedTabs = t_TabControl;
    t_WindowTitle.DockAlign = PGA_Top;
    ForEach PlayerOwner().DynamicActors(class'HxClientManager', ClientManager) break;
    AddPanel(class'HxGUIMenuGeneralPanel', 0);
}

event Opened(GUIComponent Sender)
{
    UpdateTabControl();
    Super.Opened(Sender);
}

function UpdateTabControl()
{
    local int i;

    for (i = 0; i < ClientManager.CRIs.Length; ++i)
    {
        if (ClientManager.CRIs[i] == None)
        {
            PurgePanels(ClientManager.CRIClasses[i]);
        }
        else
        {
            UpdatePanels(ClientManager.CRIs[i]);
        }
    }
}

function UpdatePanels(HxClientReplicationInfo CRI)
{
    local int i;

    for (i = 0; i < CRI.PanelClasses.Length; ++i)
    {
        if (!CRI.PanelClasses[i].static.CheckDependencies(CRI))
        {
            RemovePanel(FindPanel(CRI.PanelClasses[i]));
        }
        else if (FindPanel(CRI.PanelClasses[i]) < 0)
        {
            AddPanel(CRI.PanelClasses[i], (CRI.Order << 8 | i));
        }
    }
}

function PurgePanels(class<HxClientReplicationInfo> CRIClass)
{
    local int i;

    for (i = 0; i < CRIClass.default.PanelClasses.Length; ++i)
    {
        RemovePanel(FindPanel(CRIClass.default.PanelClasses[i]));
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

function TabControlOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (HxGUIMenuPanel(NewComp) != None)
    {
        HxGUIMenuPanel(NewComp).ClientManager = ClientManager;
    }
}

function Refresh()
{
    local int i;

    for (i = 0; i < Panels.Length; ++i)
    {
        Panels[i].Refresh();
    }
}

function LevelChanged()
{
    ClientManager = None;
    Panels.Length = 0;
    Super.LevelChanged();
}

defaultproperties
{
    Begin Object class=GUITabControl Name=TabControl
        WinWidth=0.97
        WinHeight=0.05
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
}
