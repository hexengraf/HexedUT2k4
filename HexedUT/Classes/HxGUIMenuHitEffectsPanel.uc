class HxGUIMenuHitEffectsPanel extends HxGUIMenuBasePanel;

const SECTION_HIT_SOUNDS = 0;
const SECTION_DAMAGE_NUMBERS = 1;
const SECTION_DAMAGE_POINT_EDITOR = 2;

var automated moCheckBox ch_HitSounds;
var automated moComboBox co_HitSoundNames;
var automated moSlider sl_HitSoundVolume;
var automated moComboBox co_PitchMode;
var automated moCheckBox ch_DamageNumbers;
var automated moComboBox co_DisplayMode;
var automated moComboBox co_DisplayFont;
var automated moFloatEdit fl_DisplayPosX;
var automated moFloatEdit fl_DisplayPosY;
var automated moComboBox co_DamagePoints;
var automated moNumericEdit nu_Value;
var automated moSlider sl_Pitch;
var automated GUIButton b_PlaySound;
var automated HxGUIFramedImage i_Preview;
var automated moSlider sl_Scale;
var automated moSlider sl_RedColor;
var automated moSlider sl_GreenColor;
var automated moSlider sl_BlueColor;

var localized string PitchModeNames[3];
var localized string DisplayModeNames[5];
var localized string DamagePointNames[5];

var private HxUTClient Client;
var private int DPIndex;

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
    Sections[SECTION_DAMAGE_NUMBERS].Insert(fl_DisplayPosX);
    Sections[SECTION_DAMAGE_NUMBERS].Insert(fl_DisplayPosY);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(co_DamagePoints);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(nu_Value);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_Pitch);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(b_PlaySound);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_Scale);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_RedColor);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_GreenColor);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_BlueColor);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(i_Preview);
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
            co_HitSoundNames.AddItem(GetItemName(HitSoundNames[i]),,HitSoundNames[i]);
        }
    }
    for (i = 0; i < ArrayCount(PitchModeNames); ++i)
    {
        co_PitchMode.AddItem(PitchModeNames[i],,string(GetEnum(enum'EHxPitchMode', i)));
    }
    for (i = 0; i < ArrayCount(DisplayModeNames); ++i)
    {
        co_DisplayMode.AddItem(DisplayModeNames[i],,string(GetEnum(enum'EHxDisplayMode', i)));
    }
    for (i = 0; i < ArrayCount(DamagePointNames); ++i)
    {
        co_DamagePoints.AddItem(DamagePointNames[i],,string(i));
    }
    PopulateFonts();
}

function PopulateFonts()
{
    local bool bFoundFont;
    local int i;

    co_DisplayFont.bIgnoreChange = true;
    for (i = 0; i < class'HxHitEffects'.default.FontNames.Length; ++i)
    {
        if (class'HxHitEffects'.default.DisplayFontName ~= class'HxHitEffects'.default.FontNames[i])
        {
            bFoundFont = true;
        }
        co_DisplayFont.AddItem(
            GetItemName(class'HxHitEffects'.default.FontNames[i]),,
            class'HxHitEffects'.default.FontNames[i]);
    }
    if (!bFoundFont)
    {
        co_DisplayFont.AddItem(
            GetItemName(class'HxHitEffects'.default.DisplayFontName),,
            class'HxHitEffects'.default.DisplayFontName);
    }
    co_DisplayFont.bIgnoreChange = false;
}

function HitSoundsAfterChange()
{
    local bool bHitSoundsEnabled;

    bHitSoundsEnabled = Client.bAllowHitSounds && Client.HitEffects.bHitSounds;
    if (bHitSoundsEnabled)
    {
        EnableComponent(co_HitSoundNames);
        EnableComponent(sl_HitSoundVolume);
        EnableComponent(co_PitchMode);
        EnableComponent(b_PlaySound);
        EnableComponent(sl_Pitch);
    }
    else
    {
        DisableComponent(co_HitSoundNames);
        DisableComponent(sl_HitSoundVolume);
        DisableComponent(co_PitchMode);
        DisableComponent(b_PlaySound);
        DisableComponent(sl_Pitch);
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
        EnableComponent(co_DisplayMode);
        EnableComponent(co_DisplayFont);
        EnableComponent(fl_DisplayPosX);
        EnableComponent(fl_DisplayPosY);
        EnableComponent(sl_Scale);
        EnableComponent(sl_RedColor);
        EnableComponent(sl_GreenColor);
        EnableComponent(sl_BlueColor);
    }
    else
    {
        DisableComponent(co_DisplayMode);
        DisableComponent(co_DisplayFont);
        DisableComponent(fl_DisplayPosX);
        DisableComponent(fl_DisplayPosY);
        DisableComponent(sl_Scale);
        DisableComponent(sl_RedColor);
        DisableComponent(sl_GreenColor);
        DisableComponent(sl_BlueColor);
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
            EnableComponent(nu_Value);
        }
        else
        {
            DisableComponent(nu_Value);
        }
    }
    else
    {
        DisableComponent(co_DamagePoints);
        DisableComponent(nu_Value);
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
        case nu_Value:
            nu_Value.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Value, true);
            break;
        case sl_Pitch:
            sl_Pitch.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Pitch, true);
            break;
        case sl_Scale:
            sl_Scale.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Scale, true);
            break;
        case sl_RedColor:
            sl_RedColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.R, true);
            break;
        case sl_GreenColor:
            sl_GreenColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.G, true);
            break;
        case sl_BlueColor:
            sl_BlueColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.B, true);
            break;
    }
}

function HitEffectsOnChange(GUIComponent Sender)
{
    if (Client == None || Client.HitEffects == None)
    {
        return;
    }
    DefaultOnChange(Sender, Client.HitEffects);
    switch (Sender)
    {
        case ch_HitSounds:
            HitSoundsAfterChange();
            break;
        case co_HitSoundNames:
            if (!Client.HitEffects.LoadHitSound())
            {
                co_HitSoundNames.LoadINI();
            }
        case ch_DamageNumbers:
            DamageNumbersAfterChange();
            break;
        case co_DisplayFont:
            if (!Client.HitEffects.LoadFont())
            {
                co_DisplayFont.LoadINI();
            }
            break;
        default:
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
        case nu_Value:
            Client.HitEffects.DamagePoints[DPIndex].Value = nu_Value.GetValue();
            break;
        case sl_Pitch:
            Client.HitEffects.DamagePoints[DPIndex].Pitch = sl_Pitch.GetValue();
            break;
        case sl_Scale:
            Client.HitEffects.DamagePoints[DPIndex].Scale = sl_Scale.GetValue();
            break;
        case sl_RedColor:
            Client.HitEffects.DamagePoints[DPIndex].Color.R = sl_RedColor.GetValue();
            break;
        case sl_GreenColor:
            Client.HitEffects.DamagePoints[DPIndex].Color.G = sl_GreenColor.GetValue();
            break;
        case sl_BlueColor:
            Client.HitEffects.DamagePoints[DPIndex].Color.B = sl_BlueColor.GetValue();
            break;
    }
    Client.HitEffects.SaveConfig();
}

function RefreshDamagePointEditorSection()
{
    if (DPIndex != 0)
    {
        EnableComponent(nu_Value);
    }
    else
    {
        DisableComponent(nu_Value);
    }
    nu_Value.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Value);
    sl_Pitch.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Pitch);
    sl_Scale.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Scale);
    sl_RedColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.R);
    sl_GreenColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.G);
    sl_BlueColor.SetComponentValue(Client.HitEffects.DamagePoints[DPIndex].Color.B);
}

function DrawPreview(Canvas C)
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
        C.OrgX = i_Preview.ActualLeft();
        C.OrgY = i_Preview.ActualTop();
        C.ClipX = i_Preview.ActualWidth();
        C.ClipY = i_Preview.ActualHeight();
        Client.HitEffects.DrawPreview(C, DPIndex);
        C.OrgX = SavedOrgX;
        C.OrgY = SavedOrgY;
        C.ClipX = SavedClipX;
        C.ClipY = SavedClipY;
        C.FontScaleX = SavedFontScaleX;
        C.FontScaleY = SavedFontScaleY;
    }
    i_Preview.InternalOnRendered(C);
}

function bool PlaySoundOnClick(GUIComponent Sender)
{
    Client.HitEffects.PlayHitSound(Client.HitEffects.DamagePoints[DPIndex].Value);
    return true;
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

    Begin Object class=moComboBox Name=HitSoundNamesComboBox
        Caption="Sound"
        INIOption="HxHitEffects HitSoundName"
        ComponentWidth=0.65
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=1
    End Object
    co_HitSoundNames=HitSoundNamesComboBox

    Begin Object class=moSlider Name=HitSoundVolumeSlider
        Caption="Volume"
        INIOption="HxHitEffects HitSoundVolume"
        ComponentWidth=0.65
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=2
    End Object
    sl_HitSoundVolume=HitSoundVolumeSlider

    Begin Object class=moComboBox Name=PitchModeComboBox
        Caption="Pitch mode"
        INIOption="HxHitEffects PitchMode"
        ComponentWidth=0.65
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=3
    End Object
    co_PitchMode=PitchModeComboBox

    Begin Object class=moCheckBox Name=DamageNumbersCheckBox
        Caption="Enable damage numbers"
        INIOption="HxHitEffects bDamageNumbers"
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=4
    End Object
    ch_DamageNumbers=DamageNumbersCheckBox

    Begin Object class=moComboBox Name=DisplayModeComboBox
        Caption="Mode"
        INIOption="HxHitEffects DisplayMode"
        ComponentWidth=0.65
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=5
    End Object
    co_DisplayMode=DisplayModeComboBox

    Begin Object class=moComboBox Name=DisplayFontComboBox
        Caption="Font"
        INIOption="HxHitEffects DisplayFontName"
        ComponentWidth=0.65
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=6
    End Object
    co_DisplayFont=DisplayFontComboBox

    Begin Object class=moFloatEdit Name=PosXFloatEdit
        Caption="X position"
        INIOption="HxHitEffects DisplayPosX"
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        ComponentWidth=0.25
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=7
    End Object
    fl_DisplayPosX=PosXFloatEdit

    Begin Object class=moFloatEdit Name=PosYFloatEdit
        Caption="Y position"
        INIOption="HxHitEffects DisplayPosY"
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        ComponentWidth=0.25
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=8
    End Object
    fl_DisplayPosY=PosYFloatEdit

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

    Begin Object class=moNumericEdit Name=ValueNumericEdit
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
    nu_Value=ValueNumericEdit

    Begin Object class=moSlider Name=PitchSlider
        Caption="Pitch"
        INIOption="@INTERNAL"
        ComponentWidth=0.65
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=DamagePointEditorOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=12
    End Object
    sl_Pitch=PitchSlider

    Begin Object class=GUIButton Name=PlaySoundButton
        Caption="Play sound"
        bStandardized=true
        StandardHeight=0.035
        OnClick=PlaySoundOnClick
        OnClickSound=CS_None
        TabOrder=13
    End Object
    b_PlaySound=PlaySoundButton

    Begin Object class=moSlider Name=ScaleSlider
        Caption="Scale"
        INIOption="@INTERNAL"
        ComponentWidth=0.65
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=DamagePointEditorOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=14
    End Object
    sl_Scale=ScaleSlider

    Begin Object class=moSlider Name=RedColorSlider
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
    sl_RedColor=RedColorSlider

    Begin Object class=moSlider Name=GreenColorSlider
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
    sl_GreenColor=GreenColorSlider

    Begin Object class=moSlider Name=BlueColorSlider
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
    sl_BlueColor=BlueColorSlider

    Begin Object class=HxGUIFramedImage Name=PreviewImage
        ImageSources(0)=(Color=(R=0,G=0,B=0,A=128),Style=ISTY_Stretched)
        RenderStyle=MSTY_Alpha
        OnRendered=DrawPreview
    End Object
    i_Preview=PreviewImage

    PanelCaption="Hit Effects"
    PanelHint="Hit sounds and damage numbers"
    bInsertFront=true
    bDoubleColumn=true
    bFillPanelHeight=false
    Sections(0)=HitSoundsSection
    Sections(1)=DamageNumbersSection
    Sections(2)=DamagePointEditorSection
    Sections(3)=None
    PitchModeNames(0)="Disabled"
    PitchModeNames(1)="Low to high"
    PitchModeNames(2)="High to low"
    DisplayModeNames(0)="Static per hit"
    DisplayModeNames(1)="Static total"
    DisplayModeNames(2)="Static per hit & total"
    DisplayModeNames(3)="Float per hit"
    DisplayModeNames(4)="Float per hit & total"
    DamagePointNames(0)="Zero damage"
    DamagePointNames(1)="Low damage"
    DamagePointNames(2)="Medium damage"
    DamagePointNames(3)="High damage"
    DamagePointNames(4)="Extreme damage"
    DPIndex=4
}
