class HxGUIPatchesSettings extends Settings_Tabs;

var automated GUISectionBackground i_BG1;
var automated GUISectionBackground i_BG2;
var automated GUISectionBackground i_BG3;
var automated moCheckBox ch_SmallCursor;
var automated moCheckBox ch_FixedMouseSize;
var automated moCheckBox ch_ScaleWithY;
var automated moNumericEdit nu_OverrideFontSize;
var automated moFloatEdit fl_HorPlusFOV;
var automated moCheckBox ch_ReplaceHUDs;
var automated moCheckBox ch_ScaleWeapons;
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
var private float HorPlusFOV;
var private bool bReplaceHUDs;
var private bool bScaleWeapons;
var private int CustomNetSpeed;
var private HxNETController.EHxMasterServer MasterServer;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    PopulateHexedControllers(HxGUIController(MyController));
    Super.InitComponent(MyController, MyOwner);

    i_BG1.ManageComponent(ch_FixedMouseSize);
    i_BG1.ManageComponent(ch_ScaleWithY);
    i_BG1.ManageComponent(nu_OverrideFontSize);

    i_BG2.ManageComponent(fl_HorPlusFOV);
    i_BG2.ManageComponent(ch_SmallCursor);
    i_BG2.ManageComponent(ch_ReplaceHUDs);
    i_BG2.ManageComponent(ch_ScaleWeapons);
    i_BG2.ManageComponent(nu_CustomNetSpeed);
    i_BG2.ManageComponent(co_MasterServer);

    for (i = 0; i < 2; ++i)
    {
        co_MasterServer.AddItem(Mid(GetEnum(enum'EHxMasterServer', i), 17));
    }
    if (GUIController.bOldUnrealPatch)
    {
        i_BG2.DisableMe();
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
        case fl_HorPlusFOV:
            HorPlusFOV = class'HxAspectRatio'.static.ScaleFOV(
                PlayerOwner().DefaultFOV, GUIController.GetCurrentAspectRatio(), 4/3);
            fl_HorPlusFOV.SetComponentValue(HorPlusFOV, true);
            break;
        case ch_SmallCursor:
            bSmallCursor = GUIController.bSmallCursor;
            ch_SmallCursor.SetComponentValue(bSmallCursor, true);
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
    if (HorPlusFOV != fl_HorPlusFOV.GetValue())
    {
        HorPlusFOV = fl_HorPlusFOV.GetValue();
        PlayerOwner().FOV(
            class'HxAspectRatio'.static.GetScaledFOV(HorPlusFOV, GUIController.GetCurrentAspectRatio()));
    }
    if (HUDController != None)
    {
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
    if (NETController != None)
    {
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
    class'HxNETController'.static.ResetConfig("CustomNetSpeed");
    class'HxNETController'.static.ResetConfig("MasterServer");

    for (i = 0; i < Components.Length; ++i)
    {
        Components[i].LoadINI();
    }
    GUIController.SetSmallCursor(bSmallCursor);
    GUIController.bFixedMouseSize = bFixedMouseSize;
    UpdateHUDSection();
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
        case fl_HorPlusFOV:
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
    if (HUDController == None || HUDController.CheckConflictingPackages())
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
    Begin Object class=GUISectionBackground Name=FixesSection
        Caption="Fixes"
        WinLeft=0.031797
        WinTop=0.03
        WinWidth=0.448633
        WinHeight=0.2603739
        bRemapStack=false
    End Object
    i_BG1=FixesSection

    Begin Object class=GUISectionBackground Name=Legacy3369FixesSection
        Caption="Legacy 3369 Fixes"
        WinLeft=0.031797
        WinTop=0.3003739
        WinWidth=0.448633
        WinHeight=0.38190167
        bRemapStack=false
    End Object
    i_BG2=Legacy3369FixesSection

    Begin Object class=moCheckBox Name=FixedMouseSizeCheckBox
        Caption="Fixed cursor size"
        Hint="Stop changing cursor size when it hovers a menu option."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=0
    End Object
    ch_FixedMouseSize=FixedMouseSizeCheckBox

    Begin Object class=moCheckBox Name=ScaleWithYCheckBox
        Caption="Scale fonts with screen height"
        Hint="Scale fonts with the screen height instead of the screen width. Restart required."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=1
    End Object
    ch_ScaleWithY=ScaleWithYCheckBox

    Begin Object class=moNumericEdit Name=OverrideFontSizeNumericEdit
        Caption="Override font scale"
        Hint="Override font scale (between 0 and 6). Use -1 for default scale. Restart required."
        INIOption="@Internal"
        MinValue=-1
        MaxValue=6
        CaptionWidth=0.725
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=2
    End Object
    nu_OverrideFontSize=OverrideFontSizeNumericEdit

    Begin Object class=moFloatEdit Name=HorPlusFOVFloatEdit
        Caption="Hor+ FOV"
        Hint="Desired Hor+ FOV value."
        INIOption="@Internal"
        MinValue=80
        MaxValue=140
        Step=1
        CaptionWidth=0.725
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=3
    End Object
    fl_HorPlusFOV=HorPlusFOVFloatEdit

    Begin Object class=moCheckBox Name=SmallCursorCheckBox
        Caption="Small cursor"
        Hint="Use a custom cursor to compensate the stupid scaling. Recommended for high resolutions."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=4
    End Object
    ch_SmallCursor=SmallCursorCheckBox

    Begin Object class=moCheckBox Name=ReplaceHUDsCheckBox
        Caption="Replace HUDs"
        Hint="Replace HUDs to fix widescreen scaling."
        INIOption="@Internal"
        bSquare=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=5
    End Object
    ch_ReplaceHUDs=ReplaceHUDsCheckBox

    Begin Object class=moCheckBox Name=ScaleWeaponsCheckBox
        Caption="Scale weapons"
        Hint="Scale FOV of displayed weapon models when using replaced HUDs."
        INIOption="@Internal"
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=6
    End Object
    ch_ScaleWeapons=ScaleWeaponsCheckBox

    Begin Object class=moNumericEdit Name=CustomNetSpeedNumericEdit
        Caption="Custom network speed"
        Hint="Custom network speed to use for both internet and LAN games (applied on every level change)."
        INIOption="@Internal"
        MinValue=0
        MaxValue=999999999
        Step=1000000
        CaptionWidth=0.725
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=7
    End Object
    nu_CustomNetSpeed=CustomNetSpeedNumericEdit

    Begin Object class=moComboBox Name=MasterServerComboBox
        Caption="Master server"
        Hint="Select your preferred master server. Restart required."
        INIOption="@Internal"
        CaptionWidth=0.55
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=8
    End Object
    co_MasterServer=MasterServerComboBox

    WinTop=0.15
    WinLeft=0
    WinWidth=1
    WinHeight=0.74
    bAcceptsInput=false

    PanelCaption="HexedPatches"
    PanelHint="Customize HexedPatches..."
}
