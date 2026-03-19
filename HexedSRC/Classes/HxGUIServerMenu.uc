class HxGUIServerMenu extends HxGUIFloatingWindow;

var automated HxGUIFramedSection Section;
var automated HxGUIMultiOptionListBox lb_Options;
var automated moCheckBox ch_Advanced;

var HxClientManager ClientManager;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    Section.Insert(lb_Options);
    Section.Insert(ch_Advanced, 0.015, 0.015);
    ForEach PlayerOwner().DynamicActors(class'HxClientManager', ClientManager) break;
}

event Opened(GUIComponent Sender)
{
    Super.Opened(Sender);
    ch_Advanced.Checked(Controller.bExpertMode);
    Refresh();
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    local int FirstIndex;
    local int i;

    if (IsAdmin())
    {
        for (i = 0; i < ClientManager.CRIs.Length; ++i)
        {
            FirstIndex = UpdateProperties(ClientManager.CRIs[i], FirstIndex);
        }
    }
    Super.Closed(Sender, bCancelled);
}

function int UpdateProperties(HxClientReplicationInfo CRI, int FirstIndex)
{
    local int Limit;
    local int i;

    Limit = Min(lb_Options.Options.Length, FirstIndex + CRI.ServerInfo.Settings.Length);
    for (i = FirstIndex; i < Limit; ++i)
    {
        if (lb_Options.IsModified(i))
        {
            lb_Options.ResetModified(i);
            CRI.ServerUpdateProperty(
                lb_Options.Options[i].Tag - FirstIndex, lb_Options.Options[i].GetComponentValue());
        }
    }
    return Limit;
}

function Refresh()
{
    lb_Options.PopulateWithCRIs(ClientManager.CRIs);
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
        ExpandIndex=0
    End Object
    Section=ConfigListSection

    Begin Object Class=HxGUIMultiOptionListBox Name=ConfigListBox
        bVisibleWhenEmpty=true
        bUseServerInfo=true
        NumColumns=1
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
    WinWidth=0.41
    WinHeight=0.65
    WinLeft=0.295
    WinTop=0.15
    OnKeyEvent=InternalOnKeyEvent
}
