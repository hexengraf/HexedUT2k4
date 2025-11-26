class HxMenuSlider extends HxMenuOption;

var float MaxValue;
var float MinValue;
var bool bIntSlider;
var string SliderStyleName;
var string SliderCaptionStyleName;
var string SliderBarStyleName;
var GUISlider Slider;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
    Super.InitComponent(InController, InOwner);
    Slider = GUISlider(MyComponent);
    Slider.MinValue = MinValue;
    Slider.MaxValue = MaxValue;
    Slider.bIntSlider = bIntSlider;
    Slider.StyleName = SliderStyleName;
    Slider.CaptionStyleName = SliderCaptionStyleName;
    Slider.BarStyleName = SliderBarStyleName;
    Slider.SetReadOnly(bValueReadOnly);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
    if (bNoChange)
    {
        bIgnoreChange = true;
    }
    Slider.SetValue(float(NewValue));
    bIgnoreChange = false;
}

function string GetComponentValue()
{
    return string(Slider.Value);
}

defaultproperties
{
    MinValue=0
    MaxValue=1.0
    ComponentWidth=0.70
    ComponentClassName="XInterface.GUISlider"
    SliderStyleName="SliderKnob"
    SliderBarStyleName="SliderBar"
    SliderCaptionStyleName="SliderCaption"
}
