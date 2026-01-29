class HxGUIVotingChatBox extends HxGUIFramedImage;

enum EHxChatInputType
{
    HX_CHAT_INPUT_Say,
    HX_CHAT_INPUT_TeamSay,
    HX_CHAT_INPUT_Console,
};
const INPUT_TYPE_COUNT = 3;

var automated GUIScrollTextBox lb_Chat;
var automated HxGUIFramedButton fb_InputType;
var automated GUIEditBox ed_Input;

var Color MessageColor;
var Color MessageFallbackColor;
var int MaxChatHistory;
var int MaxInputHistory;
var localized string InputTypes[INPUT_TYPE_COUNT];

var private string InputTypeCommands[INPUT_TYPE_COUNT];
var private EHxChatInputType SelectedInput;
var private array<string> InputHistory;
var private int RecallIndex;
var private bool bIgnoreChange;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local ExtendedConsole Console;

    Super.InitComponent(MyController, MyOwner);
    Console = ExtendedConsole(Controller.ViewportOwner.Console);
    if (Console != None)
    {
        Console.OnChatMessage = ReceiveChat;
    }
    lb_Chat.MyScrollText.SetContent("");
    lb_Chat.MyScrollText.FontScale = FNS_Small;
    InputHistory[InputHistory.Length] = "";
    RecallIndex = 0;
    SetInputType(HX_CHAT_INPUT_Say);
}

function bool OnSendChat(string Text)
{
    local PlayerController PC;

    if (Text != "")
    {
        PC = PlayerOwner();
        switch (SelectedInput)
        {
            case HX_CHAT_INPUT_Say:
                PC.Say(Text);
                return UpdateInputHistory(Text, IsMessageSent(PC));
            case HX_CHAT_INPUT_TeamSay:
                PC.TeamSay(Text);
                return UpdateInputHistory(Text, IsMessageSent(PC));
            case HX_CHAT_INPUT_Console:
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
    if (bSent)
    {
        InputHistory[InputHistory.Length - 1] = Text;
        if (InputHistory.Length == MaxInputHistory)
        {
            InputHistory.Remove(0, 1);
        }
        RecallIndex = InputHistory.Length;
        InputHistory[RecallIndex] = "";
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
    local bool bConsumed;

    Action = EInputAction(State);
    bIgnoreChange = true;
    bConsumed = false;
    switch (EInputKey(Key))
    {
        case IK_Enter:
            if (Action == IST_Release)
            {
                if (OnSendChat(ed_Input.GetText()))
                {
                    ed_Input.SetText("");
                }
                bConsumed = true;
            }
            break;
        case IK_Up:
            if (Action == IST_Press || Action == IST_Hold)
            {
                RecallIndex = Max(0, RecallIndex - 1);
                ed_Input.SetText(InputHistory[RecallIndex]);
                bConsumed = true;
            }
            break;
        case IK_Down:
            if (Action == IST_Press || Action == IST_Hold)
            {
                RecallIndex = Min(InputHistory.Length - 1, RecallIndex + 1);
                ed_Input.SetText(InputHistory[RecallIndex]);
                bConsumed = true;
            }
            break;
        default:
            break;
    }
    bIgnoreChange = false;
    return bConsumed || ed_Input.InternalOnKeyEvent(Key, State, Delta);
}

function OnChangeInput(GUIComponent Sender)
{
    local string Left;
    local string Right;
    local int Length;
    local int i;

    if (!bIgnoreChange)
    {
        RecallIndex = InputHistory.Length - 1;
        InputHistory[RecallIndex] = ed_Input.GetText();
        if (Divide(InputHistory[RecallIndex], " ", Left, Right))
        {
            Length = Len(Left);
            for (i = 0; i < INPUT_TYPE_COUNT; ++i)
            {
                if (StrCmp(InputTypeCommands[i], Left, Length, false) == 0)
                {
                    bIgnoreChange = true;
                    ed_Input.SetText(Right);
                    bIgnoreChange = false;
                    SetInputType(EHxChatInputType(i));
                    break;
                }
            }
        }
    }
}

function bool OnClickInput(GUIComponent Sender)
{
    SetInputType(EHxChatInputType((SelectedInput + 1) % INPUT_TYPE_COUNT));
    return true;
}

function bool AlignComponents(Canvas C)
{
    local float XL;
    local float YL;

    fb_InputType.Style.TextSize(
        C, fb_InputType.MenuState, InputTypes[1], XL, YL, fb_InputType.FontScale);
    fb_InputType.WinHeight = fb_InputType.RelativeHeight(YL * 1.5);
    fb_InputType.WinWidth = fb_InputType.RelativeWidth(XL * 1.2);
    fb_InputType.WinTop = 1.0 - fb_InputType.WinHeight;
    ed_Input.WinLeft = fb_InputType.WinWidth;
    ed_Input.WinTop = fb_InputType.WinTop;
    ed_Input.WinWidth = 1.0 - ed_Input.WinLeft;
    ed_Input.WinHeight = fb_InputType.WinHeight;
    lb_Chat.WinHeight = fb_InputType.WinTop;
    return false;
}

function SetInputType(EHxChatInputType Type)
{
    SelectedInput = Type;
    fb_InputType.SetCaption(InputTypes[SelectedInput]);
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
        bBackgroundVisible=false
        bStripColors=true
        ColorReplacements(0)=(Match=(R=200,G=1,B=1),ReplaceWith=(R=255,G=66,B=66))
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=2
    End Object
    lb_Chat=ChatScrollBox

    Begin Object Class=HxGUIFramedButton Name=InputTypeButton
        Hint="Click to cycle between channels."
        WinLeft=0
        FontScale=FNS_Small
        bNeverFocus=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickInput
    End Object
    fb_InputType=InputTypeButton

    Begin Object class=GUIEditBox Name=ChatInputBox
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

    ImageColor=(R=28,G=43,B=91,A=255)
    MaxChatHistory=256
    MaxInputHistory=128
    MessageColor=(R=236,G=236,B=236)
    MessageFallbackColor=(R=255,G=210,B=0,A=255)
    InputTypes(0)="Say"
    InputTypes(1)="TeamSay"
    InputTypes(2)="Console"
    InputTypeCommands(0)="/say"
    InputTypeCommands(1)="/teamsay"
    InputTypeCommands(2)="/console"
    OnPreDrawInit=AlignComponents
}
