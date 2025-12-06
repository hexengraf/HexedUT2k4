class HxGUIPatchesSettings extends Settings_Tabs;

var HxGUIController GUIController;
var HxHUDController HUDController;
var HxOPTController OPTController;

var automated GUISectionBackground i_BG1;
var automated GUISectionBackground i_BG2;
var automated moCheckBox ch_SmallCursor;
var automated moCheckBox ch_FixedMouseSize;
var automated moCheckBox ch_ReplaceHUDs;
var automated moCheckBox ch_ScaleWeapons;

var localized string PanelHint;
var bool bSmallCursor;
var bool bFixedMouseSize;
var bool bReplaceHUDs;
var bool bScaleWeapons;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    PopulateHexedControllers(HxGUIController(MyController));
    Super.InitComponent(MyController, MyOwner);

    i_BG1.ManageComponent(ch_SmallCursor);
    i_BG1.ManageComponent(ch_FixedMouseSize);

    i_BG2.ManageComponent(ch_ReplaceHUDs);
    i_BG2.ManageComponent(ch_ScaleWeapons);
}

function PopulateHexedControllers(HxGUIController MyController)
{
    GUIController = MyController;
    HUDController = MyController.HUDController;
    OPTController = MyController.OPTController;
}

event ResolutionChanged(int NewX, int NewY)
{
    Super.ResolutionChanged(NewX, NewY);
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    switch (Sender)
    {
        case ch_SmallCursor:
            bSmallCursor = GUIController.bSmallCursor;
            ch_SmallCursor.SetComponentValue(bSmallCursor, true);
            break;
        case ch_FixedMouseSize:
            bFixedMouseSize = GUIController.bFixedMouseSize;
            ch_FixedMouseSize.SetComponentValue(bFixedMouseSize, true);
            break;
        case ch_ReplaceHUDs:
            bReplaceHUDs = HUDController.bReplaceHUDs;
            ch_ReplaceHUDs.SetComponentValue(bReplaceHUDs, true);
            UpdateHUDSection();
            break;
        case ch_ScaleWeapons:
            bScaleWeapons = HUDController.default.bScaleWeapons;
            ch_ScaleWeapons.SetComponentValue(bScaleWeapons, true);
            break;
    }
}

function SaveSettings()
{
    local bool bSave;

    Super.SaveSettings();

    if (GUIController.bSmallCursor != bSmallCursor)
    {
        GUIController.bSmallCursor = bSmallCursor;
        GUIController.UpdateCursor();
        bSave = true;
    }
    if (GUIController.bFixedMouseSize != bFixedMouseSize)
    {
        GUIController.bFixedMouseSize = bFixedMouseSize;
        bSave = true;
    }
    if (bSave)
    {
        bSave = false;
        GUIController.SaveConfig();
    }
    if (HUDController.bReplaceHUDs != bReplaceHUDs)
    {
        HUDController.SetReplaceHUDs(bReplaceHUDs);
        bSave = true;
    }
    if (HUDController.bScaleWeapons != bScaleWeapons)
    {
        HUDController.SetScaleWeapons(bScaleWeapons);
        bSave = true;
    }
    if (bSave)
    {
        bSave = false;
        HUDController.SaveConfig();
    }
}

function ResetClicked()
{
    local int i;

    Super.ResetClicked();

    class'HxGUIController'.static.ResetConfig("bSmallCursor");
    class'HxGUIController'.static.ResetConfig("bFixedMouseSize");
    class'HxHUDController'.static.ResetConfig("bReplaceHUDs");
    class'HxHUDController'.static.ResetConfig("bScaleWeapons");

    for (i = 0; i < Components.Length; ++i)
    {
        Components[i].LoadINI();
    }
}

function InternalOnChange(GUIComponent Sender)
{
    Super.InternalOnChange(Sender);

    switch (Sender)
    {
        case ch_SmallCursor:
            bSmallCursor = ch_SmallCursor.IsChecked();
            break;
        case ch_FixedMouseSize:
            bFixedMouseSize = ch_FixedMouseSize.IsChecked();
            break;
        case ch_ReplaceHUDs:
            bReplaceHUDs = ch_ReplaceHUDs.IsChecked();
            UpdateHUDSection();
            break;
        case ch_ScaleWeapons:
            bScaleWeapons = ch_ScaleWeapons.IsChecked();
            break;
    }
}

function UpdateHUDSection()
{
    if (HUDController.CheckConflictingPackages())
    {
        ch_ReplaceHUDs.DisableMe();
        ch_ScaleWeapons.DisableMe();
    }
    else
    {
        ch_ReplaceHUDs.EnableMe();
    }
    if (bReplaceHUDs)
    {
        ch_ScaleWeapons.EnableMe();
    }
    else
    {
        ch_ScaleWeapons.DisableMe();
    }
}

static function AddToSettings()
{
    local int Index;

    Index = class'UT2K4SettingsPage'.default.PanelClass.Length;
    class'UT2K4SettingsPage'.default.PanelCaption[Index] = default.PanelCaption;
    class'UT2K4SettingsPage'.default.PanelClass[Index] = string(default.Class);
    class'UT2K4SettingsPage'.default.PanelHint[Index] = default.PanelHint;
}

defaultproperties
{
    Begin Object class=GUISectionBackground Name=CursorSection
        Caption="Cursor"
        WinWidth=0.448633
        WinHeight=0.199610
        // WinHeight=0.901485
        WinLeft=0.031797
        WinTop=0.057604
        RenderWeight=0.001
    End Object
    i_BG1=CursorSection

    Begin Object class=GUISectionBackground Name=HUDSection
        Caption="HUD"
        WinWidth=0.448633
        WinHeight=0.199610
        WinLeft=0.031797
        WinTop=0.267214
        RenderWeight=0.001
    End Object
    i_BG2=HUDSection

    Begin Object class=moCheckBox Name=SmallCursor
        Caption="Small cursor"
        Hint="Use a custom cursor to compensate the stupid scaling. Recommended for high resolutions."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.9
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=0
    End Object
    ch_SmallCursor=SmallCursor

    Begin Object class=moCheckBox Name=FixedMouseSize
        Caption="Fixed cursor size"
        Hint="Stop changing cursor size when it hovers a menu option."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.9
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=1
    End Object
    ch_FixedMouseSize=FixedMouseSize

    Begin Object class=moCheckBox Name=ReplaceHUDs
        Caption="Replace HUDs"
        Hint="Replace HUDs to fix widescreen scaling."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.9
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=2
    End Object
    ch_ReplaceHUDs=ReplaceHUDs

    Begin Object class=moCheckBox Name=ScaleWeapons
        Caption="Scale weapons"
        Hint="Scale FOV of displayed weapon models when using replaced HUDs."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.9
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=3
    End Object
    ch_ScaleWeapons=ScaleWeapons

     WinTop=0.15
    WinLeft=0
    WinWidth=1
    WinHeight=0.74
    bAcceptsInput=false

    PanelCaption="Patches"
    PanelHint="Customize patches..."
}
