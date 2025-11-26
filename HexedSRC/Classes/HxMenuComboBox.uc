class HxMenuComboBox extends HxMenuOption;

var bool bReadOnly;
var bool bAlwaysNotify;
var localized array<string> DisplayNames;
var GUIComboBox ComboBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.InitComponent(MyController, MyOwner);
    ComboBox = GUIComboBox(MyComponent);
    ComboBox.Edit.bAlwaysNotify = bAlwaysNotify;
    ComboBox.ReadOnly(bReadOnly);

    for (i = 0; i < DisplayNames.Length; ++i)
    {
        ComboBox.AddItem(DisplayNames[i]);
    }
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
    if (bNoChange)
    {
        bIgnoreChange = True;
    }
    ComboBox.SetIndex(int(NewValue));
    bIgnoreChange = False;
}

function string GetComponentValue()
{
    return string(ComboBox.GetIndex());
}

function AddItem(string Item, optional object Extra, optional string Str)
{
    DisplayNames[DisplayNames.Length] = Item;
    ComboBox.AddItem(Item, Extra, Str);
}

function RemoveItem(int Item, optional int Count)
{
    DisplayNames.Remove(Item, Count);
    ComboBox.RemoveItem(Item, Count);
}

function bool FocusFirst(GUIComponent Sender)
{
    local bool bResult;

    bResult = Super.FocusFirst(Sender);
    if (bResult && ComboBox != None)
    {
        ComboBox.HideListBox();
    }
    return bResult;
}

defaultproperties
{
    ComponentClassName="XInterface.GUIComboBox"
    ComponentWidth=0.70
    bAlwaysNotify=false
    bReadOnly=true
}
