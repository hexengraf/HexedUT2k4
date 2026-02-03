class HxGUIVotingBaseList extends GUIMultiColumnList
    abstract
    DependsOn(HxFavorites);

var bool bAutoSpacing;
var float LineSpacing;
var float ColumnSpacing;
var float LeftPadding;
var float TopPadding;
var float FrameThickness;

var localized string AddToLabel;
var localized string RemoveFromLabel;
var localized string LikedMapsLabel;
var localized string HatedMapsLabel;

var protected bool bReInit;
var protected VotingReplicationInfo VRI;
var protected int PreviousSortColumn;
var protected HxGUIVertScrollBar HxScrollbar;
var protected HxGUIVotingSearchBar SearchBar;
var protected float MyItemHeight;
var protected int MyItemsPerPage;
var protected array<int> MapIndices;
var protected array<HxFavorites.EHxTag> MapTags;

var private string LastMapSelected;

delegate OnTagUpdated(int MapIndex, HxFavorites.EHxTag NewTag);

function PopulateList();
function DrawRow(Canvas C, GUIStyles DrawStyle, int Row, float Y, float H);
function string GetNormalizedString(int Row, int Column);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    HxScrollbar = HxGUIVertScrollBar(MyScrollBar);
    SearchBar = HxGUIVotingBaseListBox(MenuOwner).SearchBar;
    ContextMenu.AddItem(AddToLabel@LikedMapsLabel);
    ContextMenu.AddItem(AddToLabel@HatedMapsLabel);
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
    if (VRI != None)
    {
        if (Index > -1)
        {
            LastMapSelected = GetMapName();
        }
        PopulateList();
        return SetIndexByMapName(LastMapSelected);
    }
    return false;
}

function string GetSortString(int Row)
{
    if (SortColumn != PreviousSortColumn)
    {
        return GetSortStringFor(Row, SortColumn)$GetSortStringFor(Row, PreviousSortColumn);
    }
    return GetSortStringFor(Row, SortColumn);
}

function string GetSortStringFor(int Row, int Column)
{
    switch (Column)
    {
        case 0:
            return string(int(MapTags[Row]));
        default:
            break;
    }
    return GetNormalizedString(Row, Column);
}

event OnSortChanged()
{
    Super.OnSortChanged();
    PreviousSortColumn = SortColumn;
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

function AddMap(int MapIndex)
{
    MapIndices[MapIndices.Length] = MapIndex;
    MapTags[MapTags.Length] = class'HxFavorites'.static.GetMapTag(VRI.MapList[MapIndex].MapName);
    AddedItem();
}

function RemoveMap(int Position)
{
    MapIndices.Remove(SortData[Position].SortItem, 1);
    MapTags.Remove(SortData[Position].SortItem, 1);
    RemovedItem(Position);
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

function VotingHandler.MapVoteMapList GetVRIEntry(int Row)
{
    return VRI.MapList[MapIndices[Row]];
}

function bool SetIndexByMapName(string MapName)
{
    local int i;

    if (MapName != "")
    {
        for (i = 0; i < SortData.Length; ++i)
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

function Clear()
{
    MapIndices.Remove(0, MapIndices.Length);
    MapTags.Remove(0, MapTags.Length);
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

function GetCellLeftWidth(int Column, out float Left, out float Width)
{
    local float Padding;

    Super.GetCellLeftWidth(Column, left, Width);
    if (Column == 0)
    {
        Padding = LeftPadding * MenuOwner.ActualWidth();
        Left += Padding;
        Width -= Padding;
    }
}

function DrawItem(Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local GUIStyles S;
    local float Offset;

    if (VRI == None)
    {
        return;
    }
    if (bSelected)
    {
        Offset = Round(FrameThickness * C.ClipY);
        SelectedStyle.Draw(C, MenuState, ActualLeft() + Offset, Y, ActualWidth() - 2 * Offset, H);
        S = SelectedStyle;
    }
    else
    {
        S = Style;
    }
    GetCellLeftWidth(0, X, W);
    class'HxFavorites'.static.DrawTag(
        C, MapTags[SortData[i].SortItem], X + (W / 2) - (H / 2), Y, H * 0.97);
    DrawRow(C, S, i, Y, H);
}

function bool OnOpenContextMenu(GUIContextMenu Sender)
{
    if (Index > -1)
    {
        switch (MapTags[SortData[Index].SortItem])
        {
            case HX_TAG_Like:
                ContextMenu.ReplaceItem(0, RemoveFromLabel@LikedMapsLabel);
                ContextMenu.ReplaceItem(1, AddToLabel@HatedMapsLabel);
                break;
            case HX_TAG_Hate:
                ContextMenu.ReplaceItem(0, AddToLabel@LikedMapsLabel);
                ContextMenu.ReplaceItem(1, RemoveFromLabel@HatedMapsLabel);
                break;
            default:
                ContextMenu.ReplaceItem(0, AddToLabel@LikedMapsLabel);
                ContextMenu.ReplaceItem(1, AddToLabel@HatedMapsLabel);
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
        UpdatedItem(Index);
        if (SortColumn == 0)
        {
            Refresh();
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

static function string NormalizeNumber(int Value)
{
    return right("000000" $ Value, 6);
}

defaultproperties
{
    Begin Object Class=GUIContextMenu Name=TagContextMenu
        OnOpen=OnOpenContextMenu
        OnSelect=OnSelectMapTag
    End Object
    ContextMenu=TagContextMenu

    ColumnHeadings(0)=""
    ColumnHeadingHints(0)="Click to sort by liked/hated maps."
    bAutoSpacing=true
    LineSpacing=0.003
    ColumnSpacing=0.003
    LeftPadding=0.002
    FrameThickness=0.001
    bDropSource=false
    bDropTarget=false
    ExpandLastColumn=true
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    GetItemHeight=GetSpacedItemHeight
    bReInit=true
    OnDrawItem=DrawItem

    AddToLabel="Add to"
    RemoveFromLabel="Remove from"
    LikedMapsLabel="liked maps"
    HatedMapsLabel="hated maps"
}
