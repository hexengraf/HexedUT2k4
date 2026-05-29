class HxGUIVertImageListBox extends GUIVertImageListBox;

var float ScrollbarWidth;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    HxGUIVertScrollBar(MyScrollBar).StandardWidth = ScrollbarWidth;
}

defaultproperties
{
    Begin Object Class=HxGUIVertScrollBar Name=HxScrollbar
        bScaleToParent=true
    End Object
    MyScrollBar=HxScrollbar

    ScrollbarWidth=0.016
}
