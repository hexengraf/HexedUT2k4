class HxMapVoteFilter extends Object
	Config(HxMapVoteFilters)
	PerObjectConfig;

enum EHxMapSource
{
    HX_MAP_SOURCE_Any,
    HX_MAP_SOURCE_Official,
    HX_MAP_SOURCE_Custom,
};

var config string Name;

var EHxMapSource MapSource;
var array<string> Prefixes;

function bool Test(VotingHandler.MapVoteMapList Entry)
{
    return TestSource(Entry.MapName) && TestPrefix(Entry.MapName);
}

function bool TestPrefix(string MapName)
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

function bool TestSource(string MapName)
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
