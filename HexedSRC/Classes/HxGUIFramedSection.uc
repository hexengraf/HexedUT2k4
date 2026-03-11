class HxGUIFramedSection extends HxGUIFramedImage;

const INDENT_SPACE = 0.03;

var automated HxGUIFramedImage HeaderBar;
var automated GUILabel l_Header;
var automated GUILabel l_HideReason;

var localized string Caption;
var array<float> ColumnWidths;
var float LeftPadding;
var float TopPadding;
var float RightPadding;
var float BottomPadding;
var float LineSpacing;
var float ColumnSpacing;
var bool bAutoSpacing;
var bool bShrinkToFit;
var int MaxItemsPerColumn;
var int ExpandIndex;

var private array<GUIComponent> Grid;
var private array<float> LeftIndents;
var private array<float> RightIndents;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    l_Header.Caption = Caption;
    bInit = true;
}

event SetVisibility(bool bIsVisible)
{
    local int i;

    Super.SetVisibility(bIsVisible);
    HeaderBar.SetVisibility(bIsVisible);
    l_Header.SetVisibility(bIsVisible);
    for (i = 0; i < Grid.Length; ++i)
    {
        Grid[i].SetVisibility(bIsVisible);
    }
}

function SetHide(bool bHide, optional string Reason)
{
    local int i;

    for (i = 0; i < Grid.Length; ++i)
    {
        Grid[i].SetVisibility(!bHide);
    }
    l_HideReason.Caption = Reason;
    l_HideReason.SetVisibility(bHide);
}

function bool Insert(GUIComponent Component, optional float LeftIndent, optional float RightIndent)
{
    if (Component == None)
    {
        return false;
    }
    if (FindIndex(Component) == -1)
    {
        Grid[Grid.Length] = Component;
        LeftIndents[LeftIndents.Length] = LeftIndent;
        RightIndents[RightIndents.Length] = RightIndent;
        return true;
    }
    return false;
}

function bool Remove(GUIComponent Component)
{
    local int i;

    i = FindIndex(Component);
    if (i >= 0 && i < Grid.Length)
    {
        Grid.Remove(i, 1);
        return true;
    }
    return false;
}

function int FindIndex(GUIComponent Component)
{
    local int i;

    if (Component != None)
    {
        for (i = 0; i < Grid.Length; ++i)
        {
            if (Grid[i] == Component)
            {
                return i;
            }
        }
    }
    return -1;
}

function bool OnPreDrawInit(Canvas C)
{
    local float Height;
    local float Border;
    local float Top;
    local float Bottom;

    Height = ActualHeight();
    Border = ActualFrameThickness(C);
    Top = AlignHeader(C, Border, Height);
    Bottom = AlignColumns(
        C,
        ActualLeft() + Border + (LeftPadding * C.ClipY),
        Top + (TopPadding * C.ClipY),
        ActualWidth() - (2 * Border) - (RightPadding + LeftPadding) * C.ClipY,
        Height - (Top - ActualTop()) - Border - (TopPadding + BottomPadding) * C.ClipY,
        0);
    if (bShrinkToFit)
    {
        WinHeight = RelativeHeight(Bottom - ActualTop() + Border);
    }
    return false;
}

function float AlignHeader(Canvas C, float ActualTop, float Height)
{
    GetFontSize(l_Header, C,,, l_Header.WinHeight);
    l_Header.WinTop = (ActualTop - HeaderBar.ActualFrameThickness(C)) / Height;
    l_Header.WinWidth = ActualWidth();
    l_Header.WinHeight *= MED_FONT_SPACING;
    HeaderBar.WinTop = l_Header.WinTop;
    HeaderBar.WinWidth = l_Header.WinWidth;
    HeaderBar.WinHeight = l_Header.WinHeight;
    l_HideReason.WinTop = l_HideReason.RelativeHeight(l_Header.ActualHeight());
    l_HideReason.WinHeight = 1.0 - l_HideReason.WinTop;
    return l_Header.ActualTop() + l_Header.WinHeight;
}

function float AlignColumns(Canvas C, float Left, float Top, float Width, float Height, int Index)
{
    local float ColumnWidth;
    local float Spacing;
    local float Bottom;
    local int i;

    Spacing = ColumnSpacing * C.ClipY;
    for (i = 0; i < ColumnWidths.Length; ++i)
    {
        ColumnWidth = (Width * ColumnWidths[i]);
        if (i == 0)
        {
            if (ColumnWidths.Length > 1)
            {
                ColumnWidth -= Spacing / 2;
            }
        }
        else
        {
            if (i == ColumnWidths.Length - 1)
            {
                ColumnWidth -= Spacing / 2;
            }
            else
            {
                ColumnWidth -= Spacing;
            }
            Left += Spacing;
        }
        Bottom = Max(Bottom, AlignColumn(C, Left, Top, ColumnWidth, Height, Index));
        if (Index >= Grid.Length)
        {
            break;
        }
        Left += ColumnWidth;
    }
    return Bottom;
}

function float AlignColumn(Canvas C, float Left, float Top, float Width, float Height, out int Index)
{
    local int MaxLines;
    local float Spacing;
    local float Bottom;
    local float LeftIndent;

    MaxLines = GetMaxLines(Index);
    Spacing = GetLineSpacing(C, Index, MaxLines, Height);
    Top -= Spacing / 2;

    Bottom = Top + Height;
    if (ExpandIndex >= Index && ExpandIndex < MaxLines)
    {
        Grid[ExpandIndex].WinHeight = Grid[ExpandIndex].RelativeHeight(
            Grid[ExpandIndex].ActualHeight() + Height - GetFilledHeight(C, Index, MaxLines, Height));
    }
    while (Index < MaxLines && Top < Bottom)
    {
        LeftIndent = GetLeftIndent(C, Index);
        Grid[Index].WinLeft = Grid[Index].RelativeLeft(Left + LeftIndent);
        Grid[Index].WinWidth = Grid[Index].RelativeWidth(
            Width - LeftIndent - GetRightIndent(C, Index));
        Grid[Index].WinTop = Grid[Index].RelativeTop(Top + Spacing / 2);
        Top += Grid[Index].ActualHeight() + Spacing;
        ++Index;
    }
    return Top;
}

function float GetLineSpacing(Canvas C, int Index, int MaxLines, float Height)
{
    if (bAutoSpacing && !bShrinkToFit && (ExpandIndex < Index || ExpandIndex >= MaxLines))
    {
        Height -= GetFilledHeight(C, Index, MaxLines);
        if (Height > 0)
        {
            return ActualLineSpacing(C) + (Height / Max(1, MaxLines - Index - 1));
        }
    }
    return ActualLineSpacing(C);
}

function float GetFilledHeight(Canvas C, int Index, int MaxLines, optional float Height)
{
    local float FilledHeight;
    local float Spacing;
    local int i;

    Spacing = ActualLineSpacing(C);
    for (i = Index; i < MaxLines; ++i)
    {
        FilledHeight += Grid[i].ActualHeight() + Spacing;
        if ((Height > 0 && FilledHeight >= Height))
        {
            break;
        }
    }
    return FilledHeight - Spacing;
}

function int GetMaxLines(optional int Index)
{
    if (MaxItemsPerColumn > 0)
    {
        return Min(Index + MaxItemsPerColumn, Grid.Length);
    }
    return Grid.Length;
}

function float GetLeftIndent(Canvas C, int Index)
{
    return LeftIndents[Index] * C.ClipY;
}

function float GetRightIndent(Canvas C, int Index)
{
    return RightIndents[Index] * C.ClipY;
}

function float ActualLineSpacing(Canvas C)
{
    return LineSpacing * C.ClipY;
}

function int Count()
{
    return Grid.Length;
}

function int ColumnCount()
{
    return ColumnWidths.Length;
}

function Reset()
{
    Grid.Remove(0, Grid.Length);
    bInit = true;
}

function SetPosition(float Left, float Top, float Width, float Height, optional bool bRelative)
{
    Super.SetPosition(Left, Top, Width, Height, bRelative);
    bInit = true;
}

defaultproperties
{
    Begin Object Class=HxGUIFramedImage Name=HeaderBarImage
        WinLeft=0
        WinTop=0
        RenderWeight=0.3
        ImageSources(0)=(Color=(R=21,G=73,B=126,A=255),Style=ISTY_Stretched)
        bScaleToParent=false
        bBoundToParent=true
    End Object
    HeaderBar=HeaderBarImage

    Begin Object class=GUILabel Name=HeaderLabel
        WinLeft=0
        WinTop=0
        TextColor=(R=255,G=255,B=255,A=255)
        TextAlign=TXTA_Center
        bTransparent=true
        bScaleToParent=false
        bBoundToParent=true
    End Object
    l_Header=HeaderLabel

    Begin Object class=GUILabel Name=HideReasonLabel
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        TextColor=(R=255,G=255,B=255,A=255)
        TextAlign=TXTA_Center
        bTransparent=true
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_HideReason=HideReasonLabel

    ColumnWidths(0)=1.0
    LeftPadding=0.015
    TopPadding=0.015
    RightPadding=0.015
    BottomPadding=0.015
    LineSpacing=0.01
    ColumnSpacing=0.039
    bAutoSpacing=true
    bShrinkToFit=false
    ExpandIndex=-1
    ImageSources(0)=(Color=(R=0,G=38,B=74,A=176),Style=ISTY_Stretched,RenderWeight=0.1)

    bScaleToParent=true
    bBoundToParent=true
    FontScale=FNS_Small
    RenderWeight=0.09
}
