class HxGUIVotingVoteList extends HxGUIVotingBaseList
    DependsOn(HxFavorites);

var private array<string> MapMarks;

function PopulateList()
{
    local int i;

    Clear();
    for (i = 0; i < VRI.MapVoteCount.Length; ++i)
    {
        AddMap(VRI.MapVoteCount[i].MapIndex);
    }
}

function AddMap(int MapIndex)
{
    AddedItem();
    MapMarks[MapMarks.Length] = class'HxFavorites'.static.GetMapMarkName(
        VRI.MapList[MapIndex].MapName);
}

function RemoveMap(int Position)
{
    RemovedItem(Position);
    MapMarks.Remove(SortData[Position].SortItem, 1);
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

function UpdateMapMark(int MapIndex, HxFavorites.EHxMark NewMark)
{
    local int i;

    for (i = 0; i < VRI.MapVoteCount.Length; ++i)
    {
        if (MapIndex == -1 || VRI.MapVoteCount[i].MapIndex == MapIndex)
        {
            MapMarks[SortData[i].SortItem] = class'HxFavorites'.static.MarkToName(NewMark);
            UpdatedItem(i);
        }
    }
}

function Clear()
{
    MapMarks.Remove(0, MapMarks.Length);
    Super.Clear();
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

function bool SetIndexByMapName(string MapName)
{
    local int i;

    if (MapName != "")
    {
        for (i = 0; i < VRI.MapVoteCount.Length; ++i)
        {
            if (VRI.MapList[VRI.MapVoteCount[i].MapIndex].MapName == MapName)
            {
                SetTopItem(i - ItemsPerPage / 2);
                SetIndex(i);
                return true;
            }
        }
    }
    return false;
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
    GetCellLeftWidth(0, X, W);
    DrawStyle.DrawText(
        C, MenuState, X, Y, W, H, TXTA_Center, MapMarks[SortData[Row].SortItem], FontScale);
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
        case 1:
            return left(Caps(VRI.MapList[VRI.MapVoteCount[Row].MapIndex].MapName), 32);
        case 2:
            return left(Caps(VRI.GameConfig[VRI.MapVoteCount[Row].GameConfigIndex].GameName), 32);
        case 3:
            return NormalizeNumber(VRI.MapVoteCount[Row].VoteCount);
        default:
            break;
    }
    return string(int(class'HxFavorites'.static.NameToMark(MapMarks[Row])));
}

defaultproperties
{
    ColumnHeadings(0)="Mark"
    ColumnHeadings(1)="Map Name"
    ColumnHeadings(2)="Game Type"
    ColumnHeadings(3)="Votes"
    ColumnHeadingHints(0)="Click to sort by mark."
    ColumnHeadingHints(1)="Click to sort by map name."
    ColumnHeadingHints(2)="Click to sort by game type."
    ColumnHeadingHints(3)="Click to sort by number of votes."

    SortColumn=3
    PreviousSortColumn=3
    SortDescending=true
}
