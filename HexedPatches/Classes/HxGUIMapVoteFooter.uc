class HxGUIMapVoteFooter extends MapVoteFooter;

var int MaxHistory;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    sb_Background.UnManageComponent(lb_Chat);
    OnDraw = None;
}

function ReceiveChat(string Msg)
{
    lb_Chat.AddText(Msg);
    if (lb_Chat.MyScrollText.ItemCount > MaxHistory)
    {
        lb_Chat.MyScrollText.Remove(0, lb_Chat.MyScrollText.ItemCount - MaxHistory);
    }
    lb_Chat.MyScrollText.End();
}

defaultproperties
{
    Begin Object Class=AltSectionBackground Name=NewMapVoteFooterBackground
        bVisible=false
    End Object
    sb_Background=NewMapVoteFooterBackground

    Begin Object Class=HxGUIScrollTextBox Name=NewChatScrollBox
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=0.82
        bBoundToParent=true
        bScaleToParent=true
        bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
        bStripColors=false
        bCenter=false
        TabOrder=2
    End Object
    lb_Chat=NewChatScrollBox

    Begin Object class=moEditBox Name=NewChatEditBox
        Caption="Say:"
        WinLeft=0
        WinTop=0.85
        WinWidth=1
        WinHeight=0.15
        CaptionWidth=0.11
        OnKeyEvent=InternalOnKeyEvent
        TabOrder=0
        bStandardized=true
        bBoundToParent=true
        bScaleToParent=true
    End Object
    ed_Chat=NewChatEditBox

    b_Accept=None
    b_Submit=None
    b_Close=None

    MaxHistory=64
}
