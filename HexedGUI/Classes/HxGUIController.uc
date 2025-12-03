class HxGUIController extends UT2K4GUIController;

var config bool bSmallCursor;

event InitializeController()
{
    Super.InitializeController();

    if (bSmallCursor)
    {
        MouseCursors[0] = material'HxPointer';
    }
    class'UT2K4SettingsPage'.default.PanelClass[2] = "HexedGUI.HxPlayerSettings";
    Master.AddInteraction("HexedHUD.HxHUDManager", ViewportOwner);
}

defaultproperties
{
    Begin Object Class=HxFontMenu Name=GUIMenuFont
    End Object

    Begin Object Class=HxFontDefault Name=GUIDefaultFont
    End Object

    Begin Object Class=HxFontLarge Name=GUILargeFont
    End Object

    Begin Object Class=HxFontHeader Name=GUIHeaderFont
    End Object

    Begin Object Class=HxFontSmall Name=GUISmallFont
    End Object

    Begin Object Class=HxFontMidGame Name=GUIMidGameFont
    End Object

    Begin Object Class=HxFontSmallHeader Name=GUISmallHeaderFont
    End Object

    Begin Object Class=HxFontServerList Name=GUIServerListFont
    End Object

    Begin Object Class=HxFontIRC Name=GUIIRCFont
    End Object

    Begin Object Class=HxFontMainMenu Name=GUIMainMenuFont
    End Object

    Begin Object Class=HxFontMedium Name=GUIMediumMenuFont
    End Object

    bSmallCursor=false
    FONT_NUM=11
    FontStack(0)=GUIMenuFont
    FontStack(1)=GUIDefaultFont
    FontStack(2)=GUILargeFont
    FontStack(3)=GUIHeaderFont
    FontStack(4)=GUISmallFont
    FontStack(5)=GUIMidGameFont
    FontStack(6)=GUISmallHeaderFont
    FontStack(7)=GUIServerListFont
    FontStack(8)=GUIIRCFont
    FontStack(9)=GUIMainMenuFont
    FontStack(10)=GUIMediumMenuFont
    MainMenuOptions(6)="HexedGUI.HxQuitPage"
}
