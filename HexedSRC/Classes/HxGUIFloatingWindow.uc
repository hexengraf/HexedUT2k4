class HxGUIFloatingWindow extends FloatingWindow;

var automated GUIBorder b_Background;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super(PopupPageBase).InitComponent(MyController, MyComponent);
    SetupWindowHeader();
    AdjustWindowSize(Controller.ResX, Controller.ResY);
}

function SetupWindowHeader()
{
    t_WindowTitle.SetCaption(WindowName);
    if (bMoveAllowed)
    {
        t_WindowTitle.bAcceptsInput = True;
        t_WindowTitle.MouseCursorIndex = HeaderMouseCursorIndex;
    }
    b_ExitButton = HxGUIHeader(t_WindowTitle).b_Close;
    b_ExitButton.OnClick = XButtonClicked;
    b_ExitButton.FocusInstead = t_WindowTitle;
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
    WinWidth = default.WinWidth * ((4.0 / 3.0) / (X / Y));
    WinLeft = default.WinLeft + ((default.WinWidth - WinWidth) / 2);
}

event bool NotifyLevelChange()
{
    bPersistent = false;
    LevelChanged();
    return true;
}

defaultproperties
{
     Begin Object Class=HxGUIHeader Name=WindowTitleHeader
        OnMousePressed=FloatingWindow.FloatingMousePressed
        OnMouseRelease=FloatingWindow.FloatingMouseRelease
     End Object
     t_WindowTitle=WindowTitleHeader

    Begin Object Class=GUIBorder Name=BackgroundBorder
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        RenderWeight=0.000001
        StyleName="HxMenuBackground"
        bScaleToParent=true
        bBoundToParent=true
    End Object
    b_Background=BackgroundBorder
    i_FrameBG=None

    bRenderWorld=true
    bRequire640x480=true
    bCaptureInput=true
    bAllowedAsLast=true
    bResizeWidthAllowed=false
    bResizeHeightAllowed=false
    bMoveAllowed=false
    bPersistent=true
    bScaleToParent=true
    WinLeft=0.1
    WinTop=0.1
    WinWidth=0.8
    WinHeight=0.75
    InactiveFadeColor=(R=64,G=64,B=64,A=255)
}
