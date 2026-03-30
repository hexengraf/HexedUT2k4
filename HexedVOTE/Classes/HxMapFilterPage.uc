class HxMapFilterPage extends HxGUIFloatingWindow
    DependsOn(CacheManager);

const SECTION_RULES = 0;
const SECTION_ALL_MAPS = 1;
const SECTION_FILTER_LIST = 2;

var automated HxGUIFramedSection Sections[3];

var automated moComboBox co_Filter;
var automated GUIButton b_NewFilter;
var automated GUIButton b_RenameFilter;
var automated GUIButton b_DeleteFilter;
var automated GUIMenuOption RuleOptions[7];

var automated moComboBox co_GameType;
var automated moEditBox ed_SearchMaps;
var automated HxGUIListBox lb_Maps;
var automated GUILabel l_AllMapsButtonAnchor;
var automated GUIButton b_Add;
var automated GUIButton b_AddAll;

var automated moEditBox ed_SearchFilterList;
var automated HxGUIListBox lb_FilterList;
var automated GUILabel l_MapListButtonAnchor;
var automated GUIButton b_Remove;
var automated GUIButton b_RemoveAll;

var localized string TagFilterNames[4];
var localized string NameLabel;
var localized string NewFilterPageCaption;
var localized string RenameFilterPageCaption;
var localized string ConfirmFilterDeletionLabel;
var localized string InvalidNamePrefix;
var localized string InvalidNameSuffix;
var localized string MapListModeNames[2];

var private HxMapFilterManager FilterManager;
var private HxMapFilter SelectedFilter;
var private string Properties[7];
var private array<CacheManager.GameRecord> GameTypes;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    local int i;

    WindowName = class'MutHexedVOTE'.default.FriendlyName@"-"@default.WindowName;
    Super.InitComponent(MyController, MyComponent);
    for (i = 0; i < ArrayCount(RuleOptions); ++i)
    {
        Sections[SECTION_RULES].Insert(RuleOptions[i]);
    }
    Sections[SECTION_ALL_MAPS].Insert(co_GameType, 0.015, 0.015);
    Sections[SECTION_ALL_MAPS].Insert(ed_SearchMaps, 0.015, 0.015);
    Sections[SECTION_ALL_MAPS].Insert(lb_Maps, 0.001);
    Sections[SECTION_ALL_MAPS].Insert(l_AllMapsButtonAnchor, 0.015, 0.015);
    Sections[SECTION_FILTER_LIST].Insert(RuleOptions[6], 0.015, 0.015);
    Sections[SECTION_FILTER_LIST].Insert(ed_SearchFilterList, 0.015, 0.015);
    Sections[SECTION_FILTER_LIST].Insert(lb_FilterList, 0.001);
    Sections[SECTION_FILTER_LIST].Insert(l_MapListButtonAnchor, 0.015, 0.015);
    class'HxGUIStyles'.static.ApplyComboBoxStyle(Controller, co_Filter);
    class'HxGUIStyles'.static.ApplyComboBoxStyle(Controller, co_GameType);
    class'HxGUIStyles'.static.ApplyEditBoxStyle(Controller, ed_SearchMaps);
    class'HxGUIStyles'.static.ApplyEditBoxStyle(Controller, ed_SearchFilterList);
    for (i = 0; i < 4; ++i)
    {
        class'HxGUIStyles'.static.ApplyEditBoxStyle(Controller, moEditBox(RuleOptions[i]));
    }
    for (i = 3; i < ArrayCount(RuleOptions); ++i)
    {
        class'HxGUIStyles'.static.ApplyComboBoxStyle(Controller, moComboBox(RuleOptions[i]));
    }
    RuleOptions[0].ToolTip.ExpirationSeconds = 6;
    RuleOptions[0].SetHint(
        RuleOptions[0].Hint@class'HxPatternMatch'.default.StringPatternMatchHint);
    RuleOptions[1].ToolTip.ExpirationSeconds = 6;
    RuleOptions[1].SetHint(
        RuleOptions[1].Hint@class'HxPatternMatch'.default.StringPatternMatchHint);
    moEditBox(RuleOptions[2]).MyEditBox.AllowedCharSet = "0123456789<=>*-";
    RuleOptions[2].ToolTip.ExpirationSeconds = 20;
    RuleOptions[2].SetHint(
        RuleOptions[2].Hint@class'HxPatternMatch'.default.RangePatternMatchHint);
    moEditBox(RuleOptions[3]).MyEditBox.AllowedCharSet = "0123456789<=>*";
    RuleOptions[3].ToolTip.ExpirationSeconds = 8;
    RuleOptions[3].SetHint(
        RuleOptions[3].Hint@class'HxPatternMatch'.default.ValuePatternMatchHint);
    FilterManager = HxMapVotingPage(ParentPage).FilterManager;
    class'CacheManager'.static.GetGameTypeList(GameTypes);
    InitComboBoxes();
}

function InitComboBoxes()
{
    local string Name;
    local int i;

    for (i = 0; i < 3; ++i)
    {
        Name = string(GetEnum(enum'EHxMapSource', i));
        moComboBox(RuleOptions[4]).AddItem(Mid(Name, 14),, Name);
    }
    for (i = 0; i < ArrayCount(TagFilterNames); ++i)
    {
        moComboBox(RuleOptions[5]).AddItem(TagFilterNames[i],, string(GetEnum(enum'EHxTag', i)));
    }
    for (i = 0; i < GameTypes.Length; ++i)
    {
        co_GameType.AddItem(GameTypes[i].GameName,, GameTypes[i].MapPrefix);
    }
    co_GameType.MyComboBox.List.Sort();
    co_GameType.SetIndex(0);
    for (i = 0; i < ArrayCount(MapListModeNames); ++i)
    {
        moComboBox(RuleOptions[6]).AddItem(
            MapListModeNames[i],, string(GetEnum(enum'EHxFilterMode', i)));
    }
}

function InitMapsList(string MapPrefix)
{
    local array<CacheManager.MapRecord> Records;
    local int i;

    if (MapPrefix != "")
    {
        class'CacheManager'.static.GetMapList(Records, MapPrefix);
        lb_Maps.Clear();
        for (i = 0; i < Records.Length; ++i)
        {
            lb_Maps.Add(Records[i].MapName);
        }
        lb_Maps.Subtract(lb_FilterList);
    }
    lb_Maps.SetIndex(0);
    UpdateListButtons();
}

function InitFilterList()
{
    local int i;

    lb_FilterList.Clear();
    for (i = 0; i < SelectedFilter.FilterList.Length; ++i)
    {
        lb_FilterList.Add(SelectedFilter.FilterList[i]);
    }
}

function InternalOnOpen()
{
    UpdateFilterComboBox(co_Filter.GetIndex());
    DisplaySelectedFilter();
}

function UpdateFilterComboBox(optional int Index)
{
    local bool bEnabled;
    local int i;

    SelectedFilter = None;
    co_Filter.ResetComponent();
    FilterManager.PopulateComboBox(co_Filter, true);
    bEnabled = co_Filter.ItemCount() != 0;
    if (bEnabled)
    {
        if (Index > -1)
        {
            co_Filter.SilentSetIndex(Min(Index, co_Filter.ItemCount() - 1));
        }
        SelectedFilter = FilterManager.GetFilter(co_Filter.GetComponentValue());
    }
    for (i = 0; i < ArrayCount(RuleOptions); ++i)
    {
        SetEnable(RuleOptions[i], bEnabled);
    }
    SetEnable(b_RenameFilter, bEnabled);
    SetEnable(b_DeleteFilter, bEnabled);
    SetEnable(co_GameType, bEnabled);
    SetEnable(ed_SearchMaps, bEnabled);
    SetEnable(lb_Maps, bEnabled);
    SetEnable(b_Add, bEnabled);
    SetEnable(b_AddAll, bEnabled);
    SetEnable(ed_SearchFilterList, bEnabled);
}

function UpdateListButtons()
{
    SetEnable(b_Add, lb_Maps.IsEnabled() && lb_Maps.ItemCount() != 0);
    SetEnable(b_AddAll, lb_Maps.IsEnabled() && lb_Maps.ItemCount() != 0);
    SetEnable(b_Remove, lb_FilterList.ItemCount() != 0);
    SetEnable(b_RemoveAll, lb_FilterList.ItemCount() != 0);
}

function DisplaySelectedFilter()
{
    local int i;

    if (SelectedFilter != None)
    {
        for (i = 0; i < ArrayCount(RuleOptions); ++i)
        {
            RuleOptions[i].SetComponentValue(SelectedFilter.GetPropertyText(Properties[i]));
        }
        InitFilterList();
        InitMapsList(co_GameType.GetComponentValue());
    }
    else
    {
        SelectedFilter = FilterManager.GetFilter();
        for (i = 0; i < ArrayCount(RuleOptions); ++i)
        {
            RuleOptions[i].SetComponentValue(SelectedFilter.GetPropertyText(Properties[i]));
        }
        SelectedFilter = None;
        lb_FilterList.Clear();
    }
}

function SaveSelectedFilter()
{
    local string Property;
    local string Value;
    local bool bDirty;
    local int i;

    if (SelectedFilter != None)
    {
        for (i = 0; i < ArrayCount(RuleOptions); ++i)
        {
            Property = Properties[i];
            Value = RuleOptions[i].GetComponentValue();
            if (SelectedFilter.GetPropertyText(Property) != Value)
            {
                SelectedFilter.SetPropertyText(Property, Value);
                bDirty = true;
            }
        }
        if (lb_FilterList.ItemCount() > 0 || SelectedFilter.FilterList.Length > 0)
        {
            SelectedFilter.FilterList.Length = lb_FilterList.ItemCount();
            for (i = 0; i < lb_FilterList.ItemCount(); ++i)
            {
                SelectedFilter.FilterList[i] = lb_FilterList.List.Elements[i].Item;
            }
            bDirty = true;
        }
        if (bDirty)
        {
            SelectedFilter.SaveConfig();
            SelectedFilter.ParseConfig();
        }
    }
}

function AddMap()
{
    local string Map;

    Map = lb_Maps.Get();
    lb_FilterList.Add(Map);
    lb_Maps.RemoveItem(Map);
    UpdateListButtons();
}

function AddAllMaps()
{
    local int i;

    for (i = 0; i < lb_Maps.ItemCount(); ++i)
    {
        lb_FilterList.Add(lb_Maps.GetItemAtIndex(i));
    }
    lb_Maps.Clear();
    UpdateListButtons();
}

function RemoveMap()
{
    local string Map;

    Map = lb_FilterList.Get();
    lb_FilterList.RemoveItem(Map);
    lb_Maps.Add(Map);
    UpdateListButtons();
}

function RemoveAllMaps()
{
    local int i;

    for (i = 0; i < lb_FilterList.ItemCount(); ++i)
    {
        lb_Maps.Add(lb_FilterList.GetItemAtIndex(i));
    }
    lb_FilterList.Clear();
    UpdateListButtons();
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputAction Action;

    if (moComboBox(RuleOptions[6]).MyComboBox.List.bHasFocus
        || co_GameType.MyComboBox.List.bHasFocus)
    {
        return false;
    }
    Action = EInputAction(State);
    switch (EInputKey(Key))
    {
        case IK_MouseWheelUp:
        case IK_MouseWheelDown:
            if (lb_Maps.IsInBounds())
            {
                if (!lb_Maps.bHasFocus)
                {
                    lb_Maps.SetFocus(None);
                }
            }
            else if (lb_FilterList.IsInBounds())
            {
                if (!lb_FilterList.bHasFocus)
                {
                    lb_FilterList.SetFocus(None);
                }
            }
            break;
    }
    return false;
}

function OnChangeFilter(GUIComponent Sender)
{
    SaveSelectedFilter();
    SelectedFilter = FilterManager.GetFilter(co_Filter.GetComponentValue());
    DisplaySelectedFilter();
}

function OnChangeGameType(GUIComponent Sender)
{
    InitMapsList(GUIMenuOption(Sender).GetComponentValue());
}

function OnChangeSearchMaps(GUIComponent Sender)
{
    lb_Maps.SetFilter(GUIMenuOption(Sender).GetComponentValue());
    InitMapsList(co_GameType.GetComponentValue());
}

function OnChangeSearchFilterList(GUIComponent Sender)
{
    lb_FilterList.SetFilter(GUIMenuOption(Sender).GetComponentValue());
    if (SelectedFilter != None)
    {
        InitFilterList();
    }
}

function bool OnClickNewFilter(GUIComponent Sender)
{
    if (Controller.OpenMenu(Controller.RequestDataMenu, NewFilterPageCaption, NameLabel))
    {
        SaveSelectedFilter();
        Controller.ActivePage.OnClose = OnCloseNewFilter;
    }
    return true;
}

function OnCloseNewFilter(optional bool bCancelled)
{
    local string FilterName;

    if (!bCancelled)
    {
        FilterName = Controller.ActivePage.GetDataString();
        if (FilterManager.NewFilter(FilterName) != None)
        {
            UpdateFilterComboBox(co_Filter.ItemCount());
            DisplaySelectedFilter();
        }
        else
        {
            ShowInvalidNameDialog(FilterName);
        }
    }
}

function bool OnClickRenameFilter(GUIComponent Sender)
{
    if (Controller.OpenMenu(Controller.RequestDataMenu, RenameFilterPageCaption, NameLabel))
    {
        SaveSelectedFilter();
        Controller.ActivePage.SetDataString(co_Filter.GetText());
        Controller.ActivePage.OnClose = OnCloseRenameFilter;
    }
    return true;
}

function OnCloseRenameFilter(optional bool bCancelled)
{
    local string NewName;

    if (!bCancelled)
    {
        NewName = Controller.ActivePage.GetDataString();
        if (NewName != co_Filter.GetText())
        {
            if (FilterManager.RenameFilter(co_Filter.GetComponentValue(), NewName) != None)
            {
                UpdateFilterComboBox(co_Filter.GetIndex());
            }
            else
            {
                ShowInvalidNameDialog(NewName);
            }
        }
    }
}

function bool OnClickDeleteFilter(GUIComponent Sender)
{
    if (Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage"))
    {
        GUIQuestionPage(Controller.ActivePage).SetupQuestion(
            ConfirmFilterDeletionLabel, QBTN_YesNo, QBTN_Yes);
        GUIQuestionPage(Controller.ActivePage).OnButtonClick = OnCloseDeleteFilter;
    }
    return true;
}

function OnCloseDeleteFilter(byte bButton)
{
    if (bButton == QBTN_Yes && FilterManager.DeleteFilter(co_Filter.GetComponentValue()))
    {
        UpdateFilterComboBox(co_Filter.GetIndex());
        DisplaySelectedFilter();
    }
}

function ShowInvalidNameDialog(string Name)
{
    if (Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage"))
    {
        GUIQuestionPage(Controller.ActivePage).SetupQuestion(
            InvalidNamePrefix@"\""$Name$"\""@InvalidNameSuffix, QBTN_Ok, QBTN_Ok);
    }
}

function bool OnClickAdd(GUIComponent Sender)
{
    AddMap();
    return true;
}

function bool OnClickAddAll(GUIComponent Sender)
{
    AddAllMaps();
    return true;
}

function bool OnClickRemove(GUIComponent Sender)
{
    RemoveMap();
    return true;
}
function bool OnClickRemoveAll(GUIComponent Sender)
{
    RemoveAllMaps();
    return true;
}

function bool AllMapsButtonsOnPreDraw(Canvas C)
{
    if (l_AllMapsButtonAnchor.bInit)
    {
        l_AllMapsButtonAnchor.bInit = Sections[SECTION_ALL_MAPS].bInit;
        b_Add.WinLeft = l_AllMapsButtonAnchor.WinLeft;
        b_Add.WinTop = l_AllMapsButtonAnchor.WinTop;
        b_Add.WinWidth = l_AllMapsButtonAnchor.WinWidth / 2 - 0.005;
        b_AddAll.WinLeft = b_Add.WinLeft + b_Add.WinWidth + 0.01;
        b_AddAll.WinTop = l_AllMapsButtonAnchor.WinTop;
        b_AddAll.WinWidth = b_Add.WinWidth;
    }
    return false;
}

function bool MapListButtonsOnPreDraw(Canvas C)
{
    if (l_MapListButtonAnchor.bInit)
    {
        l_MapListButtonAnchor.bInit = Sections[SECTION_ALL_MAPS].bInit;
        b_Remove.WinLeft = l_MapListButtonAnchor.WinLeft;
        b_Remove.WinTop = l_MapListButtonAnchor.WinTop;
        b_Remove.WinWidth = l_MapListButtonAnchor.WinWidth / 2 - 0.005;
        b_RemoveAll.WinLeft = b_Remove.WinLeft + b_Remove.WinWidth + 0.01;
        b_RemoveAll.WinTop = l_MapListButtonAnchor.WinTop;
        b_RemoveAll.WinWidth = b_Remove.WinWidth;
    }
    return false;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    SaveSelectedFilter();
    Super.Closed(Sender, bCancelled);
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=FilterRulesSection
        Caption="Filter Rules"
        WinLeft=0.015
        WinTop=0.106
        WinWidth=0.97
        WinHeight=0.26
        ColumnWidths=(0.5,0.5)
        MaxItemsPerColumn=3
    End Object
    Sections(0)=FilterRulesSection

    Begin Object class=HxGUIFramedSection Name=AllMapsSection
        Caption="All Maps"
        WinLeft=0.015
        WinTop=0.3775
        WinWidth=0.481
        WinHeight=0.602
        LeftPadding=0
        RightPadding=0
        LineSpacing=0.0134
        ExpandIndex=2
    End Object
    Sections(1)=AllMapsSection

    Begin Object class=HxGUIFramedSection Name=MapListSection
        Caption="Filter List"
        WinLeft=0.504
        WinTop=0.3775
        WinWidth=0.481
        WinHeight=0.602
        LeftPadding=0
        RightPadding=0
        LineSpacing=0.0134
        ExpandIndex=2
    End Object
    Sections(2)=MapListSection

    Begin Object class=moComboBox Name=FilterComboBox
        Caption="Filter"
        Hint="Select filter to modify."
        WinLeft=0.020715
        WinTop=0.052
        WinWidth=0.496285
        CaptionWidth=0.175
        bReadOnly=true
        bScaleToParent=true
        bBoundToParent=true
        OnChange=OnChangeFilter
        TabOrder=1
    End Object
    co_Filter=FilterComboBox

    Begin Object Class=GUIButton Name=NewColorButton
        Caption="New"
        Hint="Add new filter."
        WinLeft=0.526
        WinTop=0.052
        WinWidth=0.147
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        bScaleToParent=true
        bBoundToParent=true
        OnClick=OnClickNewFilter
        TabOrder=2
    End Object
    b_NewFilter=NewColorButton

    Begin Object Class=GUIButton Name=RenameColorButton
        Caption="Rename"
        Hint="Rename current filter."
        WinLeft=0.682
        WinTop=0.052
        WinWidth=0.147
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        bScaleToParent=true
        bBoundToParent=true
        OnClick=OnClickRenameFilter
        TabOrder=3
    End Object
    b_RenameFilter=RenameColorButton

    Begin Object Class=GUIButton Name=DeleteColorButton
        Caption="Delete"
        Hint="Delete current filter."
        WinLeft=0.838
        WinTop=0.052
        WinWidth=0.147
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        bScaleToParent=true
        bBoundToParent=true
        OnClick=OnClickDeleteFilter
        TabOrder=4
    End Object
    b_DeleteFilter=DeleteColorButton

    Begin Object class=moEditBox Name=MapNameEditBox
        Caption="Map name"
        Hint="Filter by map name."
        CaptionWidth=0.42
        TabOrder=10
    End Object
    RuleOptions(0)=MapNameEditBox

    Begin Object class=moEditBox Name=AuthorNameEditBox
        Caption="Author name"
        Hint="Filter by author name."
        CaptionWidth=0.42
        TabOrder=11
    End Object
    RuleOptions(1)=AuthorNameEditBox

    Begin Object class=moEditBox Name=NumPlayersEditBox
        Caption="Num. players"
        Hint="Filter by number of players."
        CaptionWidth=0.42
        TabOrder=12
    End Object
    RuleOptions(2)=NumPlayersEditBox

    Begin Object class=moEditBox Name=TimerPlayedEditBox
        Caption="Times played"
        Hint="Filter by number of times played."
        CaptionWidth=0.42
        TabOrder=13
    End Object
    RuleOptions(3)=TimerPlayedEditBox

    Begin Object class=moComboBox Name=MapSourceComboBox
        Caption="Map Source"
        Hint="Filter by source (any, official, custom)."
        CaptionWidth=0.42
        bReadOnly=true
        TabOrder=14
    End Object
    RuleOptions(4)=MapSourceComboBox

    Begin Object class=moComboBox Name=MapTagComboBox
        Caption="Map Tag"
        Hint="Filter by tag (Any, Liked, Untagged, Disliked)."
        CaptionWidth=0.42
        bReadOnly=true
        TabOrder=15
    End Object
    RuleOptions(5)=MapTagComboBox

    Begin Object class=moComboBox Name=GameTypeComboBox
        Caption="Type"
        Hint="Choose game type to show all maps from."
        CaptionWidth=0.2
        bReadOnly=true
        OnChange=OnChangeGameType
        TabOrder=19
    End Object
    co_GameType=GameTypeComboBox

    Begin Object class=moEditBox Name=SearchMapsEditBox
        Caption="Find"
        Hint="Find maps to add."
        CaptionWidth=0.2
        OnChange=OnChangeSearchMaps
        TabOrder=20
    End Object
    ed_SearchMaps=SearchMapsEditBox

    Begin Object Class=HxGUIListBox Name=MapsListBox
        ScrollbarWidth=0.034
        bVisibleWhenEmpty=true
        bSorted=True
        TabOrder=21
    End Object
    lb_Maps=MapsListBox

    Begin Object class=GUILabel Name=AllMapsButtonAnchorLabel
        StandardHeight=0.03
        bStandardized=true
        bInit=true
        OnPreDraw=AllMapsButtonsOnPreDraw
    End Object
    l_AllMapsButtonAnchor=AllMapsButtonAnchorLabel

    Begin Object Class=GUIButton Name=AddButton
        Caption="Add"
        Hint="Add selected map to the map list."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickAdd
        TabOrder=22
    End Object
    b_Add=AddButton

    Begin Object Class=GUIButton Name=AddAllButton
        Caption="Add All"
        Hint="Add all maps to the map list."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickAddAll
        TabOrder=23
    End Object
    b_AddAll=AddAllButton

    Begin Object class=moComboBox Name=FilterListModeComboBox
        Caption="Mode"
        Hint="Choose how the filter list is used: to include or to exclude maps from the filter."
        CaptionWidth=0.2
        bReadOnly=true
        TabOrder=30
    End Object
    RuleOptions(6)=FilterListModeComboBox

    Begin Object class=moEditBox Name=SearchFilterListEditBox
        Caption="Find"
        Hint="Find maps already added to the filter list."
        CaptionWidth=0.2
        OnChange=OnChangeSearchFilterList
        TabOrder=31
    End Object
    ed_SearchFilterList=SearchFilterListEditBox

    Begin Object Class=HxGUIListBox Name=FilterListBox
        ScrollbarWidth=0.034
        bVisibleWhenEmpty=true
        bSorted=True
        TabOrder=32
    End Object
    lb_FilterList=FilterListBox

    Begin Object class=GUILabel Name=MapListButtonAnchorLabel
        StandardHeight=0.03
        bStandardized=true
        bInit=true
        OnPreDraw=MapListButtonsOnPreDraw
    End Object
    l_MapListButtonAnchor=MapListButtonAnchorLabel

    Begin Object Class=GUIButton Name=RemoveButton
        Caption="Remove"
        Hint="Remove selected map from the map list."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickRemove
        TabOrder=32
    End Object
    b_Remove=RemoveButton

    Begin Object Class=GUIButton Name=RemoveAllButton
        Caption="Remove All"
        Hint="Remove all maps from the map list."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickRemoveAll
        TabOrder=33
    End Object
    b_RemoveAll=RemoveAllButton

    WindowName="Manage Map Filters"
    WinWidth=0.65
    WinHeight=0.7
    WinLeft=0.175
    WinTop=0.15
    OnOpen=InternalOnOpen
    OnKeyEvent=InternalOnKeyEvent

    TagFilterNames(0)="Any"
    TagFilterNames(1)="Liked maps"
    TagFilterNames(2)="Untagged maps"
    TagFilterNames(3)="Disliked maps"
    NameLabel="Name"
    NewFilterPageCaption="New Filter"
    RenameFilterPageCaption="Rename Filter"
    ConfirmFilterDeletionLabel="Are you sure you want to delete this filter?"
    InvalidNamePrefix="The name"
    InvalidNameSuffix="is already in use or invalid."
    MapListModeNames(0)="Include Maps"
    MapListModeNames(1)="Exclude Maps"

    Properties(0)="MapName"
    Properties(1)="AuthorName"
    Properties(2)="NumPlayers"
    Properties(3)="TimesPlayed"
    Properties(4)="MapSource"
    Properties(5)="MapTag"
    Properties(6)="FilterListMode"
}
