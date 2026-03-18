class HxGUIMultiOptionListHeader extends GUIListHeader;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyLabel.bTransparent = false;
}

defaultproperties
{
    LabelJustification=TXTA_Center
    LabelStyleName="HxOptionList"
    StyleName="HxOptionList"
    FontScale=FNS_Medium
    Tag=-1
}
