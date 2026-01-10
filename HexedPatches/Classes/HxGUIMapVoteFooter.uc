class HxGUIMapVoteFooter extends MapVoteFooter;

var int MaxHistory;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    sb_Background.UnManageComponent(lb_Chat);
    ed_Chat.MyComponent.FontScale = ed_Chat.FontScale;
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

function LevelChanged()
{
    lb_Chat.SetContent("");
    lb_Chat.MyScrollText.NewText = "";
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
        WinTop=0.8575
        WinWidth=1
        WinHeight=0.1429
        LabelFont="HxSmallerFont"
        FontScale=FNS_Small
        CaptionWidth=0.01
        OnKeyEvent=InternalOnKeyEvent
        TabOrder=0
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
    End Object
    ed_Chat=NewChatEditBox

    b_Accept=None
    b_Submit=None
    b_Close=None

    MaxHistory=64
}
