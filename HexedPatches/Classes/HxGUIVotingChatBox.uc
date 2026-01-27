class HxGUIVotingChatBox extends GUIMultiComponent;

var automated GUIScrollTextBox lb_Chat;
var automated moEditBox ed_Input;

var Color FallbackColor;
var Color MessageColor;
var int MaxChatHistory;
var int MaxInputHistory;

var private array<string> InputHistory;
var private int RecallIndex;

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
    ed_Input.MyComponent.FontScale = ed_Input.FontScale;
    InputHistory[InputHistory.Length] = "";
    RecallIndex = 0;
}

function bool OnSendChat(string Text)
{
    local bool bSent;

    if (Text != "")
    {
        if (Left(Text,4) ~= "cmd ")
        {
            bSent = true;
            PlayerOwner().ConsoleCommand(Mid(Text, 4));
        }
        else if (Left(Text,1) == ".")
        {
            PlayerOwner().TeamSay(Mid(Text,1));
            bSent = IsMessageSent(PlayerOwner());
        }
        else
        {
            PlayerOwner().Say(Text);
            bSent = IsMessageSent(PlayerOwner());
        }
    }
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
        AddText(MakeColorCode(FallbackColor)$Name$":"$MakeColorCode(MessageColor)$Text);
    }
    else
    {
        AddText(MakeColorCode(FallbackColor)$StripColorCodes(Message));
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

function bool OnKeyEventInput(out byte Key, out byte State, float delta)
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
                    ed_Input.SetComponentValue("", true);
                }
                return true;
            }
            break;
        case IK_Up:
            if (Action == IST_Press || Action == IST_Hold)
            {
                RecallIndex = Max(0, RecallIndex - 1);
                ed_Input.SetComponentValue(InputHistory[RecallIndex], true);
                return true;
            }
            break;
        case IK_Down:
            if (Action == IST_Press || Action == IST_Hold)
            {
                RecallIndex = Min(InputHistory.Length - 1, RecallIndex + 1);
                ed_Input.SetComponentValue(InputHistory[RecallIndex], true);
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
    RecallIndex = InputHistory.Length - 1;
    InputHistory[RecallIndex] = ed_Input.GetText();
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
        WinHeight=0.84
        LeftPadding=0.02
        TopPadding=0.05
        RightPadding=0.02
        BottomPadding=0.05
        VertAlign=TXTA_Right
        bAutoSpacing=true
        bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
        bStripColors=true
        ColorReplacements(0)=(Match=(R=200,G=1,B=1),ReplaceWith=(R=255,G=66,B=66))
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=2
    End Object
    lb_Chat=ChatScrollBox

    Begin Object class=moEditBox Name=ChatInputBox
        Caption="Say:"
        WinLeft=0
        WinTop=0.8575
        WinWidth=1
        WinHeight=0.1429
        LabelStyleName="HxSmallLabel"
        FontScale=FNS_Small
        CaptionWidth=0.01
        TabOrder=0
        bStandardized=true
        StandardHeight=0.0275
        bBoundToParent=true
        bScaleToParent=true
        OnCreateComponent=FixEditBoxStyle
        OnKeyEvent=OnKeyEventInput
        OnChange=OnChangeInput
    End Object
    ed_Input=ChatInputBox

    MaxChatHistory=256
    MaxInputHistory=128
    FallbackColor=(R=255,G=210,B=0,A=255)
    MessageColor=(R=236,G=236,B=236)
}
