class HxMapVoteFilter extends Object
	Config(HxMapVoteFilters)
	PerObjectConfig;

enum EHxMapSource
{
    HX_MAP_SOURCE_Any,
    HX_MAP_SOURCE_Official,
    HX_MAP_SOURCE_Custom,
};

struct HxPseudoRegex
{
    var bool bEnabled;
    var bool bCaseSensitive;
    var string Prefix;
    var string Suffix;
    var array<string> Parts;
};

var config string Name;

var EHxMapSource MapSource;
var array<string> Prefixes;
var HxPseudoRegex NameSearch;

function bool Test(VotingHandler.MapVoteMapList Entry)
{
    return TestSource(Entry.MapName) && TestPrefix(Entry.MapName) && MatchName(Entry.MapName);
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

function bool MatchName(string MapName)
{
    return RegexMatch(MapName, NameSearch);
}

function bool RegexMatch(string Text, HxPseudoRegex Regex)
{
    local int Position;
    local int Size;
    local int i;

    if (!Regex.bEnabled)
    {
        return true;
    }
    if (!Regex.bCaseSensitive)
    {
        Text = Caps(Text);
    }
    if (Regex.Prefix != "")
    {
        Log("Prefix:"@Regex.Prefix);
        Size = Len(Regex.Prefix);
        if (StrCmp(Text, Regex.Prefix, Size, Regex.bCaseSensitive) != 0)
        {
            return false;
        }
        Text = Mid(Text, Size);
    }
    for (i = 0; i < Regex.Parts.Length; ++i)
    {
        Position = InStr(Text, Regex.Parts[i]);
        if (Position < 0)
        {
            return false;
        }
        Text = Mid(Text, Position + Len(Regex.Parts[i]));
    }
    if (Regex.Suffix != "")
    {
        Size = Len(Regex.Suffix);
        if (StrCmp(Right(Text, Size), Regex.Suffix, Size, Regex.bCaseSensitive) != 0)
        {
            return false;
        }
    }
    return true;
}

function SetNameSearch(string RawRegex, optional bool bCaseSensitive)
{
    NameSearch = ParseRegex(RawRegex, bCaseSensitive);
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

static function HxPseudoRegex ParseRegex(string RawRegex, optional bool bCaseSensitive)
{
    local HxPseudoRegex Regex;
    local int Length;
    local int i;

    Regex.bCaseSensitive = bCaseSensitive;

    if (RawRegex == "")
    {
        return Regex;
    }
    if (!bCaseSensitive)
    {
        RawRegex = Caps(RawRegex);
    }
    Split(RawRegex, "*", Regex.Parts);
    if (StrCmp(Regex.Parts[0], "^", 1) == 0)
    {
        if (Len(Regex.Parts[0]) > 1)
        {
            Regex.Prefix = Mid(Regex.Parts[0], 1);
        }
        Regex.Parts.Remove(0, 1);
    }
    if (Regex.Parts.Length > 0)
    {
        i = Regex.Parts.Length - 1;
        if (Right(Regex.Parts[i], 1) == "$")
        {
            Length = Len(Regex.Parts[i]);
            if (Length > 1)
            {
                Regex.Suffix = Left(Regex.Parts[i], Length - 1);
            }
            Regex.Parts.Remove(i, 1);
        }
    }
    i = 0;
    while (i < Regex.Parts.Length)
    {
        if (Regex.Parts[i] == "")
        {
            Regex.Parts.Remove(i, 1);
        }
        else
        {
            ++i;
        }
    }
    Regex.bEnabled = Regex.Parts.Length > 0 || Regex.Prefix != "" || Regex.Suffix != "";
    return Regex;
}

defaultproperties
{
    Name="None"
    MapSource=HX_MAP_SOURCE_Any
}
