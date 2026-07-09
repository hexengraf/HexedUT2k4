class HxGUIMenuHUDPanel extends HxGUIMenuPanel;

const SECTION_SCOREBOARD = 0;
const SECTION_SP_TIMER = 1;

var automated moCheckBox ch_EnhancedScoreboard;
var automated moComboBox co_TeamScoreStyle;
var automated moCheckBox ch_ShowBotCallSigns;
var automated moCheckBox ch_ShowBotOrders;
var automated GUIButton b_ChangeAppearance;
var automated moCheckBox ch_SPTimer;
var automated moCheckBox ch_PulsingDigits;
var automated GUILabel l_PositionAnchor;
var automated moFloatEdit fl_PosX;
var automated moFloatEdit fl_PosY;
var automated moCheckBox ch_UseHUDColor;
var automated moSlider sl_ColorRed;
var automated moSlider sl_ColorGreen;
var automated moSlider sl_ColorBlue;
var automated moSlider sl_ColorAlpha;

var localized string TeamScoreStyleLabels[2];

var private HxUTClient Client;
var private HxScoreBoardConfig ScoreboardConfig;
var private HxSPTimerConfig SPTimerConfig;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.InitComponent(MyController, MyOwner);
    Sections[SECTION_SCOREBOARD].Insert(ch_EnhancedScoreboard);
    Sections[SECTION_SCOREBOARD].Insert(co_TeamScoreStyle);
    Sections[SECTION_SCOREBOARD].Insert(ch_ShowBotCallSigns);
    Sections[SECTION_SCOREBOARD].Insert(ch_ShowBotOrders);
    Sections[SECTION_SCOREBOARD].Insert(b_ChangeAppearance);
    Sections[SECTION_SP_TIMER].Insert(ch_SPTimer);
    Sections[SECTION_SP_TIMER].Insert(ch_PulsingDigits);
    Sections[SECTION_SP_TIMER].Insert(l_PositionAnchor);
    Sections[SECTION_SP_TIMER].Insert(ch_UseHUDColor);
    Sections[SECTION_SP_TIMER].Insert(sl_ColorRed);
    Sections[SECTION_SP_TIMER].Insert(sl_ColorGreen);
    Sections[SECTION_SP_TIMER].Insert(sl_ColorBlue);
    Sections[SECTION_SP_TIMER].Insert(sl_ColorAlpha);
    co_TeamScoreStyle.MyComboBox.MyListBox.MyList.bInitializeList = false;
    for (i = 0; i < ArrayCount(TeamScoreStyleLabels); ++i)
    {
        co_TeamScoreStyle.AddItem(
            TeamScoreStyleLabels[i],,string(GetEnum(enum'EHxSBTeamScoreStyle', i)));
    }
}

event Opened(GUIComponent Sender)
{
    if (Client == None)
    {
        Client = HxUTClient(ClientManager.Find(class'HxUTClient'));
    }
    if (Client != None)
    {
        if (ScoreboardConfig == None)
        {
            ScoreboardConfig = HxScoreBoardConfig(Client.FindConfig(class'HxScoreBoardConfig'));
        }
        if (SPTimerConfig == None)
        {
            SPTimerConfig = HxSPTimerConfig(Client.FindConfig(class'HxSPTimerConfig'));
        }
    }
    Super.Opened(Sender);
}

function Refresh()
{
    local bool bAllowSpawnProtectionTimer;

    bAllowSpawnProtectionTimer = bool(Client.GetServerProperty("bAllowSpawnProtectionTimer"));
    Sections[SECTION_SP_TIMER].SetHide(!bAllowSpawnProtectionTimer, HideDueDisable);
    fl_PosX.SetVisibility(bAllowSpawnProtectionTimer);
    fl_PosY.SetVisibility(bAllowSpawnProtectionTimer);
    SPTimerAfterChange();
    Super.Refresh();
}

function ScoreboardOnLoadINI(GUIComponent Sender, string s)
{
    GUIMenuOption(Sender).SetComponentValue(ScoreboardConfig.GetProperty(Sender.Tag), true);
}

function ScoreboardOnChange(GUIComponent Sender)
{
    Client.SetConfigProperty(
        ScoreboardConfig.Index, Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
}

function SPTimerOnLoadINI(GUIComponent Sender, string s)
{
    switch (Sender)
    {
        case sl_ColorRed:
            sl_ColorRed.SetComponentValue(SPTimerConfig.CustomColor.R, true);
            break;
        case sl_ColorGreen:
            sl_ColorGreen.SetComponentValue(SPTimerConfig.CustomColor.G, true);
            break;
        case sl_ColorBlue:
            sl_ColorBlue.SetComponentValue(SPTimerConfig.CustomColor.B, true);
            break;
        case sl_ColorAlpha:
            sl_ColorAlpha.SetComponentValue(SPTimerConfig.CustomColor.A, true);
            break;
        default:
            GUIMenuOption(Sender).SetComponentValue(SPTimerConfig.GetProperty(Sender.Tag), true);
            break;
    }
}

function SPTimerOnChange(GUIComponent Sender)
{
    switch (Sender)
    {
        case sl_ColorRed:
            SPTimerConfig.CustomColor.R = byte(sl_ColorRed.GetComponentValue());
            Client.SetConfigProperty(
                SPTimerConfig.Index, Sender.Tag, SPTimerConfig.GetProperty(Sender.Tag));
            break;
        case sl_ColorGreen:
            SPTimerConfig.CustomColor.G = byte(sl_ColorGreen.GetComponentValue());
            Client.SetConfigProperty(
                SPTimerConfig.Index, Sender.Tag, SPTimerConfig.GetProperty(Sender.Tag));
            break;
        case sl_ColorBlue:
            SPTimerConfig.CustomColor.B = byte(sl_ColorBlue.GetComponentValue());
            Client.SetConfigProperty(
                SPTimerConfig.Index, Sender.Tag, SPTimerConfig.GetProperty(Sender.Tag));
            break;
        case sl_ColorBlue:
            SPTimerConfig.CustomColor.A = byte(sl_ColorAlpha.GetComponentValue());
            Client.SetConfigProperty(
                SPTimerConfig.Index, Sender.Tag, SPTimerConfig.GetProperty(Sender.Tag));
            break;
        default:
            Client.SetConfigProperty(
                SPTimerConfig.Index, Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
            SPTimerAfterChange();
            break;
    }
}

function SPTimerAfterChange()
{
    local bool bCustomColor;

    bCustomColor = !ch_UseHUDColor.IsChecked();
    SetEnable(sl_ColorRed, bCustomColor);
    SetEnable(sl_ColorGreen, bCustomColor);
    SetEnable(sl_ColorBlue, bCustomColor);
    SetEnable(sl_ColorAlpha, bCustomColor);
}

function bool PositionFloatEditsOnPreDraw(Canvas C)
{
    if (l_PositionAnchor.bInit)
    {
        l_PositionAnchor.bInit = Sections[SECTION_SP_TIMER].bInit;
        fl_PosX.WinLeft = l_PositionAnchor.WinLeft + l_PositionAnchor.WinWidth * 0.36;
        fl_PosX.WinTop = l_PositionAnchor.WinTop;
        fl_PosX.WinWidth = l_PositionAnchor.WinWidth * 0.32 - 0.005;
        fl_PosY.WinLeft = fl_PosX.WinLeft + fl_PosX.WinWidth + 0.01;
        fl_PosY.WinTop = l_PositionAnchor.WinTop;
        fl_PosY.WinWidth = fl_PosX.WinWidth;
    }
    return false;
}

function bool OnClickChangeAppearance(GUIComponent Sender)
{
    if (Controller.ReplaceMenu(string(class'HxGUIScoreBoardAppearanceWindow')))
    {
        Controller.ActivePage.OnClose = OnCloseChangeAppearance;
    }
    return true;
}

function OnCloseChangeAppearance(optional bool bCancelled)
{
    ClientManager.OpenConfigurationMenu();
}

event Free()
{
    ClientManager = None;
    Client = None;
    ScoreBoardConfig = None;
    SPTimerConfig = None;
    Super.Free();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=ScoreboardSection
        Caption="Enhanced Scoreboards"
        WinHeight=1
        LineSpacing=0.02
        bAutoSpacing=false
    End Object

    Begin Object class=HxGUIFramedSection Name=SPTimerSection
        Caption="Spawn Protection Timer"
        WinHeight=1
        LineSpacing=0.02
        bAutoSpacing=false
    End Object

    Begin Object class=moCheckBox Name=EnhancedScoreboardCheckBox
        Caption="Enable enhanced scoreboards"
        Hint="Replace original scoreboards with an enhanced version."
        INIOption="@INTERNAL"
        Tag=0
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=0
    End Object
    ch_EnhancedScoreboard=EnhancedScoreboardCheckBox

    Begin Object class=moComboBox Name=TeamScoreStyleCheckBox
        Caption="Team score style"
        Hint="Style to show team scores and total score (Invasion)."
        INIOption="@INTERNAL"
        Tag=3
        bReadOnly=true
        CaptionWidth=0.5
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=5
    End Object
    co_TeamScoreStyle=TeamScoreStyleCheckBox

    Begin Object class=moCheckBox Name=ShowBotCallSignsCheckBox
        Caption="Show bot call signs"
        Hint="Show bot call signs at the end of their names (team games only)."
        INIOption="@INTERNAL"
        Tag=8
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=5
    End Object
    ch_ShowBotCallSigns=ShowBotCallSignsCheckBox

    Begin Object class=moCheckBox Name=ShowBotOrdersCheckBox
        Caption="Show bot orders"
        Hint="Show bot orders in front of their location (team games only)."
        INIOption="@INTERNAL"
        Tag=9
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=5
    End Object
    ch_ShowBotOrders=ShowBotOrdersCheckBox

    Begin Object class=GUIButton Name=ChangeAppearanceButton
        Caption="Change Appearance"
        Hint="Customize colors, alignments, and more."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickChangeAppearance
        TabOrder=7
    End Object
    b_ChangeAppearance=ChangeAppearanceButton

    Begin Object class=moCheckBox Name=SPTimerCheckBox
        Caption="Enable spawn protection timer"
        Hint="Show timer indicating remaining spawn protection duration."
        INIOption="@INTERNAL"
        Tag=0
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=10
    End Object
    ch_SPTimer=SPTimerCheckBox

    Begin Object class=moCheckBox Name=PulsingDigitsCheckBox
        Caption="Use pulsing digits"
        Hint="Use pulsing digits for the timer."
        INIOption="@INTERNAL"
        Tag=2
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=11
    End Object
    ch_PulsingDigits=PulsingDigitsCheckBox

    Begin Object class=GUILabel Name=PositionAnchorLabel
        Caption="Position"
        bStandardized=true
        StandardHeight=0.03
        StyleName="TextLabel"
        bInit=true
        bBoundToParent=true
        bScaleToParent=true
        OnPreDraw=PositionFloatEditsOnPreDraw
    End Object
    l_PositionAnchor=PositionAnchorLabel

    Begin Object class=moFloatEdit Name=PosXFloatEdit
        Caption="X"
        INIOption="@INTERNAL"
        Tag=3
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        CaptionWidth=0.17
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=12
    End Object
    fl_PosX=PosXFloatEdit

    Begin Object class=moFloatEdit Name=PosYFloatEdit
        Caption="Y"
        INIOption="@INTERNAL"
        Tag=4
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        CaptionWidth=0.17
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=13
    End Object
    fl_PosY=PosYFloatEdit

    Begin Object class=moCheckBox Name=UseHUDColorCheckBox
        Caption="Use HUD's color"
        Hint="Use the same color as the HUD for the timer's icon."
        INIOption="@INTERNAL"
        Tag=1
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=14
    End Object
    ch_UseHUDColor=UseHUDColorCheckBox

    Begin Object class=moSlider Name=ColorRedSlider
        Caption="Red"
        INIOption="@INTERNAL"
        Tag=5
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=15
    End Object
    sl_ColorRed=ColorRedSlider

    Begin Object class=moSlider Name=ColorGreenSlider
        Caption="Green"
        INIOption="@INTERNAL"
        Tag=5
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=16
    End Object
    sl_ColorGreen=ColorGreenSlider

    Begin Object class=moSlider Name=ColorBlueSlider
        Caption="Blue"
        INIOption="@INTERNAL"
        Tag=5
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=17
    End Object
    sl_ColorBlue=ColorBlueSlider

    Begin Object class=moSlider Name=ColorAlphaSlider
        Caption="Alpha"
        INIOption="@INTERNAL"
        Tag=5
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=18
    End Object
    sl_ColorAlpha=ColorAlphaSlider

    PanelCaption="HUD"
    PanelHint="HUD options"
    Dependencies=("bAllowEnhancedScoreBoards", "bAllowSpawnProtectionTimer")
    bDoubleColumn=true
    bFillPanelHeight=false
    Sections(0)=ScoreboardSection
    Sections(1)=SPTimerSection
    TeamScoreStyleLabels(0)="Full size"
    TeamScoreStyleLabels(1)="Compact"
}
