class HxMapVotingBaseList extends HxGUITable
    abstract
    DependsOn(HxFavorites);

var localized string AddToLabel;
var localized string RemoveFromLabel;
var localized string LikedMapsLabel;
var localized string DislikedMapsLabel;

var protected HxVTClient Client;
var protected array<int> MapIndices;

var private array<int> CurrentSortOrder;
var private array<int> PreviousSortOrder;
var private string LastMapSelected;
var private Color RecentColor;
var private Color OldColor;

delegate OnTagUpdated(int MapIndex);

function PopulateList();
function string GetNormalizedSortString(int Row, int Column);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    ContextMenu.AddItem(AddToLabel@LikedMapsLabel);
    ContextMenu.AddItem(AddToLabel@DislikedMapsLabel);
}

function SetClient(HxVTClient Client)
{
    Self.Client = Client;
}

function Initialize()
{
    if (Client.IsInitialized())
    {
        if (PreviousSortColumn != -1)
        {
            SortColumn = PreviousSortColumn;
            SortDescending = bPreviousSortDescending;
        }
        SoftClear();
        PopulateList();
        Sort();
        if (PreviousSortColumn != -1)
        {
            SortColumn = default.SortColumn;
            SortDescending = default.SortDescending;
            OnSortChanged();
        }
    }
}

function bool Refresh()
{
    if (Client.IsInitialized())
    {
        if (Index > -1)
        {
            LastMapSelected = GetMapName();
        }
        SoftClear();
        PopulateList();
        SortList();
        return SetIndexByMapName(LastMapSelected);
    }
    return false;
}

function AddMap(int MapIndex)
{
    MapIndices[MapIndices.Length] = MapIndex;
    AddedItem();
}

function RemoveMap(int Position)
{
    MapIndices.Remove(Position, 1);
    RemovedItem(Position);
}

function string GetSortString(int Row)
{
    local string SortString;
    local int MapIndex;

    MapIndex = MapIndices[Row];
    switch (SortColumn)
    {
        case 0:
            if (Client.Maps[MapIndex].Sequence == 0) {
                SortString = "999999";
            }
            else
            {
                SortString = NormalizeInt(Client.Maps[MapIndex].Sequence, 6);
            }
            break;
        case 1:
            SortString = string(int(Client.Maps[MapIndex].Tag));
            break;
        case 2:
            SortString = NormalizeString(Client.Maps[MapIndex].Name);
            break;
        default:
            SortString = GetNormalizedSortString(Row, SortColumn);
            break;
    }
    if (PreviousSortOrder.Length > 0)
    {
        if (SortDescending)
        {
            SortString $= NormalizeInt(MapIndices.Length - PreviousSortOrder[MapIndex] - 1, 6);
        }
        else
        {
            SortString $= NormalizeInt(PreviousSortOrder[MapIndex], 6);
        }
    }
    return SortString;
}

function Sort()
{
    SavePreviousSortOrder();
    Super.Sort();
    if (IsValid())
    {
        Index = InvSortData[Index];
    }
    SaveCurrentSortOrder();
}

event OnSortChanged()
{
    SavePreviousSortOrder();
    Super.OnSortChanged();
    SaveCurrentSortOrder();
}

function SaveCurrentSortOrder()
{
    local int i;

    CurrentSortOrder.Length = Client.Maps.Length;
    for (i = 0; i < SortData.Length; ++i)
    {
        CurrentSortOrder[GetSortedMapIndex(i)] = i;
    }
}

function SavePreviousSortOrder()
{
    if (SortColumn != PreviousSortColumn)
    {
        PreviousSortOrder.Length = CurrentSortOrder.Length;
        PreviousSortOrder = CurrentSortOrder;
    }
}

function int GetMapIndex()
{
    if(Index > -1)
    {
        return GetSortedMapIndex(Index);
    }
    return -1;
}

function int GetSortedMapIndex(int SortedRow)
{
    return MapIndices[SortData[SortedRow].SortItem];
}

function string GetMapName()
{
    if(Index > -1)
    {
        return Client.Maps[MapIndices[SortData[Index].SortItem]].Name;
    }
    return "";
}

function bool SetIndexByMapName(string MapName)
{
    local int i;

    if (MapName != "")
    {
        for (i = 0; i < SortData.Length; ++i)
        {
            if (Client.Maps[GetSortedMapIndex(i)].Name == MapName)
            {
                SetTopItem(i - ItemsPerPage / 2);
                SetIndex(i);
                return true;
            }
        }
    }
    return false;
}

function SoftClear()
{
    MapIndices.Remove(0, MapIndices.Length);
    Super.Clear();
}

function Clear()
{
    LastMapSelected = "";
    CurrentSortOrder.Remove(0, CurrentSortOrder.Length);
    PreviousSortOrder.Remove(0, PreviousSortOrder.Length);
    SoftClear();
}

function DrawItem(Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local eMenuState SavedMenuState;

    SavedMenuState = MenuState;
    if (!Client.IsEnabled(GetSortedMapIndex(i)))
    {
        MenuState = MSAT_Disabled;
    }
    Super.DrawItem(C, i, X, Y, W, H, bSelected, bPending);
    MenuState = SavedMenuState;
}

function DrawRow(Canvas C, int Row, float X, float Y, float W, float H)
{
    local float Offset;
    local int MapIndex;

    Offset = C.ClipY * FrameThickness;
    MapIndex = GetSortedMapIndex(Row);
    if (SortColumn == 0)
    {
        DrawLastPlayedIndicator(C, X, Y, H * 0.97, Offset);
    }
    DrawMapTag(C, Client.Maps[MapIndex].Tag, X, Y, H * 0.97, Offset);
    GetCellLeftWidth(2, X, W);
    Style.DrawText(C, MenuState, X, Y, W, H, TXTA_Left, Client.Maps[MapIndex].Name, FontScale);
}

function DrawLastPlayedIndicator(Canvas C, float X, float Y, float Size, float Offset)
{
    local Color SavedColor;
    local int SavedStyle;
    local float SavedCurX;
    local float SavedCurY;

    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    SavedCurX = C.CurX;
    SavedCurY = C.CurY;
    X += (Offset / 2) + (ColumnWidths[0] - Size) / 2;
    C.SetPos(X, Y);
    C.Style = 5; // STY_Alpha
    if (SortDescending)
    {
        C.DrawColor = OldColor;
        C.DrawTile(Material'HxTriangleIcon', Size, Size, 0, 64, 64, -64);
    }
    else
    {
        C.DrawColor = RecentColor;
        C.DrawTile(Material'HxTriangleIcon', Size, Size, 0, 0, 64, 64);
    }
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
    C.CurX = SavedCurX;
    C.CurY = SavedCurY;
}

function DrawMapTag(Canvas C, HxFavorites.EHxTag Tag, float X, float Y, float Size, float Offset)
{
    X += ColumnWidths[0] + (Offset / 2) + ((ColumnWidths[1] - Size) / 2);
    class'HxFavorites'.static.DrawTag(C, Tag, X, Y, Size);
}

function bool OnOpenContextMenu(GUIContextMenu Sender)
{
    if (Index > -1)
    {
        switch (Client.Maps[GetSortedMapIndex(Index)].Tag)
        {
            case HX_TAG_Like:
                ContextMenu.ReplaceItem(0, RemoveFromLabel@LikedMapsLabel);
                ContextMenu.ReplaceItem(1, AddToLabel@DislikedMapsLabel);
                break;
            case HX_TAG_Dislike:
                ContextMenu.ReplaceItem(0, AddToLabel@LikedMapsLabel);
                ContextMenu.ReplaceItem(1, RemoveFromLabel@DislikedMapsLabel);
                break;
            default:
                ContextMenu.ReplaceItem(0, AddToLabel@LikedMapsLabel);
                ContextMenu.ReplaceItem(1, AddToLabel@DislikedMapsLabel);
                break;
        }
        return true;
    }
    return false;
}

function OnSelectMapTag(GUIContextMenu Sender, int Option)
{
    local int MapIndex;

    if (Index > -1)
    {
        MapIndex = GetSortedMapIndex(Index);
        Client.SetMapTag(MapIndex, EHxTag(1 + Option * 2));
        OnTagUpdated(MapIndex);
        UpdatedItem(SortData[Index].SortItem);
        if (SortColumn == 1)
        {
            Sort();
        }
    }
}

function UpdateMapTag(int MapIndex)
{
    local int i;

    for (i = 0; i < MapIndices.Length; ++i)
    {
        if (MapIndices[i] == MapIndex)
        {
            UpdatedItem(i);
            if (SortColumn == 1)
            {
                Sort();
            }
            break;
        }
    }
}

function LevelChanged()
{
    default.SortColumn = SortColumn;
    default.SortDescending = SortDescending;
    default.PreviousSortColumn = PreviousSortColumn;
    default.bPreviousSortDescending = bPreviousSortDescending;
    Super.LevelChanged();
}

defaultproperties
{
    Begin Object Class=GUIContextMenu Name=TagContextMenu
        OnOpen=OnOpenContextMenu
        OnSelect=OnSelectMapTag
    End Object
    ContextMenu=TagContextMenu

    ColumnHeadings(0)=""
    ColumnHeadings(1)=""
    ColumnHeadings(2)="Map Name"
    ColumnHeadingHints(0)="Click to sort by last played."
    ColumnHeadingHints(1)="Click to sort by liked/disliked maps."
    ColumnHeadingHints(2)="Click to sort by map name."

    AddToLabel="Add To"
    RemoveFromLabel="Remove From"
    LikedMapsLabel="Liked Maps"
    DislikedMapsLabel="Disliked Maps"

    PreviousSortColumn=-1
    RecentColor=(R=196,G=255,B=0,A=255)
    OldColor=(R=255,G=172,B=0,A=255)
}
