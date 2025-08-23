class HxEffectsGUIPanel extends HxGUIPanel;

const SECTION_HS = 0;
const SECTION_DN = 1;
const SECTION_DP = 2;

var automated moCheckBox ch_bHitSounds;
var automated moComboBox cb_HSHitSound;
var automated moSlider sl_HSVolume;
var automated moComboBox cb_HSPitchType;

var automated moCheckBox ch_bDamageNumbers;
var automated moFloatEdit nu_DNPosX;
var automated moFloatEdit nu_DNPosY;

var automated moComboBox cb_DPPoint;
var automated moNumericEdit nu_DPValue;
var automated moSlider sl_DPPitch;
var automated moNumericEdit nu_DPFontModifier;
var automated moSlider sl_DPRed;
var automated moSlider sl_DPGreen;
var automated moSlider sl_DPBlue;

var int DPIndex;
var HxAgent Agent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);

    Sections[SECTION_HS].ManageComponent(ch_bHitSounds);
    Sections[SECTION_HS].ManageComponent(cb_HSHitSound);
    Sections[SECTION_HS].ManageComponent(sl_HSVolume);
    Sections[SECTION_HS].ManageComponent(cb_HSPitchType);

    Sections[SECTION_DN].ManageComponent(ch_bDamageNumbers);
    Sections[SECTION_DN].ManageComponent(nu_DNPosX);
    Sections[SECTION_DN].ManageComponent(nu_DNPosY);

    Sections[SECTION_DP].ManageComponent(cb_DPPoint);
    Sections[SECTION_DP].ManageComponent(nu_DPValue);
    Sections[SECTION_DP].ManageComponent(sl_DPPitch);
    Sections[SECTION_DP].ManageComponent(nu_DPFontModifier);
    Sections[SECTION_DP].ManageComponent(sl_DPRed);
    Sections[SECTION_DP].ManageComponent(sl_DPBlue);
    Sections[SECTION_DP].ManageComponent(sl_DPGreen);

    for (i = 0; i < class'HxHitEffects'.default.HitSounds.Length; ++i)
    {
        cb_HSHitSound.AddItem(string(class'HxHitEffects'.default.HitSounds[i]));
    }
    for (i = 0; i < ArrayCount(class'HxHitEffects'.default.EHxPitchNames); ++i)
    {
        cb_HSPitchType.AddItem(class'HxHitEffects'.default.EHxPitchNames[i]);
    }
    for (i = 0; i < ArrayCount(class'HxHitEffects'.default.DamagePointNames); ++i)
    {
        cb_DPPoint.AddItem(class'HxHitEffects'.default.DamagePointNames[i]);
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
            SECTION_DP, !Agent.bAllowHitSounds && !Agent.bAllowDamageNumbers, HIDE_DUE_DISABLE);
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
        case cb_HSHitSound:
            Agent.HitEffects.SelectedHitSound = cb_HSHitSound.GetIndex();
            break;
        case sl_HSVolume:
            Agent.HitEffects.HitSoundVolume = sl_HSVolume.GetValue();
            break;
        case cb_HSPitchType:
            Agent.HitEffects.PitchType = EHxPitch(cb_HSPitchType.GetIndex());
            break;
        case ch_bDamageNumbers:
            Agent.HitEffects.bDamageNumbers = ch_bDamageNumbers.IsChecked();
            UpdateDamageNumbers();
            UpdateDamagePoints();
            break;
        case nu_DPFontModifier:
            Agent.HitEffects.DamagePoints[DPIndex].FontModifier = nu_DPFontModifier.GetValue();
            break;
        case nu_DNPosX:
            Agent.HitEffects.PosX = nu_DNPosX.GetValue();
            break;
        case nu_DNPosY:
            Agent.HitEffects.PosY = nu_DNPosY.GetValue();
            break;
        case cb_DPPoint:
            DPIndex = cb_DPPoint.GetIndex();
            SetDamagePoints();
            break;
        case nu_DPValue:
            Agent.HitEffects.DamagePoints[DPIndex].Value = nu_DPValue.GetValue();
            break;
        case sl_DPPitch:
            Agent.HitEffects.DamagePoints[DPIndex].Pitch = sl_DPPitch.GetValue();
            break;
        case sl_DPRed:
            Agent.HitEffects.DamagePoints[DPIndex].Color.R = sl_DPRed.GetValue();
            break;
        case sl_DPGreen:
            Agent.HitEffects.DamagePoints[DPIndex].Color.G = sl_DPGreen.GetValue();
            break;
        case sl_DPBlue:
            Agent.HitEffects.DamagePoints[DPIndex].Color.B = sl_DPBlue.GetValue();
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
        EnableComponent(cb_HSHitSound);
        EnableComponent(sl_HSVolume);
        EnableComponent(cb_HSPitchType);
        EnableComponent(sl_DPPitch);
    }
    else
    {
        DisableComponent(cb_HSHitSound);
        DisableComponent(sl_HSVolume);
        DisableComponent(cb_HSPitchType);
        DisableComponent(sl_DPPitch);
    }
}

function UpdateDamageNumbers()
{
    if (Agent.HitEffects.bDamageNumbers)
    {
        EnableComponent(nu_DNPosX);
        EnableComponent(nu_DNPosY);
        EnableComponent(nu_DPFontModifier);
        EnableComponent(sl_DPRed);
        EnableComponent(sl_DPGreen);
        EnableComponent(sl_DPBlue);
    }
    else
    {
        DisableComponent(nu_DNPosX);
        DisableComponent(nu_DNPosY);
        DisableComponent(nu_DPFontModifier);
        DisableComponent(sl_DPRed);
        DisableComponent(sl_DPGreen);
        DisableComponent(sl_DPBlue);
    }
}

function UpdateDamagePoints()
{
    if (Agent.HitEffects.bHitSounds || Agent.HitEffects.bDamageNumbers)
    {
        EnableComponent(cb_DPPoint);
        EnableComponent(nu_DPValue);
    }
    else
    {
        DisableComponent(cb_DPPoint);
        DisableComponent(nu_DPValue);
    }
}

function SetHitSounds()
{
    ch_bHitSounds.Checked(Agent.HitEffects.bHitSounds);
    cb_HSHitSound.SetIndex(Agent.HitEffects.SelectedHitSound);
    sl_HSVolume.SetComponentValue(Agent.HitEffects.HitSoundVolume);
    cb_HSPitchType.SetIndex(Agent.HitEffects.PitchType);
}

function SetDamageNumbers()
{
    ch_bDamageNumbers.Checked(Agent.HitEffects.bDamageNumbers);
    nu_DNPosX.SetComponentValue(Agent.HitEffects.PosX);
    nu_DNPosY.SetComponentValue(Agent.HitEffects.PosY);
}

function SetDamagePoints()
{
    nu_DPValue.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Value);
    sl_DPPitch.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Pitch);
    nu_DPFontModifier.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].FontModifier);
    sl_DPRed.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.R);
    sl_DPGreen.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.G);
    sl_DPBlue.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.B);
}

defaultproperties
{
    Begin Object class=AltSectionBackground Name=HSSection
        Caption="Hit Sounds"
        WinHeight=0.274
    End Object
    Sections(0)=HSSection

    Begin Object class=AltSectionBackground Name=DNSection
        Caption="Damage Numbers"
        WinHeight=0.2055
    End Object
    Sections(1)=DNSection

    Begin Object class=AltSectionBackground Name=DPSection
        Caption="Damage Curve"
    	WinHeight=0.4795
    End Object
    Sections(2)=DPSection

    Begin Object class=moCheckBox Name=HitSounds
        Caption="Enable hit sounds"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=0
        OnChange=InternalOnChange
    End Object
    ch_bHitSounds=HitSounds

    Begin Object class=moComboBox Name=HSHitSound
		Caption="Sound"
        bReadOnly=true
        bAlwaysNotify=false
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=1
        OnChange=InternalOnChange
	End Object
    cb_HSHitSound=HSHitSound

    Begin Object class=moSlider Name=HSVolume
        Caption="Volume"
        MinValue=0.0
        MaxValue=1.0
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=2
        OnChange=InternalOnChange
    End Object
    sl_HSVolume=HSVolume

    Begin Object class=moComboBox Name=HSPitchType
        Caption="Pitch"
        bReadOnly=true
        bAlwaysNotify=false
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=3
        OnChange=InternalOnChange
    End Object
    cb_HSPitchType=HSPitchType

    Begin Object class=moCheckBox Name=DamageNumbers
        Caption="Enable damage numbers"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=4
        OnChange=InternalOnChange
    End Object
    ch_bDamageNumbers=DamageNumbers

    Begin Object class=moFloatEdit Name=DNPosX
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
        TabOrder=5
        OnChange=InternalOnChange
    End Object
    nu_DNPosX=DNPosX

    Begin Object class=moFloatEdit Name=DNPosY
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
        TabOrder=6
        OnChange=InternalOnChange
    End Object
    nu_DNPosY=DNPosY

    Begin Object class=moComboBox Name=DPPoint
		Caption="Point"
        bReadOnly=true
        bAlwaysNotify=false
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=7
        OnChange=InternalOnChange
	End Object
    cb_DPPoint=DPPoint

    Begin Object class=moNumericEdit Name=DPValue
        Caption="Damage value"
        MinValue=-300
        MaxValue=300
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=8
        OnChange=InternalOnChange
    End Object
    nu_DPValue=DPValue

    Begin Object class=moSlider Name=DPPitch
        Caption="Pitch"
        MinValue=0.0
        MaxValue=1.0
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=9
        OnChange=InternalOnChange
    End Object
    sl_DPPitch=DPPitch

    Begin Object class=moNumericEdit Name=DPFontModifier
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
    nu_DPFontModifier=DPFontModifier

    Begin Object class=moSlider Name=DPRed
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
        TabOrder=11
        OnChange=InternalOnChange
    End Object
    sl_DPRed=DPRed

    Begin Object class=moSlider Name=DPGreen
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
        TabOrder=12
        OnChange=InternalOnChange
    End Object
    sl_DPGreen=DPGreen

    Begin Object class=moSlider Name=DPBlue
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
        TabOrder=13
        OnChange=InternalOnChange
    End Object
    sl_DPBlue=DPBlue

    DPIndex=0
}
