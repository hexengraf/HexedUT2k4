class HxGUImoNumericEdit extends GUIMenuOption;

var int MinValue;
var int MaxValue;
var int Step;
var HxGUINumericEdit MyNumericEdit;

#include Classes\Include\FixedGUIMenuOptionInitComponent.uci

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    ComponentClassName = string(class'HxGUINumericEdit');
    FixedInitComponent(MyController, MyOwner);
    MyNumericEdit = HxGUINumericEdit(MyComponent);
    MyNumericEdit.MinValue = MinValue;
    MyNumericEdit.MaxValue = MaxValue;
    MyNumericEdit.Step = Step;
    MyNumericEdit.CalcMaxLen();
    MyNumericEdit.OnChange = InternalOnChange;
    MyNumericEdit.SetReadOnly(bValueReadOnly);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
    bIgnoreChange = bNoChange;
    SetValue(NewValue);
    bIgnoreChange = false;
}

function string GetComponentValue()
{
    return string(GetValue());
}

function SetValue(coerce int V)
{
    MyNumericEdit.SetValue(v);
}

function int GetValue()
{
    return int(MyNumericEdit.Value);
}

function Setup(coerce int NewMin, coerce int NewMax, coerce int NewStep)
{
    MinValue = NewMin;
    MaxValue = NewMax;
    Step = NewStep;
    MyNumericEdit.MinValue = MinValue;
    MyNumericEdit.MaxValue = MaxValue;
    MyNumericEdit.Step = Step;
    MyNumericEdit.MyEditBox.bIncludeSign = NewMin < 0;
    MyNumericEdit.CalcMaxLen();
    SetValue(FClamp(GetValue(), MinValue, MaxValue));
}

function SetReadOnly(bool b)
{
    Super.SetReadOnly(b);
    MyNumericEdit.SetReadOnly(b);
}

defaultproperties
{
    LabelStyleName="HxTextLabel"
    MinValue=-9999
    MaxValue=9999
    Step=1
}
