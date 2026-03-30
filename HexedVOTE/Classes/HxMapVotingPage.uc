class HxMapVotingPage extends MapVotingPage;

const VERT_SPACING = 0.009;
const MED_FONT_SPACING = 1.44;

var automated GUIBorder b_Background;
var automated HxMapVotingVoteListBox lb_VoteList;
var automated GUIImage i_VoteListBorder;
var automated moComboBox co_MapFilter;
var automated GUIButton b_ManageFilters;
var automated HxMapVotingMapListBox lb_MapList;
var automated GUILabel l_RetrievingMapList;
var automated HxGUIMapPreviewBanner MapBanner;
var automated GUIButton b_Random;
var automated GUIButton b_Vote;
var automated HxGUIChatBox ChatBox;

var localized string LoadingText;
var localized string RetrievingMapListText;

var HxMapFilterManager FilterManager;
var private int SelectedGameType;
var private int SelectedMap;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    WindowName = class'MutHexedVOTE'.default.FriendlyName@"-"@default.WindowName;
    Super(PopupPageBase).InitComponent(MyController, MyOwner);
    FilterManager = new() class'HxMapFilterManager';
    lb_MapList.OnTagUpdated = lb_VoteList.UpdateMapTag;
    lb_VoteList.OnTagUpdated = lb_MapList.UpdateMapTag;
    class'HxGUIStyles'.static.ApplyComboBoxStyle(Controller, co_GameType);
    class'HxGUIStyles'.static.ApplyComboBoxStyle(Controller, co_MapFilter);
    SetupWindowHeader();
    Unpause();
    AdjustWindowSize(Controller.ResX, Controller.ResY);
    UpdateMapFilter();
    ShowInitialState();
}

function SetupWindowHeader()
{
    t_WindowTitle.SetCaption(WindowName);
    if (bMoveAllowed)
    {
        t_WindowTitle.bAcceptsInput = True;
        t_WindowTitle.MouseCursorIndex = HeaderMouseCursorIndex;
    }
    b_ExitButton = HxGUIHeader(t_WindowTitle).b_Close;
    b_ExitButton.OnClick = XButtonClicked;
    b_ExitButton.FocusInstead = t_WindowTitle;
}

function Unpause()
{
    local PlayerController PC;

    PC = PlayerOwner();
    if(PC != None)
    {
        if (PC.Level.Pauser != None)
        {
            PC.SetPause(false);
        }
    }
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

    if (co_GameType.MyComboBox.List.bHasFocus || co_MapFilter.MyComboBox.List.bHasFocus)
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
            else if (MapBanner.lb_Information.IsInBounds())
            {
                if (!MapBanner.lb_Information.bHasFocus)
                {
                    MapBanner.lb_Information.SetFocus(None);
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
    co_MapFilter.DisableMe();
    b_ManageFilters.DisableMe();
    lb_MapList.DisableMe();
    b_Random.DisableMe();
    b_Vote.DisableMe();
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
    co_MapFilter.EnableMe();
    b_ManageFilters.EnableMe();
    lb_MapList.EnableMe();
    b_Random.EnableMe();
    b_Vote.EnableMe();
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

function UpdateMapFilter()
{
    local int Index;

    Index = Max(0, co_MapFilter.GetIndex());
    co_MapFilter.ResetComponent();
    FilterManager.PopulateComboBox(co_MapFilter);
    co_MapFilter.SilentSetIndex(Min(Index, co_MapFilter.ItemCount() - 1));
    lb_MapList.SetFilter(FilterManager.SwitchActiveFilter(co_MapFilter.GetComponentValue()));
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

function bool OnClickManageFilters(GUIComponent Sender)
{
    if (Controller.OpenMenu(string(class'HxMapFilterPage')))
    {
        Controller.ActivePage.OnClose = OnCloseFilterPage;
    }
    return true;
}

function OnCloseFilterPage(optional bool bCancelled)
{
    UpdateMapFilter();
}

function OnChangeMapFilter(GUIComponent Sender)
{
    lb_MapList.SetFilter(
        FilterManager.SwitchActiveFilter(GUIMenuOption(Sender).GetComponentValue()));
}

function OnChangeSelectedMap(GUIComponent Sender)
{
    local int NewSelectedMap;

    NewSelectedMap = HxMapVotingBaseListBox(Sender).GetMapIndex();
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
        MapBanner.SetMap(HxMapVotingBaseListBox(Sender).GetMapName());
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

event Free()
{
    Super(GUIPage).Free();
}

function LevelChanged()
{
    bPersistent = false;
    ShowInitialState();
    Super.LevelChanged();
}

defaultproperties
{
    Begin Object Class=HxGUIHeader Name=WindowTitleHeader
        OnMousePressed=FloatingWindow.FloatingMousePressed
        OnMouseRelease=FloatingWindow.FloatingMouseRelease
    End Object
    t_WindowTitle=HxGUIHeader'HxGUIFloatingWindow.WindowTitleHeader'

    Begin Object Class=GUIBorder Name=BackgroundBorder
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        RenderWeight=0.000001
        StyleName="HxMenuBackground"
        bScaleToParent=true
        bBoundToParent=true
    End Object
    b_Background=BackgroundBorder
    i_FrameBG=None

    Begin Object Class=HxMapVotingVoteListBox Name=VoteListBox
        WinLeft=0.01
        WinTop=0.045
        WinWidth=0.605
        WinHeight=0.22
        bScaleToParent=true
        bBoundToParent=true
        FontScale=FNS_Small
        NotifySelection=OnChangeSelectedMap
        NotifyVote=OnClickSubmitVote
        TabOrder=0
    End Object
    lb_VoteList=VoteListBox

    Begin Object class=moComboBox Name=GameTypeComboBox
        Caption="Game Type"
        Hint="Select game type to show."
        WinLeft=0.015
        WinTop=0.2745
        WinWidth=0.6
        StandardHeight=0.0325
        bStandardized=true
        CaptionWidth=0.176
        LabelStyleName="HxTextLabel"
        bReadOnly=true
        bScaleToParent=true
        bBoundToParent=true
        OnChange=OnChangeGameType
        TabOrder=1
    End Object
    co_GameType=GameTypeComboBox

    Begin Object class=moComboBox Name=MapFilterComboBox
        Caption="Map Filter"
        Hint="Select map filter to apply."
        WinLeft=0.015
        WinTop=0.324625
        WinWidth=0.4243
        StandardHeight=0.0325
        bStandardized=true
        CaptionWidth=0.2489
        LabelStyleName="HxTextLabel"
        bReadOnly=true
        bScaleToParent=true
        bBoundToParent=true
        OnChange=OnChangeMapFilter
        TabOrder=1
    End Object
    co_MapFilter=MapFilterComboBox

    Begin Object Class=GUIButton Name=ManageFiltersButton
        Caption="Manage Filters"
        Hint="Manage map filters."
        WinLeft=0.4448
        WinTop=0.324625
        WinWidth=0.1702
        StandardHeight=0.0325
        bStandardized=true
        StyleName="HxSquareButton"
        bNeverFocus=true
        bRepeatClick=true
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickManageFilters
    End Object
    b_ManageFilters=ManageFiltersButton

    Begin Object Class=HxMapVotingMapListBox Name=MapListBox
        WinLeft=0.01
        WinTop=0.37425
        WinWidth=0.605
        WinHeight=0.60775
        bScaleToParent=true
        bBoundToParent=true
        FontScale=FNS_Small
        NotifySelection=OnChangeSelectedMap
        NotifyVote=OnClickSubmitVote
        TabOrder=3
    End Object
    lb_MapList=MapListBox

    Begin Object Class=GUILabel Name=RetrievingMapListLabel
        WinLeft=0.01
        WinTop=0.37425
        WinWidth=0.605
        WinHeight=0.60775
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

    Begin Object Class=HxGUIMapPreviewBanner Name=MapPreviewBanner
        WinLeft=0.6205
        WinTop=0.045
        WinWidth=0.3695
        WinHeight=0.658375
        bBoundToParent=true
        bScaleToParent=true
    End Object
    MapBanner=MapPreviewBanner

    Begin Object Class=GUIButton Name=RandomButton
        Caption="Select Random"
        Hint="Select a random map from the map list (or vote list if focused and non-empty)."
        WinLeft=0.6205
        WinTop=0.712375
        WinWidth=0.182
        StandardHeight=0.0325
        bStandardized=true
        StyleName="HxSquareButton"
        bNeverFocus=true
        bRepeatClick=true
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickSelectRandom
    End Object
    b_Random=RandomButton

    Begin Object Class=GUIButton Name=VoteButton
        Caption="Submit Vote"
        Hint="Vote for the currently selected map."
        WinLeft=0.808
        WinTop=0.712375
        WinWidth=0.182
        StandardHeight=0.0325
        bStandardized=true
        StyleName="HxSquareButton"
        bNeverFocus=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickSubmitVote
    End Object
    b_Vote=VoteButton

    Begin Object Class=HxGUIChatBox Name=VotingChatBox
        WinLeft=0.6205
        WinTop=0.762
        WinWidth=0.3695
        WinHeight=0.22
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=4
    End Object
    ChatBox=VotingChatBox

    WinLeft=0.02
    WinWidth=0.96
    OnKeyEvent=InternalOnKeyEvent

    WindowName="Map Voting"
    lb_VoteCountListBox=None
    lb_MapListBox=None
    i_MapCountListBackground=None
    i_MapListBackground=None
    f_Chat=None
    bPersistent=true

    LoadingText="LOADING..."
    RetrievingMapListText="Retrieving Map List"
}
