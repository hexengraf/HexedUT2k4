class HxGUIVotingMapList extends HxGUIVotingBaseList
    DependsOn(HxTiers);

var private array<int> MapIndices;
var private array<string> MapTiers;
var private HxMapVoteFilter ActiveFilter;

function PopulateList()
{
    local HxTiers.EHxTier Tier;
    local int i;

    Clear();
    for (i = 0; i < VRI.MapList.Length; ++i)
    {
        Tier = class'HxTiers'.static.GetTier(VRI.MapList[i].MapName);
        if (ActiveFilter.Match(VRI.MapList[i], Tier))
        {
            MapIndices[MapIndices.Length] = i;
            MapTiers[MapTiers.Length] = class'HxTiers'.static.TierToName(Tier);
            AddedItem();
        }
    }
    Sort();
}

function int GetMapIndex()
{
    if(Index > -1)
    {
        return MapIndices[SortData[Index].SortItem];
    }
    return -1;
}

function string GetMapName()
{
    if(Index > -1)
    {
        return GetVRIEntry(SortData[Index].SortItem).MapName;
    }
    return "";
}

function bool SetIndexByMapName(string MapName)
{
    local int i;

    if (MapName != "")
    {
        for (i = 0; i < MapIndices.Length; ++i)
        {
            if (GetVRIEntry(SortData[i].SortItem).MapName == MapName)
            {
                SetTopItem(i - ItemsPerPage / 2);
                SetIndex(i);
                return true;
            }
        }
    }
    return false;
}

function SetFilter(HxMapVoteFilter Filter)
{
    ActiveFilter = Filter;
    Refresh();
}

function SetPrefix(string Prefix)
{
    ActiveFilter.SetPrefix(Prefix);
    Refresh();
}

function SetMapSource(int Source)
{
    ActiveFilter.SetMapSource(Source);
    Refresh();
}

function SearchName(string SearchTerm, optional bool bCaseSensitive)
{
    ActiveFilter.SearchName(SearchTerm, bCaseSensitive);
    Refresh();
}

function SearchTier(string SearchTerm)
{
    ActiveFilter.SearchTier(SearchTerm);
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

function SearchRecent(string SearchTerm)
{
    ActiveFilter.SearchRecent(SearchTerm);
    Refresh();
}


function Clear()
{
    MapIndices.Remove(0, MapIndices.Length);
    MapTiers.Remove(0, MapTiers.Length);
    Super.Clear();
}

function VotingHandler.MapVoteMapList GetVRIEntry(int Row)
{
    return VRI.MapList[MapIndices[Row]];
}

function DrawRow(Canvas C, GUIStyles DrawStyle, int Row, float Y, float H)
{
    local VotingHandler.MapVoteMapList Entry;
    local CacheManager.MapRecord Record;
    local eMenuState S;
    local float X;
    local float W;

    Entry = GetVRIEntry(SortData[Row].SortItem);
    Record = class'CacheManager'.static.GetMapRecord(Entry.MapName);

    if (!Entry.bEnabled)
    {
        S = MSAT_Disabled;
    }
    else
    {
        S = MenuState;
    }
    GetCellLeftWidth(0, X, W);
    DrawStyle.DrawText(C, S, X, Y, W, H, TXTA_Left, Entry.MapName, FontScale);
    GetCellLeftWidth(1, X, W);
    DrawStyle.DrawText(C, S, X, Y, W, H, TXTA_Left, MapTiers[SortData[Row].SortItem], FontScale);
    GetCellLeftWidth(2, X, W);
    DrawStyle.DrawText(C, S, X, Y, W, H, TXTA_Left, GetMapSizeString(Record), FontScale);
    GetCellLeftWidth(3, X, W);
    DrawStyle.DrawText(C, S, X, Y, W, H, TXTA_Left, string(Entry.PlayCount), FontScale);
    GetCellLeftWidth(4, X, W);
    DrawStyle.DrawText(C, S, X, Y, W, H, TXTA_Left, string(Entry.Sequence), FontScale);
}

function string GetNormalizedString(int Row, int Column)
{
    local VotingHandler.MapVoteMapList Entry;
    local CacheManager.MapRecord Record;

    Entry = GetVRIEntry(Row);
    switch (Column)
    {
        case 1:
            if (MapTiers[Row] == "")
            {
                return "Z";
            }
            return MapTiers[Row];
        case 2:
            Record = class'CacheManager'.static.GetMapRecord(Entry.MapName);
            if (Record.PlayerCountMax == 0) {
                return "999999999999";
            }
            return NormalizeNumber(Record.PlayerCountMin)$NormalizeNumber(Record.PlayerCountMax);
        case 3:
            return NormalizeNumber(Entry.PlayCount);
        case 4:
            if (Entry.Sequence == 0) {
                return "999999";
            }
            return NormalizeNumber(Entry.Sequence);
        default:
            break;
    }
    return left(Caps(Entry.MapName), 20);
}

function string GetMapSizeString(CacheManager.MapRecord Record)
{
    if (Record.PlayerCountMax == 0) {
        return "?";
    }
    if (Record.PlayerCountMin == Record.PlayerCountMax)
    {
        return string(Record.PlayerCountMin);
    }
    return Record.PlayerCountMin@"-"@Record.PlayerCountMax;
}

function OnSelectTier(GUIContextMenu Sender, int Option)
{
    local HxTiers.EHxTier Tier;

    if (Index > -1)
    {
        Tier = EHxTier(6 - Option);
        class'HxTiers'.static.SetTier(GetMapName(), Tier);
        MapTiers[SortData[Index].SortItem] = class'HxTiers'.static.TierToName(Tier);
        Refresh();
    }
}

static function string NormalizeNumber(int Value)
{
    return right("000000" $ Value, 6);
}

defaultproperties
{
    Begin Object Class=GUIContextMenu Name=GradingContextMenu
        ContextItems(0)="Add to A tier"
        ContextItems(1)="Add to B tier"
        ContextItems(2)="Add to C tier"
        ContextItems(3)="Add to D tier"
        ContextItems(4)="Add to E tier"
        ContextItems(5)="Add to F tier"
        ContextItems(6)="Remove tier"
        OnSelect=OnSelectTier
    End Object
    ContextMenu=GradingContextMenu

    ColumnHeadings(0)="Map Name"
    ColumnHeadings(1)="Tier"
    ColumnHeadings(2)="Players"
    ColumnHeadings(3)="Played"
    ColumnHeadings(4)="Recent"
    ColumnHeadingHints(0)="Click to sort by map name."
    ColumnHeadingHints(1)="Click to sort by tier."
    ColumnHeadingHints(2)="Click to sort by number of recommended players."
    ColumnHeadingHints(3)="Click to sort by number of times the map has been played."
    ColumnHeadingHints(4)="Click to sort by how recently this map has been played."

    SortColumn=0
    PreviousSortColumn=0
}
