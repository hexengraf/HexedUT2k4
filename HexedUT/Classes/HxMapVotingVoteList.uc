class HxMapVotingVoteList extends HxMapVotingBaseList;

function PopulateList()
{
    local HxFavorites.EHxTag MapTag;
    local int i;

    for (i = 0; i < VRI.MapVoteCount.Length; ++i)
    {
        MapTag = class'HxMapFavorites'.static.GetMapTag(
            VRI.MapList[VRI.MapVoteCount[i].MapIndex].MapName);
        AddMap(VRI.MapVoteCount[i].MapIndex, MapTag);
    }
}

function UpdatedVoteCount(int UpdatedIndex, bool bRemoved)
{
    local HxFavorites.EHxTag MapTag;

    if (bRemoved)
    {
        RemoveMap(UpdatedIndex);
    }
    else if (UpdatedIndex >= ItemCount)
    {
        MapTag = class'HxMapFavorites'.static.GetMapTag(
            VRI.MapList[VRI.MapVoteCount[UpdatedIndex].MapIndex].MapName);
        AddMap(VRI.MapVoteCount[UpdatedIndex].MapIndex, MapTag);
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

function bool InternalOnPreDraw(Canvas C)
{
    if (bReInit)
    {
        ShrinkToFit(C, 3);
    }
    return Super.InternalOnPreDraw(C);
}

function DrawRow(Canvas C, int Row, float X, float Y, float W, float H)
{
    local VotingHandler.MapVoteScore Entry;

    Super.DrawRow(C, Row, X, Y, W, H);
    Entry = VRI.MapVoteCount[SortData[Row].SortItem];
    GetCellLeftWidth(3, X, W);
    Style.DrawText(
        C, MenuState, X, Y, W, H, TXTA_Left, VRI.GameConfig[Entry.GameConfigIndex].GameName, FontScale);
    GetCellLeftWidth(4, X, W);
    Style.DrawText(C, MenuState, X, Y, W, H, TXTA_Left, string(Entry.VoteCount), FontScale);
}

function string GetNormalizedSortString(int Row, int Column)
{
    switch (Column)
    {
        case 3:
            return NormalizeString(VRI.GameConfig[VRI.MapVoteCount[Row].GameConfigIndex].GameName);
        case 4:
            return NormalizeInt(VRI.MapVoteCount[Row].VoteCount, 6);
        default:
            break;
    }
    return "";
}

defaultproperties
{
    ColumnHeadings(3)="Game Type"
    ColumnHeadings(4)="Votes"
    ColumnHeadingHints(3)="Click to sort by game type."
    ColumnHeadingHints(4)="Click to sort by number of votes."

    SortColumn=4
    SortDescending=true
}
