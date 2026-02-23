class HxGUIFontMainMenu extends HxGUIFont;

var bool bReverted;

// function Font GetFontScaled(int XRes)
// {
//     if (HxGUIController(Controller).bOldUnrealPatch && !bReverted)
//     {
//         // NormalXRes = 800;
//         // NormalYRes = 600;
//         // FontArrayNames[0] = "2K4Fonts.Impact32";
//         NormalXRes = 1920;
//         NormalYRes = 1080;
//         bReverted = true;
//     }
//     return Super.GetFontScaled(XRes);
// }

defaultproperties
{
    KeyName="UT2MainMenuFont"
    bScaled=true
    NormalXRes=1920
    HxNormalYRes=1080
    FallBackRes=512

    FontArrayNames(0)="HexedPatches.Impact52"
    FontArrayNames(1)="2K4Fonts.Verdana24"
}
