class HxEffectsGUIPanel extends HxGUIPanel;

const SECTION_HS = 0;
const SECTION_DN = 1;
const SECTION_DC = 2;

var automated moCheckBox ch_bHitSounds;
var automated moComboBox cb_HitSound;
var automated moSlider sl_HitSoundVolume;
var automated moComboBox cb_PitchType;

var automated moCheckBox ch_bDamageNumbers;
var automated moNumericEdit nu_FontSizeModifier;
var automated moFloatEdit nu_PosX;
var automated moFloatEdit nu_PosY;

var automated moComboBox cb_DamagePoint;
var automated moNumericEdit nu_DamagePointValue;
var automated moSlider sl_DamagePointPitch;
var automated moSlider sl_DamagePointRed;
var automated moSlider sl_DamagePointGreen;
var automated moSlider sl_DamagePointBlue;

var int DPIndex;
var HxAgent Agent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);

    Sections[SECTION_HS].ManageComponent(ch_bHitSounds);
    Sections[SECTION_HS].ManageComponent(cb_HitSound);
    Sections[SECTION_HS].ManageComponent(sl_HitSoundVolume);
    Sections[SECTION_HS].ManageComponent(cb_PitchType);

    Sections[SECTION_DN].ManageComponent(ch_bDamageNumbers);
    Sections[SECTION_DN].ManageComponent(nu_FontSizeModifier);
    Sections[SECTION_DN].ManageComponent(nu_PosX);
    Sections[SECTION_DN].ManageComponent(nu_PosY);

    Sections[SECTION_DC].ManageComponent(cb_DamagePoint);
    Sections[SECTION_DC].ManageComponent(nu_DamagePointValue);
    Sections[SECTION_DC].ManageComponent(sl_DamagePointPitch);
    Sections[SECTION_DC].ManageComponent(sl_DamagePointRed);
    Sections[SECTION_DC].ManageComponent(sl_DamagePointBlue);
    Sections[SECTION_DC].ManageComponent(sl_DamagePointGreen);

    for (i = 0; i < class'HxHitEffects'.default.HitSounds.Length; ++i)
    {
        cb_HitSound.AddItem(string(class'HxHitEffects'.default.HitSounds[i]));
    }
    for (i = 0; i < ArrayCount(class'HxHitEffects'.default.EHxPitchNames); ++i)
    {
        cb_PitchType.AddItem(class'HxHitEffects'.default.EHxPitchNames[i]);
    }
    for (i = 0; i < ArrayCount(class'HxHitEffects'.default.DamagePointNames); ++i)
    {
        cb_DamagePoint.AddItem(class'HxHitEffects'.default.DamagePointNames[i]);
    }
}

function ShowPanel(bool bShow)
{
    Super.ShowPanel(bShow);
    if (bShow)
    {
        UpdateAvailableOptions();
    }
}

function UpdateAvailableOptions()
{
    if (!Initialize())
    {
        HideAllSections(true, HIDE_DUE_INIT);
    }
    else
    {
        UpdateHitSounds();
        UpdateDamageNumbers();
        UpdateDamagePoints();
        HideSection(SECTION_HS, !Agent.bAllowHitSounds, HIDE_DUE_DISABLE);
        HideSection(SECTION_DN, !Agent.bAllowDamageNumbers, HIDE_DUE_DISABLE);
        HideSection(
            SECTION_DC, !Agent.bAllowHitSounds && !Agent.bAllowDamageNumbers, HIDE_DUE_DISABLE);
    }
}

function InternalOnChange(GUIComponent C)
{
    switch(C)
    {
        case ch_bHitSounds:
            Agent.HitEffects.bHitSounds = ch_bHitSounds.IsChecked();
            UpdateHitSounds();
            UpdateDamagePoints();
            break;
        case cb_HitSound:
            Agent.HitEffects.SelectedHitSound = cb_HitSound.GetIndex();
            break;
        case sl_HitSoundVolume:
            Agent.HitEffects.HitSoundVolume = sl_HitSoundVolume.GetValue();
            break;
        case cb_PitchType:
            Agent.HitEffects.PitchType = EHxPitch(cb_PitchType.GetIndex());
            break;
        case ch_bDamageNumbers:
            Agent.HitEffects.bDamageNumbers = ch_bDamageNumbers.IsChecked();
            UpdateDamageNumbers();
            UpdateDamagePoints();
            break;
        case nu_FontSizeModifier:
            Agent.HitEffects.FontSizeModifier = nu_FontSizeModifier.GetValue();
            break;
        case nu_PosX:
            Agent.HitEffects.PosX = nu_PosX.GetValue();
            break;
        case nu_PosY:
            Agent.HitEffects.PosY = nu_PosY.GetValue();
            break;
        case cb_DamagePoint:
            DPIndex = cb_DamagePoint.GetIndex();
            SetDamagePoints();
            break;
        case nu_DamagePointValue:
            Agent.HitEffects.DamagePoints[DPIndex].Value = nu_DamagePointValue.GetValue();
            break;
        case sl_DamagePointPitch:
            Agent.HitEffects.DamagePoints[DPIndex].Pitch = sl_DamagePointPitch.GetValue();
            break;
        case sl_DamagePointRed:
            Agent.HitEffects.DamagePoints[DPIndex].Color.R = sl_DamagePointRed.GetValue();
            break;
        case sl_DamagePointGreen:
            Agent.HitEffects.DamagePoints[DPIndex].Color.G = sl_DamagePointGreen.GetValue();
            break;
        case sl_DamagePointBlue:
            Agent.HitEffects.DamagePoints[DPIndex].Color.B = sl_DamagePointBlue.GetValue();
            break;
    }
    Agent.HitEffects.SaveConfig();
}

function bool Initialize()
{
    if (Agent == None)
    {
        Agent = class'HxAgent'.static.GetAgent(PlayerOwner());
    }
    if (Agent != None)
    {
        SetHitSounds();
        SetDamageNumbers();
        SetDamagePoints();
        return true;
    }
    return false;
}

function UpdateHitSounds()
{
    if (Agent.HitEffects.bHitSounds)
    {
        EnableComponent(cb_HitSound);
        EnableComponent(sl_HitSoundVolume);
        EnableComponent(cb_PitchType);
        EnableComponent(sl_DamagePointPitch);
    }
    else
    {
        DisableComponent(cb_HitSound);
        DisableComponent(sl_HitSoundVolume);
        DisableComponent(cb_PitchType);
        DisableComponent(sl_DamagePointPitch);
    }
}

function UpdateDamageNumbers()
{
    if (Agent.HitEffects.bDamageNumbers)
    {
        EnableComponent(nu_FontSizeModifier);
        EnableComponent(nu_PosX);
        EnableComponent(nu_PosY);
        EnableComponent(sl_DamagePointRed);
        EnableComponent(sl_DamagePointGreen);
        EnableComponent(sl_DamagePointBlue);
    }
    else
    {
        DisableComponent(nu_FontSizeModifier);
        DisableComponent(nu_PosX);
        DisableComponent(nu_PosY);
        DisableComponent(sl_DamagePointRed);
        DisableComponent(sl_DamagePointGreen);
        DisableComponent(sl_DamagePointBlue);
    }
}

function UpdateDamagePoints()
{
    if (Agent.HitEffects.bHitSounds || Agent.HitEffects.bDamageNumbers)
    {
        EnableComponent(cb_DamagePoint);
        EnableComponent(nu_DamagePointValue);
    }
    else
    {
        DisableComponent(cb_DamagePoint);
        DisableComponent(nu_DamagePointValue);
    }
}

function SetHitSounds()
{
    ch_bHitSounds.Checked(Agent.HitEffects.bHitSounds);
    cb_HitSound.SetIndex(Agent.HitEffects.SelectedHitSound);
    sl_HitSoundVolume.SetComponentValue(Agent.HitEffects.HitSoundVolume);
    cb_PitchType.SetIndex(Agent.HitEffects.PitchType);
}

function SetDamageNumbers()
{
    ch_bDamageNumbers.Checked(Agent.HitEffects.bDamageNumbers);
    nu_FontSizeModifier.SetComponentValue(Agent.HitEffects.FontSizeModifier);
    nu_PosX.SetComponentValue(Agent.HitEffects.PosX);
    nu_PosY.SetComponentValue(Agent.HitEffects.PosY);
}

function SetDamagePoints()
{
    nu_DamagePointValue.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Value);
    sl_DamagePointPitch.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Pitch);
    sl_DamagePointRed.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.R);
    sl_DamagePointGreen.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.G);
    sl_DamagePointBlue.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.B);
}

defaultproperties
{
    Begin Object class=AltSectionBackground Name=HitSoundsSection
        Caption="Hit Sounds"
        WinHeight=0.274
    End Object
    Sections(0)=HitSoundsSection

    Begin Object class=AltSectionBackground Name=DamageNumbersSection
        Caption="Damage Numbers"
        WinHeight=0.274
    End Object
    Sections(1)=DamageNumbersSection

    Begin Object class=AltSectionBackground Name=DamagePointsSection
        Caption="Damage Curve"
    	WinHeight=0.411
    End Object
    Sections(2)=DamagePointsSection

    Begin Object class=moCheckBox Name=HitSounds
        Caption="Enable hit sounds"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=3
        OnChange=InternalOnChange
    End Object
    ch_bHitSounds=HitSounds

    Begin Object class=moComboBox Name=HitSound
		Caption="Sound"
        bReadOnly=true
        bAlwaysNotify=false
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=4
        OnChange=InternalOnChange
	End Object
    cb_HitSound=HitSound

    Begin Object class=moSlider Name=HitSoundVolume
        Caption="Volume"
        MinValue=0.0
        MaxValue=1.0
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=5
        OnChange=InternalOnChange
    End Object
    sl_HitSoundVolume=HitSoundVolume

    Begin Object class=moComboBox Name=PitchType
        Caption="Pitch"
        bReadOnly=true
        bAlwaysNotify=false
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=6
        OnChange=InternalOnChange
    End Object
    cb_PitchType=PitchType

    Begin Object class=moCheckBox Name=DamageNumbersCheck
        Caption="Enable damage numbers"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=9
        OnChange=InternalOnChange
    End Object
    ch_bDamageNumbers=DamageNumbersCheck

    Begin Object class=moNumericEdit Name=FontSizeModifier
        Caption="Font size modifier"
        MinValue=-8
        MaxValue=8
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=10
        OnChange=InternalOnChange
    End Object
    nu_FontSizeModifier=FontSizeModifier

    Begin Object class=moFloatEdit Name=PosX
        Caption="X position"
        MinValue=0.0
        MaxValue=1.0
        Step=0.010000
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=12
        OnChange=InternalOnChange
    End Object
    nu_PosX=PosX

    Begin Object class=moFloatEdit Name=PosY
        Caption="Y position"
        MinValue=0.0
        MaxValue=1.0
        Step=0.010000
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=13
        OnChange=InternalOnChange
    End Object
    nu_PosY=PosY

    Begin Object class=moComboBox Name=DamagePoint
		Caption="Point"
        bReadOnly=true
        bAlwaysNotify=false
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=14
        OnChange=InternalOnChange
	End Object
    cb_DamagePoint=DamagePoint

    Begin Object class=moNumericEdit Name=DamagePointValue
        Caption="Damage value"
        MinValue=-300
        MaxValue=300
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=15
        OnChange=InternalOnChange
    End Object
    nu_DamagePointValue=DamagePointValue

    Begin Object class=moSlider Name=DamagePointPitch
        Caption="Pitch"
        MinValue=0.0
        MaxValue=1.0
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=16
        OnChange=InternalOnChange
    End Object
    sl_DamagePointPitch=DamagePointPitch

    Begin Object class=moSlider Name=DamagePointRed
        Caption="Red"
        MinValue=0
        MaxValue=255
       	bIntSlider=true
        LabelColor=(R=255,G=0,B=0,A=255)
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=17
        OnChange=InternalOnChange
    End Object
    sl_DamagePointRed=DamagePointRed

    Begin Object class=moSlider Name=DamagePointGreen
        Caption="Green"
        MinValue=0
        MaxValue=255
       	bIntSlider=true
        LabelColor=(R=0,G=255,B=0,A=255)
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=18
        OnChange=InternalOnChange
    End Object
    sl_DamagePointGreen=DamagePointGreen

    Begin Object class=moSlider Name=DamagePointBlue
        Caption="Blue"
        MinValue=0
        MaxValue=255
       	bIntSlider=true
        LabelColor=(R=0,G=0,B=255,A=255)
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=19
        OnChange=InternalOnChange
    End Object
    sl_DamagePointBlue=DamagePointBlue

    DPIndex=0
}
