class HxGUIMenuHUDPanel extends HxGUIMenuPanel;

const SECTION_SCOREBOARD = 0;
const SECTION_SP_TIMER = 1;

var automated moCheckBox ch_EnhancedScoreboard;
var automated moCheckBox ch_CompactTeamScores;
var automated moCheckBox ch_bShowSecondaryStats;
var automated moCheckBox ch_PreferVerticalLayout;
var automated moCheckBox ch_AbbreviateHeadings;
var automated moCheckBox ch_ShowPlayerPortraits;
var automated moCheckBox ch_ShowBotCallSigns;
var automated moCheckBox ch_ShowBotOrders;
var automated moCheckBox ch_ShowShortcuts;
var automated moCheckBox ch_ShowTimestamp;
var automated GUIButton b_ChangeColumns;
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

var private HxMutatorInfo MutatorInfo;
var private HxScoreBoardConfig ScoreboardConfig;
var private HxSPTimerConfig SPTimerConfig;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    Sections[SECTION_SCOREBOARD].Insert(ch_EnhancedScoreboard);
    Sections[SECTION_SCOREBOARD].Insert(ch_CompactTeamScores);
    Sections[SECTION_SCOREBOARD].Insert(ch_bShowSecondaryStats);
    Sections[SECTION_SCOREBOARD].Insert(ch_PreferVerticalLayout);
    Sections[SECTION_SCOREBOARD].Insert(ch_AbbreviateHeadings);
    Sections[SECTION_SCOREBOARD].Insert(ch_ShowPlayerPortraits);
    Sections[SECTION_SCOREBOARD].Insert(ch_ShowBotCallSigns);
    Sections[SECTION_SCOREBOARD].Insert(ch_ShowBotOrders);
    Sections[SECTION_SCOREBOARD].Insert(ch_ShowShortcuts);
    Sections[SECTION_SCOREBOARD].Insert(ch_ShowTimestamp);
    Sections[SECTION_SCOREBOARD].Insert(b_ChangeColumns);
    Sections[SECTION_SCOREBOARD].Insert(b_ChangeAppearance);
    Sections[SECTION_SP_TIMER].Insert(ch_SPTimer);
    Sections[SECTION_SP_TIMER].Insert(ch_PulsingDigits);
    Sections[SECTION_SP_TIMER].Insert(l_PositionAnchor);
    Sections[SECTION_SP_TIMER].Insert(ch_UseHUDColor);
    Sections[SECTION_SP_TIMER].Insert(sl_ColorRed);
    Sections[SECTION_SP_TIMER].Insert(sl_ColorGreen);
    Sections[SECTION_SP_TIMER].Insert(sl_ColorBlue);
    Sections[SECTION_SP_TIMER].Insert(sl_ColorAlpha);
    ClientManager.FindMutatorInfo(class'MutHexedUT', MutatorInfo);
    ScoreboardConfig = HxScoreBoardConfig(ClientManager.FindConfig(
        class'MutHexedUT', class'HxScoreBoardConfig'));
    SPTimerConfig = HxSPTimerConfig(ClientManager.FindConfig(
        class'MutHexedUT', class'HxSPTimerConfig'));
}

function Refresh()
{
    local bool bAllowSpawnProtectionTimer;

    bAllowSpawnProtectionTimer = bool(MutatorInfo.Get("bAllowSpawnProtectionTimer"));
    Sections[SECTION_SP_TIMER].SetHide(!bAllowSpawnProtectionTimer);
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
    ScoreboardConfig.SetProperty(Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
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
            SPTimerConfig.SetProperty(Sender.Tag, SPTimerConfig.GetProperty(Sender.Tag));
            break;
        case sl_ColorGreen:
            SPTimerConfig.CustomColor.G = byte(sl_ColorGreen.GetComponentValue());
            SPTimerConfig.SetProperty(Sender.Tag, SPTimerConfig.GetProperty(Sender.Tag));
            break;
        case sl_ColorBlue:
            SPTimerConfig.CustomColor.B = byte(sl_ColorBlue.GetComponentValue());
            SPTimerConfig.SetProperty(Sender.Tag, SPTimerConfig.GetProperty(Sender.Tag));
            break;
        case sl_ColorBlue:
            SPTimerConfig.CustomColor.A = byte(sl_ColorAlpha.GetComponentValue());
            SPTimerConfig.SetProperty(Sender.Tag, SPTimerConfig.GetProperty(Sender.Tag));
            break;
        default:
            SPTimerConfig.SetProperty(Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
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

function bool OnClickChangeColumns(GUIComponent Sender)
{
    if (Controller.ReplaceMenu(string(class'HxGUIScoreBoardColumnsWindow')))
    {
        Controller.ActivePage.OnClose = OnCloseSubMenu;
    }
    return true;
}

function bool OnClickChangeAppearance(GUIComponent Sender)
{
    if (Controller.ReplaceMenu(string(class'HxGUIScoreBoardAppearanceWindow')))
    {
        Controller.ActivePage.OnClose = OnCloseSubMenu;
    }
    return true;
}

function OnCloseSubMenu(optional bool bCancelled)
{
    ClientManager.HexedMenu();
}

event Free()
{
    MutatorInfo = None;
    ScoreBoardConfig = None;
    SPTimerConfig = None;
    Super.Free();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=ScoreboardSection
        Caption="Enhanced Scoreboards"
        WinHeight=1
    End Object

    Begin Object class=HxGUIFramedSection Name=SPTimerSection
        Caption="Spawn Protection Timer"
        WinHeight=1
        LineSpacing=0.016
        bAutoSpacing=false
    End Object

    Begin Object class=moCheckBox Name=EnhancedScoreboardCheckBox
        Caption="Enable Enhanced Scoreboards"
        Hint="Replace original scoreboards with an enhanced version."
        INIOption="@INTERNAL"
        Tag=0
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=0
    End Object
    ch_EnhancedScoreboard=EnhancedScoreboardCheckBox

    Begin Object class=moCheckBox Name=CompactTeamScoresCheckBox
        Caption="Use Compact Team Scores"
        Hint="Show team scores and total score (Invasion) directly inside the header space."
        INIOption="@INTERNAL"
        Tag=7
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=1
    End Object
    ch_CompactTeamScores=CompactTeamScoresCheckBox

    Begin Object class=moCheckBox Name=SecondaryInfoCheckBox
        Caption="Show Secondary Stats"
        Hint="Show an additional line of stats in each column when available."
        INIOption="@INTERNAL"
        Tag=8
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=2
    End Object
    ch_bShowSecondaryStats=SecondaryInfoCheckBox

    Begin Object class=moCheckBox Name=PreferVerticalLayoutCheckBox
        Caption="Default To Vertical Layout"
        Hint="Prefer the vertical layout in team scoreboards."
        INIOption="@INTERNAL"
        Tag=9
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=3
    End Object
    ch_PreferVerticalLayout=PreferVerticalLayoutCheckBox

    Begin Object class=moCheckBox Name=AbbreviateHeadingsCheckBox
        Caption="Abbreviate Long Headings"
        Hint="Abbreviate long headings to reduce required column width and fit more columns."
        INIOption="@INTERNAL"
        Tag=10
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=4
    End Object
    ch_AbbreviateHeadings=AbbreviateHeadingsCheckBox

    Begin Object class=moCheckBox Name=ShowPlayerPortraitsCheckBox
        Caption="Show Player Portraits"
        Hint="Show player portraits in front of player names."
        INIOption="@INTERNAL"
        Tag=11
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=5
    End Object
    ch_ShowPlayerPortraits=ShowPlayerPortraitsCheckBox

    Begin Object class=moCheckBox Name=ShowBotCallSignsCheckBox
        Caption="Show Bot Call Signs"
        Hint="Show bot call signs at the end of their names (team games only)."
        INIOption="@INTERNAL"
        Tag=12
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=6
    End Object
    ch_ShowBotCallSigns=ShowBotCallSignsCheckBox

    Begin Object class=moCheckBox Name=ShowBotOrdersCheckBox
        Caption="Show Bot Orders"
        Hint="Show bot orders in front of their location (team games only)."
        INIOption="@INTERNAL"
        Tag=13
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=7
    End Object
    ch_ShowBotOrders=ShowBotOrdersCheckBox

    Begin Object class=moCheckBox Name=ShowShortcutsCheckBox
        Caption="Show Shortcuts"
        Hint="Show available shortcuts at the bottom left of the screen."
        INIOption="@INTERNAL"
        Tag=14
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=8
    End Object
    ch_ShowShortcuts=ShowShortcutsCheckBox

    Begin Object class=moCheckBox Name=ShowTimestampCheckBox
        Caption="Show Timestamp"
        Hint="Show current timestamp at the bottom right of the screen."
        INIOption="@INTERNAL"
        Tag=15
        OnLoadINI=ScoreboardOnLoadINI
        OnChange=ScoreboardOnChange
        TabOrder=9
    End Object
    ch_ShowTimestamp=ShowTimestampCheckBox

    Begin Object class=GUIButton Name=ChangeColumnsButton
        Caption="Change Columns"
        Hint="Customize which information to display for each game type."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickChangeColumns
        TabOrder=10
    End Object
    b_ChangeColumns=ChangeColumnsButton

    Begin Object class=GUIButton Name=ChangeAppearanceButton
        Caption="Change Appearance"
        Hint="Customize colors, alignments, and more."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickChangeAppearance
        TabOrder=11
    End Object
    b_ChangeAppearance=ChangeAppearanceButton

    Begin Object class=moCheckBox Name=SPTimerCheckBox
        Caption="Enable Spawn Protection Timer"
        Hint="Show timer indicating remaining spawn protection duration."
        INIOption="@INTERNAL"
        Tag=0
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=21
    End Object
    ch_SPTimer=SPTimerCheckBox

    Begin Object class=moCheckBox Name=PulsingDigitsCheckBox
        Caption="Use Pulsing Digits"
        Hint="Use pulsing digits for the timer."
        INIOption="@INTERNAL"
        Tag=2
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=22
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
        TabOrder=23
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
        TabOrder=24
    End Object
    fl_PosY=PosYFloatEdit

    Begin Object class=moCheckBox Name=UseHUDColorCheckBox
        Caption="Use HUD's Color"
        Hint="Use the same color as the HUD for the timer's icon."
        INIOption="@INTERNAL"
        Tag=1
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=25
    End Object
    ch_UseHUDColor=UseHUDColorCheckBox

    Begin Object class=moSlider Name=ColorRedSlider
        Caption="Red"
        INIOption="@INTERNAL"
        Tag=5
        CaptionWidth=0.35
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=26
    End Object
    sl_ColorRed=ColorRedSlider

    Begin Object class=moSlider Name=ColorGreenSlider
        Caption="Green"
        INIOption="@INTERNAL"
        Tag=5
        CaptionWidth=0.35
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=27
    End Object
    sl_ColorGreen=ColorGreenSlider

    Begin Object class=moSlider Name=ColorBlueSlider
        Caption="Blue"
        INIOption="@INTERNAL"
        Tag=5
        CaptionWidth=0.35
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=28
    End Object
    sl_ColorBlue=ColorBlueSlider

    Begin Object class=moSlider Name=ColorAlphaSlider
        Caption="Alpha"
        INIOption="@INTERNAL"
        Tag=5
        CaptionWidth=0.35
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=SPTimerOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=29
    End Object
    sl_ColorAlpha=ColorAlphaSlider

    PanelCaption="HUD"
    PanelHint="HUD options"
    Dependencies=("bAllowEnhancedScoreBoards", "bAllowSpawnProtectionTimer")
    bDoubleColumn=true
    bFillPanelHeight=false
    Sections(0)=ScoreboardSection
    Sections(1)=SPTimerSection
}
