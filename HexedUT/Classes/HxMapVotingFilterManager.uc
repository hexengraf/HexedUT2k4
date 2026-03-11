class HxMapVotingFilterManager extends Object;

var localized string PredefinedFilterName;

var HxMapVotingFilter DefaultFilter;
var array<HxMapVotingFilter> LoadedFilters;

function HxMapVotingFilter GetFilter(optional string FilterName)
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
        DefaultFilter = new(Self) class'HxMapVotingFilter';
    }
    return DefaultFilter;
}

function HxMapVotingFilter NewFilter(optional string FilterName)
{
    local int i;

    if (FilterName == "")
    {
        FilterName = PredefinedFilterName$"#"$LoadedFilters.Length;
    }
    i = LoadedFilters.Length;
    LoadedFilters[i] = new(Self, Repl(FilterName, " ", Chr(27))) class'HxMapVotingFilter';
    LoadedFilters[i].Name = FilterName;
    return LoadedFilters[i];
}

static function array<string> GetFilterNames()
{
    return GetPerObjectNames("HxMapVotingFilters", "HxMapVotingFilter");
}

defaultproperties
{
    PredefinedFilterName="Filter"
}
