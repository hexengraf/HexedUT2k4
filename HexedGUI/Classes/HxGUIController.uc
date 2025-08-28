class HxGUIController extends UT2K4GUIController;

defaultproperties
{
    Begin Object Class=HxFontMenu Name=GUIMenuFont
    End Object
    FontStack(0)=GUIMenuFont

    Begin Object Class=HxFontDefault Name=GUIDefaultFont
    End Object
    FontStack(1)=GUIDefaultFont

    Begin Object Class=HxFontLarge Name=GUILargeFont
    End Object
    FontStack(2)=GUILargeFont

    Begin Object Class=HxFontHeader Name=GUIHeaderFont
    End Object
    FontStack(3)=GUIHeaderFont

    Begin Object Class=HxFontSmall Name=GUISmallFont
    End Object
    FontStack(4)=GUISmallFont

    Begin Object Class=HxFontMidGame Name=GUIMidGameFont
    End Object
    FontStack(5)=GUIMidGameFont

    Begin Object Class=HxFontSmallHeader Name=GUISmallHeaderFont
    End Object
    FontStack(6)=GUISmallHeaderFont

    Begin Object Class=HxFontServerList Name=GUIServerListFont
    End Object
    FontStack(7)=GUIServerListFont

    Begin Object Class=HxFontIRC Name=GUIIRCFont
    End Object
	FontStack(8)=GUIIRCFont

    Begin Object Class=HxFontMainMenu Name=GUIMainMenuFont
    End Object
	FontStack(9)=GUIMainMenuFont

	Begin Object Class=HxFontMedium Name=GUIMediumMenuFont
	End Object
	FontStack(10)=GUIMediumMenuFont

	FONT_NUM=11

	MainMenuOptions(6)="HexedGUI.HxQuitPage"
}
