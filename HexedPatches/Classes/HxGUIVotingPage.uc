class HxGUIVotingPage extends MapVotingPage;

const VERT_SPACING = 0.009;
const MED_FONT_SPACING = 1.44;

var automated HxGUIVotingVoteListBox lb_VoteList;
var automated GUIImage i_VoteListBorder;
var automated moComboBox co_MapSource;
var automated HxGUIVotingMapListBox lb_MapList;
var automated GUILabel l_RetrievingMapList;
var automated HxGUIVotingMapBanner MapBanner;
var automated HxGUIFramedButton fb_Random;
var automated HxGUIFramedButton fb_Vote;
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

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputAction Action;

    if (co_GameType.MyComboBox.List.bHasFocus || co_MapSource.MyComboBox.List.bHasFocus)
    {
        return false;
    }
    Action = EInputAction(State);
    switch (EInputKey(Key))
    {
        case IK_MouseWheelUp:
        case IK_MouseWheelDown:
            if (lb_VoteList.IsInBounds())
            {
                if (!lb_VoteList.bHasFocus)
                {
                    lb_VoteList.SetFocus(None);
                }
            }
            else if (lb_MapList.IsInBounds())
            {
                if (!lb_MapList.bHasFocus)
                {
                    lb_MapList.SetFocus(None);
                }
            }
            else if (MapBanner.lb_Description.IsInBounds())
            {
                if (!MapBanner.lb_Description.bHasFocus)
                {
                    MapBanner.lb_Description.SetFocus(None);
                }
            }
            else if (ChatBox.lb_Chat.IsInBounds())
            {
                if (!ChatBox.lb_Chat.bHasFocus)
                {
                    ChatBox.lb_Chat.SetFocus(None);
                }
            }
            break;
    }
    return false;
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

function bool OnClickSubmitVote(GUIComponent Sender)
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
    return true;
}

function bool OnClickSelectRandom(GUIComponent Sender)
{
    if (lb_VoteList.bHasFocus && !lb_VoteList.IsEmpty())
    {
        lb_VoteList.SelectRandom();
    }
    else
    {
        lb_MapList.SelectRandom();
    }
    return true;
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

function bool FloatingPreDraw(Canvas C)
{
    if (bInit)
    {
        AdjustWindowSize(C.ClipX, C.ClipY);
        AlignRightSideComponents(C);
    }
    return Super.FloatingPreDraw(C);
}

function AdjustWindowSize(coerce float X, coerce float Y)
{
    local float Coefficient;

    Coefficient = (4.0 / 3.0) / (X / Y);
    WinWidth = default.WinWidth * Coefficient;
    WinLeft = default.WinLeft + ((default.WinWidth - WinWidth) / 2);
}

function AlignRightSideComponents(Canvas C)
{
    fb_Random.WinHeight = fb_Random.RelativeHeight(fb_Random.GetFontHeight(C) * MED_FONT_SPACING);
    fb_Random.WinTop = ChatBox.WinTop - VERT_SPACING - fb_Random.WinHeight;
    fb_Vote.WinTop = fb_Random.WinTop;
    fb_Vote.WinHeight = fb_Random.WinHeight;
    MapBanner.WinHeight = fb_Random.WinTop - VERT_SPACING - MapBanner.WinTop;
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
        NotifyVote=OnClickSubmitVote
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
        WinLeft=0.4483
        WinTop=0.2735
        WinWidth=0.1702
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
        NotifyVote=OnClickSubmitVote
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
    End Object
    MapBanner=VotingMapBanner

    Begin Object Class=HxGUIFramedButton Name=RandomButton
        Caption="Select Random"
        Hint="Select a random map from the map list (or vote list if focused and non-empty)."
        WinLeft=0.624
        WinWidth=0.1785
        bNeverFocus=true
        bRepeatClick=true
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickSelectRandom
    End Object
    fb_Random=RandomButton

    Begin Object Class=HxGUIFramedButton Name=VoteButton
        Caption="Submit Vote"
        Hint="Vote for the currently selected map."
        WinLeft=0.808
        WinWidth=0.1785
        bNeverFocus=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickSubmitVote
    End Object
    fb_Vote=VoteButton

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
    OnKeyEvent=InternalOnKeyEvent

    lb_VoteCountListBox=None
    lb_MapListBox=None
    i_MapCountListBackground=None
    i_MapListBackground=None
    f_Chat=None
    bPersistent=true

    LoadingText="LOADING..."
    RetrievingMapListText="Retrieving Map List"
}
