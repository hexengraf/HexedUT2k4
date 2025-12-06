class HxGUIController extends UT2K4GUIController;

#exec texture Import File=Textures\HxPointer.tga Name=HxPointer Mips=Off Alpha=1

var config bool bSmallCursor;

var HxHUDController HUDController;
var HxOPTController OPTController;

event InitializeController()
{
    Super.InitializeController();

    SetSmallCursor(bSmallCursor);
    UpdateSettingsPage();
    HUDController = HxHUDController(
        Master.AddInteraction("HexedPatches.HxHUDController", ViewportOwner));
    OPTController = HxOPTController(
        Master.AddInteraction("HexedPatches.HxOPTController", ViewportOwner));
}

function UpdateSettingsPage()
{
    class'UT2K4SettingsPage'.default.PanelClass[0] = "HexedPatches.HxGUIDetailSettings";
    class'UT2K4SettingsPage'.default.PanelClass[2] = "HexedPatches.HxGUIPlayerSettings";
    class'HxGUIPatchesSettings'.static.AddToSettings();
}

function SetSmallCursor(bool bValue)
{
    bSmallCursor = bValue;
    if (bSmallCursor)
    {
        MouseCursors[0] = material'HxPointer';
    }
    else
    {
        MouseCursors[0] = default.MouseCursors[0];
    }
}

defaultproperties
{
    Begin Object Class=HxGUIFontMenu Name=GUIMenuFont
    End Object

    Begin Object Class=HxGUIFontDefault Name=GUIDefaultFont
    End Object

    Begin Object Class=HxGUIFontLarge Name=GUILargeFont
    End Object

    Begin Object Class=HxGUIFontHeader Name=GUIHeaderFont
    End Object

    Begin Object Class=HxGUIFontSmall Name=GUISmallFont
    End Object

    Begin Object Class=HxGUIFontMidGame Name=GUIMidGameFont
    End Object

    Begin Object Class=HxGUIFontSmallHeader Name=GUISmallHeaderFont
    End Object

    Begin Object Class=HxGUIFontServerList Name=GUIServerListFont
    End Object

    Begin Object Class=HxGUIFontIRC Name=GUIIRCFont
    End Object

    Begin Object Class=HxGUIFontMainMenu Name=GUIMainMenuFont
    End Object

    Begin Object Class=HxGUIFontMedium Name=GUIMediumMenuFont
    End Object

    bSmallCursor=true
    bFixedMouseSize=true
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
    MainMenuOptions(6)="HexedPatches.HxGUIQuitPage"
}
