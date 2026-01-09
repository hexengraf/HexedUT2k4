class HxGUIScrollTextBox extends GUIScrollTextBox;

enum EHxLayoutState
{
    HX_LAYOUT_Outdated,
    HX_LAYOUT_Unevaluated,
    HX_LAYOUT_Updated,
};

var automated GUIImage i_Background;

var float HorizontalPadding;
var float VerticalPadding;
var float ScrollBarWidth;
var Color BackgroundColor;
var bool bCenter;

var EHxLayoutState LayoutState;
var bool bPaddingApplied;

var int SavedOffsets[4];

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyScrollBar.WinWidth = ScrollBarWidth;
    i_Background.ImageColor = BackgroundColor;
}

function bool InternalOnPreDraw(Canvas C)
{
    if (!bPaddingApplied)
    {
        ApplyPadding();
    }
    if (bCenter)
    {
        CenterText();
    }
    return false;
}

function ApplyPadding()
{
    i_Background.WinLeft = ActualLeft();
    i_Background.WinTop = ActualTop();
    i_Background.WinWidth = ActualWidth();
    i_Background.WinHeight = ActualHeight();
    SetPaddedPosition(
        i_Background.WinLeft, i_Background.WinTop, i_Background.WinWidth, i_Background.WinHeight);
    bPaddingApplied = true;
}

function SetPaddedPosition(float Left, float Top, float Width, float Height)
{
    local float BufferWidth;
    local float XOffset;
    local float YOffset;

    BufferWidth = MyScrollBar.ActualWidth();
    XOffset = HorizontalPadding * Width;
    if (!bCenter)
    {
        Width -= BufferWidth / 2;
    }
    else
    {
        XOffset += BufferWidth;
    }
    YOffset = VerticalPadding * Height;
    SetPosition(Left + XOffset, Top + YOffset, Width - (2 * XOffset), Height - (2 * YOffset), true);
}

function CenterText()
{
    local float MaxHeight;
    local float ContentHeight;

    switch (LayoutState)
    {
        case HX_LAYOUT_Outdated:
            LayoutState = HX_LAYOUT_Unevaluated;
            SetPaddedPosition(
                i_Background.ActualLeft(),
                i_Background.ActualTop(),
                i_Background.ActualWidth(),
                i_Background.ActualHeight());
            break;
        case HX_LAYOUT_Unevaluated:
            if (MyScrollText.ItemCount > 0)
            {
                MaxHeight = ActualHeight();
                ContentHeight = MyScrollText.ItemCount * MyScrollText.ItemHeight;
                if (ContentHeight > MaxHeight)
                {
                    SetPosition(
                        ActualLeft() + (MyScrollBar.ActualWidth() / 2),
                        ActualTop(),
                        ActualWidth(),
                        ActualHeight(),
                        true);
                }
                else
                {
                    SetPosition(
                        ActualLeft(),
                        ActualTop() + (MaxHeight - ContentHeight) / 2,
                        ActualWidth(),
                        ContentHeight,
                        true);
                }
            }
            LayoutState = HX_LAYOUT_Updated;
            break;
        case HX_LAYOUT_Updated:
            break;
    }
}

function SetContent(string NewContent, optional string sep)
{
    LayoutState = HX_LAYOUT_Outdated;
    Super.SetContent(NewContent, sep);
}

defaultproperties
{
     Begin Object Class=GUIImage Name=Background
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        Image=Material'2K4Menus.NewControls.NewFooter'
        Y1=2
        ImageStyle=ISTY_Stretched
        RenderWeight=0.1
    End Object
    i_Background=Background

    Begin Object Class=HxGUIVertScrollBar Name=NewTheScrollbar
        bOutside=true
        bScaleToParent=true
    End Object
    MyScrollBar=NewTheScrollbar

    bRequiresStyle=true
    StyleName="HxSimpleList"
    HorizontalPadding=0.02
    VerticalPadding=0.05
    ScrollBarWidth=0.025
    BackgroundColor=(R=255,G=255,B=255,A=192)
    bCenter=false
    OnPreDraw=InternalOnPreDraw
}
