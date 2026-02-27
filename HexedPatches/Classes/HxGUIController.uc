class HxGUIController extends UT2K4GUIController;

#exec texture Import File=Textures\HxPointer.tga Name=HxPointer Mips=Off Alpha=1

var config bool bSmallCursor;

var HxHUDController HUDController;
var HxNETController NETController;
var bool bInitialized;
var bool bOldUnrealPatch;

event InitializeController()
{
    Super.InitializeController();
    class'HxGUIPatchesSettings'.static.AddToSettings();
    HUDController = HxHUDController(
        Master.AddInteraction("HexedPatches.HxHUDController", ViewportOwner));
    NETController = HxNETController(
        Master.AddInteraction("HexedPatches.HxNETController", ViewportOwner));
    MapVotingMenu = string(class'HxGUIVotingPage');
}

function UpdateSettingsPage()
{
    if (!bOldUnrealPatch)
    {
        class'UT2K4SettingsPage'.default.PanelClass[0] = "HexedPatches.HxGUIDetailSettings";
        class'UT2K4SettingsPage'.default.PanelClass[2] = "HexedPatches.HxGUIPlayerSettings";
        class'UT2K4SettingsPage'.default.PanelClass[3] = "HexedPatches.HxGUIGameSettings";
    }
}

function SetSmallCursor(bool bValue)
{
    bSmallCursor = !bOldUnrealPatch && bValue;
    if (bSmallCursor)
    {
        MouseCursors[0] = material'HxPointer';
    }
    else
    {
        MouseCursors[0] = default.MouseCursors[0];
    }
}

event NotifyLevelChange()
{
    if (!bInitialized && ViewportOwner.Actor != None)
    {
        bInitialized = true;
        bOldUnrealPatch = int(ViewportOwner.Actor.Level.EngineVersion) > 3369;
        SetSmallCursor(bSmallCursor);
        UpdateSettingsPage();
    }
    Super.NotifyLevelChange();
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

    Begin Object Class=HxGUIFontSmaller Name=NewGUIFontSmaller
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
    FontStack(11)=NewGUIFontSmaller
    FONT_NUM=12
    MainMenuOptions(6)="HexedPatches.HxGUIQuitPage"
}
