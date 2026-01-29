class HxGUIVotingPage extends MapVotingPage;

var automated HxGUIVotingVoteListBox lb_VoteList;
var automated GUIImage i_VoteListBorder;
var automated moComboBox co_MapSource;
var automated moEditBox ed_SearchName;
var automated HxGUIVotingMapListBox lb_MapList;
var automated GUIImage i_MapListBorder;
var automated GUIEditBox ed_SearchPlayers;
var automated GUIEditBox ed_SearchPlayed;
var automated GUIEditBox ed_SearchSeq;
var automated moCheckBox ch_CaseSensitive;
var automated GUILabel l_RetrievingMapList;
var automated HxGUIVotingMapBanner MapBanner;
var automated HxGUIVotingChatBox ChatBox;

var localized string LoadingText;
var localized string RetrievingMapListText;

var HxMapVoteFilterManager FilterManager;
var HxMapVoteFilter ActiveFilter;
var int SelectedGameType;
var int SelectedMap;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    FilterManager = new(Self) class'HxMapVoteFilterManager';
    ActiveFilter = FilterManager.GetFilter();
    lb_MapList.SetFilter(ActiveFilter);
    AdjustWindowSize(Controller.ResX, Controller.ResY);
    PropagateEditBoxProperties();
    PopulateLocalLists();
    ShowInitialState();
}

function InternalOnOpen()
{
    if (MVRI == None)
    {
        MVRI = VotingReplicationInfo(PlayerOwner().VoteReplicationInfo);
        SetTimer(0.02, true);
    }
}

event ResolutionChanged(int NewX, int NewY)
{
    Super.ResolutionChanged(NewX, NewY);
    AdjustWindowSize(NewX, NewY);
}

event Timer()
{
    if (MVRI != None)
    {
        if (!MVRI.bMapVote)
        {
            ShowDisabledMessage();
        }
        else if (MVRI.GameConfig.Length < MVRI.GameConfigCount
                 || MVRI.MapList.Length < MVRI.MapCount)
        {
            ShowLoadingState();
        }
        else
        {
            ShowReadyState();
            KillTimer();
        }
    }
}

function ShowInitialState()
{
    MVRI = None;
    SelectedGameType = -1;
    SelectedMap = -1;
    lb_VoteList.Clear();
    lb_VoteList.DisableMe();
    co_GameType.ResetComponent();
    co_GameType.DisableMe();
    co_MapSource.DisableMe();
    lb_MapList.Clear();
    lb_MapList.DisableMe();
    ed_SearchName.DisableMe();
    ed_SearchPlayers.SetText("");
    ed_SearchPlayers.DisableMe();
    ed_SearchPlayed.SetText("");
    ed_SearchPlayed.DisableMe();
    ed_SearchSeq.SetText("");
    ed_SearchSeq.DisableMe();
    ch_CaseSensitive.DisableMe();
    l_RetrievingMapList.SetVisibility(false);
    MapBanner.SetMap("");
}

function ShowLoadingState()
{
    t_WindowTitle.Caption = WindowName@"("$LoadingText$")";
    l_RetrievingMapList.Caption = RetrievingMapListText@"("$MVRI.MapList.Length$"/"$MVRI.MapCount$")";
    l_RetrievingMapList.SetVisibility(true);
    PopulateGameTypeList();
}

function ShowReadyState()
{
    t_WindowTitle.Caption = WindowName@"("$lmsgMode[MVRI.Mode]$")";
    lb_VoteList.EnableMe();
    co_GameType.EnableMe();
    co_MapSource.EnableMe();
    lb_MapList.EnableMe();
    ed_SearchName.EnableMe();
    ed_SearchPlayers.EnableMe();
    ed_SearchPlayed.EnableMe();
    ed_SearchSeq.EnableMe();
    ch_CaseSensitive.EnableMe();
    l_RetrievingMapList.SetVisibility(false);
    PopulateGameTypeList();
    lb_MapList.PopulateList(MVRI);
    lb_VoteList.PopulateList(MVRI);
}

function ShowDisabledMessage()
{
    local GUIQuestionPage QuestionPage;

    Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
    QuestionPage = GUIQuestionPage(Controller.TopPage());
    QuestionPage.SetupQuestion(lmsgMapVotingDisabled, QBTN_Ok, QBTN_Ok);
    QuestionPage.OnClose = OnCloseQuestionPage;
}

function PopulateGameTypeList()
{
    local int i;

    if (MVRI.GameConfig.Length < MVRI.GameConfigCount
        || co_GameType.MyComboBox.List.Elements.Length > 0)
    {
        return;
    }
    for (i = 0; i < MVRI.GameConfig.Length; ++i)
    {
        co_GameType.AddItem(MVRI.GameConfig[i].GameName, none, string(i));
    }
    co_GameType.MyComboBox.List.SortList();
    SelectedGameType = co_GameType.FindExtra(string(MVRI.CurrentGameConfig));
    co_GameType.SetIndex(SelectedGameType);
}

function PopulateLocalLists()
{
    local int i;

    for (i = 0; i < 3; ++i)
    {
        co_MapSource.AddItem(Mid(GetEnum(enum'EHxMapSource', i), 14));
    }
    co_MapSource.SetIndex(0);
}

function UpdateMapVoteCount(int UpdatedIndex, bool bRemoved)
{
    lb_VoteList.UpdatedVoteCount(UpdatedIndex, bRemoved);
}

function OnChangeGameType(GUIComponent Sender)
{
    local int Type;

    Type = int(co_GameType.GetExtra());
    if (Type > -1)
    {
        ActiveFilter.SetPrefix(MVRI.GameConfig[Type].Prefix);
        OnFilterChange();
    }
}

function SubmitVote()
{
    local PlayerController PC;

    if (SelectedMap > -1 && SelectedGameType > -1)
    {
        PC = PlayerOwner();
        if (MVRI.MapList[SelectedMap].bEnabled || PC.PlayerReplicationInfo.bAdmin)
        {
            MVRI.SendMapVote(SelectedMap, SelectedGameType);
        }
        else
        {
            PC.ClientMessage(lmsgMapDisabled);
        }
    }
}

function SelectRandom()
{
    if (lb_VoteList.bHasFocus && !lb_VoteList.IsEmpty())
    {
        lb_VoteList.SelectRandom();
    }
    else
    {
        lb_MapList.SelectRandom();
    }
}

function OnChangeMapSource(GUIComponent Sender)
{
    ActiveFilter.SetMapSource(co_MapSource.GetIndex());
    OnFilterChange();
}

function OnChangeSelectedMap(GUIComponent Sender)
{
    local int NewSelectedMap;

    NewSelectedMap = HxGUIVotingBaseListBox(Sender).GetMapIndex();
    if (NewSelectedMap > -1)
    {
        switch (Sender)
        {
            case lb_VoteList:
                SelectedGameType = lb_VoteList.GetGameTypeIndex();
                break;
            case lb_MapList:
                SelectedGameType = int(co_GameType.GetExtra());
                break;
        }
        SelectedMap = NewSelectedMap;
        MapBanner.SetMap(HxGUIVotingBaseListBox(Sender).GetMapName());
    }
}

function OnChangeNameSearch(GUIComponent Sender)
{
    ActiveFilter.SetSearchBarName(ed_SearchName.GetText(), ch_CaseSensitive.IsChecked());
    OnFilterChange();
}

function OnChangePlayersSearch(GUIComponent Sender)
{
    ActiveFilter.SetSearchBarPlayers(ed_SearchPlayers.GetText());
    OnFilterChange();
}

function OnChangePlayedSearch(GUIComponent Sender)
{
    ActiveFilter.SetSearchBarPlayed(ed_SearchPlayed.GetText());
    OnFilterChange();
}

function OnChangeSequenceSearch(GUIComponent Sender)
{
    ActiveFilter.SetSearchBarSequence(ed_SearchSeq.GetText());
    OnFilterChange();
}

function OnFilterChange()
{
    lb_MapList.FilterUpdated(MapBanner.DisplayedMap);
}

function OnCloseQuestionPage(optional bool bCanceled)
{
    Controller.CloseMenu(bCanceled);
}

function FixEditBoxStyle(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIEditBox(NewComp) != None)
    {
        NewComp.StyleName = "HxEditBox";
    }
}

function AdjustWindowSize(coerce float X, coerce float Y)
{
    local float Coefficient;

    Coefficient = (4.0 / 3.0) / (X / Y);
    WinWidth = default.WinWidth * Coefficient;
    WinLeft = default.WinLeft + ((default.WinWidth - WinWidth) / 2);
}

function PropagateEditBoxProperties()
{
    ed_SearchName.MyComponent.Hint = ed_SearchName.Hint;
    ed_SearchName.Hint = "";
    ed_SearchName.MyComponent.StyleName = "HxEditBox";
    ed_SearchName.MyComponent.ToolTip.ExpirationSeconds = 5;
    ed_SearchName.MyComponent.FontScale = ed_SearchName.FontScale;
    ed_SearchPlayers.ToolTip.ExpirationSeconds = 10;
    ed_SearchPlayed.ToolTip.ExpirationSeconds = 6;
    ed_SearchSeq.ToolTip.ExpirationSeconds = 6;
}

function bool InternalOnPreDraw(Canvas C)
{
    UpdateSearchBarWidth();
    return Super.InternalOnPreDraw(C);
}

function UpdateSearchBarWidth()
{
    local float Width;

    if (lb_MapList.List.ColumnWidths.Length >= 3)
    {
        Width = ActualWidth();
        ed_SearchName.WinWidth = (lb_MapList.List.ColumnWidths[0] / Width) - 0.001;
        ed_SearchPlayers.WinLeft = ed_SearchName.WinLeft + ed_SearchName.WinWidth + 0.001;
        ed_SearchPlayers.WinWidth = (lb_MapList.List.ColumnWidths[1] / Width) - 0.001;
        ed_SearchPlayed.WinLeft = ed_SearchPlayers.WinLeft + ed_SearchPlayers.WinWidth + 0.001;
        ed_SearchPlayed.WinWidth = (lb_MapList.List.ColumnWidths[2] / Width) - 0.001;
        ed_SearchSeq.WinLeft = ed_SearchPlayed.WinLeft + ed_SearchPlayed.WinWidth + 0.001;
        ed_SearchSeq.WinWidth = ch_CaseSensitive.WinLeft - ed_SearchSeq.WinLeft - 0.002;
    }
}

event Free()
{
    local VotingReplicationInfo VRI;
    VRI = MVRI;
    Super.Free();
    MVRI = VRI;
}

function LevelChanged()
{
    ShowInitialState();
    Super.LevelChanged();
}

defaultproperties {
    Begin Object Class=HxGUIVotingVoteListBox Name=VoteListBox
        WinLeft=0.02
        WinTop=0.052930
        WinWidth=0.5907
        WinHeight=0.21
        bScaleToParent=true
        bBoundToParent=true
        FontScale=FNS_Small
        NotifySelection=OnChangeSelectedMap
        NotifyVote=SubmitVote
        TabOrder=0
    End Object
    lb_VoteList=VoteListBox

    Begin Object class=moComboBox Name=GameTypeComboBox
        Caption="Game Type:"
        Hint="Select game type to show."
        WinLeft=0.02
        WinTop=0.27293
        WinWidth=0.415
        WinHeight=0.0375
        CaptionWidth=0.001
        bReadOnly=true
        bScaleToParent=true
        bBoundToParent=true
        OnChange=OnChangeGameType
        TabOrder=1
    End Object
    co_GameType=GameTypeComboBox

    Begin Object class=moComboBox Name=MapSourceComboBox
        Caption="Source:"
        Hint="Select map sources to show."
        WinLeft=0.445
        WinTop=0.27293
        WinWidth=0.1657
        WinHeight=0.0375
        CaptionWidth=0.001
        bReadOnly=true
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangeMapSource
        TabOrder=2
    End Object
    co_MapSource=MapSourceComboBox

    Begin Object Class=HxGUIVotingMapListBox Name=MapListBox
        WinLeft=0.02
        WinTop=0.3136
        WinWidth=0.5907
        WinHeight=0.60782
        bScaleToParent=true
        bBoundToParent=true
        FontScale=FNS_Small
        NotifySelection=OnChangeSelectedMap
        NotifyVote=SubmitVote
        TabOrder=3
    End Object
    lb_MapList=MapListBox

    Begin Object class=moEditBox Name=SearchNameEditBox
        Caption="Search:"
        Hint="Search by map name. * matches anything. ^ and $ matches begin and end of name."
        WinLeft=0.02
        WinTop=0.92527
        WinWidth=0.5575
        WinHeight=0.03143
        StyleName="HxEditBox"
        LabelStyleName="HxSmallLabel"
        FontScale=FNS_Small
        CaptionWidth=0.001
        TabOrder=4
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangeNameSearch
        OnCreateComponent=FixEditBoxStyle
    End Object
    ed_SearchName=SearchNameEditBox

    Begin Object class=GUIEditBox Name=SearchPlayersEditBox
        Hint="Search by player count. One number shows maps that support it. Two numbers separated by - shows min-max player counts. * matches anything. > or < or = followed by a number matches with comparison."
        WinTop=0.92527
        WinHeight=0.03143
        StyleName="HxEditBox"
        FontScale=FNS_Small
        TabOrder=5
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangePlayersSearch
    End Object
    ed_SearchPlayers=SearchPlayersEditBox

    Begin Object class=GUIEditBox Name=SearchPlayedEditBox
        Hint="Search by played count. * matches anything. > or < or = followed by a number matches with comparison."
        WinTop=0.92527
        WinHeight=0.03143
        StyleName="HxEditBox"
        FontScale=FNS_Small
        TabOrder=6
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangePlayedSearch
    End Object
    ed_SearchPlayed=SearchPlayedEditBox

    Begin Object class=GUIEditBox Name=SearchSeqEditBox
        Hint="Search by sequence. * matches anything. > or < or = followed by a number matches with comparison."
        WinTop=0.92527
        WinHeight=0.03143
        StyleName="HxEditBox"
        FontScale=FNS_Small
        TabOrder=7
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangeSequenceSearch
    End Object
    ed_SearchSeq=SearchSeqEditBox

    Begin Object class=moCheckBox Name=CaseSensitiveCheckBox
        Hint="Case Sensitive"
        WinLeft=0.5905
        WinTop=0.92527
        WinWidth=0.02
        WinHeight=0.03143
        bSquare=true
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
        ComponentJustification=TXTA_Right
        TabOrder=8
        OnChange=OnChangeNameSearch
    End Object
    ch_CaseSensitive=CaseSensitiveCheckBox

    Begin Object Class=GUILabel Name=RetrievingMapListLabel
        WinLeft=0.02
        WinTop=0.3136
        WinWidth=0.59
        WinHeight=0.60782
        TextFont="MediumFont"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        BackColor=(R=38,G=59,B=126,A=255)
        bTransparent=false
        bVisible=false
        RenderWeight=1
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_RetrievingMapList=RetrievingMapListLabel

    Begin Object Class=HxGUIVotingMapBanner Name=VotingMapBanner
        WinLeft=0.6175
        WinTop=0.052930
        WinWidth=0.3625
        WinHeight=0.67391
        bBoundToParent=true
        bScaleToParent=true
        SelectRandom=SelectRandom
        SubmitVote=SubmitVote
    End Object
    MapBanner=VotingMapBanner

    Begin Object Class=HxGUIVotingChatBox Name=VotingChatBox
        WinLeft=0.6175
        WinTop=0.7367
        WinWidth=0.3625
        WinHeight=0.22
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=11
    End Object
    ChatBox=VotingChatBox

    WinTop=0.05
    WinLeft=0.0025
    WinWidth=0.995
    WinHeight=0.875

    lb_VoteCountListBox=None
    lb_MapListBox=None
    i_MapCountListBackground=None
    i_MapListBackground=None
    f_Chat=None
    bPersistent=true

    LoadingText="LOADING..."
    RetrievingMapListText="Retrieving Map List"
}
