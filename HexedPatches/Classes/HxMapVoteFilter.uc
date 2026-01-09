class HxMapVoteFilter extends Object;

enum EHxMapSource
{
    HX_MAP_SOURCE_Any,
    HX_MAP_SOURCE_Official,
    HX_MAP_SOURCE_Custom,
};

var EHxMapSource MapSourceFilter;
var array<string> Prefixes;

static function bool Filter(VotingHandler.MapVoteMapList Entry)
{
    return FilterBySource(Entry.MapName) && FilterByType(Entry.MapName);
}

static function bool FilterByType(string MapName)
{
    local int Prefix;

    for (Prefix = 0; Prefix < default.Prefixes.Length; ++Prefix)
    {
        if (StrCmp(MapName, default.Prefixes[Prefix], len(default.Prefixes[Prefix])) == 0)
        {
            return true;
        }
    }
    return false;
}

static function bool FilterBySource(string MapName)
{
    switch (default.MapSourceFilter)
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

static function SetGameTypeFilter(string Prefix)
{
    default.Prefixes.Length = 0;
    Split(Prefix, ",", default.Prefixes);
}

static function SetMapSourceFilter(int Source)
{
    default.MapSourceFilter = EHxMapSource(Source);
}

defaultproperties
{
    MapSourceFilter=HX_MAP_SOURCE_Any
}
