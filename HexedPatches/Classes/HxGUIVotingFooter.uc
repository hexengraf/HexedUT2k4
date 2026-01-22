class HxGUIVotingFooter extends MapVoteFooter;

var automated GUIImage i_ChatScrollBoxBorder;

var int MaxHistory;
var Color FallbackColor;
var Color MessageColor;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    sb_Background.UnManageComponent(lb_Chat);
    ed_Chat.MyComponent.FontScale = ed_Chat.FontScale;
    OnDraw = None;
}

function ReceiveChat(string Message)
{
    local string Name;
    local string Text;

    if (Divide(Message, ":", Name, Text))
    {
        AddText(MakeColorCode(FallbackColor)$Name$":"$MakeColorCode(MessageColor)$Text);
    }
    else
    {
        AddText(MakeColorCode(FallbackColor)$StripColorCodes(Message));
    }
    if (lb_Chat.MyScrollText.ItemCount > MaxHistory)
    {
        lb_Chat.MyScrollText.Remove(0, lb_Chat.MyScrollText.ItemCount - MaxHistory);
    }
    lb_Chat.MyScrollText.End();
}

function AddText(string Message)
{
    if (lb_Chat.MyScrollText.ItemCount > 0)
    {
        lb_Chat.AddText(Message);
    }
    else
    {
        lb_Chat.SetContent(Message);
    }
}

function FixEditBoxStyle(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIEditBox(NewComp) != None)
    {
        NewComp.StyleName = "HxEditBox";
    }
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

    Begin Object Class=GUIImage Name=ChatScrollBoxBorder
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=0.84
        Image=Texture'engine.WhiteSquareTexture'
        ImageColor=(R=255,G=255,B=255,A=78)
        ImageStyle=ISTY_Stretched
        RenderWeight=0.1
        bScaleToParent=true
        bBoundToParent=true
    End Object
    i_ChatScrollBoxBorder=ChatScrollBoxBorder

    Begin Object Class=HxGUIScrollTextBox Name=NewChatScrollBox
        WinLeft=0.00276
        WinTop=0.006364
        WinWidth=0.99448
        WinHeight=0.827272
        // WinLeft=0
        // WinTop=0
        // WinWidth=1
        // WinHeight=0.84
        LeftPadding=0.02
        TopPadding=0.05
        RightPadding=0.02
        BottomPadding=0.05
        bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
        bStripColors=true
        ColorReplacements(0)=(Match=(R=200,G=1,B=1),ReplaceWith=(R=255,G=66,B=66))
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=2
    End Object
    lb_Chat=NewChatScrollBox

    Begin Object class=moEditBox Name=NewChatEditBox
        Caption="Say:"
        WinLeft=0
        WinTop=0.8575
        WinWidth=1
        WinHeight=0.1429
        LabelStyleName="HxSmallLabel"
        FontScale=FNS_Small
        CaptionWidth=0.01
        OnKeyEvent=InternalOnKeyEvent
        TabOrder=0
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
        OnCreateComponent=FixEditBoxStyle
    End Object
    ed_Chat=NewChatEditBox

    b_Accept=None
    b_Submit=None
    b_Close=None

    MaxHistory=64
    FallbackColor=(R=255,G=210,B=0,A=255)
    MessageColor=(R=236,G=236,B=236)
}
