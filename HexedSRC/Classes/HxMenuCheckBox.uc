class HxMenuCheckBox extends HxMenuOption;

var string CheckStyleName;
var GUICheckBoxButton CheckBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local GUIStyles S;

    Super.InitComponent(MyController, MyOwner);
    CheckBox = GUICheckBoxButton(MyComponent);
    CheckBox.OnChange = ButtonChecked;
    CheckBox.OnClick = InternalClick;
    S = Controller.GetStyle(CheckStyleName, CheckBox.FontScale);
    if (S != None)
    {
        CheckBox.Graphic = S.Images[0];
    }
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
    if (bNoChange)
    {
        bIgnoreChange = true;
    }
    CheckBox.SetChecked(bool(NewValue));
    bIgnoreChange = false;
}

function string GetComponentValue()
{
    return string(CheckBox.bChecked);
}

function ButtonChecked(GUIComponent Sender)
{
    if (Sender == MyComponent)
    {
        InternalOnChange(Self);
    }
}

private function bool InternalClick(GUIComponent Sender)
{
    if (bValueReadOnly)
    {
        return true;
    }
    return CheckBox.InternalOnClick(Sender);
}

defaultproperties
{
    ComponentClassName="XInterface.GUICheckBoxButton"
    bSquare=true
    ComponentWidth=-1
    CaptionWidth=0.8
}
