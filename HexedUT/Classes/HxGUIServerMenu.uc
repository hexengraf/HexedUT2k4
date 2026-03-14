class HxGUIServerMenu extends HxGUIMenu;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    t_TabControl.WinHeight = 0.0575;
    Super.InitComponent(MyController, MyComponent);
}

defaultproperties
{
    WindowName="HexedUT - Server Options"
    WinWidth=0.725
    WinHeight=0.65
    WinLeft=0.1375
    WinTop=0.15
    Panels(0)=(PanelClass=class'HxGUIServerMenuGeneralPanel',Caption="General",Hint="General options")
    Panels(1)=(PanelClass=class'HxGUIServerMenuModifiersPanel',Caption="Modifiers",Hint="Game modifiers")
}
