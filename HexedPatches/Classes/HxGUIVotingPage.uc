class HxGUIVotingPage extends MapVotingPage;

var automated HxGUIVotingVoteListBox lb_VoteList;
var automated GUIImage i_VoteListBorder;
var automated moComboBox co_MapSource;
var automated HxGUIVotingMapListBox lb_MapList;
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
    lb_MapList.OnTagUpdated = lb_VoteList.UpdateMapTag;
    lb_VoteList.OnTagUpdated = lb_MapList.UpdateMapTag;
    AdjustWindowSize(Controller.ResX, Controller.ResY);
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
    lb_VoteList.Refresh();
    lb_MapList.Refresh();
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
    lb_VoteList.SetVRI(None);
    lb_VoteList.Clear();
    lb_MapList.SetVRI(None);
    lb_MapList.Clear();
    co_GameType.ResetComponent();
    MapBanner.SetMap("");
    lb_VoteList.DisableMe();
    co_GameType.DisableMe();
    co_MapSource.DisableMe();
    lb_MapList.DisableMe();
    l_RetrievingMapList.SetVisibility(false);
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
    l_RetrievingMapList.SetVisibility(false);
    PopulateGameTypeList();
    lb_MapList.SetVRI(MVRI);
    lb_VoteList.SetVRI(MVRI);
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
        lb_MapList.SetPrefix(MVRI.GameConfig[Type].Prefix);
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
    lb_MapList.SetMapSource(co_MapSource.GetIndex());
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
                lb_MapList.SilentSetIndex(-1);
                break;
            case lb_MapList:
                SelectedGameType = int(co_GameType.GetExtra());
                lb_VoteList.SilentSetIndex(-1);
                break;
        }
        SelectedMap = NewSelectedMap;
        MapBanner.SetMap(HxGUIVotingBaseListBox(Sender).GetMapName());
    }
}

function OnCloseQuestionPage(optional bool bCanceled)
{
    Controller.CloseMenu(bCanceled);
}

function AdjustWindowSize(coerce float X, coerce float Y)
{
    local float Coefficient;

    Coefficient = (4.0 / 3.0) / (X / Y);
    WinWidth = default.WinWidth * Coefficient;
    WinLeft = default.WinLeft + ((default.WinWidth - WinWidth) / 2);
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
        WinLeft=0.0135
        WinTop=0.04
        WinWidth=0.605
        WinHeight=0.224
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
        WinLeft=0.0135
        WinTop=0.2735
        WinWidth=0.4293
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
        WinLeft=0.4528
        WinTop=0.2735
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
        WinLeft=0.0135
        WinTop=0.32
        WinWidth=0.605
        WinHeight=0.6497
        bScaleToParent=true
        bBoundToParent=true
        FontScale=FNS_Small
        NotifySelection=OnChangeSelectedMap
        NotifyVote=SubmitVote
        TabOrder=3
    End Object
    lb_MapList=MapListBox

    Begin Object Class=GUILabel Name=RetrievingMapListLabel
        WinLeft=0.0135
        WinTop=0.32
        WinWidth=0.605
        WinHeight=0.6497
        TextFont="MediumFont"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        bVisible=false
        RenderWeight=1
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_RetrievingMapList=RetrievingMapListLabel

    Begin Object Class=HxGUIVotingMapBanner Name=VotingMapBanner
        WinLeft=0.624
        WinTop=0.04
        WinWidth=0.3625
        WinHeight=0.7
        bBoundToParent=true
        bScaleToParent=true
        SelectRandom=SelectRandom
        SubmitVote=SubmitVote
    End Object
    MapBanner=VotingMapBanner

    Begin Object Class=HxGUIVotingChatBox Name=VotingChatBox
        WinLeft=0.624
        WinTop=0.7497
        WinWidth=0.3625
        WinHeight=0.22
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=4
    End Object
    ChatBox=VotingChatBox

    WinLeft=0.02
    WinWidth=0.96

    lb_VoteCountListBox=None
    lb_MapListBox=None
    i_MapCountListBackground=None
    i_MapListBackground=None
    f_Chat=None
    bPersistent=true

    LoadingText="LOADING..."
    RetrievingMapListText="Retrieving Map List"
}
