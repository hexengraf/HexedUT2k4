class HxGUITableList extends GUIMultiColumnList
    abstract;

const INT_PADDING = "0000000000";
const INT_PADDING_SIZE = 10;
const STRING_PADDING = "                                ";
const STRING_PADDING_SIZE = 32;

var bool bAutoSpacing;
var float LineSpacing;
var float ColumnSpacing;
var float FrameThickness;

var protected bool bReInit;
var protected HxGUIVertScrollBar HxScrollbar;
var protected HxGUITableSearchBar SearchBar;
var protected float MyItemHeight;
var protected int MyItemsPerPage;

var int PreviousSortColumn;
var bool bPreviousSortDescending;
var private GUIStyles DefaultStyle;

delegate bool OnEnterKeyEvent(GUIComponent Sender);
function bool Refresh();
function DrawRow(Canvas C, int Row, float X, float Y, float W, float H);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    HxScrollbar = HxGUIVertScrollBar(MyScrollBar);
    SearchBar = HxGUITable(MenuOwner).SearchBar;
    DefaultStyle = Style;
}

event ResolutionChanged(int NewX, int NewY)
{
    Super.ResolutionChanged(NewX, NewY);
    bReInit = true;
}

function float GetSpacedItemHeight(Canvas C)
{
    local float XL;
    local float YL;

    Style.TextSize(C, MenuState, "q|W", XL, YL, FontScale);
    MyItemHeight = YL + (LineSpacing * C.ClipY);
    if (bAutoSpacing)
    {
        MyItemsPerPage = int(WinHeight / MyItemHeight);
        MyItemHeight = YL + FMax(
            0, int((WinHeight - (MyItemsPerPage * YL)) / float(MyItemsPerPage)));
    }
    MyItemsPerPage = WinHeight / MyItemHeight;
    return MyItemHeight;
}

event InitializeColumns(Canvas C)
{
    local float Width;
    local int i;

    Width = MenuOwner.ActualWidth();
    for (i = 0; i < InitColumnPerc.Length; ++i)
    {
        ColumnWidths[i] = InitColumnPerc[i] * Width;
    }
    bInit = false;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    if (EInputAction(State) == IST_Hold)
    {
        if (EInputKey(Key) == IK_Up && Up())
        {
            return true;
        }
        if (EInputKey(Key) == IK_Down && Down())
        {
            return true;
        }
    }
    else if (EInputAction(State) == IST_Release)
    {
        if (EInputKey(Key) == IK_Enter && MenuState == MSAT_Focused)
        {
            return OnEnterKeyEvent(Self);
        }
    }
    return Super.InternalOnKeyEvent(Key, State, Delta);
}

function bool InternalOnPreDraw(Canvas C)
{
    local float Offset;
    local float OwnerWidth;
    local float CurrentWidth;

    Super.InternalOnPreDraw(C);
    OwnerWidth = MenuOwner.ActualWidth();
    CurrentWidth = ActualWidth();
    CellSpacing = ColumnSpacing * C.ClipY;
    WinTop = ActualTop();
    WinHeight = ActualHeight();
    if (SearchBar != None)
    {
        WinHeight -= SearchBar.ActualHeight();
    }
    GetSpacedItemHeight(C);
    Offset = FMax(0, (WinHeight - (MyItemsPerPage * MyItemHeight)) / 2);
    WinTop += Offset;
    WinHeight -= Offset;

    if (CurrentWidth < OwnerWidth)
    {
        if (HxScrollbar != None && HxScrollbar.StandardWidth > 0)
        {
            WinWidth = OwnerWidth - (HxScrollbar.StandardWidth * C.ClipY);
        }
        else
        {
            WinWidth = OwnerWidth - MyScrollBar.ActualWidth();
        }
    }
    if (bReInit)
    {
        InitializeColumns(C);
        bReInit = false;
    }
    else if (ExpandLastColumn)
    {
        ColumnWidths[ColumnWidths.Length - 1] += OwnerWidth - CurrentWidth;
    }
    return true;
}

function DrawItem(Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float Offset;

    X = ActualLeft();
    Offset = FrameThickness * C.ClipY;
    if (bSelected)
    {
        Style = SelectedStyle;
        Style.Draw(C, MenuState, X + Offset, Y, W - 2 * Offset, H);
    }
    DrawRow(C, i, X, Y, W, H);
    Style = DefaultStyle;
}

function ShrinkToFit(Canvas C, int FirstColumn)
{
    local GUIMultiColumnListHeader Header;
    local float OwnerWidth;
    local float Width;
    local int i;

    OwnerWidth =  MenuOwner.ActualWidth();
    CellSpacing = ColumnSpacing * C.ClipY;
    Header = GUIMultiColumnListBox(MenuOwner).Header;
    InitColumnPerc[FirstColumn] = 1;
    for (i = 0; i < FirstColumn; ++i)
    {
        InitColumnPerc[FirstColumn] -= InitColumnPerc[i];
    }
    for (i = FirstColumn + 1; i < InitColumnPerc.Length; ++i)
    {
        class'HxGUIStyles'.static.GetFontSize(Header, C, ColumnHeadings[i], Width);
        InitColumnPerc[i] = FMax(0.1, (Width + (4 * CellSpacing)) / OwnerWidth);
        InitColumnPerc[FirstColumn] -= InitColumnPerc[i];
    }
    if (SearchBar != None)
    {
        SearchBar.bInit = true;
    }
}

static function string NormalizeString(string S)
{
    return left(Caps(S)$STRING_PADDING, STRING_PADDING_SIZE);
}

static function string NormalizeInt(coerce string Value, int Count)
{
    return right(INT_PADDING$Value, Min(Count, INT_PADDING_SIZE));
}

defaultproperties
{
    bAutoSpacing=true
    LineSpacing=0.003
    ColumnSpacing=0.005
    FrameThickness=0.001
    bDropSource=false
    bDropTarget=false
    ExpandLastColumn=true
    StyleName="HxList"
    SelectedStyleName="HxListSelection"
    bReInit=true
    GetItemHeight=GetSpacedItemHeight
    OnDrawItem=DrawItem
    PreviousSortColumn=-1
}
