class HxGUImoNumericEdit extends moNumericEdit;

#include Classes\Include\FixedGUIMenuOptionInitComponent.uci

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    FixedInitComponent(MyController, MyOwner);
    MyNumericEdit = GUINumericEdit(MyComponent);
    MyNumericEdit.MinValue = MinValue;
    MyNumericEdit.MaxValue = MaxValue;
    MyNumericEdit.Step = Step;
    MyNumericEdit.CalcMaxLen();
    MyNumericEdit.OnChange = InternalOnChange;
    MyNumericEdit.SetReadOnly(bValueReadOnly);
}

defaultproperties
{
}
