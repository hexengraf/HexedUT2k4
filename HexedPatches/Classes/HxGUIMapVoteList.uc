class HxGUIMapVoteList extends HxGUIMapVoteBaseList;

var array<int> MapIndices;
var int SelectedGameType;
var int MapSourceFilter;

function OnPopulateList()
{
    local PlayerController PC;
    local int Type;

    PC = PlayerOwner();

    for (Type = 0; Type < VRI.GameConfig.Length; ++Type)
    {
        if (VRI.GameConfig[Type].GameClass ~= PC.GameReplicationInfo.GameClass)
        {
            SelectedGameType = Type;
            break;
        }
    }
    Refresh();
}

function Refresh()
{
    local int i;

    Clear();
    class'HxMapVoteFilter'.static.SetGameTypeFilter(VRI.GameConfig[SelectedGameType].Prefix);

    for (i = 0; i < VRI.MapList.Length; ++i)
    {
        if (class'HxMapVoteFilter'.static.Filter(VRI.MapList[i]))
        {
            MapIndices[MapIndices.Length] = i;
            AddedItem();
        }
    }
    NeedsSorting = true;
}

function int GetSelectedMapIndex()
{
    if(Index > -1)
    {
        return MapIndices[SortData[Index].SortItem];
    }
    return -1;
}

function string GetSelectedMapName()
{
    if(Index > -1)
    {
        return GetVRIEntry(SortData[Index].SortItem).MapName;
    }
    return "";
}

function SetSelectedGameType(int Type)
{
    SelectedGameType = Type;
    if (VRI != None)
    {
        Refresh();
    }
}

function SetSelectedMapSource(int Source)
{
    class'HxMapVoteFilter'.static.SetMapSourceFilter(Source);
    if (VRI != None)
    {
        Refresh();
    }
}

function Clear()
{
    MapIndices.Length = 0;
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
    local CacheManager.MapRecord Record;

    switch (Column)
    {
        case 1:
            Record = class'CacheManager'.static.GetMapRecord(GetVRIEntry(Row).MapName);
            return NormalizeNumber(Record.PlayerCountMin)$NormalizeNumber(Record.PlayerCountMax);
        case 2:
            return NormalizeNumber(GetVRIEntry(Row).PlayCount);
        case 3:
            return NormalizeNumber(GetVRIEntry(Row).Sequence);
        default:
            break;
    }
    return left(Caps(GetVRIEntry(Row).MapName), 20);
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
    ColumnHeadings(3)="Seq"
    ColumnHeadingHints(0)="Map name."
    ColumnHeadingHints(1)="Number of recommended players."
    ColumnHeadingHints(2)="Number of times the map has been played."
    ColumnHeadingHints(3)="Sequence, The number of games that have been played since this map was last played."
    InitColumnPerc(0)=0.50
    InitColumnPerc(1)=0.175
    InitColumnPerc(2)=0.175
    InitColumnPerc(3)=0.10

    SortColumn=0
    PreviousSortColumn=0
    SelectedGameType=0
    OnDrawItem=DrawItem
}
