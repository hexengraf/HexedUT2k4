class HxGUIMapVoteBaseList extends GUIMultiColumnList;

var VotingReplicationInfo VRI;
var int PreviousSortColumn;

function OnPopulateList();
function string GetNormalizedString(int Row, int Column);
function int GetSelectedGameTypeIndex();
function int GetSelectedMapIndex();
function string GetSelectedMapName();
function SetSelectedGameType(int Type);

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

defaultproperties
{
    ExpandLastColumn=true
    bDropSource=false
    bDropTarget=false
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
}
