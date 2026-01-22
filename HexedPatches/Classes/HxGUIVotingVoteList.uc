class HxGUIVotingVoteList extends HxGUIVotingBaseList;

function OnPopulateList()
{
    local int Map;

    for (Map = 0; Map < VRI.MapVoteCount.Length; ++Map)
    {
        AddedItem();
    }
}

function UpdatedVoteCount(int UpdatedIndex, bool bRemoved)
{
    if (bRemoved)
    {
        RemovedItem(UpdatedIndex);
    }
    else if (UpdatedIndex >= ItemCount)
    {
        AddedItem();

    }
    else
    {
        UpdatedItem(UpdatedIndex);
    }
    NeedsSorting = true;
}

function int GetGameTypeIndex()
{
    if (Index > -1)
    {
        return VRI.MapVoteCount[SortData[Index].SortItem].GameConfigIndex;
    }
    return Index;
}

function int GetMapIndex()
{
    if (Index > -1)
    {
        return VRI.MapVoteCount[SortData[Index].SortItem].MapIndex;
    }
    return Index;
}

function string GetMapName()
{
    if (Index > -1)
    {
        return VRI.MapList[VRI.MapVoteCount[SortData[Index].SortItem].MapIndex].MapName;
    }
    return "";
}

function DrawRow(Canvas C, GUIStyles DrawStyle, int Row, float Y, float H)
{
    local VotingHandler.MapVoteScore Entry;
    local float X;
    local float W;

    Entry = VRI.MapVoteCount[SortData[Row].SortItem];
    GetCellLeftWidth(0, X, W);
    DrawStyle.DrawText(
        C, MenuState, X, Y, W, H, TXTA_Left, VRI.GameConfig[Entry.GameConfigIndex].GameName, FontScale);
    GetCellLeftWidth(1, X, W);
    DrawStyle.DrawText(
        C, MenuState, X, Y, W, H, TXTA_Left, VRI.MapList[Entry.MapIndex].MapName, FontScale);
    GetCellLeftWidth(2, X, W);
    DrawStyle.DrawText(C, MenuState, X, Y, W, H, TXTA_Left, string(Entry.VoteCount), FontScale);
}

function string GetNormalizedString(int Row, int Column)
{
    switch (Column)
    {
        case 1:
            return left(Caps(VRI.GameConfig[VRI.MapVoteCount[Row].GameConfigIndex].GameName), 15);
        case 2:
            return left(Caps(VRI.MapList[VRI.MapVoteCount[Row].MapIndex].MapName), 20);
        default:
            break;
    }
    return left(Caps(VRI.GameConfig[VRI.MapVoteCount[Row].GameConfigIndex].GameName), 15);
}

defaultproperties
{
    ColumnHeadings(0)="Game Type"
    ColumnHeadings(1)="Name"
    ColumnHeadings(2)="Votes"
    ColumnHeadingHints(0)="Voted game type."
    ColumnHeadingHints(1)="Voted map name."
    ColumnHeadingHints(2)="Number of votes."

    SortColumn=2
    PreviousSortColumn=2
    SortDescending=true
}
