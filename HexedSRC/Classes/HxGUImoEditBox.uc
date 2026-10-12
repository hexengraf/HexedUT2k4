class HxGUImoEditBox extends moEditBox;

#include Classes\Include\FixedGUIMenuOptionInitComponent.uci

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    FixedInitComponent(MyController, MyOwner);
    MyEditBox = GUIEditBox(MyComponent);
    ReadOnly(bReadOnly || bValueReadOnly);
    MaskText(bMaskText);
}

defaultproperties
{
}
