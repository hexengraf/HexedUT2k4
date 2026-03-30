class HxMapVotingMapList extends HxMapVotingBaseList;

var private HxMapFilter ActiveFilter;
var private array<string> Prefixes;

function PopulateList()
{
    local HxFavorites.EHxTag MapTag;
    local int i;

    for (i = 0; i < VRI.MapList.Length; ++i)
    {
        MapTag = class'HxMapFavorites'.static.GetMapTag(VRI.MapList[i].MapName);
        if (PrefixMatch(VRI.MapList[i].MapName) && ActiveFilter.Match(VRI.MapList[i], MapTag))
        {
            AddMap(i, MapTag);
        }
    }
}

function bool PrefixMatch(string MapName)
{
    local int i;

    for (i = 0; i < Prefixes.Length; ++i)
    {
        if (StrCmp(MapName, Prefixes[i], len(Prefixes[i])) == 0)
        {
            return true;
        }
    }
    return false;
}

function SetFilter(HxMapFilter Filter)
{
    ActiveFilter = Filter;
    Refresh();
}

function SetPrefix(string Prefix)
{
    Prefixes.Length = 0;
    Split(Prefix, ",", Prefixes);
    Refresh();
}

function SearchName(string SearchTerm)
{
    ActiveFilter.SearchName(SearchTerm);
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

    Super.DrawRow(C, Row, X, Y, W, H);
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
    ColumnHeadingHints(4)="Click to sort by number of times played."

    SortColumn=1
    PreviousSortColumn=2
}
