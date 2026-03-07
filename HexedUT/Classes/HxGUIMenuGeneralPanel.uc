class HxGUIMenuGeneralPanel extends HxGUIMenuBasePanel;

const SECTION_SERVER_OPTIONS = 0;
const SECTION_SERVER_STATUS = 1;
const SECTION_CLIENT_OPTIONS = 2;

var automated moCheckBox ch_ReplaceMapVoteMenu;
var automated moCheckBox ch_ShowSPTimer;
var automated moCheckBox ch_UseHUDColor;
var automated moCheckBox ch_PulsingDigits;
var automated GUILabel l_PositionAnchor;
var automated moFloatEdit fl_PosX;
var automated moFloatEdit fl_PosY;
var automated array<GUIMenuOption> ServerOptions;
var automated HxGUIScrollTextBox st_ServerStatus;

var localized string VersionLabel;

var private HxUTClient Client;
var private Color NameColor;
var private Color ValueColor;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);
    for (i = 0; i < ServerOptions.Length; ++i)
    {
        ServerOptions[i].OnLoadINI = ServerOptionOnLoadINI;
        ServerOptions[i].OnChange = ServerOptionOnChange;
        Sections[SECTION_SERVER_OPTIONS].Insert(
            ServerOptions[i], int(i == ServerOptions.Length - 1));
    }
    Sections[SECTION_SERVER_STATUS].Insert(st_ServerStatus);
    Sections[SECTION_CLIENT_OPTIONS].Insert(ch_ReplaceMapVoteMenu);
    sections[SECTION_CLIENT_OPTIONS].Insert(ch_ShowSPTimer);
    sections[SECTION_CLIENT_OPTIONS].Insert(ch_UseHUDColor, 1);
    sections[SECTION_CLIENT_OPTIONS].Insert(ch_PulsingDigits, 1);
    sections[SECTION_CLIENT_OPTIONS].Insert(l_PositionAnchor, 1);
    PrependClassNameToINIOptions();
}

function bool Initialize()
{
    if (Client != None)
    {
        return Client.SPTimer != None;
    }
    Client = class'HxUTClient'.static.GetClient(PlayerOwner());
    return Client != None && Client.SPTimer != None;
}

function Refresh()
{
    Super.Refresh();
    ServerStatusAfterChange();
    SPTimerAfterChange(Client.bAllowSpawnProtectionTimer);
    Sections[SECTION_SERVER_OPTIONS].SetHide(!IsAdmin(), HIDE_DUE_ADMIN);
}

function ServerOptionOnLoadINI(GUIComponent Sender, string s)
{
    local GUIMenuOption Option;

    Option = GUIMenuOption(Sender);
    if (Client != None && Option != None)
    {
        Option.SetComponentValue(Client.GetPropertyText(Option.INIOption));
    }
}

function InterfaceOnChange(GUIComponent Sender)
{
    if (Client == None)
    {
        return;
    }
    switch (Sender)
    {
        case ch_ReplaceMapVoteMenu:
            Client.SetMapVoteMenu(ch_ReplaceMapVoteMenu.IsChecked());
            break;
    }
    Client.SaveConfig();
}

function SPTimerOnChange(GUIComponent Sender)
{
    if (Client == None || Client.SPTimer == None)
    {
        return;
    }
    DefaultOnChange(Sender, Client.SPTimer);
    SPTimerAfterChange(Client.bAllowSpawnProtectionTimer);
}

function ServerOptionOnChange(GUIComponent Sender)
{
    local GUIMenuOption Option;

    Option = GUIMenuOption(Sender);
    if (Client != None && Option != None && IsAdmin())
    {
        Client.RemoteSetProperty(Option.INIOption, Option.GetComponentValue());
    }
    SPTimerAfterChange(moCheckBox(ServerOptions[2]).IsChecked());
    ServerStatusAfterChange();
}

function SPTimerAfterChange(bool bIsAllowed)
{
    local bool bIsEnabled;

    bIsEnabled = bIsAllowed && Client.SPTimer.bEnabled;
    SetEnable(ch_ShowSPTimer, bIsAllowed);
    SetEnable(ch_UseHUDColor, bIsEnabled);
    SetEnable(ch_PulsingDigits, bIsEnabled);
    SetEnable(l_PositionAnchor, bIsEnabled);
    SetEnable(fl_PosX, bIsEnabled);
    SetEnable(fl_PosY, bIsEnabled);
}

function ServerStatusAfterChange()
{
    local string Name;
    local string Value;
    local string NameColorCode;
    local string ValueColorCode;
    local int i;

    NameColorCode = MakeColorCode(NameColor);
    ValueColorCode = MakeColorCode(ValueColor);
    st_ServerStatus.SetContent(
        NameColorCode$VersionLabel$":"@ValueColorCode$class'MutHexedUT'.default.FriendlyName);
    for (i = 0; i < class'MutHexedUT'.default.PropertyInfoEntries.Length; ++i)
    {
        Name = NameColorCode$class'MutHexedUT'.default.PropertyInfoEntries[i].Caption;
        Value = ValueColorCode$Client.GetPropertyText(
            class'MutHexedUT'.default.PropertyInfoEntries[i].Name);
        st_ServerStatus.AddText(Name$":"@Value);
    }
}

function bool PositionFloatEditsOnPreDraw(Canvas C)
{
    if (l_PositionAnchor.bInit)
    {
        l_PositionAnchor.bInit = Sections[SECTION_CLIENT_OPTIONS].bInit;
        fl_PosX.WinLeft = l_PositionAnchor.WinLeft + l_PositionAnchor.WinWidth * 0.4;
        fl_PosX.WinTop = l_PositionAnchor.WinTop;
        fl_PosX.WinWidth = l_PositionAnchor.WinWidth * 0.3 - 0.005;
        fl_PosY.WinLeft = fl_PosX.WinLeft + fl_PosX.WinWidth + 0.01;
        fl_PosY.WinTop = l_PositionAnchor.WinTop;
        fl_PosY.WinWidth = fl_PosX.WinWidth;
    }
    return false;
}

function PrependClassNameToINIOptions()
{
    local string ClassName;

    ClassName = string(class'HxUTClient');
    ch_ReplaceMapVoteMenu.INIOption = ClassName@ch_ReplaceMapVoteMenu.INIOption;
    ClassName = string(class'HxSpawnProtectionTimer');
    ch_ShowSPTimer.INIOption = ClassName@ch_ShowSPTimer.INIOption;
    ch_UseHUDColor.INIOption = ClassName@ch_UseHUDColor.INIOption;
    ch_PulsingDigits.INIOption = ClassName@ch_PulsingDigits.INIOption;
    fl_PosX.INIOption = ClassName@fl_PosX.INIOption;
    fl_PosY.INIOption = ClassName@fl_PosY.INIOption;
}

static function bool AddToMenu()
{
    local int i;
    local int Order;

    if (Super.AddToMenu())
    {
        Order = 1;
        for (i = 0; i < default.ServerOptions.Length; ++i)
        {
            default.ServerOptions[i].TabOrder = Order++;
            default.ServerOptions[i].Caption =
                class'MutHexedUT'.default.PropertyInfoEntries[i].Caption;
            default.ServerOptions[i].Hint = class'MutHexedUT'.default.PropertyInfoEntries[i].Hint;
            default.ServerOptions[i].INIOption =
                class'MutHexedUT'.default.PropertyInfoEntries[i].Name;
        }
        return true;
    }
    return false;
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=ServerOptionsSection
        Caption="Server Options"
    End Object

    Begin Object class=HxGUIFramedSection Name=ClientOptionsSection
        Caption="Client Options"
    End Object

    Begin Object class=HxGUIFramedSection Name=ServerStatusSection
        Caption="Server Status"
        LeftPadding=0
        TopPadding=0
        RightPadding=0
        BottomPadding=0
        ExpandIndex=0
    End Object

    Begin Object class=moCheckBox Name=AllowHitSoundsCheckBox
    End Object

    Begin Object class=moCheckBox Name=AllowDamageNumbersCheckBox
    End Object

    Begin Object class=moCheckBox Name=AllowSpawnProtectionTimerCheckBox
    End Object

    Begin Object class=moCheckBox Name=ColoredDeathMessagesCheckBox
    End Object

    Begin Object class=moCheckBox Name=AllowSkinHighlightCheckBox
    End Object

    Begin Object class=moFloatEdit Name=SkinHighlightFactorFloatEdit
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        ComponentWidth=0.25
    End Object

    Begin Object class=moCheckBox Name=ReplaceMapVoteMenuCheckBox
        Caption="Replace map vote menu"
        Hint="Replace the default map vote menu."
        INIOption="bMapVoteMenu"
        OnLoadINI=DefaultOnLoadINI
        OnChange=InterfaceOnChange
        TabOrder=10
    End Object
    ch_ReplaceMapVoteMenu=ReplaceMapVoteMenuCheckBox

    Begin Object class=moCheckBox Name=ShowSPTimerCheckBox
        Caption="Enable spawn protection timer"
        Hint="Show timer indicating remaining spawn protection duration."
        INIOption="bEnabled"
        OnLoadINI=DefaultOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=11
    End Object
    ch_ShowSPTimer=ShowSPTimerCheckBox

    Begin Object class=moCheckBox Name=UseHUDColorCheckBox
        Caption="Use HUD's color"
        Hint="Use the same color as the HUD for the timer's icon."
        INIOption="bUseHUDColor"
        OnLoadINI=DefaultOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=12
    End Object
    ch_UseHUDColor=UseHUDColorCheckBox

    Begin Object class=moCheckBox Name=PulsingDigitsCheckBox
        Caption="Use pulsing digits"
        Hint="Use pulsing digits for the timer."
        INIOption="bPulsingDigits"
        OnLoadINI=DefaultOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=13
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
        Hint="Adjust X position."
        INIOption="PosX"
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        CaptionWidth=0.17
        OnLoadINI=DefaultOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=14
    End Object
    fl_PosX=PosXFloatEdit

    Begin Object class=moFloatEdit Name=PosYFloatEdit
        Caption="Y"
        Hint="Adjust Y position."
        INIOption="PosY"
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        CaptionWidth=0.17
        OnLoadINI=DefaultOnLoadINI
        OnChange=SPTimerOnChange
        TabOrder=15
    End Object
    fl_PosY=PosYFloatEdit

    Begin Object Class=HxGUIScrollTextBox Name=ServerStatusTextBox
        WinHeight=0.5
        LeftPadding=0.02
        TopPadding=0.005
        RightPadding=0.02
        BottomPadding=0.005
        LineSpacing=0.01
        VertAlign=TXTA_Left
        bAutoSpacing=true
        bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
        bHideFrame=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=0
    End Object
    st_ServerStatus=ServerStatusTextBox

    PanelCaption="General"
    PanelHint="General options and server status"
    bInsertFront=true
    bDoubleColumn=true
    bFillPanelHeight=true
    Sections(0)=ServerOptionsSection
    Sections(1)=ServerStatusSection
    Sections(2)=ClientOptionsSection
    Sections(3)=None
    ServerOptions(0)=AllowHitSoundsCheckBox
    ServerOptions(1)=AllowDamageNumbersCheckBox
    ServerOptions(2)=AllowSpawnProtectionTimerCheckBox
    ServerOptions(3)=ColoredDeathMessagesCheckBox
    ServerOptions(4)=AllowSkinHighlightCheckBox
    ServerOptions(5)=SkinHighlightFactorFloatEdit
    VersionLabel="Version"
    NameColor=(R=255,G=255,B=255,A=255)
    ValueColor=(R=255,G=195,B=0,A=255)
}
