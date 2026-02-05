class HxGUIVotingMapList extends HxGUIVotingBaseList;

var private HxMapVoteFilter ActiveFilter;

function PopulateList()
{
    local int i;

    for (i = 0; i < VRI.MapList.Length; ++i)
    {
        if (ActiveFilter.Match(VRI.MapList[i]))
        {
            AddMap(i);
        }
    }
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
    if (bReInit)
    {
        ShrinkToFit(C, 2);
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

function string GetNormalizedSortString(int Row, int Column)
{
    local VotingHandler.MapVoteMapList Entry;
    local CacheManager.MapRecord Record;

    Entry = VRI.MapList[MapIndices[Row]];
    switch (Column)
    {
        case 3:
            Record = class'CacheManager'.static.GetMapRecord(Entry.MapName);
            if (Record.PlayerCountMax == 0) {
                return "999999";
            }
            return NormalizeInt(Record.PlayerCountMin, 3)$NormalizeInt(Record.PlayerCountMax, 3);
        case 4:
            return NormalizeInt(Entry.PlayCount, 7);
        default:
            break;
    }
    return "";
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
}
