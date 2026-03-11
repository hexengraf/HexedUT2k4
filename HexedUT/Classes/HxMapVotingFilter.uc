class HxMapVotingFilter extends HxPatternMatch
    config(HxMapVotingFilters)
    PerObjectConfig;

enum EHxMapSource
{
    HX_MAP_SOURCE_Any,
    HX_MAP_SOURCE_Official,
    HX_MAP_SOURCE_Custom,
};

struct HxSearchBar
{
    var HxStringPattern Name;
    var HxRangePattern Players;
    var HxValuePattern Played;
    var HxValuePattern Recent;
};

var config string Name;

var EHxMapSource MapSource;
var array<string> Prefixes;
var HxSearchBar SearchBar;

function bool Match(VotingHandler.MapVoteMapList Entry)
{
    return SourceMatch(Entry.MapName)
        && PrefixMatch(Entry.MapName)
        && StringPatternMatch(Entry.MapName, SearchBar.Name)
        && ValuePatternMatch(Entry.PlayCount, SearchBar.Played)
        && ValuePatternMatch(Entry.Sequence, SearchBar.Recent)
        && CacheRecordMatch(Entry.MapName);
}

function bool CacheRecordMatch(string MapName)
{
    local CacheManager.MapRecord Record;

    Record = class'CacheManager'.static.GetMapRecord(MapName);
    return RangePatternMatch(Record.PlayerCountMin, Record.PlayerCountMax, SearchBar.Players);
}

function bool SourceMatch(string MapName)
{
    switch (MapSource)
    {
        case HX_MAP_SOURCE_Any:
            return true;
        case HX_MAP_SOURCE_Official:
            return class'CacheManager'.static.IsDefaultContent(MapName);
        case HX_MAP_SOURCE_Custom:
            return !class'CacheManager'.static.IsDefaultContent(MapName);
    }
    return true;
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

function SearchName(string SearchTerm, optional bool bCaseSensitive)
{
    SearchBar.Name = ParseStringPattern(SearchTerm, bCaseSensitive);
}

function SearchPlayers(string SearchTerm)
{
    SearchBar.Players = ParseRangePattern(SearchTerm);
}

function SearchPlayed(string SearchTerm)
{
    SearchBar.Played = ParseValuePattern(SearchTerm);
}

function SearchRecent(string SearchTerm)
{
    SearchBar.Recent = ParseValuePattern(SearchTerm);
}

function SetPrefix(string Prefix)
{
    Prefixes.Length = 0;
    Split(Prefix, ",", Prefixes);
}

function SetMapSource(int Source)
{
    MapSource = EHxMapSource(Source);
}

defaultproperties
{
    Name="None"
    MapSource=HX_MAP_SOURCE_Any
}
