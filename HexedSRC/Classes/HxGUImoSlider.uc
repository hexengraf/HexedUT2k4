class HxGUImoSlider extends GUIMenuOption;

var float MaxValue;
var float MinValue;
var float Value;
var bool bIntSlider;
var string SliderStyleName;
var string SliderBarStyleName;
var string SliderFillStyleName;
var HxGUISlider MySlider;

#include Classes\Include\FixedGUIMenuOptionInitComponent.uci

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    ComponentClassName = string(class'HxGUISlider');
    FixedInitComponent(MyController, MyOwner);
    SetReadOnly(bValueReadOnly);
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    MySlider = HxGUISlider(NewComp);
    if (MySlider != None)
    {
        MySlider.MinValue = MinValue;
        MySlider.MaxValue = MaxValue;
        MySlider.bIntSlider = bIntSlider;
        MySlider.StyleName = SliderStyleName;
        MySlider.BarStyleName = SliderBarStyleName;
        MySlider.FillStyleName = SliderFillStyleName;
    }
    Super.InternalOnCreateComponent(NewComp, Sender);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
    if (bNoChange)
    {
        bIgnoreChange = true;
    }
    SetValue(NewValue);
    bIgnoreChange = false;
}

function string GetComponentValue()
{
    return string(GetValue());
}

function Adjust(float Amount)
{
    if (MySlider != None)
    {
        MySlider.Adjust(Amount);
    }
}

function SetValue(coerce float NewV)
{
    if (MySlider != None)
    {
        Value = MySlider.SetValue(NewV);
    }
}

function float GetValue()
{
    if (MySlider != None)
    {
        return MySlider.Value;
    }
    return 0.0;
}

function Setup(coerce float MinV, coerce float MaxV, optional bool bInt)
{
    MinValue = MinV;
    MaxValue = MaxV;
    bIntSlider = bInt;
    if (MySlider != None)
    {
        MySlider.MinValue = MinValue;
        MySlider.MaxValue = MaxValue;
        MySlider.bIntSlider = bIntSlider;
    }
}

function InternalOnChange(GUIComponent Sender)
{
    Value = MySlider.Value;
    Super.InternalOnChange(Sender);
}

function SetReadOnly(bool b)
{
    Super.SetReadOnly(b);
    MySlider.SetReadOnly(b);
}

defaultproperties
{
    SliderStyleName="HxSquareButton"
    SliderBarStyleName="HxSliderBar"
    SliderFillStyleName="HxSliderFill"
}
