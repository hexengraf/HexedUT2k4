class HxGUIMultiColumnListBox extends GUIMultiColumnListBox
    abstract;

var automated HxGUIBackground b_ListBackground;
var automated HxGUIMultiColumnListSearchBar SearchBar;

var float StandardHeaderHeight;
var float ScrollbarWidth;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    HxGUIMultiColumnList(List).FrameThickness =
        class'HxGUIStyles'.static.StaticFrameThickness(b_ListBackground);
    HxGUIVertScrollBar(MyScrollBar).RightOffset = HxGUIMultiColumnList(List).FrameThickness;
    HxGUIVertScrollBar(MyScrollBar).StandardWidth = ScrollbarWidth;
}

event ResolutionChanged(int NewX, int NewY)
{
    local int i;

    for (i = 0; i < HeaderColumnPerc.Length; ++i)
    {
        HeaderColumnPerc[i] = default.HeaderColumnPerc[i];
    }
    bInit = true;
    Super.ResolutionChanged(NewX, NewY);
}

function bool Refresh()
{
    return HxGUIMultiColumnList(List).Refresh();
}

function SelectRandom()
{
    if (List.ItemCount > 0)
    {
        List.SetIndex(Rand(List.ItemCount));
    }
}

function bool IsEmpty()
{
    return List.ItemCount == 0;
}

function int SilentSetIndex(int NewIndex)
{
    return List.SilentSetIndex(NewIndex);
}

function Clear()
{
    if (SearchBar != None)
    {
        SearchBar.Clear();
    }
    List.Clear();
}

function bool InternalOnPreDraw(Canvas C)
{
    local float FullHeight;
    local float SearchBarHeight;
    local float Offset;

    if (bInit)
    {
        FullHeight = ActualHeight();
        Offset = class'HxGUIStyles'.static.GetActualFrameThickness(b_ListBackground);
        b_ListBackground.WinTop = (GetHeaderHeight(C) - Offset) / FullHeight;
        b_ListBackground.WinHeight = 1.0 - b_ListBackground.WinTop;
        if (SearchBar != None)
        {
            SearchBarHeight = SearchBar.ActualHeight();
            SearchBar.WinTop = (FullHeight - SearchBarHeight) / FullHeight;
            HxGUIVertScrollBar(MyScrollBar).BottomOffset = SearchBarHeight / C.ClipY;
            b_ListBackground.WinHeight -= (SearchBarHeight - Offset) / FullHeight;
        }
        bInit = false;
        return true;
    }
    return false;
}

function bool OnHoverHeader(GUIComponent Sender)
{
    local float Left;
    local float Right;
    local bool bOnResizing;
    local int i;

    Left = Header.ActualLeft() + 5;
    for (i = 0; i < Header.MyList.ColumnHeadingHints.Length; ++i)
    {
        Right = Left + Header.MyList.ColumnWidths[i] - 10;
        if (Controller.MouseX > Left && Controller.MouseX < Right)
        {
            if (Header.Hint != Header.MyList.ColumnHeadingHints[i])
            {
                Header.SetHint(Header.MyList.ColumnHeadingHints[i]);
            }
            break;
        }
        if (Controller.MouseX <= Right + 10 && Controller.MouseX >= Right)
        {
            bOnResizing = true;
            break;
        }
        Left += Header.MyList.ColumnWidths[i];
    }
    if (bOnResizing && i > 1 && i < Header.MyList.ColumnHeadingHints.Length - 1)
    {
        Header.MouseCursorIndex = 5;
    }
    else
    {
        Header.MouseCursorIndex = 0;
    }
    return true;
}

function bool OnPreDrawHeader(Canvas C)
{
    Header.WinHeight = GetHeaderHeight(C);
    return true;
}

function OnRenderedHeader(Canvas C)
{
    local Material FrameMaterial;
    local float Offset;
    local float Left;
    local float Width;
    local float Height;
    local int i;

    C.Style = 5;
    Left = Header.ActualLeft();
    Width = Header.ActualWidth();
    Height = Header.ActualHeight();
    if (HxGUIStyles(b_ListBackground.Style) != None)
    {
        C.DrawColor = HxGUIStyles(b_ListBackground.Style).GetFrameColor();
        FrameMaterial = HxGUIStyles(b_ListBackground.Style).GetFrameMaterial();
        Offset = class'HxGUIStyles'.static.GetActualFrameThickness(b_ListBackground);
        Height -= Offset;
        C.SetPos(Left, Header.ActualTop());
        C.DrawTileStretched(FrameMaterial, Width, Offset);
        C.CurY += Offset;
        C.DrawTileStretched(FrameMaterial, Offset, Height);
        C.CurX += Width - Offset;
        C.DrawTileStretched(FrameMaterial, Offset, Height);
    }
    if (HxGUIStyles(Header.Style) != None)
    {
        C.DrawColor = HxGUIStyles(Header.Style).GetFrameColor();
        FrameMaterial = HxGUIStyles(Header.Style).GetFrameMaterial();
        Offset = class'HxGUIStyles'.static.GetActualFrameThickness(Header);
        C.CurX += Offset / 2;
        Height -= Offset;
        for (i = List.ColumnHeadings.Length - 1; i > 0; --i)
        {
            C.CurX -= List.ColumnWidths[i];
            C.DrawTileStretched(FrameMaterial, Offset, Height);
        }
        C.SetPos(Left + Offset, C.CurY + Height);
        C.DrawTileStretched(FrameMaterial, Width - 2 * Offset, Offset);
    }
}

function OnMousePressedHeader(GUIComponent Sender, bool bRepeat)
{
    HxGUIMultiColumnList(List).PreviousSortColumn = List.SortColumn;
    HxGUIMultiColumnList(List).bPreviousSortDescending = List.SortDescending;
}

function bool OnCapturedMouseMoveHeader(float deltaX, float deltaY)
{
    if (Header.SizingCol == 0 || Header.SizingCol == 1)
    {
        Header.MenuState = Header.LastMenuState;
    }
    return false;
}

function float GetHeaderHeight(Canvas C)
{
    return Round(C.ClipY * StandardHeaderHeight);
}

function SetCustomBackground(string BackgroundName)
{
    b_ListBackground.SetCustomBackground(BackgroundName);
}

defaultproperties
{
    Begin Object Class=GUIToolTip Name=HeaderToolTip
    End Object

    Begin Object Class=GUIMultiColumnListHeader Name=MyNewHeader
        StyleName="HxListHeader"
        BarStyleName="HxListHeader"
        ToolTip=HeaderToolTip
        bNeverFocus=true
        OnMousePressed=OnMousePressedHeader
        OnCapturedMouseMove=OnCapturedMouseMoveHeader
        OnHover=OnHoverHeader
        OnPreDraw=OnPreDrawHeader
        OnRendered=OnRenderedHeader
    End Object
    Header=MyNewHeader

    Begin Object Class=HxGUIBackground Name=ListBackground
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        RenderWeight=0.1
        StyleName="HxBackground"
        bScaleToParent=true
        bBoundToParent=true
    End Object
    b_ListBackground=ListBackground

    Begin Object Class=HxGUIVertScrollBar Name=NewTheScrollbar
        bScaleToParent=true
    End Object
    MyScrollBar=NewTheScrollbar

    StandardHeaderHeight=0.0325
    ScrollbarWidth=0.016
    StyleName="HxList"
    SelectedStyleName="HxListSelection"
    bVisibleWhenEmpty=true
    OnPreDraw=InternalOnPreDraw
}
