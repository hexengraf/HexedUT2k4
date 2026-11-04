class HxGUIComboBox extends GUIComboBox;

defaultproperties
{
    Begin Object class=GUIEditBox Name=BaseEditBox
        StyleName="HxEditBox"
        bNeverScale=true
        OnActivate=BaseEditBox.InternalActivate
        OnDeActivate=BaseEditBox.InternalDeactivate
        OnKeyType=BaseEditBox.InternalOnKeyType
        OnKeyEvent=BaseEditBox.InternalOnKeyEvent
    End Object
    Edit=BaseEditBox

    Begin Object class=GUIComboButton Name=BaseShowButton
        StyleName="HxButtonRight"
        RenderWeight=0.600000
        bNeverScale=true
        OnKeyEvent=BaseShowButton.InternalOnKeyEvent
    End Object
    MyShowListBtn=BaseShowButton

    Begin Object class=HxGUIListBox Name=BaseListBox
        OnCreateComponent=BaseListBox.InternalOnCreateComponent
        StyleName="HxComboList"
        SelectedStyleName="HxListSelection"
        OverflowStyleName="HxComboListLeft"
        ScrollZoneStyleName="HxComboListScrollZone"
        ScrollbarWidth=0.0172
        LeftPadding=0.005
        RenderWeight=0.700000
        bTabStop=false
        bVisible=false
        bNeverScale=true
    End Object
    MyListBox=BaseListBox
}
