class HxMapFilterManager extends Object;

const MAX_MAP_FILTERS = 1024;

var localized string DefaultFilterTitle;
var localized string OfficialMapsFilterTitle;
var localized string CustomMapsFilterTitle;

var private array<HxMapFilter> LoadedFilters;
var private HxMapFilter ActiveFilter;

event Created()
{
    local array<string> Names;
    local int i;

    CreateDefaultFilter();
    Names = GetPerObjectNames("HexedFilters", "HxMapFilter", MAX_MAP_FILTERS);
    if (Names.Length == 0)
    {
        CreateSourceFilters();
    }
    for (i = 0; i < Names.Length; ++i)
    {
        LoadedFilters[i + 1] = new(None, Names[i]) class'HxMapFilter';
        LoadedFilters[i + 1].Title = Repl(Names[i], Chr(27), " ");
    }
}

function CreateDefaultFilter()
{
    LoadedFilters.Insert(0, 1);
    LoadedFilters[0] = new(None) class'HxMapFilter';
    LoadedFilters[0].Title = DefaultFilterTitle;
}

function CreateSourceFilters()
{
    LoadedFilters.Insert(1, 1);
    LoadedFilters[1] = new(
        None, Repl(OfficialMapsFilterTitle, " ", Chr(27))) class'HxMapFilter';
    LoadedFilters[1].Title = OfficialMapsFilterTitle;
    LoadedFilters[1].MapSource = HX_MAP_SOURCE_Official;
    LoadedFilters[1].SaveConfig();
    LoadedFilters[1].ParseConfig();
    LoadedFilters.Insert(2, 1);
    LoadedFilters[2] = new(
        None, Repl(CustomMapsFilterTitle, " ", Chr(27))) class'HxMapFilter';
    LoadedFilters[2].Title = CustomMapsFilterTitle;
    LoadedFilters[2].MapSource = HX_MAP_SOURCE_Custom;
    LoadedFilters[2].SaveConfig();
    LoadedFilters[2].ParseConfig();
}

function HxMapFilter GetActiveFilter()
{
    if (ActiveFilter == None)
    {
        ActiveFilter = LoadedFilters[0];
    }
    return ActiveFilter;
}

function HxMapFilter SwitchActiveFilter(coerce int Index)
{
    if (IsValidIndex(Index))
    {
        if (ActiveFilter != None && ActiveFilter != LoadedFilters[Index])
        {
            LoadedFilters[Index].CopySearchRules(ActiveFilter);
        }
        ActiveFilter = LoadedFilters[Index];
    }
    return ActiveFilter;
}

function HxMapFilter GetFilter(optional coerce int Index)
{
    if (IsValidIndex(Index))
    {
        return LoadedFilters[Index];
    }
    return None;
}

function HxMapFilter NewFilter(string FilterName)
{
    local HxMapFilter Filter;

    if (!IsValidFilterName(FilterName))
    {
        return None;
    }
    Filter = new(None, Repl(FilterName, " ", Chr(27))) class'HxMapFilter';
    Filter.Title = FilterName;
    LoadedFilters[LoadedFilters.Length] = Filter;
    Filter.SaveConfig();
    return Filter;
}

function HxMapFilter RenameFilter(coerce int Index, string NewName)
{
    local HxMapFilter Filter;

    if (IsValidIndex(Index))
    {
        Filter = new(None, Repl(NewName, " ", Chr(27))) class'HxMapFilter';
        Filter.Title = NewName;
        Filter.CopyConfig(LoadedFilters[Index]);
        Filter.SaveConfig();
        LoadedFilters[Index].ClearConfig();
        LoadedFilters[Index] = Filter;
        return Filter;
    }
    return None;
}

function bool DeleteFilter(coerce int Index)
{
    if (IsValidIndex(Index))
    {
        if (ActiveFilter == LoadedFilters[Index])
        {
            LoadedFilters[0].CopySearchRules(ActiveFilter);
            ActiveFilter = LoadedFilters[0];
        }
        LoadedFilters[Index].ClearConfig();
        LoadedFilters.Remove(Index, 1);
        return true;
    }
    return false;
}

function bool IsValidIndex(int Index)
{
    return Index > -1 && Index < LoadedFilters.Length;
}

function bool IsValidFilterName(string FilterName)
{
    local int i;

    if (FilterName == "")
    {
        return false;
    }
    for (i = 0; i < LoadedFilters.Length; ++i)
    {
        if (LoadedFilters[i].Title ~= FilterName)
        {
            return false;
        }
    }
    return true;
}

function PopulateComboBox(moComboBox ComboBox, optional bool bSkipDefault)
{
    local int Start;
    local int i;

    if (bSkipDefault)
    {
        Start = 1;
    }
    else
    {
        Start = 0;
    }
    for (i = Start; i < LoadedFilters.Length; ++i)
    {
        ComboBox.AddItem(LoadedFilters[i].Title,, string(i));
    }
}

defaultproperties
{
    DefaultFilterTitle="All Maps"
    OfficialMapsFilterTitle="Official Maps"
    CustomMapsFilterTitle="Custom Maps"
}
