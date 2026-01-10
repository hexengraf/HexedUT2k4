class HxMapVoteFilterManager extends Object;

var localized string PredefinedFilterName;

var HxMapVoteFilter DefaultFilter;
var array<HxMapVoteFilter> LoadedFilters;

function HxMapVoteFilter GetFilter(optional string FilterName)
{
    local int i;

    if (FilterName != "")
    {
        for (i = 0; i < LoadedFilters.Length; ++i)
        {
            if (LoadedFilters[i].Name ~= FilterName)
            {
                return LoadedFilters[i];
            }
        }
        return NewFilter(FilterName);
    }
    if (DefaultFilter == None)
    {
        DefaultFilter = new(Self) class'HxMapVoteFilter';
    }
    return DefaultFilter;
}

function HxMapVoteFilter NewFilter(optional string FilterName)
{
    local int i;

    if (FilterName == "")
    {
        FilterName = PredefinedFilterName$"#"$LoadedFilters.Length;
    }
    i = LoadedFilters.Length;
    LoadedFilters[i] = new(Self, Repl(FilterName, " ", Chr(27))) class'HxMapVoteFilter';
    LoadedFilters[i].Name = FilterName;
    return LoadedFilters[i];
}

static function array<string> GetFilterNames()
{
    return GetPerObjectNames("HxMapVoteFilters", "HxMapVoteFilter");
}

defaultproperties
{
    PredefinedFilterName="Filter"
}
