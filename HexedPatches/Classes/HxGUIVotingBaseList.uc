class HxGUIVotingBaseList extends GUIMultiColumnList;

var float LineSpacing;

var VotingReplicationInfo VRI;
var int PreviousSortColumn;

function OnPopulateList();
function string GetNormalizedString(int Row, int Column);
function int GetMapIndex();
function string GetMapName();

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

function float GetSpacedItemHeight(Canvas C)
{
    local float XL;
    local float YL;

    Style.TextSize(C, MenuState, "A", XL, YL, FontScale);
    return Round(YL + LineSpacing * C.ClipY);
}

defaultproperties
{
    LineSpacing=0.003
    bDropSource=false
    bDropTarget=false
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    GetItemHeight=GetSpacedItemHeight
}
