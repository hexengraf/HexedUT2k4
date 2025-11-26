class HxMenuFloatEdit extends HxMenuOption;

var float MinValue;
var float MaxValue;
var float Step;
var GUIFloatEdit NumericEdit;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    NumericEdit = GUIFloatEdit(MyComponent);
    NumericEdit.MinValue = MinValue;
    NumericEdit.MaxValue = MaxValue;
    NumericEdit.Step = Step;
    NumericEdit.CalcMaxLen();
    NumericEdit.SetReadOnly(bValueReadOnly);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
    if (bNoChange)
    {
        bIgnoreChange = true;
    }
    NumericEdit.SetValue(float(NewValue));
    bIgnoreChange = false;
}

function string GetComponentValue()
{
    return NumericEdit.Value;
}

defaultproperties
{
    ComponentClassName="XInterface.GUIFloatEdit"
    MinValue=0.0
    MaxValue=1.0
    Step=0.01
}
