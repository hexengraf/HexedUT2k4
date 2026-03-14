class HxGUIHeader extends GUIHeader;

var automated HxGUIFramedImage fi_Background;
var automated GUIButton b_Close;

function ResolutionChanged(int ResX, int ResY)
{
    Super.ResolutionChanged(ResX, ResY);
    bInit = true;
}

function bool InternalOnPreDraw(Canvas C)
{
    local float Height;

    if (bInit)
    {
        class'HxGUIStyles'.static.GetFontSize(Self, C,,, Height);
        Height = FMax(Height * 1.2, C.ClipY * 0.022);
        WinHeight = RelativeHeight(Height);
        b_Close.WinTop = Round(0.003 * C.ClipY);
        b_Close.WinHeight = (Height - 2 * b_Close.WinTop) / Height;
        b_Close.WinWidth = b_Close.RelativeWidth(Height - 2 * b_Close.WinTop);
        b_Close.WinLeft = 1.0 - b_Close.WinWidth - b_Close.RelativeWidth(b_Close.WinTop);
        b_Close.WinTop = b_Close.WinTop / Height;
        bInit = false;
        return true;
    }
    return false;
}

defaultproperties
{
    Begin Object Class=GUIButton Name=CloseButton
        WinTop=0
        RenderWeight=1
        bNeverFocus=true
        bRepeatClick=False
        bAutoShrink=False
        StyleName="HxCloseButton"
        bScaleToParent=true
        bBoundToParent=true
    End Object
    b_Close=CloseButton

    WinWidth=1.0
    RenderWeight=0.100000
    bStandardized=false
    bUseTextHeight=False
    bAcceptsInput=True
    bNeverFocus=false
    ScalingType=SCALE_X
    StyleName="HxMenuHeader"
    bScaleToParent=true
    bBoundToParent=true
    OnPreDraw=InternalOnPreDraw
}
