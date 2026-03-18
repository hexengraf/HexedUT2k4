class HxGUIServerMenu extends HxGUIFloatingWindow;

var automated HxGUIFramedSection Section;
var automated HxGUIMultiOptionListBox lb_Options;
var automated moCheckBox ch_Advanced;

var private HxUTClient Client;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    Section.Insert(lb_Options);
    Section.Insert(ch_Advanced);
    Client = class'HxUTClient'.static.GetClient(PlayerOwner());
    lb_Options.PopulateWithPlayInfo(Client.ServerInfo);
}

event Opened(GUIComponent Sender)
{
    Super.Opened(Sender);
    if (!Client.IsServerInfoReady())
    {
        SetTimer(0.1, true);
    }
    ch_Advanced.Checked(Controller.bExpertMode);
    lb_Options.Refresh();
}

event Timer()
{
    if (Client.IsServerInfoReady())
    {
        KillTimer();
    }
    lb_Options.Refresh();
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    local int i;

    if (Client != None && Client.IsServerInfoReady() && IsAdmin())
    {
        for (i = 0; i < lb_Options.List.Elements.Length; ++i)
        {
            if (lb_Options.List.Elements[i].Tag > -1)
            {
                if (lb_Options.IsModified(lb_Options.List.Elements[i].Tag))
                {
                    lb_Options.ResetModified(lb_Options.List.Elements[i].Tag);
                    Client.ServerUpdateProperty(
                        lb_Options.List.Elements[i].Tag,
                        lb_Options.List.Elements[i].GetComponentValue());
                }
            }
        }
    }
    Super.Closed(Sender, bCancelled);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputAction Action;

    Action = EInputAction(State);
    switch (EInputKey(Key))
    {
        case IK_MouseWheelUp:
        case IK_MouseWheelDown:
            lb_Options.SetFocus(None);
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
        lb_Options.PopulateWithPlayInfo(Client.ServerInfo);
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
        WinLeft=0.025
        WinTop=0.06
        WinWidth=0.95
        WinHeight=0.91
        TopPadding=0.019
        bNoHeader=true
        ExpandIndex=0
    End Object
    Section=ConfigListSection

    Begin Object Class=HxGUIMultiOptionListBox Name=ConfigListBox
        RenderWeight=0.9
        bVisibleWhenEmpty=True
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

    WindowName="HexedUT - Server Options"
    WinWidth=0.45
    WinHeight=0.65
    WinLeft=0.275
    WinTop=0.15
    OnKeyEvent=InternalOnKeyEvent
}
