class HxGUIVotingBaseList extends GUIMultiColumnList
    abstract
    DependsOn(HxFavorites);

const INT_PADDING = "0000000000";
const INT_PADDING_SIZE = 10;
const STRING_PADDING = "                                ";
const STRING_PADDING_SIZE = 32;

var bool bAutoSpacing;
var float LineSpacing;
var float ColumnSpacing;
var float FrameThickness;

var localized string AddToLabel;
var localized string RemoveFromLabel;
var localized string LikedMapsLabel;
var localized string DislikedMapsLabel;

var protected bool bReInit;
var protected VotingReplicationInfo VRI;
var protected HxGUIVertScrollBar HxScrollbar;
var protected HxGUIVotingSearchBar SearchBar;
var protected float MyItemHeight;
var protected int MyItemsPerPage;
var protected array<int> MapIndices;
var protected array<HxFavorites.EHxTag> MapTags;

var int PreviousSortColumn;
var private array<int> CurrentSortOrder;
var private array<int> PreviousSortOrder;
var private string LastMapSelected;
var private GUIStyles DefaultStyle;
var private Color RecentColor;
var private Color OldColor;

delegate OnTagUpdated(int MapIndex, HxFavorites.EHxTag NewTag);

function PopulateList();
function RefreshList();
function DrawRow(Canvas C, int Row, float X, float Y, float W, float H);
function string GetNormalizedSortString(int Row, int Column);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    HxScrollbar = HxGUIVertScrollBar(MyScrollBar);
    SearchBar = HxGUIVotingBaseListBox(MenuOwner).SearchBar;
    ContextMenu.AddItem(AddToLabel@LikedMapsLabel);
    ContextMenu.AddItem(AddToLabel@DislikedMapsLabel);
    DefaultStyle = Style;
}

event ResolutionChanged(int NewX, int NewY)
{
    Super.ResolutionChanged(NewX, NewY);
    bReInit = true;
}

function float GetSpacedItemHeight(Canvas C)
{
    local float XL;
    local float YL;

    Style.TextSize(C, MenuState, "q|W", XL, YL, FontScale);
    MyItemHeight = YL + Round(LineSpacing * C.ClipY);
    if (bAutoSpacing)
    {
        MyItemsPerPage = WinHeight / MyItemHeight;
        MyItemHeight = YL + FMax(0, int((WinHeight - (MyItemsPerPage * YL)) / MyItemsPerPage));
    }
    MyItemsPerPage = WinHeight / MyItemHeight;
    return MyItemHeight;
}

function SetVRI(VotingReplicationInfo V)
{
    VRI = V;
    Refresh();
}

function bool Refresh()
{
    if (VRI == None)
    {
        return false;
    }
    if (Index > -1)
    {
        LastMapSelected = GetMapName();
    }
    Clear();
    PopulateList();
    if (CurrentSortOrder.Length == 0)
    {
        Sort();
    }
    else
    {
        SortList();
    }
    return SetIndexByMapName(LastMapSelected);
}

function AddMap(int MapIndex)
{
    MapIndices[MapIndices.Length] = MapIndex;
    MapTags[MapTags.Length] = class'HxFavorites'.static.GetMapTag(VRI.MapList[MapIndex].MapName);
    AddedItem();
}

function RemoveMap(int Position)
{
    MapIndices.Remove(Position, 1);
    MapTags.Remove(Position, 1);
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
            if (VRI.MapList[MapIndex].Sequence == 0) {
                SortString = "999999";
            }
            else
            {
                SortString = NormalizeInt(VRI.MapList[MapIndex].Sequence, 6);
            }
            break;
        case 1:
            SortString = string(int(MapTags[Row]));
            break;
        case 2:
            SortString = NormalizeString(VRI.MapList[MapIndex].MapName);
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

    CurrentSortOrder.Length = VRI.MapList.Length;
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

event InitializeColumns(Canvas C)
{
    local float Width;
    local int i;

    Width = MenuOwner.ActualWidth();
    for (i = 0; i < InitColumnPerc.Length; ++i)
    {
        ColumnWidths[i] = InitColumnPerc[i] * Width;
    }
    bInit = false;
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
        return VRI.MapList[MapIndices[SortData[Index].SortItem]].MapName;
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
            if (VRI.MapList[GetSortedMapIndex(i)].MapName == MapName)
            {
                SetTopItem(i - ItemsPerPage / 2);
                SetIndex(i);
                return true;
            }
        }
    }
    return false;
}

function Clear()
{
    MapIndices.Remove(0, MapIndices.Length);
    MapTags.Remove(0, MapTags.Length);
    if (VRI == None)
    {
        LastMapSelected = "";
        CurrentSortOrder.Remove(0, CurrentSortOrder.Length);
        PreviousSortOrder.Remove(0, PreviousSortOrder.Length);
        PreviousSortColumn = -1;
    }
    Super.Clear();
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    if (EInputAction(State) == IST_Hold)
    {
        if (EInputKey(Key) == IK_Up && Up())
        {
            return true;
        }
        if (EInputKey(Key) == IK_Down && Down())
        {
            return true;
        }
    }
    return Super.InternalOnKeyEvent(Key, State, Delta);
}

function bool InternalOnPreDraw(Canvas C)
{
    local float Offset;
    local float OwnerWidth;
    local float CurrentWidth;

    Super.InternalOnPreDraw(C);
    OwnerWidth = MenuOwner.ActualWidth();
    CurrentWidth = ActualWidth();
    CellSpacing = ColumnSpacing * C.ClipX;
    WinTop = ActualTop();
    WinHeight = ActualHeight();
    if (SearchBar != None)
    {
        WinHeight -= SearchBar.ActualHeight();
    }
    GetSpacedItemHeight(C);
    Offset = FMax(0, (WinHeight - (MyItemsPerPage * MyItemHeight)) / 2);
    WinTop += Offset;
    WinHeight -= Offset;

    if (CurrentWidth < OwnerWidth)
    {
        if (HxScrollbar != None && HxScrollbar.ForceRelativeWidth > 0)
        {
            WinWidth = Round(OwnerWidth * (1 - HxScrollbar.ForceRelativeWidth));
        }
        else
        {
            WinWidth = OwnerWidth - MyScrollBar.ActualWidth();
        }
    }
    if (bReInit)
    {
        InitializeColumns(C);
        bReInit = false;
    }
    else if (ExpandLastColumn)
    {
        ColumnWidths[ColumnWidths.Length - 1] += OwnerWidth - CurrentWidth;
    }
    return true;
}

function eMenuState GetMenuState(VotingHandler.MapVoteMapList Entry)
{
    if (!Entry.bEnabled)
    {
        return MSAT_Disabled;
    }
    return MenuState;
}

function DrawItem(Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local VotingHandler.MapVoteMapList Entry;
    local eMenuState SavedMenuState;
    local float Offset;

    if (VRI == None)
    {
        return;
    }
    X = ActualLeft();
    Offset = Round(FrameThickness * C.ClipY);
    if (bSelected)
    {
        Style = SelectedStyle;
        Style.Draw(C, MenuState, X + Offset, Y, W - 2 * Offset, H);
    }
    if (SortColumn == 0)
    {
        DrawLastPlayedIndicator(C, X, Y, H * 0.97, Offset);
    }
    DrawMapTag(C, MapTags[SortData[i].SortItem], X, Y, H * 0.97, Offset);
    Entry = VRI.MapList[GetSortedMapIndex(i)];
    SavedMenuState = MenuState;
    MenuState = GetMenuState(Entry);
    GetCellLeftWidth(2, X, W);
    Style.DrawText(C, MenuState, X, Y, W, H, TXTA_Left, Entry.MapName, FontScale);
    DrawRow(C, i, X, Y, W, H);
    MenuState = SavedMenuState;
    Style = DefaultStyle;
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
        switch (MapTags[SortData[Index].SortItem])
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
    local HxFavorites.EHxTag T;

    if (Index > -1)
    {
        T = EHxTag(Option * 2);
        if (MapTags[SortData[Index].SortItem] == T)
        {
            T = HX_TAG_None;
        }
        class'HxFavorites'.static.TagMap(GetMapName(), T);
        MapTags[SortData[Index].SortItem] = T;
        OnTagUpdated(GetMapIndex(), T);
        UpdatedItem(SortData[Index].SortItem);
        if (SortColumn == 1)
        {
            Sort();
        }
    }
}

function UpdateMapTag(int MapIndex, HxFavorites.EHxTag NewTag)
{
    local int i;

    for (i = 0; i < MapIndices.Length; ++i)
    {
        if (MapIndices[i] == MapIndex)
        {
            MapTags[SortData[i].SortItem] = NewTag;
            UpdatedItem(i);
        }
    }
}

function ShrinkToFit(Canvas C, int FirstColumn)
{
    local GUIMultiColumnListHeader Header;
    local float OwnerWidth;
    local float Width;
    local int i;

    OwnerWidth =  MenuOwner.ActualWidth();
    CellSpacing = ColumnSpacing * C.ClipX;
    Header = GUIMultiColumnListBox(MenuOwner).Header;
    InitColumnPerc[FirstColumn] = 1;
    for (i = 0; i < FirstColumn; ++i)
    {
        InitColumnPerc[FirstColumn] -= InitColumnPerc[i];
    }
    for (i = FirstColumn + 1; i < InitColumnPerc.Length; ++i)
    {
        class'HxGUIFramedMultiComponent'.static.GetFontSize(Header, C, ColumnHeadings[i], Width);
        InitColumnPerc[i] = FMax(0.1, (Width + (4 * CellSpacing)) / OwnerWidth);
        InitColumnPerc[FirstColumn] -= InitColumnPerc[i];
    }
    if (SearchBar != None)
    {
        SearchBar.bInit = true;
    }
}

static function string NormalizeString(string S)
{
    return left(Caps(S)$STRING_PADDING, STRING_PADDING_SIZE);
}

static function string NormalizeInt(coerce string Value, int Count)
{
    return right(INT_PADDING$Value, Min(Count, INT_PADDING_SIZE));
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
    bAutoSpacing=true
    LineSpacing=0.003
    ColumnSpacing=0.003
    FrameThickness=0.001
    bDropSource=false
    bDropTarget=false
    ExpandLastColumn=true
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    bReInit=true
    OnMousePressed=InternalOnMousePressed
    GetItemHeight=GetSpacedItemHeight
    OnDrawItem=DrawItem

    AddToLabel="Add to"
    RemoveFromLabel="Remove from"
    LikedMapsLabel="liked maps"
    DislikedMapsLabel="disliked maps"

    PreviousSortColumn=-1
    RecentColor=(R=196,G=255,B=0,A=255)
    OldColor=(R=255,G=172,B=0,A=255)
}
