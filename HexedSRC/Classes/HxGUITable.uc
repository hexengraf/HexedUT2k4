class HxGUITable extends GUIMultiColumnList
    abstract;

const INT_PADDING = "0000000000";
const INT_PADDING_SIZE = 10;
const STRING_PADDING = "                                ";
const STRING_PADDING_SIZE = 32;

var string OverflowStyleName;
var string ScrollGripStyleName;
var string ScrollZoneStyleName;
var bool bAutoSpacing;
var float LineSpacing;
var float ColumnSpacing;

var protected bool bReInit;
var protected HxGUIVertScrollBar HxScrollbar;
var protected HxGUITableSearchBar SearchBar;

var int PreviousSortColumn;
var bool bPreviousSortDescending;
var private GUIStyles OverflowStyle;
var private GUIStyles NormalStyle;

delegate bool OnEnterKeyEvent(GUIComponent Sender);
function bool Refresh();
function DrawRow(Canvas C, int Row, float X, float Y, float W, float H);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    OverflowStyle = MyController.GetStyle(OverflowStyleName, FontScale);
    Super.InitComponent(MyController, MyOwner);
    HxScrollbar = HxGUIVertScrollBar(MyScrollBar);
    SearchBar = HxGUITableBox(MenuOwner).SearchBar;
    NormalStyle = Style;
}

event ResolutionChanged(int NewX, int NewY)
{
    Super.ResolutionChanged(NewX, NewY);
    bReInit = true;
}

function float GetSpacedItemHeight(Canvas C)
{
    local float NewItemHeight;
    local float NewItemsPerPage;
    local float Height;
    local float XL;
    local float YL;

    Style.TextSize(C, MenuState, "q|W", XL, YL, FontScale);
    NewItemHeight = Ceil(YL + (LineSpacing * C.ClipY));
    if (bAutoSpacing)
    {
        Height = ClientBounds[3] - ClientBounds[1] - 1;
        NewItemsPerPage = int(Height / NewItemHeight);
        NewItemHeight = YL + FMax(0, (Height - (NewItemsPerPage * YL)) / NewItemsPerPage);
    }
    return NewItemHeight;
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
    local float CurrentWidth;
    local float OwnerWidth;

    Super.InternalOnPreDraw(C);
    CellSpacing = ColumnSpacing * C.ClipY;
    if (SearchBar != None)
    {
        WinHeight = ActualHeight() - SearchBar.ActualHeight();
    }
    CurrentWidth = ActualWidth();
    OwnerWidth = MenuOwner.ActualWidth();
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
        Style = OverflowStyle;
    }
    else
    {
        Style = NormalStyle;
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
    local GUIStyles SavedStyle;

    if (bSelected)
    {
        SavedStyle = Style;
        Style = SelectedStyle;
        Style.Draw(C, MenuState, X, Y, W, H);
        DrawRow(C, i, X, Y, W, H);
        Style = SavedStyle;
    }
    else
    {
       DrawRow(C, i, X, Y, W, H);
    }
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

event Free()
{
    NormalStyle = None;
    OverflowStyle = None;
    Super.Free();
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
    LineSpacing=0.0033
    ColumnSpacing=0.005
    bDropSource=false
    bDropTarget=false
    ExpandLastColumn=true
    StyleName="HxTable"
    OverflowStyleName="HxTableLeft"
    SelectedStyleName="HxListSelection"
    ScrollZoneStyleName="HxTableScrollZone"
    ScrollGripStyleName="HxScrollGrip"
    bReInit=true
    GetItemHeight=GetSpacedItemHeight
    OnDrawItem=DrawItem
    PreviousSortColumn=-1
}
