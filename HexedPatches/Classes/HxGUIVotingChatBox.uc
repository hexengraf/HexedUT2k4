class HxGUIVotingChatBox extends HxGUIFramedImage;

enum EHxChatChannel
{
    HX_CHAT_CHANNEL_Say,
    HX_CHAT_CHANNEL_TeamSay,
    HX_CHAT_CHANNEL_Console,
};
const CHAT_CHANNEL_COUNT = 3;

struct HxChatInputHistory
{
    var array<string> Messages;
    var int Index;
};

var automated GUIScrollTextBox lb_Chat;
var automated HxGUIFramedButton fb_Channel;
var automated HxGUIFramedEditBox ed_Input;

var Color MessageColor;
var Color MessageFallbackColor;
var int MaxChatHistory;
var int MaxInputHistory;
var localized string ChatChannels[CHAT_CHANNEL_COUNT];

var private EHxChatChannel ActiveChannel;
var private HxChatInputHistory CIH[CHAT_CHANNEL_COUNT];
var private string ChannelCommands[CHAT_CHANNEL_COUNT];
var private bool bIgnoreChange;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local ExtendedConsole Console;
    local int i;

    Super.InitComponent(MyController, MyOwner);
    Console = ExtendedConsole(Controller.ViewportOwner.Console);
    if (Console != None)
    {
        Console.OnChatMessage = ReceiveChat;
    }
    lb_Chat.MyScrollText.SetContent("");
    lb_Chat.MyScrollText.FontScale = FNS_Small;
    for (i = 0; i < CHAT_CHANNEL_COUNT; ++i)
    {
        CIH[i].Messages.Insert(0, 1);
        CIH[i].Index = 0;
    }
    SetInputType(HX_CHAT_CHANNEL_Say);
}

function bool OnSendChat(string Text)
{
    local PlayerController PC;

    if (Text != "")
    {
        PC = PlayerOwner();
        switch (ActiveChannel)
        {
            case HX_CHAT_CHANNEL_Say:
                PC.Say(Text);
                return UpdateInputHistory(Text, IsMessageSent(PC));
            case HX_CHAT_CHANNEL_TeamSay:
                PC.TeamSay(Text);
                return UpdateInputHistory(Text, IsMessageSent(PC));
            case HX_CHAT_CHANNEL_Console:
                PC.ConsoleCommand(Text);
                return UpdateInputHistory(Text, true);
            default:
                break;
        }
    }
    return false;
}

function bool UpdateInputHistory(string Text, bool bSent)
{
    local int Index;

    if (bSent)
    {
        Index = CIH[ActiveChannel].Messages.Length - 1;
        CIH[ActiveChannel].Messages[Index] = Text;
        if (Index == MaxInputHistory - 1)
        {
            CIH[ActiveChannel].Messages.Remove(0, 1);
        }
        CIH[ActiveChannel].Index = Index + 1;
        CIH[ActiveChannel].Messages[Index + 1] = "";
    }
    return bSent;
}

function ReceiveChat(string Message)
{
    local string Name;
    local string Text;

    if (Divide(Message, ":", Name, Text))
    {
        AddText(MakeColorCode(MessageFallbackColor)$Name$":"$MakeColorCode(MessageColor)$Text);
    }
    else
    {
        AddText(MakeColorCode(MessageFallbackColor)$StripColorCodes(Message));
    }
    if (lb_Chat.MyScrollText.ItemCount > MaxChatHistory)
    {
        lb_Chat.MyScrollText.Remove(0, lb_Chat.MyScrollText.ItemCount - MaxChatHistory);
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

function LevelChanged()
{
    lb_Chat.SetContent("");
    lb_Chat.MyScrollText.NewText = "";
}

function bool OnKeyEventInput(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputAction Action;

    Action = EInputAction(State);
    switch (EInputKey(Key))
    {
        case IK_Enter:
            if (Action == IST_Release)
            {
                if (OnSendChat(ed_Input.GetText()))
                {
                    SetInputSilent("");
                }
                return true;
            }
            break;
        case IK_Up:
            if (Action == IST_Press || Action == IST_Hold)
            {
                CIH[ActiveChannel].Index = Max(0, CIH[ActiveChannel].Index - 1);
                SetInputSilent(CIH[ActiveChannel].Messages[CIH[ActiveChannel].Index]);
                return true;
            }
            break;
        case IK_Down:
            if (Action == IST_Press || Action == IST_Hold)
            {
                CIH[ActiveChannel].Index = Min(
                    CIH[ActiveChannel].Messages.Length - 1, CIH[ActiveChannel].Index + 1);
                SetInputSilent(CIH[ActiveChannel].Messages[CIH[ActiveChannel].Index]);
                return true;
            }
            break;
        default:
            break;
    }
    return false;
}

function OnChangeInput(GUIComponent Sender)
{
    local string Message;
    local string Left;
    local string Right;
    local int Length;
    local int i;

    if (!bIgnoreChange)
    {
        Message = ed_Input.GetText();
        if (Divide(Message, " ", Left, Right))
        {
            Length = Len(Left);
            for (i = 0; i < CHAT_CHANNEL_COUNT; ++i)
            {
                if (StrCmp(ChannelCommands[i], Left, Length, false) == 0)
                {
                    Message = Right;
                    SetInputSilent(Right);
                    SetInputType(EHxChatChannel(i));
                    break;
                }
            }
        }
        CIH[ActiveChannel].Messages[CIH[ActiveChannel].Messages.Length - 1] = Message;
    }
}

function bool OnClickInput(GUIComponent Sender)
{
    SetInputType(EHxChatChannel((ActiveChannel + 1) % CHAT_CHANNEL_COUNT));
    return true;
}

function bool AlignComponents(Canvas C)
{
    local float XL;
    local float YL;
    local float Thickness;

    Thickness = Round(C.ClipY * FrameThickness) / ActualHeight();
    fb_Channel.Style.TextSize(
        C, fb_Channel.MenuState, ChatChannels[1], XL, YL, fb_Channel.FontScale);
    fb_Channel.WinHeight = fb_Channel.RelativeHeight(YL * 1.5);
    fb_Channel.WinWidth = fb_Channel.RelativeWidth(XL * 1.2);
    fb_Channel.WinTop = 1.0 - fb_Channel.WinHeight;
    ed_Input.WinLeft = fb_Channel.WinWidth - Thickness;
    ed_Input.WinTop = fb_Channel.WinTop;
    ed_Input.WinWidth = 1.0 - ed_Input.WinLeft;
    ed_Input.WinHeight = fb_Channel.WinHeight;
    lb_Chat.WinHeight = fb_Channel.WinTop + Thickness;
    return false;
}

function SetInputSilent(string Text)
{
    bIgnoreChange = true;
    ed_Input.SetText(Text);
    bIgnoreChange = false;
}

function SetInputType(EHxChatChannel Channel)
{
    ActiveChannel = Channel;
    fb_Channel.SetCaption(ChatChannels[ActiveChannel]);
}

static function bool IsMessageSent(PlayerController Controller)
{
    return Controller.Level.NetMode == NM_Standalone
        || Controller.PlayerReplicationInfo.bAdmin
        || Controller.LastBroadcastTime == Controller.Level.TimeSeconds;
}

defaultproperties
{
    Begin Object Class=HxGUIScrollTextBox Name=ChatScrollBox
        WinLeft=0
        WinTop=0
        WinWidth=1
        LeftPadding=0.02
        TopPadding=0.05
        RightPadding=0.02
        BottomPadding=0.05
        VertAlign=TXTA_Right
        bAutoSpacing=true
        bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
        bHideFrame=true
        bStripColors=true
        ColorReplacements(0)=(Match=(R=200,G=1,B=1),ReplaceWith=(R=255,G=66,B=66))
        RenderWeight=1
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=2
    End Object
    lb_Chat=ChatScrollBox

    Begin Object Class=HxGUIFramedButton Name=ChannelButton
        Hint="Click to cycle between channels."
        WinLeft=0
        FontScale=FNS_Small
        bNeverFocus=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickInput
    End Object
    fb_Channel=ChannelButton

    Begin Object class=HxGUIFramedEditBox Name=ChatInputBox
        Hint="Switch channel by typing /s, /t or /c followed by a space."
        StyleName="HxEditBox"
        FontScale=FNS_Small
        TabOrder=0
        bStandardized=false
        bBoundToParent=true
        bScaleToParent=true
        OnKeyEvent=OnKeyEventInput
        OnChange=OnChangeInput
    End Object
    ed_Input=ChatInputBox

    ImageSources(0)=(Color=(R=28,G=47,B=96,A=255),Style=ISTY_Stretched,RenderWeight=0.1)
    MaxChatHistory=256
    MaxInputHistory=128
    MessageColor=(R=236,G=236,B=236)
    MessageFallbackColor=(R=255,G=210,B=0,A=255)
    ChatChannels(0)="Say"
    ChatChannels(1)="TeamSay"
    ChatChannels(2)="Console"
    ChannelCommands(0)="/say"
    ChannelCommands(1)="/teamsay"
    ChannelCommands(2)="/console"
    OnPreDrawInit=AlignComponents
}
