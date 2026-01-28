class HxGUIScrollTextBox extends GUIScrollTextBox;

struct HxColorReplacement
{
    var Color Match;
    var Color ReplaceWith;
};

var automated HxGUIFramedImage i_Background;
var HxGUIScrollText ScrollText;

var eTextAlign VertAlign;
var bool bAutoSpacing;
var float LineSpacing;
var float LeftPadding;
var float TopPadding;
var float RightPadding;
var float BottomPadding;
var float ScrollbarWidth;
var float FrameThickness;
var Material BackgroundImage;
var eImgStyle BackgroundStyle;
var Color BackgroundColor;
var bool bBackgroundVisible;
var int BackgroundX1;
var int BackgroundX2;
var int BackgroundY1;
var int BackgroundY2;

var array<HxColorReplacement> ColorReplacements;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    ScrollText = HxGUIScrollText(MyScrollText);
    ScrollText.VertAlign = VertAlign;
    ScrollText.bAutoSpacing = bAutoSpacing;
    ScrollText.LineSpacing = LineSpacing;
    ScrollText.LeftPadding = LeftPadding;
    ScrollText.TopPadding = TopPadding;
    ScrollText.RightPadding = RightPadding;
    ScrollText.BottomPadding = BottomPadding;
    MyScrollBar.WinWidth = ScrollbarWidth;
    i_Background.SetImage(BackgroundImage);
    i_Background.SetImageStyle(BackgroundStyle);
    i_Background.SetImageColor(BackgroundColor);
    i_Background.SetImageSize(BackgroundX1, BackgroundX2, BackgroundY1, BackgroundY2);
    i_Background.FrameThickness = FrameThickness;
    i_Background.SetVisibility(bBackgroundVisible);
    HxGUIVertScrollBar(MyScrollBar).FrameThickness = FrameThickness;
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
    if (ColorReplacements.Length > 0)
    {
        Super.SetContent(ReplaceColorCodes(NewContent), sep);
    }
    else
    {
        Super.SetContent(NewContent, sep);
    }
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

function float GetItemHeight(Canvas C)
{
    return ScrollText.GetItemHeight(C);
}

defaultproperties
{
    Begin Object Class=HxGUIFramedImage Name=Background
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        RenderWeight=0.1
        bBoundToParent=true
        bScaleToParent=true
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
    VertAlign=TXTA_Left
    bAutoSpacing=false
    LineSpacing=0.002
    LeftPadding=0
    TopPadding=0
    RightPadding=0
    BottomPadding=0
    ScrollbarWidth=0.03
    FrameThickness=0.001
    BackgroundImage=Material'engine.WhiteSquareTexture'
    BackgroundStyle=ISTY_Scaled
    BackgroundColor=(R=38,G=59,B=126,A=255)
    bBackgroundVisible=true
    BackgroundX1=-1
    BackgroundX2=-1
    BackgroundY1=-1
    BackgroundY2=-1
}
