class HxGUIMenuHitEffectsPanel extends HxGUIMenuPanel;

const SECTION_HIT_SOUNDS = 0;
const SECTION_DAMAGE_NUMBERS = 1;
const SECTION_INTERPOLATION_CURVE = 2;

const AUTO_FONT = "AUTOSELECT";

var automated moCheckBox ch_HitSounds;
var automated moComboBox co_HitSoundNames;
var automated moSlider sl_HitSoundVolume;
var automated moComboBox co_PitchMode;
var automated moCheckBox ch_DamageNumbers;
var automated moComboBox co_DisplayMode;
var automated moComboBox co_DisplayFont;
var automated GUILabel l_PositionAnchor;
var automated moFloatEdit fl_DisplayPosX;
var automated moFloatEdit fl_DisplayPosY;
var automated moComboBox co_DamagePoints;
var automated moNumericEdit nu_Value;
var automated moSlider sl_Pitch;
var automated HxGUIBackground b_Preview;
var automated moSlider sl_Scale;
var automated moSlider sl_RedColor;
var automated moSlider sl_GreenColor;
var automated moSlider sl_BlueColor;

var localized string PitchModeLabels[3];
var localized string DisplayModeLabels[3];
var localized string DamagePointLabels[5];
var localized string AutoSelectFontLabel;

var private HxUTClient Client;
var private HxHitEffectsConfig Config;
var private int DPIndex;
var private bool bAllowHitSounds;
var private bool bAllowDamageNumbers;
var private bool bDamageNumbersEnabled;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);
    Sections[SECTION_HIT_SOUNDS].Insert(ch_HitSounds);
    Sections[SECTION_HIT_SOUNDS].Insert(co_HitSoundNames);
    Sections[SECTION_HIT_SOUNDS].Insert(sl_HitSoundVolume);
    Sections[SECTION_HIT_SOUNDS].Insert(co_PitchMode);
    Sections[SECTION_DAMAGE_NUMBERS].Insert(ch_DamageNumbers);
    Sections[SECTION_DAMAGE_NUMBERS].Insert(co_DisplayMode);
    Sections[SECTION_DAMAGE_NUMBERS].Insert(co_DisplayFont);
    Sections[SECTION_DAMAGE_NUMBERS].Insert(l_PositionAnchor);
    Sections[SECTION_INTERPOLATION_CURVE].Insert(co_DamagePoints);
    Sections[SECTION_INTERPOLATION_CURVE].Insert(nu_Value);
    Sections[SECTION_INTERPOLATION_CURVE].Insert(b_Preview);
    Sections[SECTION_INTERPOLATION_CURVE].Insert(sl_Pitch);
    Sections[SECTION_INTERPOLATION_CURVE].Insert(sl_Scale);
    Sections[SECTION_INTERPOLATION_CURVE].Insert(sl_RedColor);
    Sections[SECTION_INTERPOLATION_CURVE].Insert(sl_GreenColor);
    Sections[SECTION_INTERPOLATION_CURVE].Insert(sl_BlueColor);
    Client = HxUTClient(ClientManager.Find(class'HxUTClient'));
    Config = HxHitEffectsConfig(Client.FindConfig(class'HxHitEffectsConfig'));
    PopulateComboBoxes();
    sl_HitSoundVolume.MySlider.OnClickSound = CS_None;
    sl_Pitch.MySlider.OnClickSound = CS_None;
}

function bool CanShowPanel()
{
    return Client != None;
}

function Refresh()
{
    if (Client != None)
    {
        bAllowHitSounds = bool(Client.GetServerProperty("bAllowHitSounds"));
        bAllowDamageNumbers = bool(Client.GetServerProperty("bAllowDamageNumbers"));
        HitSoundsAfterChange();
        DamageNumbersAfterChange();
        RefreshDamagePointEditorSection();
        Sections[SECTION_HIT_SOUNDS].SetHide(!bAllowHitSounds);
        Sections[SECTION_DAMAGE_NUMBERS].SetHide(!bAllowDamageNumbers);
        fl_DisplayPosX.SetVisibility(bAllowDamageNumbers);
        fl_DisplayPosY.SetVisibility(bAllowDamageNumbers);
    }
    Super.Refresh();
}

function PopulateComboBoxes()
{
    local array<string> HitSoundNames;
    local bool bFoundFont;
    local int i;

    co_HitSoundNames.MyComboBox.MyListBox.MyList.bInitializeList = false;
    co_PitchMode.MyComboBox.MyListBox.MyList.bInitializeList = false;
    co_DisplayMode.MyComboBox.MyListBox.MyList.bInitializeList = false;
    co_DamagePoints.MyComboBox.MyListBox.MyList.bInitializeList = false;
    co_DisplayFont.MyComboBox.MyListBox.MyList.bInitializeList = false;
    if (class'HxHitEffects'.static.GetHitSoundNames(HitSoundNames))
    {
        for (i = 0; i < HitSoundNames.Length; ++i)
        {
            co_HitSoundNames.AddItem(GetItemName(HitSoundNames[i]),,HitSoundNames[i]);
        }
    }
    for (i = 0; i < Config.CustomHitSounds.Length; ++i)
    {
        co_HitSoundNames.AddItem(GetItemName(Config.CustomHitSounds[i]),,Config.CustomHitSounds[i]);
    }
    for (i = 0; i < ArrayCount(PitchModeLabels); ++i)
    {
        co_PitchMode.AddItem(PitchModeLabels[i],,string(GetEnum(enum'EHxPitchMode', i)));
    }
    for (i = 0; i < ArrayCount(DisplayModeLabels); ++i)
    {
        co_DisplayMode.AddItem(DisplayModeLabels[i],,string(GetEnum(enum'EHxDisplayMode', i)));
    }
    for (i = 0; i < ArrayCount(DamagePointLabels); ++i)
    {
        co_DamagePoints.AddItem(DamagePointLabels[i],,string(i));
    }
    co_DisplayFont.AddItem(AutoSelectFontLabel,, AUTO_FONT);
    for (i = 0; i < Config.FontNames.Length; ++i)
    {
        if (Config.DisplayFontName ~= Config.FontNames[i])
        {
            bFoundFont = true;
        }
        co_DisplayFont.AddItem(GetItemName(Config.FontNames[i]),, Config.FontNames[i]);
    }
    if (!bFoundFont && Config.DisplayFontName != AUTO_FONT)
    {
        co_DisplayFont.AddItem(GetItemName(Config.DisplayFontName),, Config.DisplayFontName);
    }
}

function HitSoundsAfterChange()
{
    local bool bHitSoundsEnabled;

    bHitSoundsEnabled = bAllowHitSounds && ch_HitSounds.IsChecked();
    SetEnable(co_HitSoundNames, bHitSoundsEnabled);
    SetEnable(sl_HitSoundVolume, bHitSoundsEnabled);
    SetEnable(co_PitchMode, bHitSoundsEnabled);
    SetEnable(sl_Pitch, bHitSoundsEnabled);
    DamagePointEditorAfterChange(
        bHitSoundsEnabled || bAllowDamageNumbers && ch_DamageNumbers.IsChecked());
}

function DamageNumbersAfterChange()
{
    bDamageNumbersEnabled = bAllowDamageNumbers && ch_DamageNumbers.IsChecked();
    SetEnable(co_DisplayMode, bDamageNumbersEnabled);
    SetEnable(co_DisplayFont, bDamageNumbersEnabled);
    SetEnable(l_PositionAnchor, bDamageNumbersEnabled);
    SetEnable(fl_DisplayPosX, bDamageNumbersEnabled);
    SetEnable(fl_DisplayPosY, bDamageNumbersEnabled);
    SetEnable(sl_Scale, bDamageNumbersEnabled);
    SetEnable(sl_RedColor, bDamageNumbersEnabled);
    SetEnable(sl_GreenColor, bDamageNumbersEnabled);
    SetEnable(sl_BlueColor, bDamageNumbersEnabled);
    DamagePointEditorAfterChange(
        bDamageNumbersEnabled || bAllowHitSounds && ch_HitSounds.IsChecked());
}

function DamagePointEditorAfterChange(bool bAnyEffectEnabled)
{
    SetEnable(co_DamagePoints, bAnyEffectEnabled);
    SetEnable(nu_Value, bAnyEffectEnabled && DPIndex != 0);
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    switch (Sender)
    {
        case co_DamagePoints:
            co_DamagePoints.SilentSetIndex(DPIndex);
            break;
        case nu_Value:
            nu_Value.SetComponentValue(Config.ExtremeDamage.Value, true);
            break;
        case sl_Pitch:
            sl_Pitch.SetComponentValue(Config.ExtremeDamage.Pitch, true);
            break;
        case sl_Scale:
            sl_Scale.SetComponentValue(Config.ExtremeDamage.Scale, true);
            break;
        case sl_RedColor:
            sl_RedColor.SetComponentValue(Config.ExtremeDamage.Color.R, true);
            break;
        case sl_GreenColor:
            sl_GreenColor.SetComponentValue(Config.ExtremeDamage.Color.G, true);
            break;
        case sl_BlueColor:
            sl_BlueColor.SetComponentValue(Config.ExtremeDamage.Color.B, true);
            break;
        default:
            GUIMenuOption(Sender).SetComponentValue(Config.GetProperty(Sender.Tag), true);
            break;
    }
}

function HitEffectsOnChange(GUIComponent Sender)
{
    Config.SetProperty(Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
    switch (Sender)
    {
        case ch_HitSounds:
            HitSoundsAfterChange();
            break;
        case sl_HitSoundVolume:
            if (Client != None)
            {
                Client.PlayHitSoundPreview(DPIndex);
            }
            break;
        case ch_DamageNumbers:
            DamageNumbersAfterChange();
            break;
    }
}

function DamagePointEditorOnChange(GUIComponent Sender)
{
    if (Sender == co_DamagePoints)
    {
        DPIndex = co_DamagePoints.GetIndex();
        RefreshDamagePointEditorSection();
    }
    else
    {
        UpdateDamagePointConfig();
        Config.SetProperty(Sender.Tag, Config.GetProperty(Sender.Tag));
    }
    if (Sender == sl_Pitch && Client != None)
    {
        Client.PlayHitSoundPreview(DPIndex);
    }
}

function RefreshDamagePointEditorSection()
{
    SetEnable(nu_Value, DPIndex != 0);
    switch (DPIndex)
    {
        case 0:
            nu_Value.SetComponentValue(Config.ZeroDamage.Value, true);
            sl_Pitch.SetComponentValue(Config.ZeroDamage.Pitch, true);
            sl_Scale.SetComponentValue(Config.ZeroDamage.Scale, true);
            sl_RedColor.SetComponentValue(Config.ZeroDamage.Color.R, true);
            sl_GreenColor.SetComponentValue(Config.ZeroDamage.Color.G, true);
            sl_BlueColor.SetComponentValue(Config.ZeroDamage.Color.B, true);
            break;
        case 1:
            nu_Value.SetComponentValue(Config.LowDamage.Value, true);
            sl_Pitch.SetComponentValue(Config.LowDamage.Pitch, true);
            sl_Scale.SetComponentValue(Config.LowDamage.Scale, true);
            sl_RedColor.SetComponentValue(Config.LowDamage.Color.R, true);
            sl_GreenColor.SetComponentValue(Config.LowDamage.Color.G, true);
            sl_BlueColor.SetComponentValue(Config.LowDamage.Color.B, true);
            break;
        case 2:
            nu_Value.SetComponentValue(Config.MediumDamage.Value, true);
            sl_Pitch.SetComponentValue(Config.MediumDamage.Pitch, true);
            sl_Scale.SetComponentValue(Config.MediumDamage.Scale, true);
            sl_RedColor.SetComponentValue(Config.MediumDamage.Color.R, true);
            sl_GreenColor.SetComponentValue(Config.MediumDamage.Color.G, true);
            sl_BlueColor.SetComponentValue(Config.MediumDamage.Color.B, true);
            break;
        case 3:
            nu_Value.SetComponentValue(Config.HighDamage.Value, true);
            sl_Pitch.SetComponentValue(Config.HighDamage.Pitch, true);
            sl_Scale.SetComponentValue(Config.HighDamage.Scale, true);
            sl_RedColor.SetComponentValue(Config.HighDamage.Color.R, true);
            sl_GreenColor.SetComponentValue(Config.HighDamage.Color.G, true);
            sl_BlueColor.SetComponentValue(Config.HighDamage.Color.B, true);
            break;
        case 4:
            nu_Value.SetComponentValue(Config.ExtremeDamage.Value, true);
            sl_Pitch.SetComponentValue(Config.ExtremeDamage.Pitch, true);
            sl_Scale.SetComponentValue(Config.ExtremeDamage.Scale, true);
            sl_RedColor.SetComponentValue(Config.ExtremeDamage.Color.R, true);
            sl_GreenColor.SetComponentValue(Config.ExtremeDamage.Color.G, true);
            sl_BlueColor.SetComponentValue(Config.ExtremeDamage.Color.B, true);
            break;
    }
    nu_Value.Tag = Config.GetPropertyIndex("ZeroDamage") + DPIndex;
    sl_Pitch.Tag = nu_Value.Tag;
    sl_Scale.Tag = nu_Value.Tag;
    sl_RedColor.Tag = nu_Value.Tag;
    sl_GreenColor.Tag = nu_Value.Tag;
    sl_BlueColor.Tag = nu_Value.Tag;
}

function bool PositionFloatEditsOnPreDraw(Canvas C)
{
    if (l_PositionAnchor.bInit)
    {
        l_PositionAnchor.bInit = Sections[SECTION_DAMAGE_NUMBERS].bInit;
        fl_DisplayPosX.WinLeft = l_PositionAnchor.WinLeft + l_PositionAnchor.WinWidth * 0.36;
        fl_DisplayPosX.WinTop = l_PositionAnchor.WinTop;
        fl_DisplayPosX.WinWidth = l_PositionAnchor.WinWidth * 0.32 - 0.005;
        fl_DisplayPosY.WinLeft = fl_DisplayPosX.WinLeft + fl_DisplayPosX.WinWidth + 0.01;
        fl_DisplayPosY.WinTop = l_PositionAnchor.WinTop;
        fl_DisplayPosY.WinWidth = fl_DisplayPosX.WinWidth;
    }
    return false;
}

function DrawPreview(Canvas C)
{
    local float SavedOrgX;
    local float SavedOrgY;
    local float SavedClipX;
    local float SavedClipY;
    local float SavedFontScaleX;
    local float SavedFontScaleY;

    if (bDamageNumbersEnabled)
    {
        SavedOrgX = C.OrgX;
        SavedOrgY = C.OrgY;
        SavedClipX = C.ClipX;
        SavedClipY = C.ClipY;
        SavedFontScaleX = C.FontScaleX;
        SavedFontScaleY = C.FontScaleY;
        C.OrgX = b_Preview.ActualLeft();
        C.OrgY = b_Preview.ActualTop();
        C.ClipX = b_Preview.ActualWidth();
        C.ClipY = b_Preview.ActualHeight();
        if (Client != None)
        {
            Client.DrawDamageNumberPreview(C, DPIndex);
        }
        C.OrgX = SavedOrgX;
        C.OrgY = SavedOrgY;
        C.ClipX = SavedClipX;
        C.ClipY = SavedClipY;
        C.FontScaleX = SavedFontScaleX;
        C.FontScaleY = SavedFontScaleY;
    }
}

function UpdateDamagePointConfig()
{
    switch (DPIndex)
    {
        case 0:
            Config.ZeroDamage.Pitch = sl_Pitch.GetValue();
            Config.ZeroDamage.Scale = sl_Scale.GetValue();
            Config.ZeroDamage.Color.R = sl_RedColor.GetValue();
            Config.ZeroDamage.Color.G = sl_GreenColor.GetValue();
            Config.ZeroDamage.Color.B = sl_BlueColor.GetValue();
            break;
        case 1:
            Config.LowDamage.Value = nu_Value.GetValue();
            Config.LowDamage.Pitch = sl_Pitch.GetValue();
            Config.LowDamage.Scale = sl_Scale.GetValue();
            Config.LowDamage.Color.R = sl_RedColor.GetValue();
            Config.LowDamage.Color.G = sl_GreenColor.GetValue();
            Config.LowDamage.Color.B = sl_BlueColor.GetValue();
            break;
        case 2:
            Config.MediumDamage.Value = nu_Value.GetValue();
            Config.MediumDamage.Pitch = sl_Pitch.GetValue();
            Config.MediumDamage.Scale = sl_Scale.GetValue();
            Config.MediumDamage.Color.R = sl_RedColor.GetValue();
            Config.MediumDamage.Color.G = sl_GreenColor.GetValue();
            Config.MediumDamage.Color.B = sl_BlueColor.GetValue();
            break;
        case 3:
            Config.HighDamage.Value = nu_Value.GetValue();
            Config.HighDamage.Pitch = sl_Pitch.GetValue();
            Config.HighDamage.Scale = sl_Scale.GetValue();
            Config.HighDamage.Color.R = sl_RedColor.GetValue();
            Config.HighDamage.Color.G = sl_GreenColor.GetValue();
            Config.HighDamage.Color.B = sl_BlueColor.GetValue();
            break;
        case 4:
            Config.ExtremeDamage.Value = nu_Value.GetValue();
            Config.ExtremeDamage.Pitch = sl_Pitch.GetValue();
            Config.ExtremeDamage.Scale = sl_Scale.GetValue();
            Config.ExtremeDamage.Color.R = sl_RedColor.GetValue();
            Config.ExtremeDamage.Color.G = sl_GreenColor.GetValue();
            Config.ExtremeDamage.Color.B = sl_BlueColor.GetValue();
            break;
    }
}

event Free()
{
    Client = None;
    Config = None;
    Super.Free();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=HitSoundsSection
        Caption="Hit Sounds"
        WinHeight=0.46
    End Object

    Begin Object class=HxGUIFramedSection Name=DamageNumbersSection
        Caption="Damage Numbers"
        WinHeight=0.46
    End Object

    Begin Object class=HxGUIFramedSection Name=InterpolationCurveSection
        Caption="Hit Effects Interpolation Curve"
        WinHeight=0.54
        ColumnWidths=(0.5,0.5)
        LineSpacing=0.017
        MaxItemsPerColumn=5
        ExpandIndices=(2,-1)
    End Object

    Begin Object class=moCheckBox Name=HitSoundsCheckBox
        Caption="Enable Hit Sounds"
        INIOption="@INTERNAL"
        Tag=0
        OnLoadINI=InternalOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=0
    End Object
    ch_HitSounds=HitSoundsCheckBox

    Begin Object class=moComboBox Name=HitSoundNamesComboBox
        Caption="Sound"
        INIOption="@INTERNAL"
        Tag=1
        CaptionWidth=0.35
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=1
    End Object
    co_HitSoundNames=HitSoundNamesComboBox

    Begin Object class=moSlider Name=HitSoundVolumeSlider
        Caption="Volume"
        INIOption="@INTERNAL"
        Tag=2
        CaptionWidth=0.35
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=InternalOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=2
    End Object
    sl_HitSoundVolume=HitSoundVolumeSlider

    Begin Object class=moComboBox Name=PitchModeComboBox
        Caption="Pitch Mode"
        INIOption="@INTERNAL"
        Tag=3
        CaptionWidth=0.35
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=3
    End Object
    co_PitchMode=PitchModeComboBox

    Begin Object class=moCheckBox Name=DamageNumbersCheckBox
        Caption="Enable Damage Numbers"
        INIOption="@INTERNAL"
        Tag=4
        OnLoadINI=InternalOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=4
    End Object
    ch_DamageNumbers=DamageNumbersCheckBox

    Begin Object class=moComboBox Name=DisplayModeComboBox
        Caption="Display Mode"
        INIOption="@INTERNAL"
        Tag=5
        CaptionWidth=0.35
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=5
    End Object
    co_DisplayMode=DisplayModeComboBox

    Begin Object class=moComboBox Name=DisplayFontComboBox
        Caption="Font"
        INIOption="@INTERNAL"
        Tag=6
        CaptionWidth=0.35
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=6
    End Object
    co_DisplayFont=DisplayFontComboBox

    Begin Object class=GUILabel Name=PositionAnchorLabel
        Caption="Position"
        bStandardized=true
        StandardHeight=0.03
        StyleName="TextLabel"
        bInit=true
        bBoundToParent=true
        bScaleToParent=true
        OnPreDraw=PositionFloatEditsOnPreDraw
    End Object
    l_PositionAnchor=PositionAnchorLabel

    Begin Object class=moFloatEdit Name=PosXFloatEdit
        Caption="X"
        INIOption="@INTERNAL"
        Tag=7
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        CaptionWidth=0.17
        OnLoadINI=InternalOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=7
    End Object
    fl_DisplayPosX=PosXFloatEdit

    Begin Object class=moFloatEdit Name=PosYFloatEdit
        Caption="Y"
        INIOption="@INTERNAL"
        Tag=8
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        CaptionWidth=0.17
        OnLoadINI=InternalOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=8
    End Object
    fl_DisplayPosY=PosYFloatEdit

    Begin Object class=moComboBox Name=DamagePointsComboBox
        Caption="Point"
        INIOption="@INTERNAL"
        CaptionWidth=0.35
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=9
    End Object
    co_DamagePoints=DamagePointsComboBox

    Begin Object class=moNumericEdit Name=ValueNumericEdit
        Caption="Damage Value"
        INIOption="@INTERNAL"
        MinValue=-300
        MaxValue=300
        Step=1
        ComponentWidth=0.25
        OnLoadINI=InternalOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=11
    End Object
    nu_Value=ValueNumericEdit

    Begin Object class=moSlider Name=PitchSlider
        Caption="Pitch"
        INIOption="@INTERNAL"
        CaptionWidth=0.35
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=InternalOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=12
    End Object
    sl_Pitch=PitchSlider

    Begin Object class=moSlider Name=ScaleSlider
        Caption="Scale"
        INIOption="@INTERNAL"
        CaptionWidth=0.35
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=InternalOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=14
    End Object
    sl_Scale=ScaleSlider

    Begin Object class=moSlider Name=RedColorSlider
        Caption="Red"
        INIOption="@INTERNAL"
        CaptionWidth=0.35
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=InternalOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=15
    End Object
    sl_RedColor=RedColorSlider

    Begin Object class=moSlider Name=GreenColorSlider
        Caption="Green"
        INIOption="@INTERNAL"
        CaptionWidth=0.35
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=InternalOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=16
    End Object
    sl_GreenColor=GreenColorSlider

    Begin Object class=moSlider Name=BlueColorSlider
        Caption="Blue"
        INIOption="@INTERNAL"
        CaptionWidth=0.35
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=InternalOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=17
    End Object
    sl_BlueColor=BlueColorSlider

    Begin Object class=HxGUIBackground Name=PreviewBackground
        StyleName="HxBackgroundDarker"
        OnRendered=DrawPreview
    End Object
    b_Preview=PreviewBackground

    PanelCaption="Hit Effects"
    PanelHint="Hit sound and damage number options"
    Dependencies=("bAllowHitSounds","bAllowDamageNumbers")
    bDoubleColumn=true
    bFillPanelHeight=false
    Sections(0)=HitSoundsSection
    Sections(1)=DamageNumbersSection
    Sections(2)=InterpolationCurveSection
    Sections(3)=None
    PitchModeLabels(0)="Disabled"
    PitchModeLabels(1)="Low To High"
    PitchModeLabels(2)="High To Low"
    DisplayModeLabels(0)="Total Damage"
    DisplayModeLabels(1)="Last Hit Damage"
    DisplayModeLabels(2)="Last Hit & Total Damage"
    DamagePointLabels(0)="Zero Damage"
    DamagePointLabels(1)="Low Damage"
    DamagePointLabels(2)="Medium Damage"
    DamagePointLabels(3)="High Damage"
    DamagePointLabels(4)="Extreme Damage"
    AutoSelectFontLabel="Auto-Select"
    DPIndex=4
}
