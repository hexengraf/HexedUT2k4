class HxGUIScoreBoardColumnsWindow extends HxGUIFloatingWindow;

var automated moComboBox co_GameType;
var automated HxGUIFramedSection Section;
var automated HxGUIMultiOptionListBox lb_Columns;
var automated GUILabel l_ButtonAnchor;
var automated GUIButton b_AddColumn;
var automated GUIButton b_RemoveColumn;
var automated GUIButton b_Reset;

var localized string ConfirmRemoveLabel;
var localized string ConfirmResetLabel;

var array<HxScoreBoard.HxSBColumnConfig> Columns;
var HxScoreBoard.EHxSBStatType StatType;
var private HxClientManager ClientManager;
var private HxScoreBoardConfig Config;
var private array<string> MainCaptions;
var private array<string> SecCaptions;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    local PlayerController PC;
    local int GameTypeIndex;
    local int i;

    Super.InitComponent(MyController, MyComponent);
    Section.Insert(lb_Columns);
    Section.Insert(l_ButtonAnchor, Section.BottomPadding, Section.BottomPadding);
    ClientManager = class'HxClientManager'.static.Get(PlayerOwner().Player);
    Config = HxScoreBoardConfig(ClientManager.FindConfig(
        class'MutHexedUT', class'HxScoreBoardConfig'));
    MainCaptions = class'HxScoreBoard'.static.ExtractMainStatCaptions();
    SecCaptions = class'HxScoreBoard'.static.ExtractSecStatCaptions();
    for (i = 0; i < Config.GameTypes.Length; ++i)
    {
        co_GameType.AddItem(Config.GameTypes[i].default.GameName,, string(i + 40));
    }
    PC = PlayerOwner();
    if (PC != None && PC.GameReplicationInfo != None)
    {
        GameTypeIndex = Config.GetGameTypeIndex(class<GameInfo>(
            PC.DynamicLoadObject(PC.GameReplicationInfo.GameClass, class'Class', true)));
        if (GameTypeIndex > -1)
        {
            co_GameType.SilentSetIndex(GameTypeIndex);
        }
    }
    GameTypeOnChange(co_GameType);
}

function AdjustWindowSize(coerce float X, coerce float Y)
{
    Super.AdjustWindowSize(X, Y);
    DefaultWidth = WinWidth;
    DefaultHeight = WinHeight;
    DefaultLeft = WinLeft;
    DefaultTop = WinTop;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputAction Action;

    Action = EInputAction(State);
    switch (EInputKey(Key))
    {
        case IK_MouseWheelUp:
        case IK_MouseWheelDown:
            if (!co_GameType.MyComboBox.List.bHasFocus && !lb_Columns.bHasFocus)
            {
                lb_Columns.SetFocus(None);
            }
            break;
    }
    return false;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    local int Index;

    if (Sender.Tag > -1)
    {
        Index = Sender.Tag / 2;
        if (Index < Columns.Length)
        {
            if (Sender.Tag % 2 == 0)
            {
                GUIMenuOption(Sender).SetComponentValue(
                    GetEnum(enum'EHxSBStatType', Columns[Index].MainStat), true);
            }
            else
            {
                GUIMenuOption(Sender).SetComponentValue(
                    GetEnum(enum'EHxSBStatType', Columns[Index].SecStat), true);
            }
        }
    }
}

function InternalOnChange(GUIComponent Sender)
{
    local int Index;

    if (Sender.Tag > -1)
    {
        Index = Sender.Tag / 2;
        if (Index < Columns.Length)
        {
            SetPropertyText("StatType", GUIMenuOption(Sender).GetComponentValue());
            if (Sender.Tag % 2 == 0)
            {
                Columns[Index].MainStat = StatType;
            }
            else
            {
                Columns[Index].SecStat = StatType;
            }
            Config.SetProperty(int(co_GameType.GetComponentValue()), GetPropertyText("Columns"));
        }
    }
}

function GameTypeOnChange(GUIComponent Sender)
{
    SetPropertyText("Columns", Config.GetProperty(int(co_GameType.GetComponentValue())));
    RefreshColumns();
}

function RefreshColumns()
{
    local GUIMenuOption Option;
    local bool bSavedCurMenuInitialized;
    local int i;

    lb_Columns.Clear();
    bSavedCurMenuInitialized = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = false;
    for (i = 0; i < Columns.Length; ++i)
    {
        Option = lb_Columns.AddComboBox("", 1, enum'EHxSBStatType', MainCaptions);
        Option.Tag = i * 2;
        Option = lb_Columns.AddComboBox("", 0, enum'EHxSBStatType', SecCaptions);
        Option.Tag = (i * 2) + 1;
    }
    Controller.bCurMenuInitialized = bSavedCurMenuInitialized;
    lb_Columns.Refresh();
}

function bool OnClickAddColumn(GUIComponent Sender)
{
    Columns.Insert(Columns.Length, 1);
    Config.SetProperty(int(co_GameType.GetComponentValue()), GetPropertyText("Columns"));
    RefreshColumns();
    return true;
}

function bool OnClickRemoveColumn(GUIComponent Sender)
{
    if (Columns.Length > 0)
    {
        if (Controller.OpenMenu(string(class'HxGUIQuestionPage')))
        {
            GUIQuestionPage(Controller.ActivePage).SetupQuestion(
                ConfirmRemoveLabel, QBTN_YesNo, QBTN_Yes);
            GUIQuestionPage(Controller.ActivePage).OnButtonClick = OnButtonClickConfirmRemove;
        }
    }
    return true;
}

function OnButtonClickConfirmRemove(byte bButton)
{
    if (bButton == QBTN_Yes)
    {
        Columns.Remove(Columns.Length - 1, 1);
        Config.SetProperty(int(co_GameType.GetComponentValue()), GetPropertyText("Columns"));
        RefreshColumns();
    }
}

function bool OnClickReset(GUIComponent Sender)
{
    if (Controller.OpenMenu(string(class'HxGUIQuestionPage')))
    {
        GUIQuestionPage(Controller.ActivePage).SetupQuestion(
            Repl(ConfirmResetLabel, "%", co_GameType.GetText()), QBTN_YesNo, QBTN_Yes);
        GUIQuestionPage(Controller.ActivePage).OnButtonClick = OnButtonClickConfirmReset;
    }
    return true;
}

function OnButtonClickConfirmReset(byte bButton)
{
    if (bButton == QBTN_Yes && Config.ResetProperty(int(co_GameType.GetComponentValue())))
    {
        Config.SaveConfig();
        Config.UpdateScoreBoard();
        GameTypeOnChange(co_GameType);
    }
}

function bool InternalButtonsOnPreDraw(Canvas C)
{
    if (l_ButtonAnchor.bInit)
    {
        l_ButtonAnchor.bInit = Section.bInit;
        b_AddColumn.WinLeft = l_ButtonAnchor.WinLeft;
        b_AddColumn.WinTop = l_ButtonAnchor.WinTop;
        b_AddColumn.WinWidth = (l_ButtonAnchor.WinWidth - 0.01) / 3;
        b_RemoveColumn.WinLeft = b_AddColumn.WinLeft + b_AddColumn.WinWidth + 0.005;
        b_RemoveColumn.WinTop = l_ButtonAnchor.WinTop;
        b_RemoveColumn.WinWidth = b_AddColumn.WinWidth;
        b_Reset.WinLeft = b_RemoveColumn.WinLeft + b_RemoveColumn.WinWidth + 0.005;
        b_Reset.WinTop = l_ButtonAnchor.WinTop;
        b_Reset.WinWidth = b_AddColumn.WinWidth;
    }
    return false;
}

function LevelChanged()
{
    ClientManager = None;
    Config = None;
    Super.LevelChanged();
}

defaultproperties
{
    Begin Object class=moComboBox Name=GameTypeComboBox
        Caption="Game Type"
        Hint="Choose the game type to modify columns."
        WinLeft=0.05
        WinTop=0.08
        WinWidth=0.90
        Tag=0
        CaptionWidth=0.33
        bAutoSizeCaption=true
        bReadOnly=true
        OnChange=GameTypeOnChange
        TabOrder=0
    End Object
    co_GameType=GameTypeComboBox

    Begin Object class=HxGUIFramedSection Name=ColumnsSection
        Caption="Columns"
        WinLeft=0.03
        WinTop=0.17
        WinWidth=0.94
        WinHeight=0.79
        LeftPadding=0
        TopPadding=0.015
        RightPadding=0
        LineSpacing=0.015
        BottomPadding=0.015
        ExpandIndices=(0)
    End Object
    Section=ColumnsSection

    Begin Object Class=HxGUIMultiOptionListBox Name=ColumnsListBox
        bVisibleWhenEmpty=true
        NumColumns=2
        ComponentWidth=1.0
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=0
    End Object
    lb_Columns=ColumnsListBox

    Begin Object class=GUILabel Name=ButtonAnchorLabel
        StandardHeight=0.03
        bStandardized=true
        bInit=true
        OnPreDraw=InternalButtonsOnPreDraw
    End Object
    l_ButtonAnchor=ButtonAnchorLabel

    Begin Object class=GUIButton Name=AddColumnButton
        Caption="Add"
        Hint="Add new column at the right."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bNeverFocus=true
        bRepeatClick=false
        OnClick=OnClickAddColumn
    End Object
    b_AddColumn=AddColumnButton

    Begin Object class=GUIButton Name=RemoveColumnButton
        Caption="Remove"
        Hint="Remove rightmost column."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bNeverFocus=true
        bRepeatClick=false
        OnClick=OnClickRemoveColumn
    End Object
    b_RemoveColumn=RemoveColumnButton

    Begin Object class=GUIButton Name=ResetButton
        Caption="Reset"
        Hint="Reset game type to the default configuration."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bNeverFocus=true
        bRepeatClick=false
        OnClick=OnClickReset
    End Object
    b_Reset=ResetButton

    WindowName="Enhanced Scoreboards - Change Columns"
    WinLeft=0.29
    WinTop=0.285
    WinWidth=0.42
    WinHeight=0.43
    bPersistent=true
    bMoveAllowed=true
    OnKeyEvent=InternalOnKeyEvent

    ConfirmRemoveLabel="Are you sure you want to remove the rightmost column?"
    ConfirmResetLabel="Are you sure you want to reset '%' to the default configuration?"
}
