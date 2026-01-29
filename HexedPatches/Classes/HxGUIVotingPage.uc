class HxGUIVotingPage extends MapVotingPage;

var automated HxGUIVotingVoteListBox lb_VoteList;
var automated GUIImage i_VoteListBorder;
var automated moComboBox co_MapSource;
var automated HxGUIVotingMapListBox lb_MapList;
var automated GUIImage i_MapListBorder;
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
                break;
            case lb_MapList:
                SelectedGameType = int(co_GameType.GetExtra());
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
        WinHeight=0.6431
        bScaleToParent=true
        bBoundToParent=true
        FontScale=FNS_Small
        NotifySelection=OnChangeSelectedMap
        NotifyVote=SubmitVote
        TabOrder=3
    End Object
    lb_MapList=MapListBox

    Begin Object Class=GUILabel Name=RetrievingMapListLabel
        WinLeft=0.02
        WinTop=0.3136
        WinWidth=0.5907
        WinHeight=0.6431
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
        TabOrder=4
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
