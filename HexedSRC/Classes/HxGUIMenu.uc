class HxGUIMenu extends HxGUIFloatingWindow;

var automated GUITabControl t_TabControl;

var HxClientManager ClientManager;
var private array<HxClientReplicationInfo> CRIs;
var private array<HxGUIMenuPanel> PanelClasses;
var private array<GUITabPanel> Panels;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    t_WindowTitle.DockedTabs = t_TabControl;
    t_WindowTitle.DockAlign = PGA_Top;
    ForEach PlayerOwner().DynamicActors(class'HxClientManager', ClientManager) break;
}

event Opened(GUIComponent Sender)
{
    UpdateTabControl();
    Super.Opened(Sender);
}

function UpdateTabControl()
{
    local int i;

    for (i = CRIs.Length; i < ClientManager.CRIs.Length; ++i)
    {
        CRIs[i] = ClientManager.CRIs[i];
        AddPanels(CRIs[i]);
    }
}

function AddPanels(HxClientReplicationInfo CRI)
{
    local int Position;
    local int i;

    for (i = 0; i < CRI.PanelClasses.Length; ++i)
    {
        if (CRI.PanelClasses[i].default.bInsertFront)
        {
            Position = 0;
        }
        else
        {
            Position = Panels.Length;
        }
        Panels.Insert(Position, 1);
        Panels[Position] = t_TabControl.InsertTab(
            Position,
            CRI.PanelClasses[i].default.PanelCaption,
            string(CRI.PanelClasses[i]),,
            CRI.PanelClasses[i].default.PanelHint,
            true);
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
    End Object
    t_TabControl=TabControl

    WindowName="HexedMenu"
}
