class HxGUIPatchesSettings extends Settings_Tabs;

var automated GUISectionBackground i_BG1;
var automated GUISectionBackground i_BG2;
var automated GUISectionBackground i_BG3;
var automated moCheckBox ch_SmallCursor;
var automated moCheckBox ch_FixedMouseSize;
var automated moCheckBox ch_ScaleWithY;
var automated moNumericEdit nu_OverrideFontSize;
var automated moNumericEdit nu_FOV43;
var automated moCheckBox ch_ReplaceHUDs;
var automated moCheckBox ch_ScaleWeapons;
var automated moCheckBox ch_SPShowTimer;
var automated moCheckBox ch_SPFollowHUDColor;
var automated moCheckBox ch_SPPulsingDigits;
var automated moFloatEdit fl_SPPosX;
var automated moFloatEdit fl_SPPosY;
var automated moNumericEdit nu_CustomNetSpeed;
var automated moComboBox co_MasterServer;

var localized string PanelHint;

var private HxGUIController GUIController;
var private HxHUDController HUDController;
var private HxNETController NETController;

var private bool bSmallCursor;
var private bool bFixedMouseSize;
var private bool bScaleWithY;
var private int OverrideFontSize;
var private int FOV43;
var private bool bReplaceHUDs;
var private bool bScaleWeapons;
var private bool bSPShowTimer;
var private bool bSPFollowHUDColor;
var private bool bSPPulsingDigits;
var private float SPPosX;
var private float SPPosY;
var private int CustomNetSpeed;
var private HxNETController.EHxMasterServer MasterServer;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    PopulateHexedControllers(HxGUIController(MyController));
    Super.InitComponent(MyController, MyOwner);

    i_BG1.ManageComponent(ch_SmallCursor);
    i_BG1.ManageComponent(ch_FixedMouseSize);
    i_BG1.ManageComponent(ch_ScaleWithY);
    i_BG1.ManageComponent(nu_OverrideFontSize);
    i_BG1.ManageComponent(nu_FOV43);

    i_BG2.ManageComponent(ch_ReplaceHUDs);
    i_BG2.ManageComponent(ch_ScaleWeapons);
    i_BG2.ManageComponent(ch_SPShowTimer);
    i_BG2.ManageComponent(ch_SPFollowHUDColor);
    i_BG2.ManageComponent(ch_SPPulsingDigits);
    i_BG2.ManageComponent(fl_SPPosX);
    i_BG2.ManageComponent(fl_SPPosY);

    i_BG3.ManageComponent(nu_CustomNetSpeed);
    i_BG3.ManageComponent(co_MasterServer);

    for (i = 0; i < 2; ++i)
    {
        co_MasterServer.AddItem(Mid(GetEnum(enum'EHxMasterServer', i), 17));
    }
    if (GUIController.bOldUnrealPatch)
    {
        ch_SmallCursor.DisableMe();
        co_MasterServer.DisableMe();
    }
}

function PopulateHexedControllers(HxGUIController MyController)
{
    GUIController = MyController;
    HUDController = MyController.HUDController;
    NETController = MyController.NETController;
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
            FOV43 = class'HxAspectRatio'.static.ScaleFOV(
                PlayerOwner().DefaultFOV, GUIController.GetCurrentAspectRatio(), 4/3);
            nu_FOV43.SetComponentValue(FOV43, true);
            break;
        case ch_ReplaceHUDs:
            bReplaceHUDs = class'HxHUDController'.default.bReplaceHUDs;
            ch_ReplaceHUDs.SetComponentValue(bReplaceHUDs, true);
            UpdateHUDSection();
            break;
        case ch_ScaleWeapons:
            bScaleWeapons = class'HxHUDController'.default.bScaleWeapons;
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
        case nu_CustomNetSpeed:
            CustomNetSpeed = class'HxNETController'.default.CustomNetSpeed;
            nu_CustomNetSpeed.SetComponentValue(CustomNetSpeed, true);
            break;
        case co_MasterServer:
            MasterServer = class'HxNETController'.default.MasterServer;
            co_MasterServer.SilentSetIndex(MasterServer);
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
        class'HxGUIFont'.default.bScaleWithY = bScaleWithY;
        bSave = true;
    }
    if (class'HxGUIFont'.default.OverrideFontSize != OverrideFontSize)
    {
        class'HxGUIFont'.default.OverrideFontSize = OverrideFontSize;
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
    if (class'HxHUDSpawnProtectionTimer'.default.bShowTimer != bSPShowTimer)
    {
        class'HxHUDSpawnProtectionTimer'.static.SetShowTimer(bSPShowTimer);
        bSave = true;
    }
    if (class'HxHUDSpawnProtectionTimer'.default.bFollowHUDColor != bSPFollowHUDColor)
    {
        class'HxHUDSpawnProtectionTimer'.static.SetFollowHUDColor(bSPFollowHUDColor);
        bSave = true;
    }
    if (class'HxHUDSpawnProtectionTimer'.default.bPulsingDigits != bSPPulsingDigits)
    {
        class'HxHUDSpawnProtectionTimer'.static.SetPulsingDigits(bSPPulsingDigits);
        bSave = true;
    }
    if (class'HxHUDSpawnProtectionTimer'.default.PosX != SPPosX)
    {
        class'HxHUDSpawnProtectionTimer'.static.SetPosX(SPPosX);
        bSave = true;
    }
    if (class'HxHUDSpawnProtectionTimer'.default.PosY != SPPosY)
    {
        class'HxHUDSpawnProtectionTimer'.static.SetPosY(SPPosY);
        bSave = true;
    }
    if (bSave)
    {
        bSave = false;
        class'HxHUDSpawnProtectionTimer'.static.StaticSaveConfig();
    }
    if (NETController.CustomNetSpeed != CustomNetSpeed)
    {
        NETController.CustomNetSpeed = CustomNetSpeed;
        NETController.UpdateCustomNetSpeed();
        bSave = true;
    }
    if (NETController.MasterServer != MasterServer)
    {
        NETController.MasterServer = MasterServer;
        NETController.UpdateMasterServer();
        bSave = true;
    }
    if (bSave)
    {
        bSave = false;
        NETController.SaveConfig();
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
    class'HxNETController'.static.ResetConfig("CustomNetSpeed");
    class'HxNETController'.static.ResetConfig("MasterServer");

    for (i = 0; i < Components.Length; ++i)
    {
        Components[i].LoadINI();
    }
    GUIController.SetSmallCursor(bSmallCursor);
    GUIController.bFixedMouseSize = bFixedMouseSize;
    UpdateHUDSection();
    class'HxHUDSpawnProtectionTimer'.static.SetShowTimer(bSPShowTimer);
    class'HxHUDSpawnProtectionTimer'.static.SetFollowHUDColor(bSPFollowHUDColor);
    class'HxHUDSpawnProtectionTimer'.static.SetPulsingDigits(bSPPulsingDigits);
    class'HxHUDSpawnProtectionTimer'.static.SetPosX(SPPosX);
    class'HxHUDSpawnProtectionTimer'.static.SetPosY(SPPosY);
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
            bScaleWithY = ch_ScaleWithY.IsChecked();
            break;
        case nu_FOV43:
            break;
        case nu_OverrideFontSize:
            OverrideFontSize = nu_OverrideFontSize.GetValue();
            break;
        case ch_ReplaceHUDs:
            bReplaceHUDs = ch_ReplaceHUDs.IsChecked();
            UpdateHUDSection();
            break;
        case ch_ScaleWeapons:
            bScaleWeapons = ch_ScaleWeapons.IsChecked();
            break;
        case ch_SPShowTimer:
            bSPShowTimer = ch_SPShowTimer.IsChecked();
            break;
        case ch_SPFollowHUDColor:
            bSPFollowHUDColor = ch_SPFollowHUDColor.IsChecked();
            break;
        case ch_SPPulsingDigits:
            bSPPulsingDigits = ch_SPPulsingDigits.IsChecked();
            break;
        case fl_SPPosX:
            SPPosX = fl_SPPosX.GetValue();
            break;
        case fl_SPPosY:
            SPPosY = fl_SPPosY.GetValue();
            break;
        case nu_CustomNetSpeed:
            CustomNetSpeed = nu_CustomNetSpeed.GetValue();
            break;
        case co_MasterServer:
            SetPropertyText(
                "MasterServer", string(GetEnum(enum'EHxMasterServer', co_MasterServer.GetIndex())));
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
        if (bReplaceHUDs)
        {
            ch_ScaleWeapons.EnableMe();
        }
        else
        {
            ch_ScaleWeapons.DisableMe();
        }
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
        WinLeft=0.031797
        WinTop=0.03
        bRemapStack=false
    End Object
    i_BG1=TemplateDisplaySection

    Begin Object class=GUISectionBackground Name=TemplateHUDSection
        Caption="HUD"
        WinWidth=0.448633
        WinHeight=0.38190167
        WinLeft=0.031797
        WinTop=0.348985
        bRemapStack=false
    End Object
    i_BG2=TemplateHUDSection

    Begin Object class=GUISectionBackground Name=TemplateNetworkSection
        Caption="Network"
        WinWidth=0.448633
        WinHeight=0.23606834
        WinLeft=0.031797
        WinTop=0.74088667
        bRemapStack=false
    End Object
    i_BG3=TemplateNetworkSection

    Begin Object class=moCheckBox Name=TemplateSmallCursor
        Caption="Small cursor"
        Hint="Use a custom cursor to compensate the stupid scaling. Recommended for high resolutions."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=0
    End Object
    ch_SmallCursor=TemplateSmallCursor

    Begin Object class=moCheckBox Name=TemplateFixedMouseSize
        Caption="Fixed cursor size"
        Hint="Stop changing cursor size when it hovers a menu option."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=1
    End Object
    ch_FixedMouseSize=TemplateFixedMouseSize

    Begin Object class=moCheckBox Name=TemplateScaleWithY
        Caption="Scale fonts with screen height"
        Hint="Scale fonts with the screen height instead of the screen width. Restart required."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=2
    End Object
    ch_ScaleWithY=TemplateScaleWithY

    Begin Object class=moNumericEdit Name=TemplateOverrideFontSize
        Caption="Override font scale"
        Hint="Override font scale (between 0 and 6). Use -1 for default scale. Restart required."
        INIOption="@Internal"
        MinValue=-1
        MaxValue=6
        CaptionWidth=0.725
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=3
    End Object
    nu_OverrideFontSize=TemplateOverrideFontSize

    Begin Object class=moNumericEdit Name=TemplateFOV43
        Caption="4:3 FOV"
        Hint="Desired 4:3 FOV value. This value will be internally scaled for the current aspect ratio."
        INIOption="@Internal"
        MinValue=80
        MaxValue=140
        CaptionWidth=0.725
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=3
    End Object
    nu_FOV43=TemplateFOV43

    Begin Object class=moCheckBox Name=TemplateReplaceHUDs
        Caption="Replace HUDs"
        Hint="Replace HUDs to fix widescreen scaling."
        INIOption="@Internal"
        bSquare=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=4
    End Object
    ch_ReplaceHUDs=TemplateReplaceHUDs

    Begin Object class=moCheckBox Name=TemplateScaleWeapons
        Caption="Scale weapons"
        Hint="Scale FOV of displayed weapon models when using replaced HUDs."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=5
    End Object
    ch_ScaleWeapons=TemplateScaleWeapons

    Begin Object class=moCheckBox Name=TemplateSPShowTimer
        Caption="Show spawn protection timer"
        Hint="Show timer indicating remaining spawn protection duration."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=6
    End Object
    ch_SPShowTimer=TemplateSPShowTimer

    Begin Object class=moCheckBox Name=TemplateSPFollowHUDColor
        Caption="Timer follows HUD's color"
        Hint="Use the same color as the HUD for the timer's icon."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=7
    End Object
    ch_SPFollowHUDColor=TemplateSPFollowHUDColor

    Begin Object class=moCheckBox Name=TemplateSPPulsingDigits
        Caption="Timer uses pulsing digits"
        Hint="Use pulsing digits for the timer."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=8
    End Object
    ch_SPPulsingDigits=TemplateSPPulsingDigits

    Begin Object class=moFloatEdit Name=TemplateSPPosX
        Caption="Timer's X position"
        Hint="Adjust timer's position in the X axis."
        INIOption="@Internal"
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        CaptionWidth=0.725
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=9
    End Object
    fl_SPPosX=TemplateSPPosX

    Begin Object class=moFloatEdit Name=TemplateSPPosY
        Caption="Timer's Y position"
        Hint="Adjust timer's position in the Y axis."
        INIOption="@Internal"
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        CaptionWidth=0.725
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=10
    End Object
    fl_SPPosY=TemplateSPPosY

    Begin Object class=moNumericEdit Name=TemplateCustomNetSpeed
        Caption="Custom network speed"
        Hint="Custom network speed to use for both internet and LAN games (applied on every level change)."
        INIOption="@Internal"
        MinValue=0
        MaxValue=999999999
        Step=1000000
        CaptionWidth=0.725
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=12
    End Object
    nu_CustomNetSpeed=TemplateCustomNetSpeed

    Begin Object class=moComboBox Name=TemplateMasterServer
        Caption="Master server"
        Hint="Select your preferred master server. Restart required."
        INIOption="@Internal"
        CaptionWidth=0.55
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=13
    End Object
    co_MasterServer=TemplateMasterServer

    WinTop=0.15
    WinLeft=0
    WinWidth=1
    WinHeight=0.74
    bAcceptsInput=false

    PanelCaption="Patches"
    PanelHint="Customize patches..."
}
