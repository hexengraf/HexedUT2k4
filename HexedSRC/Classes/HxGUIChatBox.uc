class HxGUIChatBox extends HxGUIFramedImage;

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

var automated HxGUIScrollTextBox lb_Chat;
var automated GUIButton b_Channel;
var automated GUIEditBox ed_Input;

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
    local int i;

    Super.InitComponent(MyController, MyOwner);
    lb_Chat.MyScrollText.SetContent("");
    lb_Chat.MyScrollText.FontScale = FNS_Small;
    for (i = 0; i < CHAT_CHANNEL_COUNT; ++i)
    {
        CIH[i].Messages.Insert(0, 1);
        CIH[i].Index = 0;
    }
    SetInputType(HX_CHAT_CHANNEL_Say);
    SetCustomBackground("");
}

event Opened(GUIComponent Sender)
{
    local ExtendedConsole Console;

    Super.Opened(Sender);
    Console = ExtendedConsole(Controller.ViewportOwner.Console);
    if (Console != None)
    {
        Console.OnChatMessage = ReceiveChat;
    }
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
    }
    return ed_Input.InternalOnKeyEvent(Key, State, Delta);
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
    local float Height;
    local float Thickness;

    Height = ActualHeight();
    Thickness = ActualFrameThickness(C) / Height;
    b_Channel.Style.TextSize(
        C, b_Channel.MenuState, ChatChannels[1], XL, YL, b_Channel.FontScale);
    b_Channel.WinWidth = b_Channel.RelativeWidth(XL * 1.2);
    b_Channel.WinTop = 1.0 - (b_Channel.ActualHeight() / Height);
    ed_Input.WinLeft = b_Channel.WinWidth - Thickness;
    ed_Input.WinTop = b_Channel.WinTop;
    ed_Input.WinWidth = 1.0 - ed_Input.WinLeft;
    lb_Chat.WinHeight = b_Channel.WinTop + Thickness;
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
    b_Channel.Caption = ChatChannels[ActiveChannel];
}

function SetCustomBackground(string BackgroundName)
{
    if (BackgroundName == "")
    {
        lb_Chat.i_Background.Images[0].Image = None;
    }
    else
    {
        lb_Chat.i_Background.Images[0].Image = Material(
            DynamicLoadObject(BackgroundName, class'Material'));
    }
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
        FontScale=FNS_Small
        VertAlign=TXTA_Right
        bAutoSpacing=true
        bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
        bHideFrame=true
        bStripColors=true
        ColorReplacements(0)=(Match=(R=200,G=1,B=1),ReplaceWith=(R=255,G=66,B=66))
        BackgroundSources(0)=(Color=(R=255,G=255,B=255,A=255),Style=ISTY_Scaled)
        RenderWeight=1
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=2
    End Object
    lb_Chat=ChatScrollBox

    Begin Object Class=GUIButton Name=ChannelButton
        Hint="Click to cycle between console and chat channels."
        WinLeft=0
        StandardHeight=0.027
        bStandardized=true
        FontScale=FNS_Small
        bNeverFocus=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickInput
    End Object
    b_Channel=ChannelButton

    Begin Object class=GUIEditBox Name=ChatInputBox
        Hint="Switch channel by typing /s, /t or /c followed by a space."
        StyleName="HxEditBox"
        StandardHeight=0.027
        bStandardized=true
        FontScale=FNS_Small
        TabOrder=0
        bBoundToParent=true
        bScaleToParent=true
        OnKeyEvent=OnKeyEventInput
        OnChange=OnChangeInput
    End Object
    ed_Input=ChatInputBox

    ImageSources(0)=(Color=(R=24,G=14,B=51,A=164),Style=ISTY_Stretched,RenderWeight=0.1)
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
