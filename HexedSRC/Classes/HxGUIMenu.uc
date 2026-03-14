class HxGUIMenu extends HxGUIFloatingWindow;

struct HxPanelInfo
{
    var class<UT2K4TabPanel> PanelClass;
    var localized string Caption;
    var localized string Hint;
    var bool bInsertFront;
};

var automated GUITabControl t_TabControl;

var protected array<HxPanelInfo> Panels;
var protected int PanelCount;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    t_WindowTitle.DockedTabs = t_TabControl;
    t_WindowTitle.DockAlign = PGA_Top;
    PopulateTabControl();
}

event Opened(GUIComponent Sender)
{
    PopulateTabControl();
    Super.Opened(Sender);
}

function PopulateTabControl()
{
    local int i;

    for (i = PanelCount; i < default.Panels.Length; ++i)
    {
        if (default.Panels[i].bInsertFront)
        {
            t_TabControl.InsertTab(
                0,
                default.Panels[i].Caption,
                string(default.Panels[i].PanelClass),
                ,
                default.Panels[i].Hint,
                true);
        }
        else
        {
            t_TabControl.AddTab(
                default.Panels[i].Caption,
                string(default.Panels[i].PanelClass),
                ,
                default.Panels[i].Hint);
        }
    }
    PanelCount = default.Panels.Length;
}

static function AddPanel(class<UT2K4TabPanel> PanelClass,
                         string Caption,
                         string Hint,
                         optional bool bInsertFront)
{
    local HxPanelInfo Panel;

    Panel.PanelClass = PanelClass;
    Panel.Caption = Caption;
    Panel.Hint = Hint;
    Panel.bInsertFront = bInsertFront;
    default.Panels[default.Panels.Length] = Panel;
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

    WindowName="HexedUT"
    PanelCount=0
}
