class HxGUIHeader extends GUIHeader;

const MIN_HEIGHT = 0.025;
const FONT_SPACING = 1.2;

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
        Height = GetDesiredHeight(C);
        WinHeight = RelativeHeight(Height);
        b_Close.WinTop = FMax(1.0, 0.003 * C.ClipY);
        b_Close.WinHeight = (Height - 2 * b_Close.WinTop) / Height;
        b_Close.WinWidth = b_Close.RelativeWidth(Height - 2 * b_Close.WinTop);
        b_Close.WinLeft = 1.0 - b_Close.WinWidth - b_Close.RelativeWidth(b_Close.WinTop, true);
        b_Close.WinTop = b_Close.WinTop / Height;
        bInit = false;
        return true;
    }
    return false;
}

function float GetDesiredHeight(Canvas C)
{
    local float Height;

    class'HxGUIStyles'.static.GetFontSize(Self, C,,, Height);
    return FMax(Height * FONT_SPACING, C.ClipY * MIN_HEIGHT);
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
