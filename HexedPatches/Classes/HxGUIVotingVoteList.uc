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
        class'HxGUIController'.static.GetFontSize(Header, C, ColumnHeadings[3], Width);
        NewPerc = FMax(0.1, (Width + (2 * CellSpacing)) / MenuOwner.ActualWidth());
        InitColumnPerc[1] += InitColumnPerc[3] - NewPerc;
        InitColumnPerc[3] = NewPerc;
    }
    return Super.InternalOnPreDraw(C);
}

function DrawRow(Canvas C, GUIStyles DrawStyle, int Row, float Y, float H)
{
    local VotingHandler.MapVoteScore Entry;
    local float X;
    local float W;

    Entry = VRI.MapVoteCount[SortData[Row].SortItem];
    GetCellLeftWidth(1, X, W);
    DrawStyle.DrawText(
        C, MenuState, X, Y, W, H, TXTA_Left, VRI.MapList[Entry.MapIndex].MapName, FontScale);
    GetCellLeftWidth(2, X, W);
    DrawStyle.DrawText(
        C, MenuState, X, Y, W, H, TXTA_Left, VRI.GameConfig[Entry.GameConfigIndex].GameName, FontScale);
    GetCellLeftWidth(3, X, W);
    DrawStyle.DrawText(C, MenuState, X, Y, W, H, TXTA_Left, string(Entry.VoteCount), FontScale);
}

function string GetNormalizedString(int Row, int Column)
{
    switch (Column)
    {
        case 2:
            return left(Caps(VRI.GameConfig[VRI.MapVoteCount[Row].GameConfigIndex].GameName), 32);
        case 3:
            return NormalizeNumber(VRI.MapVoteCount[Row].VoteCount);
        default:
            break;
    }
    return left(Caps(VRI.MapList[VRI.MapVoteCount[Row].MapIndex].MapName), 32);
}

defaultproperties
{
    ColumnHeadings(1)="Map Name"
    ColumnHeadings(2)="Game Type"
    ColumnHeadings(3)="Votes"
    ColumnHeadingHints(1)="Click to sort by map name."
    ColumnHeadingHints(2)="Click to sort by game type."
    ColumnHeadingHints(3)="Click to sort by number of votes."

    SortColumn=3
    PreviousSortColumn=3
    SortDescending=true
}
