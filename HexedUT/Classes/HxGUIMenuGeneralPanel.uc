class HxGUIMenuGeneralPanel extends HxGUIMenuPanel;

const SECTION_USER_OPTIONS = 0;
const SECTION_SERVER_STATUS = 1;

var automated HxGUIMultiOptionListBox lb_Options;
var automated moCheckBox ch_Advanced;
var automated GUIButton b_ServerMenu;
var automated HxGUIScrollTextBox st_ServerStatus;

var localized string VersionLabel;

var private HxUTClient Client;
var private Color NameColor;
var private Color ValueColor;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);
    Sections[SECTION_USER_OPTIONS].Insert(lb_Options);
    Sections[SECTION_USER_OPTIONS].Insert(ch_Advanced);
    Sections[SECTION_SERVER_STATUS].Insert(st_ServerStatus);
    Sections[SECTION_SERVER_STATUS].Insert(b_ServerMenu);
}

function bool Initialize()
{
    if (Client != None)
    {
        return true;
    }
    Client = class'HxUTClient'.static.GetClient(PlayerOwner());
    return Client != None;
}

function Refresh()
{
    Super.Refresh();
    lb_Options.PopulateWithCRI(Client);
    ch_Advanced.Checked(Controller.bExpertMode);
    SetEnable(b_ServerMenu, IsAdmin());
    ServerStatusAfterChange();
}

function InternalOnChange(GUIComponent Sender)
{
    if (Sender == ch_Advanced)
    {
        Controller.bExpertMode = ch_Advanced.IsChecked();
        Controller.SaveConfig();
        lb_Options.PopulateWithCRI(Client);
    }
}

function ServerStatusAfterChange()
{
    local string NameColorCode;
    local string ValueColorCode;
    local int i;

    NameColorCode = MakeColorCode(NameColor);
    ValueColorCode = MakeColorCode(ValueColor);
    st_ServerStatus.SetContent(
        NameColorCode$VersionLabel$":"@ValueColorCode$class'MutHexedUT'.default.FriendlyName);
    for (i = 0; i < Client.ServerInfo.Settings.Length; ++i)
    {
        st_ServerStatus.AddText(
            NameColorCode$Client.ServerInfo.Settings[i].DisplayName$":"
            @ValueColorCode$Client.ServerInfo.Settings[i].Value);
    }
}

function bool ServerMenuOnClick(GUIComponent Sender)
{
    Controller.OpenMenu(string(class'HxGUIServerMenu'));
    Controller.ActivePage.OnClose = ServerMenuOnClose;
    return true;
}

function ServerMenuOnClose(optional bool bCancelled)
{
    Refresh();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=UserOptionsSection
        Caption="User Options"
        ExpandIndex=0
    End Object

    Begin Object class=HxGUIFramedSection Name=ServerStatusSection
        Caption="Server Status"
        ExpandIndex=0
    End Object

    Begin Object Class=HxGUIMultiOptionListBox Name=ConfigListBox
        ScrollbarWidth=0.035
        bVisibleWhenEmpty=True
        NumColumns=1
        TabOrder=1
    End Object
    lb_Options=ConfigListBox

    Begin Object Class=moCheckBox Name=AdvancedCheckBox
        Caption="View Advanced Options"
        Hint="Toggles whether advanced properties are displayed"
        OnChange=InternalOnChange
        TabOrder=2
    End Object
    ch_Advanced=AdvancedCheckBox

    Begin Object Class=HxGUIScrollTextBox Name=ServerStatusTextBox
        WinHeight=0.5
        LeftPadding=0.02
        TopPadding=0.01
        RightPadding=0.03
        BottomPadding=0.01
        LineSpacing=0.015
        ScrollbarWidth=0.035
        FrameThickness=0
        BackgroundSources(0)=(Image=Material'engine.WhiteSquareTexture',Color=(R=22,G=38,B=77,A=110),Style=ISTY_Stretched)
        VertAlign=TXTA_Left
        bAutoSpacing=true
        bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
        bHideFrame=true
        TabOrder=10
    End Object
    st_ServerStatus=ServerStatusTextBox

    Begin Object class=GUIButton Name=ServerMenuButton
        Caption="Server Options"
        bStandardized=true
        StandardHeight=0.03
        StyleName="HxSquareButton"
        OnClick=ServerMenuOnClick
        TabOrder=11
    End Object
    b_ServerMenu=ServerMenuButton

    PanelCaption="General"
    PanelHint="General options and server status"
    bInsertFront=true
    bDoubleColumn=true
    bFillPanelHeight=true
    Sections(0)=UserOptionsSection
    Sections(1)=ServerStatusSection
    VersionLabel="Version"
    NameColor=(R=255,G=255,B=255,A=255)
    ValueColor=(R=255,G=195,B=0,A=255)
}
