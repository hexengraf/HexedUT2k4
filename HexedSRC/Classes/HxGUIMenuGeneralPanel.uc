class HxGUIMenuGeneralPanel extends HxGUIMenuPanel;

const SECTION_USER_OPTIONS = 0;
const SECTION_SERVER_STATUS = 1;

var automated HxGUIMultiOptionListBox lb_Options;
var automated HxGUIMultiOptionListBox lb_Status;
var automated moCheckBox ch_Advanced;
var automated GUIButton b_ServerMenu;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);
    Sections[SECTION_USER_OPTIONS].Insert(lb_Options);
    Sections[SECTION_USER_OPTIONS].Insert(ch_Advanced, 0.015, 0.015);
    Sections[SECTION_SERVER_STATUS].Insert(lb_Status);
    Sections[SECTION_SERVER_STATUS].Insert(b_ServerMenu, 0.015, 0.015);
}

function Refresh()
{
    Super.Refresh();
    lb_Options.PopulateWithCRIs(ClientManager.CRIs);
    lb_Status.PopulateWithCRIs(ClientManager.CRIs);
    ch_Advanced.Checked(Controller.bExpertMode);
    SetEnable(b_ServerMenu, IsAdmin());
}

function InternalOnChange(GUIComponent Sender)
{
    if (Sender == ch_Advanced)
    {
        Controller.bExpertMode = ch_Advanced.IsChecked();
        Controller.SaveConfig();
        lb_Options.PopulateWithCRIs(ClientManager.CRIs);
        lb_Status.PopulateWithCRIs(ClientManager.CRIs);
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
    Refresh();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=UserOptionsSection
        Caption="User Options"
        LeftPadding=0
        TopPadding=0
        RightPadding=0
        LineSpacing=0.015
        ExpandIndex=0
    End Object

    Begin Object class=HxGUIFramedSection Name=ServerStatusSection
        Caption="Server Status"
        LeftPadding=0
        TopPadding=0
        RightPadding=0
        LineSpacing=0.015
        ExpandIndex=0
    End Object

    Begin Object Class=HxGUIMultiOptionListBox Name=OptionsListBox
        bVisibleWhenEmpty=true
        NumColumns=1
        TabOrder=1
    End Object
    lb_Options=OptionsListBox

    Begin Object Class=HxGUIMultiOptionListBox Name=StatusListBox
        bVisibleWhenEmpty=true
        bUseServerInfo=true
        bStatusOnly=true
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
