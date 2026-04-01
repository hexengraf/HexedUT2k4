class HxGUIStyles extends GUI2Styles
    abstract;

struct HxGUIFrame
{
    var Material Material;
    var Color Color;
    var float Thickness;
};

var protected const float RelativeBorderOffsets[4];
var protected const byte SkipFrameParts[4];
var protected const array<HxGUIFrame> Frames;
var private float LastResY;
var private bool bLocked;
var private int LeftOffsetCount;
var private int TopOffsetCount;
var private int WidthOffsetCount;
var private int HeightOffsetCount;
var private Color FallbackFrameColor;

event Initialize()
{
    local int i;

    Super.Initialize();
    LeftOffsetCount = int(SkipFrameParts[0] == 0);
    TopOffsetCount = int(SkipFrameParts[1] == 0);
    WidthOffsetCount = LeftOffsetCount + int(SkipFrameParts[2] == 0);
    HeightOffsetCount = TopOffsetCount + int(SkipFrameParts[3] == 0);
    for (i = 0; i < 5; ++i)
    {
        if (Fonts[i] == None)
        {
            FontNames[i] = "UT2SmallFont";
            Fonts[i] = Controller.GetMenuFont(FontNames[i]);
        }
    }
    UpdateBorderOffsets();
}

function bool InternalOnDraw(Canvas C,
                             eMenuState MenuState,
                             float Left,
                             float Top,
                             float Width,
                             float Height)
{
    local float Offset;

    if (bLocked)
    {
        return false;
    }
    UpdateBorderOffsets();
    bLocked = true;
    Offset = DrawFrames(C, MenuState, Left, Top, Width, Height);
    Width -= WidthOffsetCount * Offset;
    Height -= HeightOffsetCount * Offset;
    Left += LeftOffsetCount * Offset;
    Top += TopOffsetCount * Offset;
    Draw(C, MenuState, Left, Top, Width, Height);
    bLocked = false;
    return true;
}

function bool UpdateBorderOffsets()
{
    local float FrameThickness;
    local int i;

    if (LastResY != Controller.ResY)
    {
        FrameThickness = ActualFrameThickness();
        for (i = 0; i < ArrayCount(BorderOffsets); ++i)
        {
            BorderOffsets[i] = Round(RelativeBorderOffsets[i] * Controller.ResY);
            if (SkipFrameParts[i] == 0)
            {
                BorderOffsets[i] += FrameThickness;
            }
        }
        LastResY = Controller.ResY;
        return true;
    }
    return false;
}

function float DrawFrames(Canvas C,
                          eMenuState MenuState,
                          float Left,
                          float Top,
                          float Width,
                          float Height)
{
    local float Offset;
    local float TotalOffset;
    local byte SavedStyle;
    local Color SavedColor;
    local int i;

    SavedStyle = C.Style;
    SavedColor = C.DrawColor;
    C.Style = RStyles[MenuState];
    for (i = 0; i < Frames.Length; ++i)
    {
        C.DrawColor = Frames[i].Color;
        Offset = Round(C.ClipY * Frames[i].Thickness);
        TotalOffset += Offset;
        Height -= 2 * Offset;
        if (Frames[i].Material != None)
        {
            DrawFrame(
                C,
                Frames[i].Material,
                MenuState,
                Left,
                Top,
                Width,
                Height,
                Offset,
                SkipFrameParts);
        }
        Left += Offset;
        Top += Offset;
        Width -= WidthOffsetCount * Offset;
    }
    C.Style = SavedStyle;
    C.DrawColor = SavedColor;
    return TotalOffset;
}

function Color GetFrameColor()
{
    if (Frames.Length > 0)
    {
        return Frames[0].Color;
    }
    return FallbackFrameColor;
}

function Material GetFrameMaterial()
{
    if (Frames.Length > 0)
    {
        return Frames[0].Material;
    }
    return None;
}

function float FrameThickness()
{
    local float Thickness;
    local int i;

    for (i = 0; i < Frames.Length; ++i)
    {
        Thickness += Frames[i].Thickness;
    }
    return Thickness;
}

function float ActualFrameThickness()
{
    local float Thickness;
    local int i;

    for (i = 0; i < Frames.Length; ++i)
    {
        Thickness += Round(Controller.ResY * Frames[i].Thickness);
    }
    return Thickness;
}

static function DrawFrame(Canvas C,
                          Material M,
                          eMenuState MenuState,
                          float Left,
                          float Top,
                          float Width,
                          float Height,
                          float Offset,
                          optional byte SkipParts[4])
{
    C.SetPos(Left, Top);
    if (SkipParts[1] == 0)
    {
        C.DrawTileStretched(M, Width, Offset);
    }
    C.SetPos(C.CurX, C.CurY + Offset);
    if (SkipParts[0] == 0)
    {
        C.DrawTileStretched(M, Offset, Height);
    }
    C.SetPos(C.CurX + Width - Offset, C.CurY);
    if (SkipParts[2] == 0)
    {
        C.DrawTileStretched(M, Offset, Height);
    }
    if (SkipParts[3] == 0)
    {
        C.SetPos(C.CurX - Width + Offset, C.CurY + Height);
    }
    C.DrawTileStretched(M, Width, Offset);
}

static function bool GetFontSize(GUIComponent Comp,
                                 Canvas C,
                                 optional string Text,
                                 optional out float Width,
                                 optional out float Height)
{
    local Font OldFont;

    if (Text == "")
    {
        Text = "q|W";
    }
    if (Comp.Style != None)
    {
        Comp.Style.TextSize(C, Comp.MenuState, Text, Width, Height, Comp.FontScale);
        return true;
    }
    if (GUILabel(Comp) != None)
    {
        OldFont = C.Font;
        C.Font = Comp.Controller.GetMenuFont(GUILabel(Comp).TextFont).GetFont(C.SizeX);
        C.TextSize(Text, Width, Height);
        C.Font = OldFont;
        return true;
    }
    return false;
}

static function FillFrame(GUIComponent Framer, GUIComponent Framed)
{
    local float Thickness;

    Thickness = GetActualFrameThickness(Framer);
    Framed.WinLeft = Framed.RelativeLeft(Framer.ActualLeft() + Thickness, Framed.bScaleToParent);
    Framed.WinTop = Framed.RelativeTop(Framer.ActualTop() + Thickness, Framed.bScaleToParent);
    Framed.WinWidth = Framed.RelativeWidth(
        Framer.ActualWidth() - 2 * Thickness, Framed.bScaleToParent);
    Framed.WinHeight = Framed.RelativeHeight(
        Framer.ActualHeight() - 2 * Thickness, Framed.bScaleToParent);
}

static function FillFrameWidth(GUIComponent Framer, GUIComponent Framed)
{
    local float Thickness;

    Thickness = GetActualFrameThickness(Framer);
    Framed.WinLeft = Framed.RelativeLeft(Framer.ActualLeft() + Thickness, Framed.bScaleToParent);
    Framed.WinWidth = Framed.RelativeWidth(
        Framer.ActualWidth() - 2 * Thickness, Framed.bScaleToParent);
}

static function AlignToRightOf(GUIComponent RightOf, GUIComponent Aligned)
{
    Aligned.WinLeft = Aligned.RelativeLeft(
        RightOf.ActualLeft() + RightOf.ActualWidth() - GetActualFrameThickness(Aligned));
}

static function AlignToBottomOf(GUIComponent BottomOf, GUIComponent Aligned)
{
    Aligned.WinTop = Aligned.RelativeTop(
        BottomOf.ActualTop() + BottomOf.ActualHeight() - GetActualFrameThickness(Aligned));
}

static function CopyPosition(GUIComponent Reference, GUIComponent Target)
{
    Target.WinLeft = Reference.WinLeft;
    Target.WinTop = Reference.WinTop;
    Target.WinWidth = Reference.WinWidth;
    Target.WinHeight = Reference.WinHeight;
}

static function float StaticFrameThickness(GUIComponent Comp)
{
    if (HxGUIStyles(Comp.Style) != None)
    {
        return HxGUIStyles(Comp.Style).FrameThickness();
    }
    return 0;
}

static function float GetActualFrameThickness(GUIComponent Comp)
{
    if (HxGUIStyles(Comp.Style) != None)
    {
        return HxGUIStyles(Comp.Style).ActualFrameThickness();
    }
    return 0;
}

defaultproperties
{
    FontNames(0)="HxSmallerFont"
    FontNames(1)="HxSmallerFont"
    FontNames(2)="HxSmallerFont"
    FontNames(3)="HxSmallerFont"
    FontNames(4)="HxSmallerFont"

    RStyles(0)=MSTY_Alpha
    RStyles(1)=MSTY_Alpha
    RStyles(2)=MSTY_Alpha
    RStyles(3)=MSTY_Alpha
    RStyles(4)=MSTY_Alpha

    ImgStyle(0)=ISTY_Scaled
    ImgStyle(1)=ISTY_Scaled
    ImgStyle(2)=ISTY_Scaled
    ImgStyle(3)=ISTY_Scaled
    ImgStyle(4)=ISTY_Scaled

    FallbackFrameColor=(R=113,G=159,B=205,A=255)
    OnDraw=InternalOnDraw
}
