class HxGUIStyles extends GUI2Styles
    abstract;

struct HxGUIFrame
{
    var Material Material;
    var Color Color;
    var float Thickness;
};

var protected bool bHideFrames;
var protected array<HxGUIFrame> Frames;
var private bool bDrawingFrame;

function bool InternalOnDraw(Canvas C,
                             eMenuState MenuState,
                             float Left,
                             float Top,
                             float Width,
                             float Height)
{
    local float Offset;
    local int i;

    if (bHideFrames || bDrawingFrame)
    {
        return false;
    }
    bDrawingFrame = true;
    Offset = DrawFrames(C, MenuState, Left, Top, Width, Height);
    Draw(C, MenuState, Left + Offset, Top + Offset, Width - 2 * Offset, Height - 2 * Offset);
    for (i = 0; i < ArrayCount(BorderOffsets); ++i)
    {
        BorderOffsets[i] = Offset;
    }
    bDrawingFrame = false;
    return true;
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
        DrawFrame(C, Frames[i].Material, MenuState, Left, Top, Width, Height, Offset);
        Left += Offset;
        Top += Offset;
        Width -= 2 * Offset;
    }
    C.Style = SavedStyle;
    C.DrawColor = SavedColor;
    return TotalOffset;
}

static function DrawFrame(Canvas C,
                          Material M,
                          eMenuState MenuState,
                          float Left,
                          float Top,
                          float Width,
                          float Height,
                          float Offset)
{
    C.SetPos(Left, Top);
    C.DrawTileStretched(M, Width, Offset);
    C.SetPos(C.CurX, C.CurY + Offset);
    C.DrawTileStretched(M, Offset, Height);
    C.SetPos(C.CurX + Width - Offset, C.CurY);
    C.DrawTileStretched(M, Offset, Height);
    C.SetPos(C.CurX - Width + Offset, C.CurY + Height);
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

defaultproperties
{
    Frames(0)=(Material=Material'engine.WhiteSquareTexture',Color=(R=113,G=159,B=205,A=255),Thickness=0.001)
    OnDraw=InternalOnDraw
}
