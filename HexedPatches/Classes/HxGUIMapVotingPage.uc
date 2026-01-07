class HxGUIMapVotingPage extends MapVotingPage;

var automated HxGUIMapVoteListBox lb_MapVoteListBox;
var automated HxGUIMapVoteCountListBox lb_MapVoteCountListBox;
var automated AltSectionBackground sb_MapPreview;
var automated GUIImage i_MapPreviewBackground;
var automated GUIImage i_Preview;
var automated GUILabel l_NoMapSelected;
var automated GUILabel l_NoPreview;
var automated GUILabel l_MapPlayerCount;
var automated GUILabel l_MapName;
var automated GUILabel l_MapAuthor;
var automated HxGUIScrollTextBox lb_MapDescription;

var localized string PlayersText;

var string SelectedMapName;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    lb_MapVoteListBox.List.OnDblClick = OnMapListDoubleClick;
    lb_MapVoteCountListBox.List.OnDblClick = OnMapListDoubleClick;
    AdjustWindowSize(Controller.ResX, Controller.ResY);
    SetTimer(0.02, true);
}

event Timer()
{
    if (MVRI != None)
    {
        if (!MVRI.bMapVote)
        {
            ShowDisabledMessage();
        }
        else
        {
            t_WindowTitle.Caption @= "("$lmsgMode[MVRI.Mode]$")";
            InitializeGameTypeList();
        }
        KillTimer();
    }
}

function ShowDisabledMessage()
{
    local GUIQuestionPage QuestionPage;

    Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
    QuestionPage = GUIQuestionPage(Controller.TopPage());
    QuestionPage.SetupQuestion(lmsgMapVotingDisabled, QBTN_Ok, QBTN_Ok);
    QuestionPage.OnClose = OnCloseQuestionPage;
}

function InitializeGameTypeList()
{
    local int i;

    for (i = 0; i < MVRI.GameConfig.Length; ++i)
    {
        co_GameType.AddItem(MVRI.GameConfig[i].GameName, none, string(i));
    }
    co_GameType.MyComboBox.List.SortList();
    co_GameType.SetIndex(co_GameType.FindExtra(string(MVRI.CurrentGameConfig)));
}

function SendVote(optional GUIComponent Sender)
{
    local PlayerController PC;
    local int Type;
    local int Map;

    if (Sender == lb_MapVoteCountListBox.List) {
        Map = lb_MapVoteCountListBox.GetSelectedMapIndex();
        Type = lb_MapVoteCountListBox.GetSelectedGameTypeIndex();
    }
    else
    {
        Map = lb_MapVoteListBox.GetSelectedMapIndex();
        Type = int(co_GameType.GetExtra());
    }
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
    lb_MapVoteCountListBox.UpdatedVoteCount(UpdatedIndex, bRemoved);
}

function OnChangeGameType(GUIComponent Sender)
{
    local int Type;

    Type = int(co_GameType.GetExtra());

    if (Type > -1)
    {
        lb_MapVoteListBox.SetSelectedGameType(Type);
    }
}

function bool OnMapListDoubleClick(GUIComponent Sender)
{
    SendVote(Sender);
    return true;
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

function ResetMapPreview()
{
    SelectedMapName = "";
    l_MapName.Caption = "";
    l_MapPlayerCount.Caption = "";
    l_MapAuthor.Caption = "";
    lb_MapDescription.SetContent("");
    i_Preview.Image = None;
    i_Preview.SetVisibility(false);
}

function bool InternalOnPreDraw(Canvas C)
{
    UpdateMapPreview(GetFocusedMapName());
    return Super.InternalOnPreDraw(C);
}

function string GetFocusedMapName()
{
    if (lb_MapVoteListBox.bHasFocus)
    {
        return lb_MapVoteListBox.GetSelectedMapName();
    }
    if (lb_MapVoteCountListBox.bHasFocus)
    {
        return lb_MapVoteCountListBox.GetSelectedMapName();
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
            l_MapPlayerCount.Caption = Record.PlayerCountMin@PlayersText;
        }
        else
        {
            l_MapPlayerCount.Caption = Record.PlayerCountMin@"-"@Record.PlayerCountMax@PlayersText;
        }
        if (Record.Author != "")
        {
            l_MapAuthor.Caption = "Author:"@Record.Author;
        }
        lb_MapDescription.SetContent(GetMapDescription(Record));
        SelectedMapName = MapName;
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

defaultproperties {
    Begin Object Class=HxGUIMapVoteCountListBox Name=MapVoteCountListBox
        WinLeft=0.02
        WinTop=0.052930
        WinWidth=0.58
        WinHeight=0.21
        bScaleToParent=true
        bBoundToParent=true
        FontScale=FNS_Small
    End Object
    lb_MapVoteCountListBox=MapVoteCountListBox

    Begin Object class=moComboBox Name=GameTypeCombo
        Caption="Game Type:"
        WinLeft=0.02
        WinTop=0.27293
        WinWidth=0.58
        WinHeight=0.037500
        CaptionWidth=0.25
        bScaleToParent=true
        bBoundToParent=true
        OnChange=OnChangeGameType
    End Object
    co_GameType=GameTypeCombo

    Begin Object Class=HxGUIMapVoteListBox Name=MapVoteListBox
        WinLeft=0.02
        WinTop=0.32043
        WinWidth=0.58
        WinHeight=0.63627
        bScaleToParent=true
        bBoundToParent=true
        FontScale=FNS_Small
    End Object
    lb_MapVoteListBox=MapVoteListBox

    Begin Object Class=GUIImage Name=MapPreviewBackground
        WinLeft=0.6075
        WinTop=0.052930
        WinWidth=0.3725
        WinHeight=0.4808468
        Image=Material'2K4Menus.NewControls.NewFooter'
        Y1=2
        ImageColor=(R=255,G=255,B=255,A=192)
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
        WinHeight=0.3715355877502963
        ImageColor=(R=255,G=255,B=255,A=255)
        ImageStyle=ISTY_Scaled
        ImageRenderStyle=MSTY_Normal
        RenderWeight=0.2
        bScaleToParent=true
        bBoundToParent=true
    End Object
    i_Preview=MapPreviewImage

    Begin Object Class=GUILabel Name=NoPreviewLabel
        Caption="No preview available"
        WinLeft=0.62325
        WinTop=0.0945
        WinWidth=0.34
        WinHeight=0.37583079685723614
        TextFont="MediumFont"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        RenderWeight=0.3
        bVisible=false
        bMultiline=true
        bTransparent=false
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_NoPreview=NoPreviewLabel

    Begin Object Class=GUILabel Name=NoMapSelectedLabel
        Caption="No map selected"
        WinLeft=0.6075
        WinTop=0.052930
        WinWidth=0.3725
        WinHeight=0.4808468
        TextFont="MediumFont"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        RenderWeight=0.3
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
        RenderWeight=0.3
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_MapName=MapNameLabel

    Begin Object class=GUILabel Name=MapPlayerCountLabel
        WinLeft=0.6075
        WinTop=0.4703307968572361
        WinWidth=0.3725
        WinHeight=0.03
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        TextFont="UT2SmallFont"
        FontScale=FNS_Small
        RenderWeight=0.3
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_MapPlayerCount=MapPlayerCountLabel

    Begin Object class=GUILabel Name=MapAuthorLabel
        WinLeft=0.6075
        WinTop=0.5003307968572361
        WinWidth=0.3725
        WinHeight=0.03
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        TextFont="UT2SmallFont"
        FontScale=FNS_Small
        RenderWeight=0.3
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_MapAuthor=MapAuthorLabel

    Begin Object Class=HxGUIScrollTextBox Name=MapDescription
        WinLeft=0.6075
        WinTop=0.5437768
        WinWidth=0.3725
        WinHeight=0.1829232
        CharDelay=0.0065
        EOLDelay=0.6
        HorizontalPadding=0.045
        StyleName="NoBackground"
        FontScale=FNS_Small
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        bTabStop=false
        bVisibleWhenEmpty=true
        bNoTeletype=false
        bNeverFocus=true
        bStripColors=false
        bBoundToParent=true
        bScaleToParent=true
    End Object
    lb_MapDescription=MapDescription

    Begin Object Class=HxGUIMapVoteFooter Name=MatchSetupFooter
        WinLeft=0.6075
        WinTop=0.7367
        WinWidth=0.3725
        WinHeight=0.22
        TabOrder=10
        RenderWeight=0.5
        bBoundToParent=true
        bScaleToParent=true
    End Object
    f_Chat=MatchSetupFooter

    WinTop=0.05
    WinLeft=0.0025
    WinWidth=0.995
    WinHeight=0.875

    lb_VoteCountListBox=None
    lb_MapListBox=None
    i_MapCountListBackground=None
    i_MapListBackground=None
    OnOpen=None

    PlayersText="players"
}
