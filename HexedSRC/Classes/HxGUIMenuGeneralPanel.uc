class HxGUIMenuGeneralPanel extends HxGUIMenuPanel;

const SECTION_USER_OPTIONS = 0;
const SECTION_SERVER_STATUS = 1;

var automated HxGUIMultiOptionListBox lb_Options;
var automated HxGUIMultiOptionListBox lb_Status;
var automated moCheckBox ch_Advanced;
var automated GUIButton b_ServerMenu;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    Sections[SECTION_USER_OPTIONS].Insert(lb_Options);
    Sections[SECTION_USER_OPTIONS].Insert(ch_Advanced, 0.015, 0.015);
    Sections[SECTION_SERVER_STATUS].Insert(lb_Status);
    Sections[SECTION_SERVER_STATUS].Insert(b_ServerMenu, 0.015, 0.015);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    ClientManager.DispatchDelayedConfigUpdates();
    Super.Closed(Sender, bCancelled);
}

function Refresh()
{
    Super.Refresh();
    ch_Advanced.Checked(Controller.bExpertMode);
    SetEnable(b_ServerMenu, IsAdmin());
    PopulateOptionLists();
}

function PopulateOptionLists()
{
    local bool bSavedCurMenuInitialized;

    lb_Options.Clear();
    lb_Status.Clear();
    bSavedCurMenuInitialized = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = false;
    ClientManager.PopulateConfigProperties(lb_Options);
    ClientManager.PopulateMutatorStatus(lb_Status);
    Controller.bCurMenuInitialized = bSavedCurMenuInitialized;
    lb_Options.Refresh();
    lb_Status.Refresh();
}

function UserOptionOnLoadINI(GUIComponent Sender, string s)
{
    if (Sender.Tag > -1)
    {
        GUIMenuOption(Sender).SetComponentValue(
            ClientManager.GetConfigPropertyByTag(Sender.Tag), true);
    }
}

function ServerStatusOnLoadINI(GUIComponent Sender, string s)
{
    if (Sender.Tag > -1)
    {
        GUIMenuOption(Sender).SetComponentValue(ClientManager.GetMutatorStatus(Sender.Tag), true);
    }
}

function UserOptionOnChange(GUIComponent Sender)
{
    if (Sender.Tag > -1)
    {
       ClientManager.SetConfigPropertyDelayed(
        Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
    }
}

function InternalOnChange(GUIComponent Sender)
{
    if (Sender == ch_Advanced)
    {
        Controller.bExpertMode = ch_Advanced.IsChecked();
        Controller.SaveConfig();
        PopulateOptionLists();
    }
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputAction Action;

    Action = EInputAction(State);
    switch (EInputKey(Key))
    {
        case IK_MouseWheelUp:
        case IK_MouseWheelDown:
            if (lb_Options.IsInBounds())
            {
                if (!lb_Options.bHasFocus)
                {
                    lb_Options.SetFocus(None);
                }
            }
            else if (lb_Status.IsInBounds())
            {
                if (!lb_Status.bHasFocus)
                {
                    lb_Status.SetFocus(None);
                }
            }
            break;
    }
    return false;
}

function bool ServerMenuOnClick(GUIComponent Sender)
{
    Controller.OpenMenu(string(class'HxGUIServerMenu'));
    Controller.ActivePage.OnClose = ServerMenuOnClose;
    return true;
}

function ServerMenuOnClose(optional bool bCancelled)
{
    HxGUIMenu(PageOwner).Refresh();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=UserOptionsSection
        Caption="User Options"
        LeftPadding=0
        TopPadding=0
        RightPadding=0
        LineSpacing=0.015
        ExpandIndices=(0)
    End Object

    Begin Object class=HxGUIFramedSection Name=ServerStatusSection
        Caption="Server Status"
        LeftPadding=0
        TopPadding=0
        RightPadding=0
        LineSpacing=0.015
        ExpandIndices=(0)
    End Object

    Begin Object Class=HxGUIMultiOptionListBox Name=OptionsListBox
        bVisibleWhenEmpty=true
        NumColumns=1
        OnLoadINI=UserOptionOnLoadINI
        OnChange=UserOptionOnChange
        TabOrder=1
    End Object
    lb_Options=OptionsListBox

    Begin Object Class=HxGUIMultiOptionListBox Name=StatusListBox
        bVisibleWhenEmpty=true
        OnLoadINI=ServerStatusOnLoadINI
        NumColumns=1
        TabOrder=1
    End Object
    lb_Status=StatusListBox

    Begin Object Class=moCheckBox Name=AdvancedCheckBox
        Caption="View Advanced Options"
        Hint="Toggles whether advanced properties are displayed"
        OnChange=InternalOnChange
        TabOrder=2
    End Object
    ch_Advanced=AdvancedCheckBox

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
    bDoubleColumn=true
    bFillPanelHeight=true
    Sections(0)=UserOptionsSection
    Sections(1)=ServerStatusSection
    OnKeyEvent=InternalOnKeyEvent
}
