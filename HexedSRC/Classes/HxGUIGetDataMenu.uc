class HxGUIGetDataMenu extends UT2K4GetDataMenu;

var automated HxGUIBackground b_Background;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    AdjustWindowSize(Controller.ResX, Controller.ResY);
}

function bool InternalOnPreDraw(Canvas C)
{
    if (bInit)
    {
        AdjustWindowSize(C.ClipX, C.ClipY);
        bInit = false;
    }
    return Super(PopupPageBase).InternalOnPreDraw(C);
}

function AdjustWindowSize(coerce float X, coerce float Y)
{
    WinWidth = default.WinWidth * ((4.0 / 3.0) / (X / Y));
    WinLeft = default.WinLeft + ((default.WinWidth - WinWidth) / 2);
}

event ResolutionChanged(int ResX, int ResY)
{
    bInit = true;
    Super.ResolutionChanged(ResX, ResY);
}

defaultproperties
{
    Begin Object Class=HxGUIBackground Name=HxBackground
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        RenderWeight=0.000001
        StyleName="HxPopupBackground"
        bScaleToParent=true
        bBoundToParent=true
    End Object
    b_Background=HxBackground
    i_FrameBG=None

    Begin Object Class=GUIButton Name=NewOkButton
        Caption="Ok"
        WinLeft=0.035
        WinTop=0.675
        WinWidth=0.35
        StandardHeight=0.0325
        bStandardized=true
        StyleName="HxSquareButton"
        bBoundToParent=true
        bScaleToParent=true
        OnClick=UT2K4GenericMessageBox.InternalOnClick
        OnKeyEvent=NewOkButton.InternalOnKeyEvent
    End Object
    b_OK=NewOkButton

    Begin Object Class=GUIButton Name=NewCancelButton
        Caption="Cancel"
        Hint="Close this menu, discarding changes."
        WinLeft=0.615
        WinTop=0.675
        WinWidth=0.35
        StandardHeight=0.0325
        bStandardized=true
        StyleName="HxSquareButton"
        bBoundToParent=true
        bScaleToParent=true
        OnClick=UT2K4GetDataMenu.InternalOnClick
        OnKeyEvent=NewCancelButton.InternalOnKeyEvent
    End Object
    b_Cancel=NewCancelButton

    Begin Object Class=moEditBox Name=NewData
        WinLeft=0.035
        WinTop=0.385
        winWidth=0.93
        CaptionWidth=0.15
        bAutoSizeCaption=true
        LabelStyleName="HxEditBox"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=0
        OnCreateComponent=NewData.InternalOnCreateComponent
    End Object
    ed_Data=NewData

    Begin Object Class=GUILabel Name=NewDialogText
        WinLeft=0
        WinTop=0.075
        WinWidth=1
        StandardHeight=0.04
        bStandardized=true
        StyleName="HxPopupHeader"
        TextAlign=TXTA_Center
        FontScale=FNS_Large
        bBoundToParent=true
        bScaleToParent=true
    End Object
    l_Text=NewDialogText

    WinLeft=0.275
    WinTop=0.4125
    WinWidth=0.45
    WinHeight=0.175
}
