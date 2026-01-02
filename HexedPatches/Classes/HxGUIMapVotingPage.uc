class HxGUIMapVotingPage extends MapVotingPage;

var automated AltSectionBackground sb_MapPreview;
var automated GUIImage i_MapPreviewBackground;
var automated GUIImage i_Preview;
var automated GUILabel l_NoPreview;
var automated GUILabel l_MapPlayerCount;
var automated GUILabel l_MapName;
var automated GUILabel l_MapAuthor;
var localized string NoPreviewAvailableText;
var localized string NoMapSelectedText;
var localized string PlayersText;
var string SelectedMapName;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    lb_VoteCountListBox.WinWidth = 0.53;
    lb_VoteCountListBox.HeaderColumnPerc[0] = 0.375;
    lb_VoteCountListBox.HeaderColumnPerc[1] = 0.475;
    lb_VoteCountListBox.HeaderColumnPerc[2] = 0.15;
    lb_VoteCountListBox.StyleName = "ServerBrowserGrid";
    co_GameType.bBoundToParent = true;
    co_GameType.WinTop = lb_VoteCountListBox.WinTop + lb_VoteCountListBox.WinHeight + 0.01;
    co_GameType.WinLeft = lb_MapListBox.WinLeft;
    co_GameType.WinWidth = 0.53;
    lb_MapListBox.WinTop = co_GameType.WinTop + co_GameType.WinHeight + 0.01;
    lb_MapListBox.WinWidth = 0.53;
    lb_MapListBox.WinHeight = 0.6225;
    lb_MapListBox.HeaderColumnPerc[0] = 0.725;
    lb_MapListBox.HeaderColumnPerc[1] = 0.15;
    lb_MapListBox.HeaderColumnPerc[2] = 0.125;

    Super.InitComponent(MyController, MyOwner);
}

function InternalOnOpen()
{
    Super.InternalOnOpen();
    AdjustWindowSize(Controller.ResX, Controller.ResY);
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
    i_Preview.Image = None;
    i_Preview.SetVisibility(false);
    l_NoPreview.Caption = NoMapSelectedText;
    l_NoPreview.SetVisibility(true);
}

function bool InternalOnPreDraw(Canvas C)
{
    UpdateMapPreview(GetFocusedMapName());
    return Super.InternalOnPreDraw(C);
}

function string GetFocusedMapName()
{
    if (lb_MapListBox.bHasFocus)
    {
        return MapVoteMultiColumnList(lb_MapListBox.List).GetSelectedMapName();
    }
    if (lb_VoteCountListBox.bHasFocus)
    {
        return MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedMapName();
    }
    return "";
}

function UpdateMapPreview(string MapName)
{
    local CacheManager.MapRecord Record;

    if (MapName == "")
    {
        ResetMapPreview();
    }
    else if (MapName != SelectedMapName)
    {
        Record = class'CacheManager'.static.GetMapRecord(MapName);
        if (Record.ScreenshotRef != "") {
            i_Preview.Image = Material(DynamicLoadObject(Record.ScreenshotRef, class'Material'));
            i_Preview.SetVisibility(true);
            l_NoPreview.SetVisibility(false);
        }
        else
        {
            ResetMapPreview();
            l_NoPreview.Caption = NoPreviewAvailableText;
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
        SelectedMapName = MapName;
    }
}

defaultproperties {
    Begin Object Class=GUIImage Name=MapPreviewBackground
        WinTop=0.052930
        WinLeft=0.56
        WinWidth=0.4175
        WinHeight=0.553632942
        Image=Material'2K4Menus.NewControls.NewFooter'
        ImageStyle=ISTY_Stretched
        RenderWeight=0.1
        bScaleToParent=true
        bBoundToParent=true
    End Object
    i_MapPreviewBackground=MapPreviewBackground

    Begin Object Class=GUILabel Name=NoPreviewLabel
        WinTop=0.052930
        WinLeft=0.56
        WinWidth=0.4175
        WinHeight=0.553632942
        TextFont="MediumFont"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        RenderWeight=0.3
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_NoPreview=NoPreviewLabel

    Begin Object Class=GUIImage Name=MapPreviewImage
        WinTop=0.092
        WinLeft=0.57075
        WinWidth=0.395
        WinHeight=0.4554962607727916
        ImageColor=(R=255,G=255,B=255,A=255)
        ImageStyle=ISTY_Scaled
        ImageRenderStyle=MSTY_Normal
        RenderWeight=0.2
        bScaleToParent=true
        bBoundToParent=true
    End Object
    i_Preview=MapPreviewImage

    Begin Object class=GUILabel Name=MapNameLabel
        WinTop=0.052930
        WinLeft=0.56
        WinWidth=0.4175
        WinHeight=0.03907
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        RenderWeight=0.3
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_MapName=MapNameLabel

    Begin Object class=GUILabel Name=MapPlayerCountLabel
        WinTop=0.551562942
        WinLeft=0.56
        WinWidth=0.4175
        WinHeight=0.025
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        TextFont="UT2IRCFont"
        FontScale=FNS_Small
        RenderWeight=0.3
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_MapPlayerCount=MapPlayerCountLabel

    Begin Object class=GUILabel Name=MapAuthorLabel
        WinTop=0.576562942
        WinLeft=0.56
        WinWidth=0.4175
        WinHeight=0.025
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        TextFont="UT2IRCFont"
        FontScale=FNS_Small
        RenderWeight=0.3
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_MapAuthor=MapAuthorLabel

    Begin Object Class=HxGUIMapVoteFooter Name=MatchSetupFooter
        WinTop=0.6175
        WinLeft=0.5575
        WinWidth=0.4225
        WinHeight=0.35
        TabOrder=10
        RenderWeight=0.5
        bBoundToParent=true
        bScaleToParent=true
    End Object
    f_Chat=MatchSetupFooter

    WinLeft=0.02
    WinWidth=0.96

    NoPreviewAvailableText="No Preview Available"
    NoMapSelectedText="No Map Selected"
    PlayersText="players"
}
