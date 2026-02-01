class HxGUIVotingMapList extends HxGUIVotingBaseList
    DependsOn(HxFavorites);

var private array<int> MapIndices;
var private array<string> MapMarks;
var private HxMapVoteFilter ActiveFilter;

function PopulateList()
{
    local HxFavorites.EHxMark Mark;
    local int i;

    Clear();
    for (i = 0; i < VRI.MapList.Length; ++i)
    {
        Mark = class'HxFavorites'.static.GetMapMark(VRI.MapList[i].MapName);
        if (ActiveFilter.Match(VRI.MapList[i], Mark))
        {
            MapIndices[MapIndices.Length] = i;
            MapMarks[MapMarks.Length] = class'HxFavorites'.static.MarkToName(Mark);
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
    MapMarks.Remove(0, MapMarks.Length);
    Super.Clear();
}

function VotingHandler.MapVoteMapList GetVRIEntry(int Row)
{
    return VRI.MapList[MapIndices[Row]];
}

function bool InternalOnPreDraw(Canvas C)
{
    local GUIMultiColumnListHeader Header;
    local float OwnerWidth;
    local float Width;
    local int i;

    if (bReInit)
    {
        OwnerWidth =  MenuOwner.ActualWidth();
        Header = GUIMultiColumnListBox(MenuOwner).Header;
        CellSpacing = ColumnSpacing * C.ClipX;
        InitColumnPerc[0] = SearchBar.l_Search.ActualWidth() / OwnerWidth;
        InitColumnPerc[1] = 1.0 - InitColumnPerc[0];
        for (i = 2; i < InitColumnPerc.Length; ++i)
        {
            class'HxGUIController'.static.GetFontSize(Header, C, ColumnHeadings[i], Width);
            InitColumnPerc[i] = FMax(0.1, (Width + (2 * CellSpacing)) / OwnerWidth);
            InitColumnPerc[1] -= InitColumnPerc[i];
        }
    }
    return Super.InternalOnPreDraw(C);
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
    DrawStyle.DrawText(C, S, X, Y, W, H, TXTA_Center, MapMarks[SortData[Row].SortItem], FontScale);
    GetCellLeftWidth(1, X, W);
    DrawStyle.DrawText(C, S, X, Y, W, H, TXTA_Left, Entry.MapName, FontScale);
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
            return left(Caps(Entry.MapName), 20);
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
    return string(int(class'HxFavorites'.static.NameToMark(MapMarks[Row])));
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

function OnSelectMark(GUIContextMenu Sender, int Option)
{
    local HxFavorites.EHxMark Mark;

    if (Option == 3)
    {
        ClearAllMarks();
    }
    else if (Index > -1)
    {
        switch (Option)
        {
            case 0:
                Mark = HX_MARK_Positive;
                break;
            case 1:
                Mark = HX_MARK_Negative;
                break;
            default:
                Mark = HX_MARK_Unmarked;
                break;
        }
        class'HxFavorites'.static.MarkMap(GetMapName(), Mark);
        MapMarks[SortData[Index].SortItem] = class'HxFavorites'.static.MarkToName(Mark);
    }
    if (SortColumn == 0)
    {
        Refresh();
    }
}

function ClearAllMarks()
{
    local int i;

    if (class'HxFavorites'.static.ClearMapMarks())
    {
        for (i = 0; i < MapMarks.Length; ++i)
        {
            MapMarks[i] = class'HxFavorites'.static.MarkToName(HX_MARK_Unmarked);
        }
    }
}

defaultproperties
{
    Begin Object Class=GUIContextMenu Name=MarkContextMenu
        ContextItems(0)="Mark map with +"
        ContextItems(1)="Mark map with -"
        ContextItems(2)="Unmark map"
        ContextItems(3)="Unmark all maps"
        OnSelect=OnSelectMark
    End Object
    ContextMenu=MarkContextMenu

    ColumnHeadings(0)="Mark"
    ColumnHeadings(1)="Map Name"
    ColumnHeadings(2)="Players"
    ColumnHeadings(3)="Played"
    ColumnHeadings(4)="Recent"
    ColumnHeadingHints(0)="Click to sort by mark."
    ColumnHeadingHints(1)="Click to sort by map name."
    ColumnHeadingHints(2)="Click to sort by number of recommended players."
    ColumnHeadingHints(3)="Click to sort by number of times the map has been played."
    ColumnHeadingHints(4)="Click to sort by how recently this map has been played."

    SortColumn=1
    PreviousSortColumn=1
}
