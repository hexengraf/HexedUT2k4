class HxGUImoCheckBox extends moCheckBox;

var string ButtonStyleName;

#include Classes\Include\FixedGUIMenuOptionInitComponent.uci

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local GUIStyles S;

    FixedInitComponent(MyController, MyOwner);
    MyCheckBox = GUICheckBoxButton(MyComponent);
    MyCheckBox.OnChange = ButtonChecked;
    MyCheckBox.OnClick = InternalClick;
    S = Controller.GetStyle(CheckStyleName, MyCheckBox.FontScale);
    if (S != None)
    {
        MyCheckBox.Graphic = S.Images[0];
    }
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (NewComp.IsA('GUICheckBoxButton'))
    {
        NewComp.StyleName = ButtonStyleName;
    }
    Super.InternalOnCreateComponent(NewComp, Sender);
}

defaultproperties
{
    ButtonStyleName="HxEditBox"
    LabelStyleName="HxTextLabel"
}
