class HxGUIFirstRunNotification extends HxGUIFloatingWindow;

var automated GUILabel l_Introduction;
var automated GUILabel l_Mutators;
var automated GUILabel l_Instructions;
var automated GUIButton b_Close;

var const localized string ExecuteText;
var const localized string PressText;

var HxClientManager ClientManager;
var private const string ProjectName;
var private const string MutateCommand;
var private const Color HighlightColor;
var private string Version;
var private byte Keybind;

event HandleParameters(string Param1, string Param2)
{
    local string Highlight;
    local string Restore;

    class'HxConfig'.static.ExtractVersion(Class, Version);
    Highlight = MakeColorCode(HighlightColor);
    Restore = MakeColorCode(l_Instructions.Style.FontColors[0]);
    ReplaceText(l_Introduction.Caption, "%", Highlight$ProjectName$Version$Restore);
    if (Param2 != "")
    {
        Keybind = byte(Param1);
        ReplaceText(l_Instructions.Caption, "%", PressText@Highlight$Param2$Restore);
    }
    else
    {
        ReplaceText(l_Instructions.Caption, "%", ExecuteText@Highlight$MutateCommand$Restore);
    }
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    if (Key == Keybind && EInputAction(State) == IST_Release)
    {
    	Controller.CloseMenu(False);
        ClientManager.OpenConfigurationMenu();
        return true;
    }
    return false;
}

defaultproperties
{
    Begin Object Class=GUILabel Name=Introduction
        Caption="This is your first time using %!"
        WinLeft=0.025
        WinTop=0.185
        WinWidth=0.95
        StandardHeight=0.0275
        bStandardized=true
        StyleName="HxTextLabel"
        bRequiresStyle=true
        TextAlign=TXTA_Center
        bBoundToParent=true
        bScaleToParent=true
    End Object
    l_Introduction=Introduction

    Begin Object Class=GUILabel Name=Preamble
        Caption="One or more of our mutators is active."
        WinLeft=0.025
        WinTop=0.346765
        WinWidth=0.95
        StandardHeight=0.0275
        bStandardized=true
        StyleName="HxTextLabel"
        bRequiresStyle=true
        TextAlign=TXTA_Center
        bBoundToParent=true
        bScaleToParent=true
    End Object
    l_Mutators=Preamble

    Begin Object Class=GUILabel Name=Instructions
        Caption="% to open the configuration menu."
        WinLeft=0.025
        WinTop=0.50853
        WinWidth=0.95
        StandardHeight=0.0275
        bStandardized=true
        StyleName="HxTextLabel"
        bRequiresStyle=true
        TextAlign=TXTA_Center
        bBoundToParent=true
        bScaleToParent=true
    End Object
    l_Instructions=Instructions

    Begin Object Class=GUIButton Name=CloseButton
        Caption="Close"
        WinLeft=0.375
        WinTop=0.725
        WinWidth=0.25
        StandardHeight=0.0325
        bStandardized=true
        StyleName="HxSquareButton"
        bNeverFocus=true
        bRepeatClick=true
        bBoundToParent=true
        bScaleToParent=true
        OnClick=XButtonClicked
    End Object
    b_Close=CloseButton

    WindowName="HexedMenu - First Run Notification"
    WinLeft=0.225
    WinTop=0.415
    WinWidth=0.55
    WinHeight=0.17
    ProjectName="HexedUT2k4 v"
    MutateCommand="mutate HexedMenu"
    HighlightColor=(R=255,G=210,B=0,A=255)
    ExecuteText="Execute"
    PressText="Press"
    OnKeyEvent=InternalOnKeyEvent
}
