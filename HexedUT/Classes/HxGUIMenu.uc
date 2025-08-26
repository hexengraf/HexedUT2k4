class HxGUIMenu extends FloatingWindow;

struct HxGUIPanelInfo
{
	var class<UT2K4TabPanel> PanelClass;
	var localized string Caption;
	var localized string Hint;
};

var array<HxGUIPanelInfo> Panels;
var automated GUITabControl TabControl;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	Super.InitComponent(MyController, MyComponent);
	t_WindowTitle.bUseTextHeight = true;
	t_WindowTitle.FontScale = FNS_Small;
	t_WindowTitle.DockedTabs = TabControl;
	t_WindowTitle.DockAlign = PGA_Top;
	i_FrameBG.ImageColor.A = 225;
	PopulateTabControl();
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

	for (i = 0; i < Panels.Length; ++i)
	{
		TabControl.AddTab(Panels[i].Caption, string(Panels[i].PanelClass),, Panels[i].Hint);
	}
}

static function AddPanel(class<UT2K4TabPanel> PanelClass, string Caption, string Hint)
{
	local HxGUIPanelInfo Panel;

	Panel.PanelClass = PanelClass;
	Panel.Caption = Caption;
	Panel.Hint = Hint;
	default.Panels[default.Panels.Length] = Panel;
}

defaultproperties
{
    Begin Object class=GUITabControl Name=HxGUIMenuTC
		WinWidth=0.97
		WinHeight=0.0425
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
    TabControl=HxGUIMenuTC

	Panels(0)=(PanelClass=class'HxEffectsGUIPanel',Caption="Effects",Hint="Hit Effect Options")

	WindowName="HexedUT"
	bRenderWorld=true
    bRequire640x480=true
    bAllowedAsLast=true
    bScaleToParent=true
	WinWidth=0.50
	WinHeight=0.90
	WinLeft=0.25
	WinTop=0.05
	bResizeWidthAllowed=false
	bResizeHeightAllowed=false
	bMoveAllowed=false
	bPersistent=true
	BackgroundColor=(R=64,G=64,B=64,A=225)
}
