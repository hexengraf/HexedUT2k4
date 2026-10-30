class HxGUImoFloatEdit extends GUIMenuOption;

var float MinValue;
var float MaxValue;
var float Step;
var HxGUIFloatEdit MyNumericEdit;

#include Classes\Include\FixedGUIMenuOptionInitComponent.uci

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    ComponentClassName = string(class'HxGUIFloatEdit');
    FixedInitComponent(MyController, MyOwner);
    MyNumericEdit = HxGUIFloatEdit(MyComponent);
    MyNumericEdit.MinValue = MinValue;
    MyNumericEdit.MaxValue = MaxValue;
    MyNumericEdit.Step = Step;
    MyNumericEdit.CalcMaxLen();
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

function SetValue(coerce float V)
{
    MyNumericEdit.SetValue(v);
}

function float GetValue()
{
    return float(MyNumericEdit.Value);
}

function Setup(coerce float NewMin, coerce float NewMax, coerce float NewStep)
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
    MinValue=-9999.0
    MaxValue=9999.0
    Step=0.10
}
