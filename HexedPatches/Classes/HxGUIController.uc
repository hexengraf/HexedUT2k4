class HxGUIController extends UT2K4GUIController;

#exec texture Import File=Textures\HxPointer.tga Name=HxPointer Mips=Off Alpha=1

var config bool bSmallCursor;

var HxHUDController HUDController;
var HxNETController NETController;

event InitializeController()
{
    Super.InitializeController();
    SetSmallCursor(bSmallCursor);
    UpdateSettingsPage();
    HUDController = HxHUDController(
        Master.AddInteraction("HexedPatches.HxHUDController", ViewportOwner));
    NETController = HxNETController(
        Master.AddInteraction("HexedPatches.HxNETController", ViewportOwner));
}

function UpdateSettingsPage()
{
    class'UT2K4SettingsPage'.default.PanelClass[0] = "HexedPatches.HxGUIDetailSettings";
    class'UT2K4SettingsPage'.default.PanelClass[2] = "HexedPatches.HxGUIPlayerSettings";
    class'UT2K4SettingsPage'.default.PanelClass[3] = "HexedPatches.HxGUIGameSettings";
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

function float GetCurrentAspectRatio()
{
    local string X;
    local string Y;

    Divide(GetCurrentRes(), "x", X, Y);
    return float(X) / float(Y);
}

defaultproperties
{
    Begin Object Class=HxGUIFontMenu Name=NewGUIMenuFont
    End Object

    Begin Object Class=HxGUIFontDefault Name=NewGUIDefaultFont
    End Object

    Begin Object Class=HxGUIFontLarge Name=NewGUILargeFont
    End Object

    Begin Object Class=HxGUIFontHeader Name=NewGUIHeaderFont
    End Object

    Begin Object Class=HxGUIFontSmall Name=NewGUISmallFont
    End Object

    Begin Object Class=HxGUIFontMidGame Name=NewGUIMidGameFont
    End Object

    Begin Object Class=HxGUIFontSmallHeader Name=NewGUISmallHeaderFont
    End Object

    Begin Object Class=HxGUIFontServerList Name=NewGUIServerListFont
    End Object

    Begin Object Class=HxGUIFontIRC Name=NewGUIIRCFont
    End Object

    Begin Object Class=HxGUIFontMainMenu Name=NewGUIMainMenuFont
    End Object

    Begin Object Class=HxGUIFontMedium Name=NewGUIMediumMenuFont
    End Object

    Begin Object Class=HxGUIFontSmaller Name=HxGUISmallerFont
    End Object

    bSmallCursor=true
    bFixedMouseSize=true
    FontStack(0)=NewGUIMenuFont
    FontStack(1)=NewGUIDefaultFont
    FontStack(2)=NewGUILargeFont
    FontStack(3)=NewGUIHeaderFont
    FontStack(4)=NewGUISmallFont
    FontStack(5)=NewGUIMidGameFont
    FontStack(6)=NewGUISmallHeaderFont
    FontStack(7)=NewGUIServerListFont
    FontStack(8)=NewGUIIRCFont
    FontStack(9)=NewGUIMainMenuFont
    FontStack(10)=NewGUIMediumMenuFont
    FontStack(11)=HxGUISmallerFont
    FONT_NUM=12
    DefaultStyleNames(60)="HexedPatches.HxSTYSmallList"
    DefaultStyleNames(61)="HexedPatches.HxSTYSmallListSelection"
    DefaultStyleNames(62)="HexedPatches.HxSTYSmallText"
    DefaultStyleNames(63)="HexedPatches.HxSTYScrollGrip"
    DefaultStyleNames(64)="HexedPatches.HxSTYScrollZone"
    DefaultStyleNames(65)="HexedPatches.HxSTYEditBox"
    DefaultStyleNames(66)="HexedPatches.HxSTYSmallLabel"
    DefaultStyleNames(67)="HexedPatches.HxSTYListHeader"
    DefaultStyleNames(68)="HexedPatches.HxSTYFlatButton"
    STYLE_NUM=69
    MainMenuOptions(6)="HexedPatches.HxGUIQuitPage"
    MapVotingMenu="HexedPatches.HxGUIVotingPage"
}
