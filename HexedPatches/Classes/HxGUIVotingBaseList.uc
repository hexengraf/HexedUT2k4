class HxGUIVotingBaseList extends GUIMultiColumnList
    abstract;

var float LineSpacing;
var float ColumnSpacing;
var float LeftPadding;
var float TopPadding;
var float FrameThickness;

var VotingReplicationInfo VRI;
var int PreviousSortColumn;

var bool bReInit;
var HxGUIVertScrollBar HxScrollbar;

function OnPopulateList();
function DrawRow(Canvas C, GUIStyles DrawStyle, int Row, float Y, float H);
function string GetNormalizedString(int Row, int Column);
function int GetMapIndex();
function string GetMapName();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    HxScrollbar = HxGUIVertScrollBar(MyScrollBar);
}

event ResolutionChanged(int NewX, int NewY)
{
    Super.ResolutionChanged(NewX, NewY);
    bReInit = true;
}

function PopulateList(VotingReplicationInfo MVRI)
{
    VRI = MVRI;
    OnPopulateList();
}

function string GetSortString(int Row)
{
    if (SortColumn != PreviousSortColumn)
    {
        return GetNormalizedString(Row, SortColumn) $ GetNormalizedString(Row, PreviousSortColumn);
    }
    return GetNormalizedString(Row, SortColumn);
}

event OnSortChanged()
{
    Super.OnSortChanged();
    PreviousSortColumn = SortColumn;
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
    return Super.InternalOnKeyEvent(Key, State, Delta);
}

function bool InternalOnPreDraw(Canvas C)
{
    local float OwnerWidth;
    local float CurrentWidth;
    local float Padding;

    Super.InternalOnPreDraw(C);
    OwnerWidth = MenuOwner.ActualWidth();
    CurrentWidth = ActualWidth();
    CellSpacing = ColumnSpacing * C.ClipX;
    Padding = TopPadding * MenuOwner.ActualHeight();
    WinTop = ActualTop() + Padding;
    WinHeight = ActualHeight() - Padding;

    if (CurrentWidth < OwnerWidth)
    {
        if (HxScrollbar != None && HxScrollbar.ForceRelativeWidth > 0)
        {
            WinWidth = Round(OwnerWidth * (1 - HxScrollbar.ForceRelativeWidth));
        }
        else
        {
            WinWidth = OwnerWidth - MyScrollBar.ActualWidth();
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
    return false;
}

function GetCellLeftWidth(int Column, out float Left, out float Width)
{
    local float Padding;

    Super.GetCellLeftWidth(Column, left, Width);
    if (Column == 0)
    {
        Padding = LeftPadding * MenuOwner.ActualWidth();
        Left += Padding;
        Width -= Padding;
    }
}

function float GetSpacedItemHeight(Canvas C)
{
    local float XL;
    local float YL;

    Style.TextSize(C, MenuState, "q|W", XL, YL, FontScale);
    return YL + Round(LineSpacing * C.ClipY);
}

function DrawItem(Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float Offset;

    if (VRI == None)
    {
        return;
    }
    if (bSelected)
    {
        Offset = Round(FrameThickness * C.ClipY);
        SelectedStyle.Draw(
            C, MenuState, ActualLeft() + Offset, Y, ActualWidth() - 2 * Offset, H);
        DrawRow(C, SelectedStyle, i, Y, H);
    }
    else
    {
        DrawRow(C, Style, i, Y, H);
    }
}

defaultproperties
{
    LineSpacing=0.003
    ColumnSpacing=0.001
    LeftPadding=0.005
    TopPadding=0.005
    FrameThickness=0.001
    bDropSource=false
    bDropTarget=false
    ExpandLastColumn=true
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    GetItemHeight=GetSpacedItemHeight
    bReInit=true
    OnDrawItem=DrawItem
}
