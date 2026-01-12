class HxGUIScrollTextBox extends GUIScrollTextBox;


enum EHxLayoutState
{
    HX_LAYOUT_Outdated,
    HX_LAYOUT_Unevaluated,
    HX_LAYOUT_Updated,
};

struct HxColorReplacement
{
    var Color Match;
    var Color ReplaceWith;
};

var automated GUIImage i_Background;

var float LineSpacing;
var float HorizontalPadding;
var float VerticalPadding;
var float ScrollBarWidth;
var Color BackgroundColor;
var array<HxColorReplacement> ColorReplacements;
var bool bCenter;
var bool bScrollBarOutside;

var EHxLayoutState LayoutState;
var bool bPaddingApplied;

var int SavedOffsets[4];

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    HxGUIScrollText(MyScrollText).LineSpacing = LineSpacing;
    MyScrollBar.WinWidth = ScrollBarWidth;
    HxGUIVertScrollBar(MyScrollBar).bOutside = bScrollBarOutside;
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
        CenterText(C);
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
    if (!bCenter && bScrollBarOutside)
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

function CenterText(Canvas C)
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

function string ReplaceColorCodes(string Text)
{
    local Color Color;
    local string NewText;
    local string Code;
    local int Position;
    local int i;

    Position = InStr(Text, Chr(27));
    while (Position > -1)
    {
        NewText $= Left(Text, Position);
        Code = Mid(Text, Position, 4);
        Color.R = Asc(Mid(Code, 1, 1));
        Color.G = Asc(Mid(Code, 2, 1));
        Color.B = Asc(Mid(Code, 3, 1));
        for (i = 0; i < ColorReplacements.Length; ++i)
        {
            if (Color == ColorReplacements[i].Match)
            {
                Color = ColorReplacements[i].ReplaceWith;
            }
        }
        NewText $= MakeColorCode(Color);
        Text = Mid(Text, Position + 4);
        Position = InStr(Text, Chr(27));
    }
    return NewText$Text;
}

function SetContent(string NewContent, optional string sep)
{
    LayoutState = HX_LAYOUT_Outdated;
    Super.SetContent(NewContent, sep);
}

function AddText(string NewText)
{
    if (ColorReplacements.Length > 0)
    {
        Super.AddText(ReplaceColorCodes(NewText));
    }
    else
    {
        Super.AddText(NewText);
    }
}

defaultproperties
{
     Begin Object Class=GUIImage Name=Background
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        Image=Material'2K4Menus.NewControls.NewFooter'
        Y1=10
        ImageStyle=ISTY_Stretched
        RenderWeight=0.1
    End Object
    i_Background=Background

    Begin Object Class=HxGUIVertScrollBar Name=NewTheScrollbar
        bScaleToParent=true
    End Object
    MyScrollBar=NewTheScrollbar

    bRequiresStyle=true
    StyleName="HxSmallText"
    SelectedStyleName="HxSmallText"
    DefaultListClass="HexedPatches.HxGUIScrollText"
    LineSpacing=0.002
    HorizontalPadding=0.02
    VerticalPadding=0.05
    ScrollBarWidth=0.025
    BackgroundColor=(R=255,G=255,B=255,A=255)
    bCenter=false
    bScrollBarOutside=true
    OnPreDraw=InternalOnPreDraw
}
