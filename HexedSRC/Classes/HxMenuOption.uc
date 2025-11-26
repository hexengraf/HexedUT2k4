class HxMenuOption extends GUIMenuOption;

var string PropertyName;
var object Target;

function SetEnable(bool bValue)
{
    if (bValue)
    {
        EnableMe();
    }
    else
    {
        DisableMe();
    }
}

function SetValueOn(Object Destination)
{
    Destination.SetPropertyText(PropertyName, GetComponentValue());
    Destination.SaveConfig();
}

function SetValueOnTarget()
{
    SetValueOn(Target);
}

function GetValueFrom(Object Source)
{
    SetComponentValue(Source.GetPropertyText(PropertyName));
}

function GetValueFromTarget()
{
    GetValueFrom(Target);
}

defaultproperties
{
    LabelJustification=TXTA_Left
    ComponentJustification=TXTA_Right
    ComponentWidth=0.25
    bAutoSizeCaption=true
    bBoundToParent=true
    bScaleToParent=true
}
