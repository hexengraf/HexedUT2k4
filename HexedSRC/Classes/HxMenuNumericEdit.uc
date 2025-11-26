class HxMenuNumericEdit extends HxMenuOption;

var int MinValue;
var int MaxValue;
var int Step;
var GUINumericEdit NumericEdit;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    NumericEdit = GUINumericEdit(MyComponent);
    NumericEdit.MinValue = MinValue;
    NumericEdit.MaxValue = MaxValue;
    NumericEdit.Step = Step;
    NumericEdit.CalcMaxLen();
    NumericEdit.OnChange = InternalOnChange;
    NumericEdit.SetReadOnly(bValueReadOnly);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
    if (bNoChange)
    {
        bIgnoreChange = true;
    }
    NumericEdit.SetValue(int(NewValue));
    bIgnoreChange = false;
}

function string GetComponentValue()
{
    return NumericEdit.Value;
}

defaultproperties
{
    ComponentClassName="XInterface.GUINumericEdit"
    Step=1
    MinValue=-9999
    MaxValue=9999
}
