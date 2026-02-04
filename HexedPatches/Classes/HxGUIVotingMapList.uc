class HxGUIVotingMapList extends HxGUIVotingBaseList;

var private HxMapVoteFilter ActiveFilter;

function PopulateList()
{
    local int i;

    Clear();
    for (i = 0; i < VRI.MapList.Length; ++i)
    {
        if (ActiveFilter.Match(VRI.MapList[i]))
        {
            AddMap(i);
        }
    }
    Sort();
}

function SetFilter(HxMapVoteFilter Filter)
{
    ActiveFilter = Filter;
    Refresh();
}

function SetPrefix(string Prefix)
{
    ActiveFilter.SetPrefix(Prefix);
    Refresh();
}

function SetMapSource(int Source)
{
    ActiveFilter.SetMapSource(Source);
    Refresh();
}

function SearchName(string SearchTerm, optional bool bCaseSensitive)
{
    ActiveFilter.SearchName(SearchTerm, bCaseSensitive);
    Refresh();
}

function SearchPlayers(string SearchTerm)
{
    ActiveFilter.SearchPlayers(SearchTerm);
    Refresh();
}

function SearchPlayed(string SearchTerm)
{
    ActiveFilter.SearchPlayed(SearchTerm);
    Refresh();
}

function SearchRecent(string SearchTerm)
{
    ActiveFilter.SearchRecent(SearchTerm);
    Refresh();
}

function bool InternalOnPreDraw(Canvas C)
{
    local GUIMultiColumnListHeader Header;
    local float OwnerWidth;
    local float Width;
    local int i;

    if (bReInit)
    {
        OwnerWidth =  MenuOwner.ActualWidth();
        Header = GUIMultiColumnListBox(MenuOwner).Header;
        CellSpacing = ColumnSpacing * C.ClipX;
        InitColumnPerc[2] = 1.0 - InitColumnPerc[0] - InitColumnPerc[1];
        for (i = 3; i < InitColumnPerc.Length; ++i)
        {
            class'HxGUIController'.static.GetFontSize(Header, C, ColumnHeadings[i], Width);
            InitColumnPerc[i] = FMax(0.1, (Width + (2 * CellSpacing)) / OwnerWidth);
            InitColumnPerc[2] -= InitColumnPerc[i];
        }
    }
    return Super.InternalOnPreDraw(C);
}

function DrawRow(Canvas C, int Row, float X, float Y, float W, float H)
{
    local VotingHandler.MapVoteMapList Entry;
    local CacheManager.MapRecord Record;

    Entry = VRI.MapList[GetSortedMapIndex(Row)];
    Record = class'CacheManager'.static.GetMapRecord(Entry.MapName);

    GetCellLeftWidth(3, X, W);
    Style.DrawText(
        C, MenuState, X, Y, W, H, TXTA_Left,
        GetMapSizeString(Record.PlayerCountMin, Record.PlayerCountMax), FontScale);
    GetCellLeftWidth(4, X, W);
    Style.DrawText(C, MenuState, X, Y, W, H, TXTA_Left, string(Entry.PlayCount), FontScale);
}

function string GetNormalizedString(int Row, int Column)
{
    local VotingHandler.MapVoteMapList Entry;
    local CacheManager.MapRecord Record;

    Entry = VRI.MapList[MapIndices[Row]];
    switch (Column)
    {
        case 2:
            Record = class'CacheManager'.static.GetMapRecord(Entry.MapName);
            if (Record.PlayerCountMax == 0) {
                return "999999999999";
            }
            return NormalizeNumber(Record.PlayerCountMin)$NormalizeNumber(Record.PlayerCountMax);
        default:
            break;
    }
    return NormalizeNumber(Entry.PlayCount);
}

static function string GetMapSizeString(int PlayerCountMin, int PlayerCountMax)
{
    if (PlayerCountMax == 0) {
        return "?";
    }
    if (PlayerCountMin == PlayerCountMax)
    {
        return string(PlayerCountMin);
    }
    return PlayerCountMin@"-"@PlayerCountMax;
}

defaultproperties
{
    ColumnHeadings(3)="Players"
    ColumnHeadings(4)="Played"
    ColumnHeadingHints(3)="Click to sort by number of recommended players."
    ColumnHeadingHints(4)="Click to sort by number of times the map has been played."

    SortColumn=2
    PreviousSortColumn=2
}
