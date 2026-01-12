class HxGUIVotingPage extends MapVotingPage;

var automated HxGUIVotingMapListBox lb_MapList;
var automated HxGUIVotingVoteListBox lb_VoteList;
var automated moComboBox co_MapSource;
var automated moEditBox ed_SearchName;
var automated moEditBox ed_SearchPlayers;
var automated moEditBox ed_SearchPlayed;
var automated moEditBox ed_SearchSeq;
var automated moCheckBox ch_CaseSensitive;
var automated AltSectionBackground sb_MapPreview;
var automated GUIImage i_MapPreviewBackground;
var automated GUIImage i_Preview;
var automated GUILabel l_ReceivingMapList;
var automated GUILabel l_NoMapSelected;
var automated GUILabel l_NoPreview;
var automated GUILabel l_MapName;
var automated HxGUIScrollTextBox lb_MapPreviewFooter;
var automated HxGUIScrollTextBox lb_MapDescription;

var localized string LoadingText;
var localized string ReceivingMapListText;
var localized string PlayersText;

var HxMapVoteFilterManager FilterManager;
var HxMapVoteFilter ActiveFilter;
var string SelectedMapName;

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
    HxGUIController(Controller).RemovePersistentMenu(Self);
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
    l_ReceivingMapList.SetVisibility(false);
    UpdateMapPreview("");
}

function ShowLoadingState()
{
    t_WindowTitle.Caption = WindowName@"("$LoadingText$")";
    l_ReceivingMapList.Caption = ReceivingMapListText@"("$MVRI.MapList.Length$"/"$MVRI.MapCount$")";
    l_ReceivingMapList.SetVisibility(true);
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
    l_ReceivingMapList.SetVisibility(false);
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
    co_GameType.SetIndex(co_GameType.FindExtra(string(MVRI.CurrentGameConfig)));
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

function SendVoteFrom(HxGUIVotingBaseListBox Sender)
{
    switch (Sender)
    {
        case lb_VoteList:
            SendMapVote(lb_VoteList.GetMapIndex(), lb_VoteList.GetGameTypeIndex());
            break;
        case lb_MapList:
            SendMapVote(lb_MapList.GetMapIndex(), co_GameType.GetExtra());
            break;
        default:
            break;
    }
}

function SendMapVote(int Map, coerce int Type)
{
    local PlayerController PC;

    if (Map > -1)
    {
        PC = PlayerOwner();
        if (MVRI.MapList[Map].bEnabled || PC.PlayerReplicationInfo.bAdmin)
        {
            MVRI.SendMapVote(Map, Type);
        }
        else
        {
            PC.ClientMessage(lmsgMapDisabled);
        }
    }
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
        lb_MapList.FilterUpdated();
    }
}

function OnChangeMapSource(GUIComponent Sender)
{
    ActiveFilter.SetMapSource(co_MapSource.GetIndex());
    lb_MapList.FilterUpdated();
}

function OnChangeNameSearch(GUIComponent Sender)
{
    ActiveFilter.SetSearchBarName(ed_SearchName.GetText(), ch_CaseSensitive.IsChecked());
    lb_MapList.FilterUpdated();
}

function OnChangePlayersSearch(GUIComponent Sender)
{
    ActiveFilter.SetSearchBarPlayers(ed_SearchPlayers.GetText());
    lb_MapList.FilterUpdated();
}

function OnChangePlayedSearch(GUIComponent Sender)
{
    ActiveFilter.SetSearchBarPlayed(ed_SearchPlayed.GetText());
    lb_MapList.FilterUpdated();
}

function OnChangeSequenceSearch(GUIComponent Sender)
{
    ActiveFilter.SetSearchBarSequence(ed_SearchSeq.GetText());
    lb_MapList.FilterUpdated();
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

function PropagateEditBoxProperties()
{
    ed_SearchName.MyComponent.Hint = ed_SearchName.Hint;
    ed_SearchName.Hint = "";
    ed_SearchName.MyComponent.ToolTip.ExpirationSeconds = 5;
    ed_SearchName.MyComponent.FontScale = ed_SearchName.FontScale;
    ed_SearchPlayers.MyComponent.ToolTip.ExpirationSeconds = 10;
    ed_SearchPlayers.MyComponent.FontScale = ed_SearchPlayers.FontScale;
    ed_SearchPlayed.MyComponent.ToolTip.ExpirationSeconds = 6;
    ed_SearchPlayed.MyComponent.FontScale = ed_SearchPlayed.FontScale;
    ed_SearchSeq.MyComponent.ToolTip.ExpirationSeconds = 6;
    ed_SearchSeq.MyComponent.FontScale = ed_SearchSeq.FontScale;
}

function ResetMapPreview()
{
    SelectedMapName = "";
    l_MapName.Caption = "";
    lb_MapPreviewFooter.SetContent("");
    lb_MapDescription.SetContent("");
    i_Preview.Image = None;
    i_Preview.SetVisibility(false);
}

function bool InternalOnPreDraw(Canvas C)
{
    UpdateMapPreview(GetFocusedMapName());
    UpdateSearchBarWidth();
    return Super.InternalOnPreDraw(C);
}

function string GetFocusedMapName()
{
    if (lb_MapList.bHasFocus)
    {
        return lb_MapList.GetSelectedMapName();
    }
    if (lb_VoteList.bHasFocus)
    {
        return lb_VoteList.GetSelectedMapName();
    }
    return SelectedMapName;
}

function UpdateMapPreview(string MapName)
{
    local CacheManager.MapRecord Record;

    if (MapName == "")
    {
        ResetMapPreview();
        l_NoPreview.SetVisibility(false);
        l_NoMapSelected.SetVisibility(true);
    }
    else if (MapName != SelectedMapName)
    {
        Record = class'CacheManager'.static.GetMapRecord(MapName);
        if (Record.ScreenshotRef != "") {
            i_Preview.Image = Material(DynamicLoadObject(Record.ScreenshotRef, class'Material'));
            i_Preview.SetVisibility(true);
            l_NoPreview.SetVisibility(false);
            l_NoMapSelected.SetVisibility(false);
        }
        else
        {
            ResetMapPreview();
            l_NoPreview.SetVisibility(true);
            l_NoMapSelected.SetVisibility(false);
        }
        l_MapName.Caption = Record.FriendlyName;
        if (Record.PlayerCountMin == Record.PlayerCountMax)
        {
            lb_MapPreviewFooter.SetContent(Record.PlayerCountMin@PlayersText);
        }
        else
        {
            lb_MapPreviewFooter.SetContent(Record.PlayerCountMin@"-"@Record.PlayerCountMax@PlayersText);
        }
        if (Record.Author != "")
        {
            lb_MapPreviewFooter.AddText("Author:"@Record.Author);
        }
        lb_MapDescription.SetContent(GetMapDescription(Record));
        SelectedMapName = MapName;
    }
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
        ed_SearchSeq.WinWidth = lb_MapList.WinWidth - ed_SearchSeq.WinLeft - 0.0013;
    }
}

function string GetMapDescription(CacheManager.MapRecord Record)
{
    local DecoText Deco;
    local string Description;
    local string PackageName;
    local string DecoTextName;
    local int i;

    if (class'CacheManager'.static.Is2003Content(Record.MapName) && Record.TextName != "")
    {
        if (!Divide(Record.TextName, ".", PackageName, DecoTextName))
        {
            PackageName = "XMaps";
            DecoTextName = Record.TextName;
        }
        Deco = class'xUtil'.static.LoadDecoText(PackageName, DecoTextName);
        if (Deco != None)
        {
            for (i = 0; i < Deco.Rows.Length; ++i)
            {
                if (Description != "")
                {
                    Description $= "|";
                }
                Description $= Deco.Rows[i];
            }
            return Description;
        }
    }
    return Record.Description;
}

event Free()
{
    local VotingReplicationInfo VRI;
    VRI = MVRI;
    Super.Free();
    MVRI = VRI;
    lb_MapDescription.MyScrollText.EndScrolling();
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
        WinWidth=0.58
        WinHeight=0.21
        bScaleToParent=true
        bBoundToParent=true
        FontScale=FNS_Small
        TabOrder=0
    End Object
    lb_VoteList=VoteListBox

    Begin Object class=moComboBox Name=GameTypeCombo
        Caption="Type:"
        Hint="Select game type to show."
        WinLeft=0.02
        WinTop=0.27293
        WinWidth=0.39
        WinHeight=0.0375
        CaptionWidth=0.001
        bScaleToParent=true
        bBoundToParent=true
        OnChange=OnChangeGameType
        TabOrder=1
    End Object
    co_GameType=GameTypeCombo

    Begin Object class=moComboBox Name=MapSource
        Caption="Source:"
        Hint="Select map sources to show."
        WinLeft=0.42
        WinTop=0.27293
        WinWidth=0.18
        WinHeight=0.0375
        CaptionWidth=0.001
        bReadOnly=true
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangeMapSource
        TabOrder=2
    End Object
    co_MapSource=MapSource

    Begin Object Class=HxGUIVotingMapListBox Name=MapListBox
        WinLeft=0.02
        WinTop=0.32043
        WinWidth=0.58
        WinHeight=0.597667
        bScaleToParent=true
        bBoundToParent=true
        FontScale=FNS_Small
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
        LabelFont="HxSmallerFont"
        FontScale=FNS_Small
        CaptionWidth=0.001
        TabOrder=4
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangeNameSearch
    End Object
    ed_SearchName=SearchNameEditBox

    Begin Object class=moEditBox Name=SearchPlayersEditBox
        Hint="Search by player count. One number shows maps that support it. Two numbers separated by - shows min-max player counts. * matches anything. > or < or = followed by a number matches with comparison."
        WinTop=0.92527
        WinHeight=0.03143
        LabelFont="HxSmallerFont"
        FontScale=FNS_Small
        CaptionWidth=0.001
        TabOrder=5
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangePlayersSearch
    End Object
    ed_SearchPlayers=SearchPlayersEditBox

    Begin Object class=moEditBox Name=SearchPlayedEditBox
        Hint="Search by played count. * matches anything. > or < or = followed by a number matches with comparison."
        WinTop=0.92527
        WinHeight=0.03143
        LabelFont="HxSmallerFont"
        FontScale=FNS_Small
        CaptionWidth=0.001
        TabOrder=6
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangePlayedSearch
    End Object
    ed_SearchPlayed=SearchPlayedEditBox

    Begin Object class=moEditBox Name=SearchSeqEditBox
        Hint="Search by sequence. * matches anything. > or < or = followed by a number matches with comparison."
        WinTop=0.92527
        WinHeight=0.03143
        LabelFont="HxSmallerFont"
        FontScale=FNS_Small
        CaptionWidth=0.001
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
        WinLeft=0.5805
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

    Begin Object Class=GUIImage Name=MapPreviewBackground
        WinLeft=0.6075
        WinTop=0.052930
        WinWidth=0.3725
        WinHeight=0.4808468
        Image=Material'2K4Menus.NewControls.NewFooter'
        Y1=10
        ImageColor=(R=255,G=255,B=255,A=255)
        ImageStyle=ISTY_Stretched
        RenderWeight=0.1
        bScaleToParent=true
        bBoundToParent=true
    End Object
    i_MapPreviewBackground=MapPreviewBackground

    Begin Object Class=GUIImage Name=MapPreviewImage
        WinLeft=0.62325
        WinTop=0.0945
        WinWidth=0.34
        WinHeight=0.37154
        ImageColor=(R=255,G=255,B=255,A=255)
        ImageStyle=ISTY_Scaled
        ImageRenderStyle=MSTY_Normal
        RenderWeight=0.5
        bScaleToParent=true
        bBoundToParent=true
    End Object
    i_Preview=MapPreviewImage

    Begin Object Class=GUILabel Name=NoPreviewLabel
        Caption="No preview available"
        WinLeft=0.62325
        WinTop=0.0945
        WinWidth=0.34
        WinHeight=0.37154
        TextFont="MediumFont"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        RenderWeight=0.5
        bVisible=false
        bMultiline=true
        bTransparent=false
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_NoPreview=NoPreviewLabel

    Begin Object Class=GUILabel Name=ReceivingMapListLabel
        WinLeft=0.02
        WinTop=0.32043
        WinWidth=0.58
        WinHeight=0.597667
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
    l_ReceivingMapList=ReceivingMapListLabel

    Begin Object Class=GUILabel Name=NoMapSelectedLabel
        Caption="No map selected"
        WinLeft=0.6075
        WinTop=0.052930
        WinWidth=0.3725
        WinHeight=0.67377
        TextFont="MediumFont"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        BackColor=(R=38,G=59,B=126,A=255)
        bTransparent=false
        RenderWeight=1
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_NoMapSelected=NoMapSelectedLabel

    Begin Object class=GUILabel Name=MapNameLabel
        WinLeft=0.6075
        WinTop=0.052930
        WinWidth=0.3725
        WinHeight=0.04157
        TextAlign=TXTA_Center
        VertAlign=TXTA_Right
        TextColor=(R=255,G=210,B=0,A=255)
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_MapName=MapNameLabel

    Begin Object Class=HxGUIScrollTextBox Name=MapPreviewFooterTextBox
        WinLeft=0.6075
        WinTop=0.46604
        WinWidth=0.3725
        WinHeight=0.0677368
        FontScale=FNS_Small
        TextAlign=TXTA_Center
        LineSpacing=0.005
        VerticalPadding=0.085
        bScrollBarOutside=false
        bTabStop=false
        bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
        bStripColors=false
        bBoundToParent=true
        bScaleToParent=true
    End Object
    lb_MapPreviewFooter=MapPreviewFooterTextBox

    Begin Object Class=HxGUIScrollTextBox Name=MapDescription
        WinLeft=0.6075
        WinTop=0.5437768
        WinWidth=0.3725
        WinHeight=0.1829232
        CharDelay=0.0065
        EOLDelay=0.5
        FontScale=FNS_Small
        TextAlign=TXTA_Center
        bCenter=true
        bTabStop=false
        bVisibleWhenEmpty=true
        bNoTeletype=false
        bNeverFocus=true
        bStripColors=false
        bBoundToParent=true
        bScaleToParent=true
    End Object
    lb_MapDescription=MapDescription

    Begin Object Class=HxGUIVotingFooter Name=MapVoteFooter
        WinLeft=0.6075
        WinTop=0.7367
        WinWidth=0.3725
        WinHeight=0.22
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=9
    End Object
    f_Chat=MapVoteFooter

    WinTop=0.05
    WinLeft=0.0025
    WinWidth=0.995
    WinHeight=0.875

    lb_VoteCountListBox=None
    lb_MapListBox=None
    i_MapCountListBackground=None
    i_MapListBackground=None
    bPersistent=true

    LoadingText="LOADING..."
    ReceivingMapListText="Receiving map list from server"
    PlayersText="players"
}
