class HxGUIMenuHitEffectsPanel extends HxGUIMenuPanel;

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
var automated GUILabel l_PositionAnchor;
var automated moFloatEdit fl_DisplayPosX;
var automated moFloatEdit fl_DisplayPosY;
var automated moComboBox co_DamagePoints;
var automated moNumericEdit nu_Value;
var automated moSlider sl_Pitch;
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
    Sections[SECTION_DAMAGE_NUMBERS].Insert(l_PositionAnchor);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(co_DamagePoints);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(nu_Value);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_Pitch);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_Scale);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_RedColor);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_GreenColor);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(sl_BlueColor);
    Sections[SECTION_DAMAGE_POINT_EDITOR].Insert(i_Preview);
    PrependClassNameToINIOptions();
    PopulateComboBoxes();
    sl_HitSoundVolume.MySlider.OnClickSound = CS_None;
    sl_Pitch.MySlider.OnClickSound = CS_None;
}

function Refresh()
{
    local bool bAllowHitSounds;
    local bool bAllowDamageNumbers;

    if (Client == None)
    {
        Client = HxUTClient(ClientManager.Find(class'HxUTClient'));
    }
    if (Client != None)
    {
        HitSoundsAfterChange();
        DamageNumbersAfterChange();
        bAllowHitSounds = bool(Client.GetServerProperty("bAllowHitSounds"));
        bAllowDamageNumbers = bool(Client.GetServerProperty("bAllowDamageNumbers"));
        Sections[SECTION_HIT_SOUNDS].SetHide(!bAllowHitSounds, HideDueDisable);
        Sections[SECTION_DAMAGE_NUMBERS].SetHide(!bAllowDamageNumbers, HideDueDisable);
        fl_DisplayPosX.SetVisibility(bAllowDamageNumbers);
        fl_DisplayPosY.SetVisibility(bAllowDamageNumbers);
        Sections[SECTION_DAMAGE_POINT_EDITOR].SetHide(
            !bAllowHitSounds && !bAllowDamageNumbers, HideDueDisable);
    }
    Super.Refresh();
}

function PopulateComboBoxes()
{
    local array<string> HitSoundNames;
    local bool bFoundFont;
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
}

function HitSoundsAfterChange()
{
    local bool bHitSoundsEnabled;

    bHitSoundsEnabled = Client.HitEffects.IsHitSoundsEnabled();
    SetEnable(co_HitSoundNames, bHitSoundsEnabled);
    SetEnable(sl_HitSoundVolume, bHitSoundsEnabled);
    SetEnable(co_PitchMode, bHitSoundsEnabled);
    SetEnable(sl_Pitch, bHitSoundsEnabled);
    DamagePointEditorAfterChange(bHitSoundsEnabled || Client.HitEffects.IsDamageNumbersEnabled());
}

function DamageNumbersAfterChange()
{
    local bool bDamageNumbersEnabled;

    bDamageNumbersEnabled = Client.HitEffects.IsDamageNumbersEnabled();
    SetEnable(co_DisplayMode, bDamageNumbersEnabled);
    SetEnable(co_DisplayFont, bDamageNumbersEnabled);
    SetEnable(l_PositionAnchor, bDamageNumbersEnabled);
    SetEnable(fl_DisplayPosX, bDamageNumbersEnabled);
    SetEnable(fl_DisplayPosY, bDamageNumbersEnabled);
    SetEnable(sl_Scale, bDamageNumbersEnabled);
    SetEnable(sl_RedColor, bDamageNumbersEnabled);
    SetEnable(sl_GreenColor, bDamageNumbersEnabled);
    SetEnable(sl_BlueColor, bDamageNumbersEnabled);
    DamagePointEditorAfterChange(bDamageNumbersEnabled || Client.HitEffects.IsHitSoundsEnabled());
}

function DamagePointEditorAfterChange(bool bAnyEffectEnabled)
{
    SetEnable(co_DamagePoints, bAnyEffectEnabled);
    SetEnable(nu_Value, bAnyEffectEnabled && DPIndex != 0);
}

function DamagePointEditorOnLoadINI(GUIComponent Sender, string s)
{
    switch (Sender)
    {
        case co_DamagePoints:
            co_DamagePoints.SilentSetIndex(DPIndex);
            break;
        case nu_Value:
            nu_Value.SetComponentValue(class'HxHitEffects'.default.ExtremeDamage.Value, true);
            break;
        case sl_Pitch:
            sl_Pitch.SetComponentValue(class'HxHitEffects'.default.ExtremeDamage.Pitch, true);
            break;
        case sl_Scale:
            sl_Scale.SetComponentValue(class'HxHitEffects'.default.ExtremeDamage.Scale, true);
            break;
        case sl_RedColor:
            sl_RedColor.SetComponentValue(class'HxHitEffects'.default.ExtremeDamage.Color.R, true);
            break;
        case sl_GreenColor:
            sl_GreenColor.SetComponentValue(class'HxHitEffects'.default.ExtremeDamage.Color.G, true);
            break;
        case sl_BlueColor:
            sl_BlueColor.SetComponentValue(class'HxHitEffects'.default.ExtremeDamage.Color.B, true);
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
            break;
        case sl_HitSoundVolume:
            Client.HitEffects.PlayHitSoundPreview(DPIndex);
            break;
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
            DPIndex = co_DamagePoints.GetIndex();
            RefreshDamagePointEditorSection();
            break;
        case nu_Value:
            Client.HitEffects.SetDamagePointValue(DPIndex, nu_Value.GetValue());
            break;
        case sl_Pitch:
            Client.HitEffects.SetDamagePointPitch(DPIndex, sl_Pitch.GetValue());
            Client.HitEffects.PlayHitSoundPreview(DPIndex);
            break;
        case sl_Scale:
            Client.HitEffects.SetDamagePointScale(DPIndex, sl_Scale.GetValue());
            break;
        case sl_RedColor:
            Client.HitEffects.SetDamagePointColorR(DPIndex, sl_RedColor.GetValue());
            break;
        case sl_GreenColor:
            Client.HitEffects.SetDamagePointColorG(DPIndex, sl_GreenColor.GetValue());
            break;
        case sl_BlueColor:
            Client.HitEffects.SetDamagePointColorB(DPIndex, sl_BlueColor.GetValue());
            break;
    }
    Client.HitEffects.SaveConfig();
}

function RefreshDamagePointEditorSection()
{
    SetEnable(nu_Value, DPIndex != 0);
    nu_Value.SetComponentValue(Client.HitEffects.GetDamagePoint(DPIndex).Value, true);
    sl_Pitch.SetComponentValue(Client.HitEffects.GetDamagePoint(DPIndex).Pitch, true);
    sl_Scale.SetComponentValue(Client.HitEffects.GetDamagePoint(DPIndex).Scale, true);
    sl_RedColor.SetComponentValue(Client.HitEffects.GetDamagePoint(DPIndex).Color.R, true);
    sl_GreenColor.SetComponentValue(Client.HitEffects.GetDamagePoint(DPIndex).Color.G, true);
    sl_BlueColor.SetComponentValue(Client.HitEffects.GetDamagePoint(DPIndex).Color.B, true);
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

    if (Client != None && Client.HitEffects.IsDamageNumbersEnabled())
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

function PrependClassNameToINIOptions()
{
    local string ClassName;

    ClassName = string(class'HxHitEffects');
    ch_HitSounds.INIOption = ClassName@ch_HitSounds.INIOption;
    co_HitSoundNames.INIOption = ClassName@co_HitSoundNames.INIOption;
    sl_HitSoundVolume.INIOption = ClassName@sl_HitSoundVolume.INIOption;
    co_PitchMode.INIOption = ClassName@co_PitchMode.INIOption;
    ch_DamageNumbers.INIOption = ClassName@ch_DamageNumbers.INIOption;
    co_DisplayMode.INIOption = ClassName@co_DisplayMode.INIOption;
    co_DisplayFont.INIOption = ClassName@co_DisplayFont.INIOption;
    fl_DisplayPosX.INIOption = ClassName@fl_DisplayPosX.INIOption;
    fl_DisplayPosY.INIOption = ClassName@fl_DisplayPosY.INIOption;
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
        MaxItemsPerColumn=7
        ExpandIndex=7
    End Object

    Begin Object class=moCheckBox Name=HitSoundsCheckBox
        Caption="Enable hit sounds"
        INIOption="bHitSounds"
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=0
    End Object
    ch_HitSounds=HitSoundsCheckBox

    Begin Object class=moComboBox Name=HitSoundNamesComboBox
        Caption="Sound"
        INIOption="HitSoundName"
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=1
    End Object
    co_HitSoundNames=HitSoundNamesComboBox

    Begin Object class=moSlider Name=HitSoundVolumeSlider
        Caption="Volume"
        INIOption="HitSoundVolume"
        ComponentWidth=0.64
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=2
    End Object
    sl_HitSoundVolume=HitSoundVolumeSlider

    Begin Object class=moComboBox Name=PitchModeComboBox
        Caption="Pitch mode"
        INIOption="PitchMode"
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=3
    End Object
    co_PitchMode=PitchModeComboBox

    Begin Object class=moCheckBox Name=DamageNumbersCheckBox
        Caption="Enable damage numbers"
        INIOption="bDamageNumbers"
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=4
    End Object
    ch_DamageNumbers=DamageNumbersCheckBox

    Begin Object class=moComboBox Name=DisplayModeComboBox
        Caption="Mode"
        INIOption="DisplayMode"
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=5
    End Object
    co_DisplayMode=DisplayModeComboBox

    Begin Object class=moComboBox Name=DisplayFontComboBox
        Caption="Font"
        INIOption="DisplayFontName"
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=DefaultOnLoadINI
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
        INIOption="DisplayPosX"
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        CaptionWidth=0.17
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=7
    End Object
    fl_DisplayPosX=PosXFloatEdit

    Begin Object class=moFloatEdit Name=PosYFloatEdit
        Caption="Y"
        INIOption="DisplayPosY"
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        CaptionWidth=0.17
        OnLoadINI=DefaultOnLoadINI
        OnChange=HitEffectsOnChange
        TabOrder=8
    End Object
    fl_DisplayPosY=PosYFloatEdit

    Begin Object class=moComboBox Name=DamagePointsComboBox
        Caption="Point"
        INIOption="@INTERNAL"
        ComponentWidth=0.64
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
        ComponentWidth=0.64
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=DamagePointEditorOnLoadINI
        OnChange=DamagePointEditorOnChange
        TabOrder=12
    End Object
    sl_Pitch=PitchSlider

    Begin Object class=moSlider Name=ScaleSlider
        Caption="Scale"
        INIOption="@INTERNAL"
        ComponentWidth=0.64
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
        ComponentWidth=0.64
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
        ComponentWidth=0.64
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
        ComponentWidth=0.64
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
    PanelHint="Hit sound and damage number options"
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
