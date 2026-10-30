class HxGUImoComboBox extends moComboBox;

#include Classes\Include\FixedGUIMenuOptionInitComponent.uci

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    ComponentClassName = string(class'HxGUIComboBox');
    FixedInitComponent(MyController, MyOwner);
    MyComboBox = GUIComboBox(MyComponent);
    MyComboBox.Edit.bAlwaysNotify = bAlwaysNotify;
    SetReadOnly(bValueReadOnly);
    ReadOnly(bReadOnly);
}

defaultproperties
{
    LabelStyleName="HxTextLabel"
}
