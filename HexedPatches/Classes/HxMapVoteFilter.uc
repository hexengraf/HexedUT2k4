class HxMapVoteFilter extends Object
    Config(HxMapVoteFilters)
    PerObjectConfig;

enum EHxMapSource
{
    HX_MAP_SOURCE_Any,
    HX_MAP_SOURCE_Official,
    HX_MAP_SOURCE_Custom,
};

enum EHxOperation
{
    HX_OPERATION_DontCare,
    HX_OPERATION_LessThan,
    HX_OPERATION_GreaterThan,
    HX_OPERATION_EqualTo,
    HX_OPERATION_EqualTo_Implicit,
};

struct HxPseudoRegex
{
    var bool bEnabled;
    var bool bCaseSensitive;
    var string Prefix;
    var string Suffix;
    var array<string> Parts;
};

struct HxValueConstraint
{
    var EHxOperation Operation;
    var int Value;
};

struct HxRangeConstraint
{
    var HxValueConstraint Min;
    var HxValueConstraint Max;
};

struct HxSearchBar
{
    var HxPseudoRegex Name;
    var HxRangeConstraint Players;
    var HxValueConstraint Played;
    var HxValueConstraint Recent;
};

var config string Name;

var EHxMapSource MapSource;
var array<string> Prefixes;
var HxSearchBar SearchBar;

function bool Match(VotingHandler.MapVoteMapList Entry)
{
    return SourceMatch(Entry.MapName)
        && PrefixMatch(Entry.MapName)
        && RegexMatch(Entry.MapName, SearchBar.Name)
        && ValueMatch(Entry.PlayCount, SearchBar.Played)
        && ValueMatch(Entry.Sequence, SearchBar.Recent)
        && PropertiesMatch(Entry.MapName);
}

function bool PropertiesMatch(string MapName)
{
    local CacheManager.MapRecord Record;

    Record = class'CacheManager'.static.GetMapRecord(MapName);
    return RangeMatch(Record.PlayerCountMin, Record.PlayerCountMax, SearchBar.Players);
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

function SearchName(string RawString, optional bool bCaseSensitive)
{
    SearchBar.Name = ParseRegex(RawString, bCaseSensitive);
}

function SearchPlayers(string RawString)
{
    SearchBar.Players = ParseRangeConstraint(RawString);
}

function SearchPlayed(string RawString)
{
    SearchBar.Played = ParseValueConstraint(RawString);
}

function SearchRecent(string RawString)
{
    SearchBar.Recent = ParseValueConstraint(RawString);
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

static function HxPseudoRegex ParseRegex(string RawString, optional bool bCaseSensitive)
{
    local HxPseudoRegex Regex;
    local int Length;
    local int i;

    Regex.bCaseSensitive = bCaseSensitive;

    if (RawString == "")
    {
        return Regex;
    }
    if (!bCaseSensitive)
    {
        RawString = Caps(RawString);
    }
    Split(RawString, "*", Regex.Parts);
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

static function HxRangeConstraint ParseRangeConstraint(string RawString)
{
    local HxRangeConstraint Constraint;
    local string Min;
    local string Max;

    ReplaceText(RawString, " ", "");
    if (RawString == "")
    {
        return Constraint;
    }
    if (Divide(RawString, "-", Min, Max))
    {
        Constraint.Min = ParseValueConstraint(Min);
        Constraint.Max = ParseValueConstraint(Max);
    }
    else
    {
        Constraint.Min = ParseValueConstraint(RawString);
        if (Constraint.Min.Operation == HX_OPERATION_EqualTo_Implicit)
        {
            Constraint.Max.Operation = HX_OPERATION_GreaterThan;
            Constraint.Max.Value = Constraint.Min.Value - 1;
            Constraint.Min.Operation = HX_OPERATION_LessThan;
            Constraint.Min.Value = Constraint.Min.Value + 1;
        }
        else
        {
            Constraint.Max = Constraint.Min;
        }
    }
    return Constraint;
}

static function HxValueConstraint ParseValueConstraint(string RawString)
{
    local HxValueConstraint Constraint;
    local string Operation;

    if (InStr(RawString, "*") > -1 || RawString == "")
    {
        return Constraint;
    }
    Operation = Left(RawString, 1);
    if (Operation == "<")
    {
        RawString = Right(RawString, Len(RawString) - 1);
        Constraint.Operation = HX_OPERATION_LessThan;
    }
    else if (Operation == ">")
    {
        RawString = Right(RawString, Len(RawString) - 1);
        Constraint.Operation = HX_OPERATION_GreaterThan;
    }
    else if (Operation == "=")
    {
        RawString = Right(RawString, Len(RawString) - 1);
        Constraint.Operation = HX_OPERATION_EqualTo;
    }
    else
    {
        Constraint.Operation = HX_OPERATION_EqualTo_Implicit;
    }
    if (RawString != "")
    {
        Constraint.Value = int(RawString);
    }
    return Constraint;
}

static function bool RegexMatch(string Text, HxPseudoRegex Regex)
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

function bool RangeMatch(int Min, int Max, HxRangeConstraint Constraint)
{
    return ValueMatch(Min, Constraint.Min) && ValueMatch(Max, Constraint.Max);
}

function bool ValueMatch(int Value, HxValueConstraint Constraint)
{
    switch (Constraint.Operation)
    {
        case HX_OPERATION_DontCare:
            return true;
        case HX_OPERATION_LessThan:
            return Value < Constraint.Value;
        case HX_OPERATION_GreaterThan:
            return Value > Constraint.Value;
        case HX_OPERATION_EqualTo:
        case HX_OPERATION_EqualTo_Implicit:
            return Value == Constraint.Value;
        default:
            break;
    }
    return true;
}

defaultproperties
{
    Name="None"
    MapSource=HX_MAP_SOURCE_Any
}
