class HxGUIVotingVoteList extends HxGUIVotingBaseList;

function PopulateList()
{
    local int i;

    Clear();
    for (i = 0; i < VRI.MapVoteCount.Length; ++i)
    {
        AddMap(VRI.MapVoteCount[i].MapIndex);
    }
    Sort();
}

function UpdatedVoteCount(int UpdatedIndex, bool bRemoved)
{
    if (bRemoved)
    {
        RemoveMap(UpdatedIndex);
    }
    else if (UpdatedIndex >= ItemCount)
    {
        AddMap(VRI.MapVoteCount[UpdatedIndex].MapIndex);
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
    local GUIMultiColumnListHeader Header;
    local float Width;
    local float NewPerc;

    if (bReInit)
    {
        Header = GUIMultiColumnListBox(MenuOwner).Header;
        CellSpacing = ColumnSpacing * C.ClipX;
        class'HxGUIController'.static.GetFontSize(Header, C, ColumnHeadings[4], Width);
        NewPerc = FMax(0.1, (Width + (2 * CellSpacing)) / MenuOwner.ActualWidth());
        InitColumnPerc[2] += InitColumnPerc[4] - NewPerc;
        InitColumnPerc[4] = NewPerc;
    }
    return Super.InternalOnPreDraw(C);
}

function DrawRow(Canvas C, int Row, float X, float Y, float W, float H)
{
    local VotingHandler.MapVoteScore Entry;

    Entry = VRI.MapVoteCount[SortData[Row].SortItem];
    GetCellLeftWidth(3, X, W);
    Style.DrawText(
        C, MenuState, X, Y, W, H, TXTA_Left, VRI.GameConfig[Entry.GameConfigIndex].GameName, FontScale);
    GetCellLeftWidth(4, X, W);
    Style.DrawText(C, MenuState, X, Y, W, H, TXTA_Left, string(Entry.VoteCount), FontScale);
}

function string GetNormalizedString(int Row, int Column)
{
    switch (Column)
    {
        case 3:
            return left(Caps(VRI.GameConfig[VRI.MapVoteCount[Row].GameConfigIndex].GameName), 32);
        default:
            break;
    }
    return NormalizeNumber(VRI.MapVoteCount[Row].VoteCount);
}

defaultproperties
{
    ColumnHeadings(3)="Game Type"
    ColumnHeadings(4)="Votes"
    ColumnHeadingHints(3)="Click to sort by game type."
    ColumnHeadingHints(4)="Click to sort by number of votes."

    SortColumn=4
    PreviousSortColumn=4
    SortDescending=true
}
