class HxGUIVotingBaseList extends GUIMultiColumnList;

var float LineSpacing;

var VotingReplicationInfo VRI;
var int PreviousSortColumn;

var bool bReInit;
var HxGUIVertScrollBar HxScrollbar;

function OnPopulateList();
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

    if (bInit)
    {
        return false;
    }
    Super.InternalOnPreDraw(C);
    OwnerWidth = MenuOwner.ActualWidth();
    CurrentWidth = ActualWidth();
    if (CurrentWidth < OwnerWidth)
    {
        if (HxScrollbar != None && HxScrollbar.ForceRelativeWidth > 0)
        {
            WinWidth = OwnerWidth * (1 - HxScrollbar.ForceRelativeWidth);
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

function float GetSpacedItemHeight(Canvas C)
{
    local float XL;
    local float YL;

    Style.TextSize(C, MenuState, "A", XL, YL, FontScale);
    return Round(YL + LineSpacing * C.ClipY);
}

function bool InternalOnDblClick(GUIComponent Sender)
{
    if (HxGUIVotingPage(PageOwner) != None)
    {
        HxGUIVotingPage(PageOwner).SendVoteFrom(MenuOwner);
        return true;
    }
    return false;
}

defaultproperties
{
    LineSpacing=0.003
    bDropSource=false
    bDropTarget=false
    ExpandLastColumn=true
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    GetItemHeight=GetSpacedItemHeight
    OnDblClick=InternalOnDblClick
    bReInit=true
}
