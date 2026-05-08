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
    ch_Advanced.Checked(Controller.bExpertMode);
    SetEnable(b_ServerMenu, IsAdmin());
    PopulateOptionLists();
}

function PopulateOptionLists()
{
    local bool bSavedCurMenuInitialized;
    local int i;

    lb_Options.Clear();
    lb_Status.Clear();
    bSavedCurMenuInitialized = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = false;
    for (i = 0; i < ClientManager.CRIs.Length; ++i)
    {
        ProcessUserOptions(ClientManager.CRIs[i], i);
        ProcessServerStatus(ClientManager.CRIs[i], i);
    }
    Controller.bCurMenuInitialized = bSavedCurMenuInitialized;
    lb_Options.Refresh();
    lb_Status.Refresh();
}

function ProcessUserOptions(HxClientReplicationInfo CRI, optional int Index)
{
    local string SectionCaption;
    local bool bSectionAdded;
    local int i;
    local int j;

    for (i = 0; i < CRI.ConfigClasses.Length; ++i)
    {
        for (j = 0; j < CRI.ConfigClasses[i].default.DisplayInfo.Length; ++j)
        {
            if (lb_Options.ShouldHideConfigProperty(CRI, CRI.ConfigClasses[i], j))
            {
                continue;
            }
            if (!bSectionAdded)
            {
                lb_Options.AddSection(CRI.MutatorClass.default.FriendlyName);
                bSectionAdded = true;
            }
            if (CRI.ConfigClasses[i].default.DisplayInfo[j].Section != SectionCaption)
            {
                lb_Options.AddSubSection(CRI.ConfigClasses[i].default.DisplayInfo[j].Section);
                SectionCaption = CRI.ConfigClasses[i].default.DisplayInfo[j].Section;
            }
            lb_Options.AddConfigOption(
                CRI.ConfigClasses[i], j, ClientManager.EncodeTag(Index, j, i));
        }
    }
}

function ProcessServerStatus(HxClientReplicationInfo CRI, int Index)
{
    local string HeaderCaption;
    local string SectionCaption;
    local int i;

    for (i = 0; i < CRI.MutatorClass.default.DisplayInfo.Length; ++i)
    {
        if (lb_Status.ShouldHideMutatorProperty(CRI.MutatorClass, i))
        {
            continue;
        }
        if (CRI.MutatorClass.default.FriendlyName != HeaderCaption)
        {
            lb_Status.AddSection(CRI.MutatorClass.default.FriendlyName);
            HeaderCaption = CRI.MutatorClass.default.FriendlyName;
        }
        if (CRI.MutatorClass.default.DisplayInfo[i].Section != SectionCaption)
        {
            lb_Status.AddSubSection(CRI.MutatorClass.default.DisplayInfo[i].Section);
            SectionCaption = CRI.MutatorClass.default.DisplayInfo[i].Section;
        }
        lb_Status.AddLabel(
            CRI.MutatorClass.default.DisplayInfo[i].Caption, ClientManager.EncodeTag(Index, i));
    }
}

function UserOptionOnLoadINI(GUIComponent Sender, string s)
{
    local int CRIIndex;
    local int ConfigIndex;
    local int PropertyIndex;

    if (ClientManager.DecodeTag(Sender.Tag, CRIIndex, PropertyIndex, ConfigIndex))
    {
        GUIMenuOption(Sender).SetComponentValue(
            ClientManager.CRIs[CRIIndex].GetConfigProperty(ConfigIndex, PropertyIndex), true);
    }
}

function ServerStatusOnLoadINI(GUIComponent Sender, string s)
{
    local HxClientReplicationInfo CRI;
    local int CRIIndex;
    local int PropertyIndex;
    local string Value;

    if (ClientManager.DecodeTag(Sender.Tag, CRIIndex, PropertyIndex))
    {
        CRI = ClientManager.CRIs[CRIIndex];
        Value = CRI.GetServerPropertyByIndex(PropertyIndex);
        switch (CRI.MutatorClass.default.Properties[PropertyIndex].Type)
        {
            case HX_PROPERTY_Float:
                Value = Left(Value, Len(Value) - 4);
                break;
        }
        GUIMenuOption(Sender).SetComponentValue(Value, true);
    }
}

function UserOptionOnChange(GUIComponent Sender)
{
    local int CRIIndex;
    local int ConfigIndex;
    local int PropertyIndex;

    if (ClientManager.DecodeTag(Sender.Tag, CRIIndex, PropertyIndex, ConfigIndex))
    {
        ClientManager.CRIs[CRIIndex].SetConfigProperty(
            ConfigIndex, PropertyIndex, GUIMenuOption(Sender).GetComponentValue());
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
