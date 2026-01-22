class HxGUIVotingMapList extends HxGUIVotingBaseList;

var array<int> MapIndices;
var HxMapVoteFilter ActiveFilter;

function OnPopulateList()
{
    local int i;

    Clear();
    for (i = 0; i < VRI.MapList.Length; ++i)
    {
        if (ActiveFilter.Match(VRI.MapList[i]))
        {
            MapIndices[MapIndices.Length] = i;
            AddedItem();
        }
    }
    SortList();
}

function bool FilterUpdated(optional string SelectMapName)
{
    if (VRI != None)
    {
        OnPopulateList();
        return SetIndexByMapName(SelectMapName);
    }
    return false;
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
    FilterUpdated();
}

function Clear()
{
    MapIndices.Remove(0, MapIndices.Length);
    Super.Clear();
}

function VotingHandler.MapVoteMapList GetVRIEntry(int Row)
{
    return VRI.MapList[MapIndices[Row]];
}

function DrawItem(Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    if (VRI == None)
    {
        return;
    }
    if (bSelected)
    {
        SelectedStyle.Draw(C, MenuState, X, Y - 2, W, H + 2);
        DrawRow(C, SelectedStyle, i, Y, H);
    }
    else
    {
        DrawRow(C, Style, i, Y, H);
    }
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
    DrawStyle.DrawText(C, S, X, Y, W, H, TXTA_Left, GetMapSizeString(Record), FontScale);
    GetCellLeftWidth(2, X, W);
    DrawStyle.DrawText(C, S, X, Y, W, H, TXTA_Left, string(Entry.PlayCount), FontScale);
    GetCellLeftWidth(3, X, W);
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
            Record = class'CacheManager'.static.GetMapRecord(Entry.MapName);
            if (Record.PlayerCountMax == 0) {
                return "999999999999";
            }
            return NormalizeNumber(Record.PlayerCountMin)$NormalizeNumber(Record.PlayerCountMax);
        case 2:
            return NormalizeNumber(Entry.PlayCount);
        case 3:
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
    if (Record.PlayerCountMin == Record.PlayerCountMax)
    {
        return string(Record.PlayerCountMin);
    }
    return Record.PlayerCountMin@"-"@Record.PlayerCountMax;
}

static function string NormalizeNumber(int Value)
{
    return right("000000" $ Value, 6);
}

defaultproperties
{
    ColumnHeadings(0)="Name"
    ColumnHeadings(1)="Players"
    ColumnHeadings(2)="Played"
    ColumnHeadings(3)="Recent"
    ColumnHeadingHints(0)="Map name."
    ColumnHeadingHints(1)="Number of recommended players."
    ColumnHeadingHints(2)="Number of times the map has been played."
    ColumnHeadingHints(3)="How recently this map has been played."
    InitColumnPerc(0)=0.565
    InitColumnPerc(1)=0.16
    InitColumnPerc(2)=0.15
    InitColumnPerc(3)=0.125

    SortColumn=0
    PreviousSortColumn=0
    OnDrawItem=DrawItem
}
