class HxGUIServerMenu extends HxGUIFloatingWindow;

var automated HxGUIFramedSection Section;
var automated HxGUIMultiOptionListBox lb_Options;
var automated moCheckBox ch_Advanced;

var private HxClientManager ClientManager;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    Section.Insert(lb_Options);
    Section.Insert(ch_Advanced, 0.015, 0.015);
    ClientManager = class'HxClientManager'.static.Get(PlayerOwner().Player);
}

event Opened(GUIComponent Sender)
{
    Super.Opened(Sender);
    ch_Advanced.Checked(Controller.bExpertMode);
    Refresh();
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    if (IsAdmin())
    {
        ClientManager.DispatchDelayedMutatorUpdates();
    }
    Super.Closed(Sender, bCancelled);
}

function Refresh()
{
    local bool bSavedCurMenuInitialized;

    lb_Options.Clear();
    bSavedCurMenuInitialized = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = false;
    ClientManager.PopulateMutatorProperties(lb_Options);
    Controller.bCurMenuInitialized = bSavedCurMenuInitialized;
    lb_Options.Refresh();
}

function OptionsOnLoadINI(GUIComponent Sender, string s)
{
    if (Sender.Tag > -1)
    {
        GUIMenuOption(Sender).SetComponentValue(
            ClientManager.GetMutatorPropertyByTag(Sender.Tag), true);
    }
}

function OptionsOnChange(GUIComponent Sender)
{
    if (Sender.Tag > -1)
    {
        ClientManager.SetMutatorPropertyDelayed(
            Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
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
            if (!lb_Options.bHasFocus)
            {
                lb_Options.SetFocus(None);
            }
            break;
    }
    return false;
}

function InternalOnChange(GUIComponent Sender)
{
    if (Sender == ch_Advanced)
    {
        Controller.bExpertMode = ch_Advanced.IsChecked();
        Controller.SaveConfig();
        Refresh();
    }
}

function bool IsAdmin()
{
    local PlayerController PC;

    PC = PlayerOwner();
    return PC != None
        && (PC.Level.NetMode == NM_Standalone
            || (PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo.bAdmin));
}

function LevelChanged()
{
    ClientManager = None;
    Super.LevelChanged();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=ConfigListSection
        WinLeft=0.03
        WinTop=0.06
        WinWidth=0.94
        WinHeight=0.91
        LeftPadding=0
        TopPadding=0
        RightPadding=0
        bNoHeader=true
        ExpandIndices=(0)
    End Object
    Section=ConfigListSection

    Begin Object Class=HxGUIMultiOptionListBox Name=ConfigListBox
        bVisibleWhenEmpty=true
        NumColumns=1
        OnLoadINI=OptionsOnLoadINI
        OnChange=OptionsOnChange
        TabOrder=1
    End Object
    lb_Options=ConfigListBox

    Begin Object Class=moCheckBox Name=AdvancedCheckBox
        Caption="View Advanced Options"
        Hint="Toggles whether advanced properties are displayed"
        TabOrder=2
        OnChange=InternalOnChange
    End Object
    ch_Advanced=AdvancedCheckBox

    WindowName="HexedMenu - Server Options"
    WinLeft=0.29
    WinTop=0.19
    WinWidth=0.42
    WinHeight=0.62
    bPersistent=false
    OnKeyEvent=InternalOnKeyEvent
}
