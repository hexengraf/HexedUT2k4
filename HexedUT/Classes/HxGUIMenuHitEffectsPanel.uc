class HxGUIMenuHitEffectsPanel extends HxGUIMenuBasePanel;

const SECTION_HIT_SOUNDS = 0;
const SECTION_DAMAGE_NUMBERS = 1;
const SECTION_DAMAGE_POINT_EDITOR = 2;

var automated moCheckBox ch_HitSounds;
var automated moComboBox co_SelectedHitSound;
var automated moSlider sl_HSVolume;
var automated moComboBox co_HSPitchMode;
var automated moCheckBox ch_DamageNumbers;
var automated moComboBox co_DMode;
var automated moComboBox co_DFont;
var automated moFloatEdit fl_DNPosX;
var automated moFloatEdit fl_DNPosY;
var automated moComboBox co_DamagePoints;
var automated moNumericEdit nu_DPValue;
var automated moSlider sl_DPPitch;
var automated GUIButton b_PlaySound;
var automated HxGUIFramedImage i_DPPReview;
var automated moSlider sl_DPScale;
var automated moSlider sl_DPRedColor;
var automated moSlider sl_DPGreenColor;
var automated moSlider sl_DPBlueColor;

var localized string PitchModeNames[3];
var localized string DamageModeNames[5];
var localized string DamagePointNames[5];

var array<string> FontNames;
var array<string> CustomFontNames;
var array<Font> LoadedFonts;
var int DPIndex;
var HxUTClient Client;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);
    Sections[SECTION_HIT_SOUNDS].Insert(ch_HitSounds);
    Sections[SECTION_HIT_SOUNDS].Insert(co_SelectedHitSound);
    Sections[SECTION_HIT_SOUNDS].Insert(sl_HSVolume);
    Sections[SECTION_HIT_SOUNDS].Insert(co_HSPitchMode);
    Sections[SECTION_DAMAGE_NUMBERS].Insert(ch_DamageNumbers);
    Sections[SECTION_DAMAGE_NUMBERS].Insert(co_DMode);
    Sections[SECTION_DAMAGE_NUMBERS].Insert(co_DFont);
    Sections[SECTION_DAMAGE_NUMBERS].Insert(fl_DNPosX);
    Sections[SECTION_DAMAGE_NUMBERS].Insert(fl_DNPosY);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(co_DamagePoints);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(nu_DPValue);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_DPPitch);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(b_PlaySound);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_DPScale);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_DPRedColor);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_DPGreenColor);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_DPBlueColor);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(i_DPPreview);
    PopulateComboBoxes();
}

function bool Initialize()
{
    if (Client == None)
    {
        Client = class'HxUTClient'.static.GetClient(PlayerOwner());
    }
    return Client != None && Client.HitEffects != None;
}

function Refresh()
{
    HitSoundsAfterChange();
    DamageNumbersAfterChange();
    RefreshDamagePointEditorSection();
    Sections[SECTION_HIT_SOUNDS].SetHide(!Client.bAllowHitSounds, HIDE_DUE_DISABLE);
    Sections[SECTION_DAMAGE_NUMBERS].SetHide(!Client.bAllowDamageNumbers, HIDE_DUE_DISABLE);
    Sections[SECTION_DAMAGE_POINT_EDITOR].SetHide(
        !Client.bAllowHitSounds && !Client.bAllowDamageNumbers,
        HIDE_DUE_DISABLE);
    Super.Refresh();
}

function PopulateComboBoxes()
{
    local array<string> HitSoundNames;
    local int i;

    if (class'HxHitEffects'.static.GetHitSoundNames(HitSoundNames))
    {
        for (i = 0; i < HitSoundNames.Length; ++i)
        {
            co_SelectedHitSound.AddItem(GetItemName(HitSoundNames[i]),,string(i));
        }
    }
    for (i = 0; i < ArrayCount(PitchModeNames); ++i)
    {
        co_HSPitchMode.AddItem(PitchModeNames[i],,string(GetEnum(enum'EHxPitchMode', i)));
    }
    for (i = 0; i < ArrayCount(DamageModeNames); ++i)
    {
        co_DMode.AddItem(DamageModeNames[i],,string(GetEnum(enum'EHxDMode', i)));
    }
    AddCustomFonts();
    for (i = 0; i < FontNames.Length; ++i)
    {
        co_DFont.AddItem(GetItemName(FontNames[i]),,FontNames[i]);
    }
    for (i = 0; i < ArrayCount(DamagePointNames); ++i)
    {
        co_DamagePoints.AddItem(DamagePointNames[i],,string(i));
    }
}

function HitSoundsAfterChange()
{
    local bool bHitSoundsEnabled;

    bHitSoundsEnabled = Client.bAllowHitSounds && Client.HitEffects.bHitSounds;
    if (bHitSoundsEnabled)
    {
        EnableComponent(co_SelectedHitSound);
        EnableComponent(sl_HSVolume);
        EnableComponent(co_HSPitchMode);
        EnableComponent(b_PlaySound);
        EnableComponent(sl_DPPitch);
    }
    else
    {
        DisableComponent(co_SelectedHitSound);
        DisableComponent(sl_HSVolume);
        DisableComponent(co_HSPitchMode);
        DisableComponent(b_PlaySound);
        DisableComponent(sl_DPPitch);
    }
    DamagePointEditorAfterChange(
        bHitSoundsEnabled || (Client.bAllowDamageNumbers && Client.HitEffects.bDamageNumbers));
}

function DamageNumbersAfterChange()
{
    local bool bDamageNumbersEnabled;

    bDamageNumbersEnabled = Client.bAllowDamageNumbers && Client.HitEffects.bDamageNumbers;
    if (bDamageNumbersEnabled)
    {
        EnableComponent(co_DMode);
        EnableComponent(co_DFont);
        EnableComponent(fl_DNPosX);
        EnableComponent(fl_DNPosY);
        EnableComponent(sl_DPScale);
        EnableComponent(sl_DPRedColor);
        EnableComponent(sl_DPGreenColor);
        EnableComponent(sl_DPBlueColor);
    }
    else
    {
        DisableComponent(co_DMode);
        DisableComponent(co_DFont);
        DisableComponent(fl_DNPosX);
        DisableComponent(fl_DNPosY);
        DisableComponent(sl_DPScale);
        DisableComponent(sl_DPRedColor);
        DisableComponent(sl_DPGreenColor);
        DisableComponent(sl_DPBlueColor);
    }
    DamagePointEditorAfterChange(
        bDamageNumbersEnabled || (Client.bAllowHitSounds && Client.HitEffects.bHitSounds));
}

function DamagePointEditorAfterChange(bool bAnyEffectEnabled)
{
    if (bAnyEffectEnabled)
    {
        EnableComponent(co_DamagePoints);
        if (DPIndex != 0)
        {
            EnableComponent(nu_DPValue);
        }
        else
        {
            DisableComponent(nu_DPValue);
        }
    }
    else
    {
        DisableComponent(co_DamagePoints);
        DisableComponent(nu_DPValue);
    }
}

function FontOnLoadINI(GUIComponent Sender, string s)
{
    if (Client == None || Client.HitEffects == None)
    {
        return;
    }
    if (Sender == co_DFont)
    {
        co_DFont.SilentSetIndex(GetFontIndex(string(Client.HitEffects.DFont)));
    }
}

function DamagePointEditorOnLoadINI(GUIComponent Sender, string s)
{
    if (Client == None || Client.HitEffects == None)
    {
        return;
    }
    switch (Sender)
    {
        case co_DamagePoints:
            co_DamagePoints.SilentSetIndex(DPIndex);
            break;
        case nu_DPValue:
            nu_DPValue.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Value, true);
            break;
        case sl_DPPitch:
            sl_DPPitch.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Pitch, true);
            break;
        case sl_DPScale:
            sl_DPScale.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Scale, true);
            break;
        case sl_DPRedColor:
            sl_DPRedColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.R, true);
            break;
        case sl_DPGreenColor:
            sl_DPGreenColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.G, true);
            break;
        case sl_DPBlueColor:
            sl_DPBlueColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.B, true);
            break;
    }
}

function HitEffectsOnChange(GUIComponent Sender)
{
    if (Client == None || Client.HitEffects == None)
    {
        return;
    }
    switch (Sender)
    {
        case ch_HitSounds:
            DefaultOnChange(Sender, Client.HitEffects);
            HitSoundsAfterChange();
            break;
        case ch_DamageNumbers:
            DefaultOnChange(Sender, Client.HitEffects);
            DamageNumbersAfterChange();
            break;
        case co_DFont:
            Client.HitEffects.DFont = GetFont(co_DFont.GetIndex());
            break;
        default:
            DefaultOnChange(Sender, Client.HitEffects);
            break;
    }
}

function DamagePointEditorOnChange(GUIComponent Sender)
{
    if (Client == None || Client.HitEffects == None)
    {
        return;
    }
    switch(Sender)
    {
        case co_DamagePoints:
            DefaultOnChange(Sender, Self);
            RefreshDamagePointEditorSection();
            break;
        case nu_DPValue:
            Client.HitEffects.DamagePoints[DPIndex].Value = nu_DPValue.GetValue();
            break;
        case sl_DPPitch:
            Client.HitEffects.DamagePoints[DPIndex].Pitch = sl_DPPitch.GetValue();
            break;
        case sl_DPScale:
            Client.HitEffects.DamagePoints[DPIndex].Scale = sl_DPScale.GetValue();
            break;
        case sl_DPRedColor:
            Client.HitEffects.DamagePoints[DPIndex].Color.R = sl_DPRedColor.GetValue();
            break;
        case sl_DPGreenColor:
            Client.HitEffects.DamagePoints[DPIndex].Color.G = sl_DPGreenColor.GetValue();
            break;
        case sl_DPBlueColor:
            Client.HitEffects.DamagePoints[DPIndex].Color.B = sl_DPBlueColor.GetValue();
            break;
    }
    Client.HitEffects.SaveConfig();
}

function RefreshDamagePointEditorSection()
{
    if (DPIndex != 0)
    {
        EnableComponent(nu_DPValue);
    }
    else
    {
        DisableComponent(nu_DPValue);
    }
    nu_DPValue.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Value);
    sl_DPPitch.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Pitch);
    sl_DPScale.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Scale);
    sl_DPRedColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.R);
    sl_DPGreenColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.G);
    sl_DPBlueColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.B);
}

function DrawDamageNumberPreview(Canvas C)
{
    local float SavedOrgX;
    local float SavedOrgY;
    local float SavedClipX;
    local float SavedClipY;
    local float SavedFontScaleX;
    local float SavedFontScaleY;

    if (Client != None && Client.bAllowDamageNumbers && Client.HitEffects.bDamageNumbers)
    {
        SavedOrgX = C.OrgX;
        SavedOrgY = C.OrgY;
        SavedClipX = C.ClipX;
        SavedClipY = C.ClipY;
        SavedFontScaleX = C.FontScaleX;
        SavedFontScaleY = C.FontScaleY;
        C.OrgX = i_DPPReview.ActualLeft();
        C.OrgY = i_DPPReview.ActualTop();
        C.ClipX = i_DPPReview.ActualWidth();
        C.ClipY = i_DPPReview.ActualHeight();
        Client.HitEffects.DrawDamageNumberPreview(C, DPIndex);
        C.OrgX = SavedOrgX;
        C.OrgY = SavedOrgY;
        C.ClipX = SavedClipX;
        C.ClipY = SavedClipY;
        C.FontScaleX = SavedFontScaleX;
        C.FontScaleY = SavedFontScaleY;
    }
    i_DPPReview.InternalOnRendered(C);
}

function bool PlaySoundOnClick(GUIComponent Sender)
{
    Client.HitEffects.PlayHitSound(Client.HitEffects.DamagePoints[DPIndex].Value);
    return true;
}

function AddCustomFonts()
{
    local int i;
    local Font F;

    LoadedFonts.Length = FontNames.Length;
    for (i = 0; i < CustomFontNames.Length; ++i)
    {
        F = Font(DynamicLoadObject(CustomFontNames[i], class'Font'));
        if (F != None)
        {
            LoadedFonts[FontNames.Length] = F;
            FontNames[FontNames.Length] = CustomFontNames[i];
        }
    }
}

function Font GetFont(int i)
{
    if (LoadedFonts.Length < FontNames.Length)
    {
        LoadedFonts.Length = FontNames.Length;
    }
    if (LoadedFonts[i] == None)
    {
        LoadedFonts[i] = Font(DynamicLoadObject(FontNames[i], class'Font'));
    }
    return LoadedFonts[i];
}

function int GetFontIndex(string FontName)
{
    local int i;

    for (i = 0; i < FontNames.Length; ++i)
    {
        if (FontNames[i] == FontName)
        {
            return i;
        }
    }
    FontNames[FontNames.Length] = FontName;
    co_DFont.AddItem(FontNames[i]);
    return i;
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=HitSoundsSection
        Caption="Hit Sounds"
        WinHeight=0.4
    End Object

    Begin Object class=HxGUIFramedSection Name=DamageNumbersSection
        Caption="Damage Numbers"
        WinHeight=0.4
    End Object

    Begin Object class=HxGUIFramedSection Name=DamagePointEditorSection
        Caption="Damage Point Editor"
        WinHeight=0.6
        ColumnWidths=(0.5,0.5)
        MaxItemsPerColumn=8
        ExpandIndex=8
    End Object

    Begin Object class=moCheckBox Name=HitSoundsCheckBox
        Caption="Enable hit sounds"
        INIOption="HxHitEffects bHitSounds"
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=0
    End Object
    ch_HitSounds=HitSoundsCheckBox

    Begin Object class=moComboBox Name=SelectedHitSoundComboBox
        Caption="Sound"
        INIOption="HxHitEffects SelectedHitSound"
        ComponentWidth=0.65
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=1
    End Object
    co_SelectedHitSound=SelectedHitSoundComboBox

    Begin Object class=moSlider Name=HSVolumeSlider
        Caption="Volume"
        INIOption="HxHitEffects HitSoundVolume"
        ComponentWidth=0.65
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=2
    End Object
    sl_HSVolume=HSVolumeSlider

    Begin Object class=moComboBox Name=HSPitchModeComboBox
        Caption="Pitch mode"
        INIOption="HxHitEffects PitchMode"
        ComponentWidth=0.65
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=3
    End Object
    co_HSPitchMode=HSPitchModeComboBox

    Begin Object class=moCheckBox Name=DamageNumbersCheckBox
        Caption="Enable damage numbers"
        INIOption="HxHitEffects bDamageNumbers"
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=4
    End Object
    ch_DamageNumbers=DamageNumbersCheckBox

    Begin Object class=moComboBox Name=DModeComboBox
        Caption="Mode"
        INIOption="HxHitEffects DMode"
        ComponentWidth=0.65
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=5
    End Object
    co_DMode=DModeComboBox

    Begin Object class=moComboBox Name=DFontComboBox
        Caption="Font"
        INIOption="HxHitEffects FontIndex"
        ComponentWidth=0.65
        bReadOnly=true
        OnLoadINI=FontOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=6
    End Object
    co_DFont=DFontComboBox

    Begin Object class=moFloatEdit Name=DNPosXFloatEdit
        Caption="X position"
        INIOption="HxHitEffects PosX"
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        ComponentWidth=0.25
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=7
    End Object
    fl_DNPosX=DNPosXFloatEdit

    Begin Object class=moFloatEdit Name=DNPosYFloatEdit
        Caption="Y position"
        INIOption="HxHitEffects PosY"
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        ComponentWidth=0.25
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=8
    End Object
    fl_DNPosY=DNPosYFloatEdit

    Begin Object class=moComboBox Name=DamagePointsComboBox
        Caption="Point"
        INIOption="HxHitEffectsMenuPanel DPIndex"
        ComponentWidth=0.65
        bReadOnly=true
        OnLoadINI=DamagePointEditorOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=9
    End Object
    co_DamagePoints=DamagePointsComboBox

    Begin Object class=moNumericEdit Name=DPValueNumericEdit
        Caption="Damage value"
        INIOption="@INTERNAL"
        MinValue=-300
        MaxValue=300
        Step=1
        ComponentWidth=0.25
        OnLoadINI=DamagePointEditorOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=11
    End Object
    nu_DPValue=DPValueNumericEdit

    Begin Object class=moSlider Name=DPPitchSlider
        Caption="Pitch"
        INIOption="@INTERNAL"
        ComponentWidth=0.65
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=DamagePointEditorOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=12
    End Object
    sl_DPPitch=DPPitchSlider

    Begin Object class=GUIButton Name=PlaySound
        Caption="Play sound"
        bStandardized=true
        StandardHeight=0.035
        OnClick=PlaySoundOnClick
        OnClickSound=CS_None
        TabOrder=13
    End Object
    b_PlaySound=PlaySound

    Begin Object class=moSlider Name=DPScaleSlider
        Caption="Scale"
        INIOption="@INTERNAL"
        ComponentWidth=0.65
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=DamagePointEditorOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=14
    End Object
    sl_DPScale=DPScaleSlider

    Begin Object class=moSlider Name=DPRedColorSlider
        Caption="Red"
        INIOption="@INTERNAL"
        ComponentWidth=0.65
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=DamagePointEditorOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=15
    End Object
    sl_DPRedColor=DPRedColorSlider

    Begin Object class=moSlider Name=DPGreenColorSlider
        Caption="Green"
        INIOption="@INTERNAL"
        ComponentWidth=0.65
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=DamagePointEditorOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=16
    End Object
    sl_DPGreenColor=DPGreenColorSlider

    Begin Object class=moSlider Name=DPBlueColorSlider
        Caption="Blue"
        INIOption="@INTERNAL"
        ComponentWidth=0.65
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=DamagePointEditorOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=17
    End Object
    sl_DPBlueColor=DPBlueColorSlider

    Begin Object class=HxGUIFramedImage Name=DPPreviewImage
        ImageSources(0)=(Color=(R=0,G=0,B=0,A=128),Style=ISTY_Stretched)
        RenderStyle=MSTY_Alpha
        OnRendered=DrawDamageNumberPreview
    End Object
    i_DPPReview=DPPreviewImage

    PanelCaption="Hit Effects"
    PanelHint="Hit sounds and damage numbers"
    bInsertFront=true
    bDoubleColumn=true
    bFillPanelHeight=false
    Sections(0)=HitSoundsSection
    Sections(1)=DamageNumbersSection
    Sections(2)=DamagePointEditorSection
    Sections(3)=None
    FontNames(0)="UT2003Fonts.FontEurostile29"
    FontNames(1)="UT2003Fonts.FontEurostile37"
    FontNames(2)="UT2003Fonts.FontNeuzeit29"
    FontNames(3)="UT2003Fonts.FontNeuzeit37"
    FontNames(4)="2K4Fonts.Verdana28"
    FontNames(5)="2K4Fonts.Verdana30"
    FontNames(6)="2K4Fonts.Verdana32"
    FontNames(7)="2K4Fonts.Verdana34"
    CustomFontNames(0)="HexedPatches.Verdana36"
    CustomFontNames(1)="HexedPatches.Verdana40"
    CustomFontNames(2)="HexedPatches.Verdana48"
    PitchModeNames(0)="Disabled"
    PitchModeNames(1)="Low to high"
    PitchModeNames(2)="High to low"
    DamageModeNames(0)="Static per hit"
    DamageModeNames(1)="Static total"
    DamageModeNames(2)="Static per hit & total"
    DamageModeNames(3)="Float per hit"
    DamageModeNames(4)="Float per hit & total"
    DamagePointNames(0)="Zero damage"
    DamagePointNames(1)="Low damage"
    DamagePointNames(2)="Medium damage"
    DamagePointNames(3)="High damage"
    DamagePointNames(4)="Extreme damage"
    DPIndex=4
}
