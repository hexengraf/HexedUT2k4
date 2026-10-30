class HxGUImoEditBox extends moEditBox;

var string EditBoxStyleName;

#include Classes\Include\FixedGUIMenuOptionInitComponent.uci

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    FixedInitComponent(MyController, MyOwner);
    MyEditBox = GUIEditBox(MyComponent);
    ReadOnly(bReadOnly || bValueReadOnly);
    MaskText(bMaskText);
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (NewComp.IsA('GUIEditBox'))
    {
        NewComp.StyleName = EditBoxStyleName;
    }
    Super.InternalOnCreateComponent(NewComp, Sender);
}

defaultproperties
{
    LabelStyleName="HxTextLabel"
    EditBoxStyleName="HxEditBox"
}
