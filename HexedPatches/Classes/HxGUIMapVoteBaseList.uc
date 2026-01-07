class HxGUIMapVoteBaseList extends GUIMultiColumnList;

var VotingReplicationInfo VRI;
var int PreviousSortColumn;

function PopulateList();
function string GetNormalizedString(int Row, int Column);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    VRI = VotingReplicationInfo(PlayerOwner().VoteReplicationInfo);
    SetTimer(0.02, true);
}

event Timer()
{
    if (VRI != None)
    {
        PopulateList();
        KillTimer();
    }
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

function Free()
{
    VRI = None;
    super.Free();
}

defaultproperties
{
    ExpandLastColumn=true
    bDropSource=false
    bDropTarget=false
    StyleName="HxSimpleList"
    SelectedStyleName="ListSelection"
}
