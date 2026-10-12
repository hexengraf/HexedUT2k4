class HxGUImoFloatEdit extends moFloatEdit;

#include Classes\Include\FixedGUIMenuOptionInitComponent.uci

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    FixedInitComponent(MyController, MyOwner);
    MyNumericEdit = GUIFloatEdit(MyComponent);
    MyNumericEdit.MinValue = MinValue;
    MyNumericEdit.MaxValue = MaxValue;
    MyNumericEdit.Step = Step;
    MyNumericEdit.CalcMaxLen();
    MyNumericEdit.SetReadOnly(bValueReadOnly);
}

defaultproperties
{
}
