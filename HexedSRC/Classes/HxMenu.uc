class HxMenu extends FloatingWindow;

struct HxPanelInfo
{
    var class<UT2K4TabPanel> PanelClass;
    var localized string Caption;
    var localized string Hint;
    var bool bInsertFront;
};

var array<HxPanelInfo> Panels;
var automated GUITabControl TabControl;
var int PanelCount;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    t_WindowTitle.bUseTextHeight = true;
    t_WindowTitle.FontScale = FNS_Small;
    t_WindowTitle.DockedTabs = TabControl;
    t_WindowTitle.DockAlign = PGA_Top;
    i_FrameBG.ImageColor.A = 225;
    AdjustWindowSize(Controller.ResX, Controller.ResY);
    PopulateTabControl();
}

event Opened(GUIComponent Sender)
{
    PopulateTabControl();
    Super.Opened(Sender);
}

function bool FloatingPreDraw(Canvas C)
{
    if (bInit)
    {
        AdjustWindowSize(C.ClipX, C.ClipY);
    }
    return Super.FloatingPreDraw(C);
}

function AdjustWindowSize(coerce float X, coerce float Y)
{
    local float Coefficient;

    Coefficient = (4.0 / 3.0) / (X / Y);
    WinWidth = default.WinWidth * Coefficient;
    WinLeft = default.WinLeft + ((default.WinWidth - WinWidth) / 2);
}

event bool NotifyLevelChange()
{
    bPersistent = false;
    LevelChanged();
    return true;
}

function PopulateTabControl()
{
    local int i;

    for (i = PanelCount; i < default.Panels.Length; ++i)
    {
        if (default.Panels[i].bInsertFront)
        {
            TabControl.InsertTab(
                0,
                default.Panels[i].Caption,
                string(default.Panels[i].PanelClass),
                ,
                default.Panels[i].Hint,
                true);
        }
        else
        {
            TabControl.AddTab(
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
    Begin Object class=GUITabControl Name=MidGameMenuTC
        WinWidth=0.97
        WinHeight=0.0465
        WinLeft=0.01500
        WinTop=0.060215
        TabHeight=0.0375
        bAcceptsInput=true
        bDockPanels=true
        bScaleToParent=true
        bFillSpace=true
        TabOrder=0
        BackgroundStyleName="TabBackground"
    End Object
    TabControl=MidGameMenuTC

    WindowName="HexedUT"
    bRenderWorld=true
    bRequire640x480=true
    bAllowedAsLast=true
    bScaleToParent=true
    WinWidth=0.90
    WinHeight=0.85
    WinLeft=0.05
    WinTop=0.05
    bResizeWidthAllowed=false
    bResizeHeightAllowed=false
    bMoveAllowed=false
    bPersistent=true
    BackgroundColor=(R=64,G=64,B=64,A=225)
    PanelCount=0
}
