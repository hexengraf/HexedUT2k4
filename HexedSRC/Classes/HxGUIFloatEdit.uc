class HxGUIFloatEdit extends GUIMultiComponent;

var automated GUIEditBox MyEditBox;
var automated GUIButton MyPlusButton;
var automated GUIButton MyMinusButton;

var string Value;
var float MinValue;
var float MaxValue;
var float Step;
var bool bReadOnly;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    if (MinValue < 0)
    {
        MyEditBox.bIncludeSign = true;
    }
    Super.InitComponent(MyController, MyOwner);
    MyEditBox.OnChange = EditOnChange;
    MyEditBox.SetText(Value);
    MyEditBox.OnKeyEvent = EditKeyEvent;
    MyEditBox.OnDeActivate = CheckValue;
    MyEditBox.INIOption = INIOption;
    MyEditBox.INIDefault = INIDefault;
    CalcMaxLen();
    MyPlusButton.FocusInstead = MyEditBox;
    MyMinusButton.FocusInstead = MyEditBox;
    SetReadOnly(bReadOnly);
    SetHint(Hint);
    bInit = true;
}

function ResolutionChanged(int ResX, int ResY)
{
    bInit = true;
    Super.ResolutionChanged(ResX, ResY);
}

function bool InternalOnPreDraw(Canvas C)
{
    local float Offset;

    if (bInit)
    {
        Offset = class'HxGUIStyles'.static.GetActualFrameThickness(MyEditBox) / ActualWidth();
        MyPlusButton.WinLeft = MyEditBox.WinWidth - Offset;
        MyPlusButton.WinWidth = 1.0 - MyEditBox.WinWidth + Offset;
        Offset = class'HxGUIStyles'.static.GetActualFrameThickness(MyMinusButton) / ActualHeight();
        MyPlusButton.WinHeight = 0.5 + Offset;
        MyMinusButton.WinLeft = MyPlusButton.WinLeft;
        MyMinusButton.WinWidth = MyPlusButton.WinWidth;
        bInit = false;
        return true;
    }
    return false;
}

function CalcMaxLen()
{
    local int DigitCount;
    local int x;

    DigitCount = 1;
    x = 10;
    while (x < MaxValue)
    {
        ++DigitCount;
        x *= 10;
    }
    MyEditBox.MaxWidth = DigitCount + 4;
}

function SetHint(string NewHint)
{
    local int i;

    Super.SetHint(NewHint);
    for (i = 0; i < Controls.Length; ++i)
    {
        Controls[i].SetHint(NewHint);
    }
}

function SetValue(float V)
{
    MyEditBox.SetText(string(FClamp(V, MinValue, MaxValue)));
}

function bool OnPlusClick(GUIComponent Sender)
{
    SetValue(float(Value) + Step);
    return true;
}

function bool OnMinusClick(GUIComponent Sender)
{
    SetValue(float(Value) - Step);
    return true;
}

function bool EditKeyEvent(out byte Key, out byte State, float delta)
{
    if (State == 3)
    {
        if (key == 0xEC)
        {
            OnPlusClick(None);
            return true;
        }
        if (key == 0xED)
        {
            OnMinusClick(None);
            return true;
        }
    }
    return MyEditBox.InternalOnKeyEvent(Key, State, Delta);
}

function CheckValue()
{
    SetValue(float(Value));
}

function EditOnChange(GUIComponent Sender)
{
    Value = string(FClamp(float(MyEditBox.TextStr), MinValue, MaxValue));
    OnChange(Sender);
}

function SetReadOnly(bool b)
{
    bReadOnly = b;
    MyEditBox.bReadOnly = b;
    if (b)
    {
        DisableComponent(MyPlusButton);
        DisableComponent(MyMinusButton);
    }
    else
    {
        EnableComponent(MyPlusButton);
        EnableComponent(MyMinusButton);
    }
}

function SetFriendlyLabel( GUILabel NewLabel )
{
    Super.SetFriendlyLabel(NewLabel);
    if (MyEditBox != None)
    {
        MyEditBox.SetFriendlyLabel(NewLabel);
    }
    if (MyPlusButton != None)
    {
        MyPlusButton.SetFriendlyLabel(NewLabel);
    }
    if (MyMinusButton != None)
    {
        MyMinusButton.SetFriendlyLabel(NewLabel);
    }
}

function ValidateValue()
{
    local float V;

    V = float(MyEditBox.TextStr);
    MyEditBox.TextStr = string(FClamp(V, MinValue, MaxValue));
    MyEditBox.bHasFocus = false;
}

defaultproperties
{
    Begin Object class=GUIEditBox Name=NewEditBox
        WinLeft=0.0
        WinTop=0.0
        WinWidth=0.75
        WinHeight=1.0
        StyleName="HxEditBox"
        bFloatOnly=true
        bBoundToParent=true
        bScaleToParent=true
    End Object
    MyEditBox=NewEditBox

    Begin Object class=GUIButton Name=NewPlusButton
        WinLeft=0.75
        WinTop=0.0
        WinWidth=0.25
        WinHeight=0.5
        StyleName="HxButtonPlus"
        bNeverFocus=true
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnPlusClick
    End Object
    MyPlusButton=NewPlusButton

    Begin Object class=GUIButton Name=NewMinusButton
        WinLeft=0.75
        WinTop=0.5
        WinWidth=0.25
        WinHeight=0.5
        StyleName="HxButtonMinus"
        bNeverFocus=true
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnMinusClick
    End Object
    MyMinusButton=NewMinusButton

    OnPreDraw=InternalOnPreDraw
    OnDeActivate=ValidateValue
}
