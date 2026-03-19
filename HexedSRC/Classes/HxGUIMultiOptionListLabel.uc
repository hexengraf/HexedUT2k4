class HxGUIMultiOptionListLabel extends GUIListSpacer;

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
    GUILabel(MyComponent).Caption = NewValue;
}

function string GetComponentValue()
{
    return GUILabel(MyComponent).Caption;
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUILabel(NewComp) != None)
    {
        GUILabel(NewComp).TextAlign = TXTA_Right;
        GUILabel(NewComp).StyleName = "HxOptionList";
    }
}

defaultproperties
{
    CaptionWidth=0.01
    ComponentWidth=0.35
    bAutoSizeCaption=true
    LabelStyleName="TextLabel"
    StyleName="HxOptionList"
    FontScale=FNS_Medium
    bNeverFocus=true
    bTabStop=false
    bAcceptsInput=false
    OnCreateComponent=InternalOnCreateComponent
}
