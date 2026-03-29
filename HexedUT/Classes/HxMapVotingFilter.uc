class HxMapVotingFilter extends HxPatternMatch
    config(HexedFilters)
    PerObjectConfig;

enum EHxMapSource
{
    HX_MAP_SOURCE_Any,
    HX_MAP_SOURCE_Official,
    HX_MAP_SOURCE_Custom,
};

struct HxMapFilterRules
{
    var HxStringPattern Name;
    var HxStringPattern Author;
    var HxRangePattern Players;
    var HxValuePattern Played;
    var EHxMapSource Source;
    var HxFavorites.EHxTag Tag;
};

struct HxMapSearchRules
{
    var HxStringPattern Name;
    var HxRangePattern Players;
    var HxValuePattern Played;
};

var config string MapName;
var config string AuthorName;
var config string NumPlayers;
var config string TimesPlayed;
var config EHxMapSource MapSource;
var config HxFavorites.EHxTag MapTag;
var config HxPatternMatch.EHxFilterMode FilterListMode;
var config array<string> FilterList;

var string Title;
var private HxMapFilterRules Rules;
var private HxMapSearchRules SearchRules;
var private bool bExplicitList;

event Created()
{
    ParseConfig();
}

function ParseConfig()
{
    Rules.Name = ParseStringPattern(MapName);
    Rules.Author = ParseStringPattern(AuthorName);
    Rules.Players = ParseRangePattern(NumPlayers);
    Rules.Played = ParseValuePattern(TimesPlayed);
    Rules.Source = MapSource;
    Rules.Tag = MapTag;
    bExplicitList = IsExplicitList();
}

function CopyConfig(HxMapVotingFilter From)
{
    MapName = From.MapName;
    AuthorName = From.AuthorName;
    NumPlayers = From.NumPlayers;
    TimesPlayed = From.TimesPlayed;
    MapSource = From.MapSource;
    MapTag = From.MapTag;
    FilterListMode = From.FilterListMode;
    FilterList = From.FilterList;
}

function CopySearchRules(HxMapVotingFilter From)
{
    SearchRules = From.SearchRules;
}

function bool Match(VotingHandler.MapVoteMapList Entry, HxFavorites.EHxTag Tag)
{
    local CacheManager.MapRecord Record;
    local int i;

    Record = class'CacheManager'.static.GetMapRecord(Entry.MapName);
    if (!StringPatternMatch(Entry.MapName, SearchRules.Name)
        || !RangePatternMatch(Record.PlayerCountMin, Record.PlayerCountMax, SearchRules.Players)
        || !ValuePatternMatch(Entry.PlayCount, SearchRules.Played))
    {
        return false;
    }
    for (i = 0; i < FilterList.Length; ++i)
    {
        if (FilterList[i] ~= Entry.MapName)
        {
            return FilterListMode == HX_FILTER_MODE_Include;
        }
        if (bExplicitList && FilterListMode == HX_FILTER_MODE_Exclude)
        {
            return true;
        }
    }
    return !bExplicitList
        && StringPatternMatch(Entry.MapName, Rules.Name)
        && StringPatternMatch(Record.Author, Rules.Author)
        && RangePatternMatch(Record.PlayerCountMin, Record.PlayerCountMax, Rules.Players)
        && ValuePatternMatch(Entry.PlayCount, Rules.Played)
        && SourceMatch(Entry.MapName, Rules.Source)
        && Rules.Tag == HX_TAG_Any || Rules.Tag == Tag;
}

function bool SourceMatch(string MapName, EHxMapSource Source)
{
    switch (Source)
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

function SearchName(string SearchTerm)
{
    SearchRules.Name = ParseStringPattern(SearchTerm);
}

function SearchPlayers(string SearchTerm)
{
    SearchRules.Players = ParseRangePattern(SearchTerm);
}

function SearchPlayed(string SearchTerm)
{
    SearchRules.Played = ParseValuePattern(SearchTerm);
}

function bool IsExplicitList()
{
    return FilterList.Length > 0
        && MapName == ""
        && AuthorName == ""
        && NumPlayers == ""
        && TimesPlayed == ""
        && MapSource == HX_MAP_SOURCE_Any
        && MapTag == HX_TAG_Any;
}

defaultproperties
{
    MapName=""
    AuthorName=""
    NumPlayers=""
    TimesPlayed=""
    MapSource=HX_MAP_SOURCE_Any
    MapTag=HX_TAG_Any
}
