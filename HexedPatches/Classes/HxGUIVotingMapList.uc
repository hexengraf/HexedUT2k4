class HxGUIVotingMapList extends HxGUIVotingBaseList;

var private HxMapVoteFilter ActiveFilter;

function PopulateList()
{
    local int i;

    Clear();
    for (i = 0; i < VRI.MapList.Length; ++i)
    {
        if (ActiveFilter.Match(VRI.MapList[i]))
        {
            AddMap(i);
        }
    }
    Sort();
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
    return left(Caps(Entry.MapName), 32);
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

defaultproperties
{
    ColumnHeadings(1)="Map Name"
    ColumnHeadings(2)="Players"
    ColumnHeadings(3)="Played"
    ColumnHeadings(4)="Recent"
    ColumnHeadingHints(1)="Click to sort by map name."
    ColumnHeadingHints(2)="Click to sort by number of recommended players."
    ColumnHeadingHints(3)="Click to sort by number of times the map has been played."
    ColumnHeadingHints(4)="Click to sort by how recently this map has been played."

    SortColumn=1
    PreviousSortColumn=1
}
