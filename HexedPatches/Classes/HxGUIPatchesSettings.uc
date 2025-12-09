class HxGUIPatchesSettings extends Settings_Tabs;

var HxGUIController GUIController;
var HxHUDController HUDController;
var HxOPTController OPTController;

var automated GUISectionBackground i_BG1;
var automated GUISectionBackground i_BG2;
var automated GUISectionBackground i_BG3;
var automated moCheckBox ch_SmallCursor;
var automated moCheckBox ch_FixedMouseSize;
var automated moCheckBox ch_ScaleWithY;
var automated moNumericEdit	nu_OverrideFontSize;
var automated moNumericEdit	nu_FOV43;
var automated moCheckBox ch_ReplaceHUDs;
var automated moCheckBox ch_ScaleWeapons;
var automated moCheckBox ch_SPShowTimer;
var automated moCheckBox ch_SPFollowHUDColor;
var automated moCheckBox ch_SPPulsingDigits;
var automated moFloatEdit fl_SPPosX;
var automated moFloatEdit fl_SPPosY;

var localized string PanelHint;
var bool bSmallCursor;
var bool bFixedMouseSize;
var bool bScaleWithY;
var int OverrideFontSize;
var int FOV43;
var bool bReplaceHUDs;
var bool bScaleWeapons;
var bool bSPShowTimer;
var bool bSPFollowHUDColor;
var bool bSPPulsingDigits;
var float SPPosX;
var float SPPosY;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    PopulateHexedControllers(HxGUIController(MyController));
    Super.InitComponent(MyController, MyOwner);

    i_BG1.ManageComponent(ch_SmallCursor);
    i_BG1.ManageComponent(ch_FixedMouseSize);
    i_BG1.ManageComponent(ch_ScaleWithY);
    i_BG1.ManageComponent(nu_OverrideFontSize);
    i_BG1.ManageComponent(nu_FOV43);

    i_BG2.ManageComponent(ch_ReplaceHUDs);
    i_BG2.ManageComponent(ch_ScaleWeapons);

    i_BG3.ManageComponent(ch_SPShowTimer);
    i_BG3.ManageComponent(ch_SPFollowHUDColor);
    i_BG3.ManageComponent(ch_SPPulsingDigits);
    i_BG3.ManageComponent(fl_SPPosX);
    i_BG3.ManageComponent(fl_SPPosY);
}

function PopulateHexedControllers(HxGUIController MyController)
{
    GUIController = MyController;
    HUDController = MyController.HUDController;
    OPTController = MyController.OPTController;
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
        case ch_ScaleWithY:
            bScaleWithY = class'HxGUIFont'.default.bScaleWithY;
            ch_ScaleWithY.SetComponentValue(bScaleWithY, true);
            break;
        case nu_OverrideFontSize:
            OverrideFontSize = class'HxGUIFont'.default.OverrideFontSize;
            nu_OverrideFontSize.SetComponentValue(OverrideFontSize, true);
            break;
        case nu_FOV43:
            FOV43 =	class'HxAspectRatio'.static.ScaleFOV(
                PlayerOwner().DefaultFOV, GUIController.GetCurrentAspectRatio(), 4/3);
            nu_FOV43.SetComponentValue(FOV43, true);
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
        case ch_SPShowTimer:
            bSPShowTimer = class'HxHUDSpawnProtectionTimer'.default.bShowTimer;
            ch_SPShowTimer.SetComponentValue(bSPShowTimer, true);
            break;
        case ch_SPFollowHUDColor:
            bSPFollowHUDColor = class'HxHUDSpawnProtectionTimer'.default.bFollowHUDColor;
            ch_SPFollowHUDColor.SetComponentValue(bSPFollowHUDColor, true);
            break;
        case ch_SPPulsingDigits:
            bSPPulsingDigits = class'HxHUDSpawnProtectionTimer'.default.bPulsingDigits;
            ch_SPPulsingDigits.SetComponentValue(bSPPulsingDigits, true);
            break;
        case fl_SPPosX:
            SPPosX = class'HxHUDSpawnProtectionTimer'.default.PosX;
            fl_SPPosX.SetComponentValue(SPPosX, true);
            break;
        case fl_SPPosY:
            SPPosY = class'HxHUDSpawnProtectionTimer'.default.PosY;
            fl_SPPosY.SetComponentValue(SPPosY, true);
            break;
    }
}

function SaveSettings()
{
    local bool bSave;

    Super.SaveSettings();

    if (GUIController.bSmallCursor != bSmallCursor)
    {
        bSmallCursor = GUIController.bSmallCursor;
        bSave = true;
    }
    if (GUIController.bFixedMouseSize != bFixedMouseSize)
    {
        bFixedMouseSize = GUIController.bFixedMouseSize;
        bSave = true;
    }
    if (bSave)
    {
        bSave = false;
        GUIController.SaveConfig();
    }
    if (class'HxGUIFont'.default.bScaleWithY != bScaleWithY)
    {
        bScaleWithY = class'HxGUIFont'.default.bScaleWithY;
        bSave = true;
    }
    if (class'HxGUIFont'.default.OverrideFontSize != OverrideFontSize)
    {
        OverrideFontSize = class'HxGUIFont'.default.OverrideFontSize;
        bSave = true;
    }
    if (bSave)
    {
        bSave = false;
        class'HxGUIFont'.static.StaticSaveConfig();
    }
    if (FOV43 != nu_FOV43.GetValue())
    {
        FOV43 = nu_FOV43.GetValue();
        PlayerOwner().FOV(
            class'HxAspectRatio'.static.GetScaledFOV(FOV43, GUIController.GetCurrentAspectRatio()));
    }
    if (HUDController.bReplaceHUDs != bReplaceHUDs)
    {
        bReplaceHUDs = HUDController.bReplaceHUDs;
        bSave = true;
    }
    if (HUDController.bScaleWeapons != bScaleWeapons)
    {
        bScaleWeapons = HUDController.bScaleWeapons;
        bSave = true;
    }
    if (bSave)
    {
        bSave = false;
        HUDController.SaveConfig();
    }
    if (class'HxHUDSpawnProtectionTimer'.default.bShowTimer != bSPShowTimer)
    {
        bSPShowTimer = class'HxHUDSpawnProtectionTimer'.default.bShowTimer;
        bSave = true;
    }
    if (class'HxHUDSpawnProtectionTimer'.default.bFollowHUDColor != bSPFollowHUDColor)
    {
        bSPFollowHUDColor = class'HxHUDSpawnProtectionTimer'.default.bFollowHUDColor;
        bSave = true;
    }
    if (class'HxHUDSpawnProtectionTimer'.default.bPulsingDigits != bSPPulsingDigits)
    {
        bSPPulsingDigits = class'HxHUDSpawnProtectionTimer'.default.bPulsingDigits;
        bSave = true;
    }
    if (class'HxHUDSpawnProtectionTimer'.default.PosX != SPPosX)
    {
        SPPosX = class'HxHUDSpawnProtectionTimer'.default.PosX;
        bSave = true;
    }
    if (class'HxHUDSpawnProtectionTimer'.default.PosY != SPPosY)
    {
        SPPosY = class'HxHUDSpawnProtectionTimer'.default.PosY;
        bSave = true;
    }
    if (bSave)
    {
        bSave = false;
        class'HxHUDSpawnProtectionTimer'.static.StaticSaveConfig();
    }
}

function ResetClicked()
{
    local int i;

    Super.ResetClicked();

    class'HxGUIController'.static.ResetConfig("bSmallCursor");
    class'HxGUIController'.static.ResetConfig("bFixedMouseSize");
    class'HxGUIFont'.static.ResetConfig("bScaleWithY");
    class'HxGUIFont'.static.ResetConfig("OverrideFontSize");
    class'HxHUDController'.static.ResetConfig("bReplaceHUDs");
    class'HxHUDController'.static.ResetConfig("bScaleWeapons");
    class'HxHUDSpawnProtectionTimer'.static.ResetConfig("bShowTimer");
    class'HxHUDSpawnProtectionTimer'.static.ResetConfig("bFollowHUDColor");
    class'HxHUDSpawnProtectionTimer'.static.ResetConfig("bPulsingDigits");
    class'HxHUDSpawnProtectionTimer'.static.ResetConfig("PosX");
    class'HxHUDSpawnProtectionTimer'.static.ResetConfig("PosY");

    GUIController.SetSmallCursor(class'HxGUIController'.default.bSmallCursor);
    GUIController.bFixedMouseSize = class'HxGUIController'.default.bFixedMouseSize;
    HUDController.SetReplaceHUDs(class'HxHUDController'.default.bReplaceHUDs);
    HUDController.SetScaleWeapons(class'HxHUDController'.default.bScaleWeapons);
    class'HxHUDSpawnProtectionTimer'.static.SetShowTimer(
        class'HxHUDSpawnProtectionTimer'.default.bShowTimer);
    class'HxHUDSpawnProtectionTimer'.static.SetFollowHUDColor(
        class'HxHUDSpawnProtectionTimer'.default.bFollowHUDColor);
    class'HxHUDSpawnProtectionTimer'.static.SetPulsingDigits(
        class'HxHUDSpawnProtectionTimer'.default.bPulsingDigits);
    class'HxHUDSpawnProtectionTimer'.static.SetPosX(
        class'HxHUDSpawnProtectionTimer'.default.PosX);
    class'HxHUDSpawnProtectionTimer'.static.SetPosY(
        class'HxHUDSpawnProtectionTimer'.default.PosY);
    UpdateHUDSection();

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
            GUIController.SetSmallCursor(ch_SmallCursor.IsChecked());
            break;
        case ch_FixedMouseSize:
            GUIController.bFixedMouseSize = ch_FixedMouseSize.IsChecked();
            break;
        case ch_ScaleWithY:
            class'HxGUIFont'.default.bScaleWithY = ch_ScaleWithY.IsChecked();
            break;
        case nu_FOV43:
            break;
        case nu_OverrideFontSize:
            class'HxGUIFont'.default.OverrideFontSize = nu_OverrideFontSize.GetValue();
            break;
        case ch_ReplaceHUDs:
            HUDController.SetReplaceHUDs(ch_ReplaceHUDs.IsChecked());
            UpdateHUDSection();
            break;
        case ch_ScaleWeapons:
            HUDController.SetScaleWeapons(ch_ScaleWeapons.IsChecked());
            break;
        case ch_SPShowTimer:
            class'HxHUDSpawnProtectionTimer'.static.SetShowTimer(ch_SPShowTimer.IsChecked());
            break;
        case ch_SPFollowHUDColor:
            class'HxHUDSpawnProtectionTimer'.static.SetFollowHUDColor(
                ch_SPFollowHUDColor.IsChecked());
            break;
        case ch_SPPulsingDigits:
            class'HxHUDSpawnProtectionTimer'.static.SetPulsingDigits(
                ch_SPPulsingDigits.IsChecked());
            break;
        case fl_SPPosX:
            class'HxHUDSpawnProtectionTimer'.static.SetPosX(fl_SPPosX.GetValue());
            break;
        case fl_SPPosY:
            class'HxHUDSpawnProtectionTimer'.static.SetPosY(fl_SPPosY.GetValue());
            break;
    }
}

function UpdateHUDSection()
{
    if (HUDController.CheckConflictingPackages())
    {
        ch_ReplaceHUDs.DisableMe();
        ch_ScaleWeapons.DisableMe();
        ch_SPShowTimer.DisableMe();
        ch_SPFollowHUDColor.DisableMe();
        ch_SPPulsingDigits.DisableMe();
        fl_SPPosX.DisableMe();
        fl_SPPosY.DisableMe();
    }
    else
    {
        ch_ReplaceHUDs.EnableMe();
    }
    if (HUDController.bReplaceHUDs)
    {
        ch_ScaleWeapons.EnableMe();
        ch_SPShowTimer.EnableMe();
        ch_SPFollowHUDColor.EnableMe();
        ch_SPPulsingDigits.EnableMe();
        fl_SPPosX.EnableMe();
        fl_SPPosY.EnableMe();
    }
    else
    {
        ch_ScaleWeapons.DisableMe();
        ch_SPShowTimer.DisableMe();
        ch_SPFollowHUDColor.DisableMe();
        ch_SPPulsingDigits.DisableMe();
        fl_SPPosX.DisableMe();
        fl_SPPosY.DisableMe();
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
    Begin Object class=GUISectionBackground Name=TemplateDisplaySection
        Caption="Display"
        WinWidth=0.448633
        WinHeight=0.308985
        // WinHeight=0.901485
        WinLeft=0.031797
        WinTop=0.057604
        RenderWeight=0.001
    End Object
    i_BG1=TemplateDisplaySection

    Begin Object class=GUISectionBackground Name=TemplateHUDSection
        Caption="HUD"
        WinWidth=0.448633
        WinHeight=0.199610
        WinLeft=0.031797
        WinTop=0.376589
        RenderWeight=0.001
    End Object
    i_BG2=TemplateHUDSection

    Begin Object class=GUISectionBackground Name=TemplateSPSection
        Caption="Spawn Protection"
        WinWidth=0.448633
        WinHeight=0.308985
        WinLeft=0.031797
        WinTop=0.586199
        RenderWeight=0.001
    End Object
    i_BG3=TemplateSPSection

    Begin Object class=moCheckBox Name=TemplateSmallCursor
        Caption="Small cursor"
        Hint="Use a custom cursor to compensate the stupid scaling. Recommended for high resolutions."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.955
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=0
    End Object
    ch_SmallCursor=TemplateSmallCursor

    Begin Object class=moCheckBox Name=TemplateFixedMouseSize
        Caption="Fixed cursor size"
        Hint="Stop changing cursor size when it hovers a menu option."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.955
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=1
    End Object
    ch_FixedMouseSize=TemplateFixedMouseSize

    Begin Object class=moCheckBox Name=TemplateScaleWithY
        Caption="Scale fonts with screen height"
        Hint="Scale fonts with the screen height instead of the screen width. Restart required."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.955
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=2
    End Object
    ch_ScaleWithY=TemplateScaleWithY

    Begin Object class=moNumericEdit Name=TemplateOverrideFontSize
        Caption="Override font scale"
        Hint="Override font scale (between 0 and 6). Use -1 for default scale. Restart required."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        MinValue=-1
        MaxValue=6
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.725
        bHeightFromComponent=false
        ComponentJustification=TXTA_Left
        TabOrder=3
    End Object
    nu_OverrideFontSize=TemplateOverrideFontSize

    Begin Object class=moNumericEdit Name=TemplateFOV43
        Caption="4:3 FOV"
        Hint="Desired 4:3 FOV value. This value will be internally scaled for the current aspect ratio."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        MinValue=80
        MaxValue=140
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.725
        bHeightFromComponent=false
        ComponentJustification=TXTA_Left
        TabOrder=3
    End Object
    nu_FOV43=TemplateFOV43

    Begin Object class=moCheckBox Name=TemplateReplaceHUDs
        Caption="Replace HUDs"
        Hint="Replace HUDs to fix widescreen scaling."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.955
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=4
    End Object
    ch_ReplaceHUDs=TemplateReplaceHUDs

    Begin Object class=moCheckBox Name=TemplateScaleWeapons
        Caption="Scale weapons"
        Hint="Scale FOV of displayed weapon models when using replaced HUDs."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.955
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=5
    End Object
    ch_ScaleWeapons=TemplateScaleWeapons

    Begin Object class=moCheckBox Name=TemplateSPShowTimer
        Caption="Show timer"
        Hint="Show timer indicating remaining duration while in spawn protection."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.955
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=6
    End Object
    ch_SPShowTimer=TemplateSPShowTimer

    Begin Object class=moCheckBox Name=TemplateSPFollowHUDColor
        Caption="Follow HUD's color"
        Hint="Use the same color as the HUD for the timer's icon."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.955
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=7
    End Object
    ch_SPFollowHUDColor=TemplateSPFollowHUDColor

    Begin Object class=moCheckBox Name=TemplateSPPulsingDigits
        Caption="Pulsing digits"
        Hint="Use pulsing digits for the time remaining."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.955
        bSquare=true
        ComponentJustification=TXTA_Left
        TabOrder=8
    End Object
    ch_SPPulsingDigits=TemplateSPPulsingDigits

    Begin Object class=moFloatEdit Name=TemplateSPPosX
        Caption="X position"
        Hint="Adjust timer's position in the X axis."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.725
        bHeightFromComponent=false
        ComponentJustification=TXTA_Left
        TabOrder=9
    End Object
    fl_SPPosX=TemplateSPPosX

    Begin Object class=moFloatEdit Name=TemplateSPPosY
        Caption="Y position"
        Hint="Adjust timer's position in the Y axis."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        bBoundToParent=true
        bScaleToParent=true
        CaptionWidth=0.725
        bHeightFromComponent=false
        ComponentJustification=TXTA_Left
        TabOrder=10
    End Object
    fl_SPPosY=TemplateSPPosY

    WinTop=0.15
    WinLeft=0
    WinWidth=1
    WinHeight=0.74
    bAcceptsInput=false

    PanelCaption="Patches"
    PanelHint="Customize patches..."
}
