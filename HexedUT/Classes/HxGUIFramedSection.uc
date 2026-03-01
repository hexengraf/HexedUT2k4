class HxGUIFramedSection extends HxGUIFramedImage;

var automated HxGUIFramedImage HeaderBar;
var automated GUILabel l_Header;
var automated GUILabel l_HideReason;

var localized string Caption;
var array<GUIComponent> Items;
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
var int ExpandItem;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    l_Header.Caption = Caption;
    Super.InitComponent(MyController, MyOwner);
}

event SetVisibility(bool bIsVisible)
{
    local int i;

    Super.SetVisibility(bIsVisible);
    HeaderBar.SetVisibility(bIsVisible);
    l_Header.SetVisibility(bIsVisible);
    for (i = 0; i < Items.Length; ++i)
    {
        Items[i].SetVisibility(bIsVisible);
    }
}

function SetHide(bool bHide, optional string Reason)
{
    local int i;

    for (i = 0; i < Items.Length; ++i)
    {
        Items[i].SetVisibility(!bHide);
    }
    l_HideReason.Caption = Reason;
    l_HideReason.SetVisibility(bHide);
}

function bool AddItem(GUIComponent Component)
{
    if (Component == None)
    {
        return false;
    }
    if (FindIndex(Component) == -1)
    {
        Items[Items.Length] = Component;
        return true;
    }
    return false;
}

function bool RemoveItem(GUIComponent Component)
{
    local int i;

    i = FindIndex(Component);
    if (i >= 0 && i < Items.Length)
    {
        Items.Remove(i, 1);
        return true;
    }
    return false;
}

function int FindIndex(GUIComponent Component)
{
    local int i;

    if (Component != None)
    {
        for (i = 0; i < Items.Length; ++i)
        {
            if (Items[i] == Component)
            {
                return i;
            }
        }
    }
    return -1;
}

function Reset()
{
    Items.Remove(0, Items.Length);
    bInit = true;
}

function bool OnPreDrawInit(Canvas C)
{
    local float Width;
    local float Height;
    local float Border;
    local float Top;
    local float Bottom;

    Width = ActualWidth();
    Height = ActualHeight();
    Border = ActualFrameThickness(C);
    Top = AlignHeader(C, Border, Height);
    Bottom = AlignColumns(
        ActualLeft() + Border + (LeftPadding * Width),
        Top + (TopPadding * Height),
        Width - (2 * Border) - (RightPadding + LeftPadding) * Width,
        Height - (Top - ActualTop()) - Border - (TopPadding + BottomPadding) * Height,
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
    return l_Header.ActualTop() + l_Header.WinHeight;
}

function float AlignColumns(float Left, float Top, float Width, float Height, int Index)
{
    local float ColumnWidth;
    local float Offset;
    local float Bottom;
    local int i;

    Offset = (ColumnSpacing * Width) / 2;
    Width += Offset;
    for (i = 0; i < ColumnWidths.Length; ++i)
    {
        ColumnWidth = Width * ColumnWidths[i];
        Bottom = Max(Bottom, AlignColumn(Left, Top, ColumnWidth - Offset, Height, Index));
        if (Index >= Items.Length)
        {
            break;
        }
        Left += ColumnWidth + Offset;
    }
    return Bottom;
}

function float AlignColumn(float Left, float Top, float Width, float Height, out int Index)
{
    local int MaxItems;
    local float Spacing;
    local float LowerBound;

    MaxItems = GetMaxItems(Index);
    Spacing = GetLineSpacing(Index, MaxItems, Height) / 2;
    Top += Spacing;
    LowerBound = Top + Height;
    if (ExpandItem >= Index && ExpandItem < MaxItems)
    {
        Items[ExpandItem].WinHeight = Items[ExpandItem].RelativeHeight(
            Items[ExpandItem].ActualHeight() + Height - GetFilledHeight(Index, MaxItems));
    }
    while (Index < MaxItems)
    {
        Top += Spacing;
        Items[Index].WinLeft = Items[Index].RelativeLeft(Left);
        Items[Index].WinTop = Items[Index].RelativeTop(Top);
        Items[Index].WinWidth = Items[Index].RelativeWidth(Width);
        Top += Items[Index].ActualHeight() + Spacing;
        if (Top >= LowerBound)
        {
            break;
        }
        ++Index;
    }
    Top += Spacing;
    return Top;
}

function float GetLineSpacing(int Index, int MaxItems, float Height)
{
    if (bAutoSpacing && !bShrinkToFit && ExpandItem == -1)
    {
        Height -= GetFilledHeight(Index, MaxItems);
        if (Height > 0)
        {
            return LineSpacing * ActualHeight() + Height / (MaxItems + 1);
        }
    }
    return LineSpacing * ActualHeight();
}

function float GetFilledHeight(int Index, int MaxItems)
{
    local float FilledHeight;
    local float Spacing;
    local int i;

    Spacing = LineSpacing * ActualHeight();
    FilledHeight = Spacing;
    for (i = 0; i < MaxItems; ++i)
    {
        FilledHeight += Items[Index + i].ActualHeight() + Spacing;
    }
    return FilledHeight;
}

function int GetMaxItems(optional int Index)
{
    if (MaxItemsPerColumn > 0)
    {
        return Min(Index + MaxItemsPerColumn, Items.Length);
    }
    return Items.Length;
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
        FrameColor=(R=68,G=159,B=241,A=255)
        ImageSources(0)=(Color=(R=21,G=73,B=126,A=255),Style=ISTY_Stretched)
        bScaleToParent=false
        bBoundToParent=true
    End Object
    HeaderBar=HeaderBarImage

    Begin Object class=GUILabel Name=HeaderLabel
        WinLeft=0
        WinTop=0
        // StyleName="TextLabel"
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
        // StyleName="TextLabel"
        TextColor=(R=255,G=210,B=0,A=255)
        TextAlign=TXTA_Center
        bTransparent=true
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_HideReason=HideReasonLabel

    ColumnWidths(0)=1.0
    LeftPadding=0.01
    TopPadding=0
    RightPadding=0.01
    BottomPadding=0
    LineSpacing=0.03
    ColumnSpacing=0.01
    bAutoSpacing=true
    bShrinkToFit=false
    ExpandItem=-1
    FrameThickness=0.003
    FrameColor=(R=68,G=159,B=241,A=255)
    ImageSources(0)=(Color=(R=11,G=59,B=106,A=255),Style=ISTY_Stretched,RenderWeight=0.1)

    bScaleToParent=true
    bBoundToParent=true
    FontScale=FNS_Small
    RenderWeight=0.09
}
