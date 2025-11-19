class HxEffectsPanel extends HxPanel;

const SECTION_HS = 0;
const SECTION_DN = 1;
const SECTION_DP = 2;

var automated moCheckBox ch_bAllowHitSounds;
var automated moCheckBox ch_bHitSounds;
var automated moComboBox cb_HSHitSound;
var automated moSlider sl_HSVolume;
var automated moComboBox cb_HSPitchMode;

var automated moCheckBox ch_bAllowDamageNumbers;
var automated moCheckBox ch_bDamageNumbers;
var automated moComboBox cb_DMode;
var automated moFloatEdit nu_DNPosX;
var automated moFloatEdit nu_DNPosY;

var automated GUIComboBox cb_DPPoint;
var automated GUIImage i_DPPReview;
var automated moNumericEdit nu_DPValue;
var automated moSlider sl_DPPitch;
var automated GUIButton b_PlaySound;
var automated GUIImage i_FillerRight;
var automated moSlider nu_DPScale;
var automated moSlider sl_DPRed;
var automated moSlider sl_DPGreen;
var automated moSlider sl_DPBlue;

var int DPIndex;
var HxAgent Agent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);

    Sections[SECTION_HS].ManageComponent(ch_bAllowHitSounds);
    Sections[SECTION_HS].ManageComponent(ch_bHitSounds);
    Sections[SECTION_HS].ManageComponent(cb_HSHitSound);
    Sections[SECTION_HS].ManageComponent(sl_HSVolume);
    Sections[SECTION_HS].ManageComponent(cb_HSPitchMode);

    Sections[SECTION_DN].ManageComponent(ch_bAllowDamageNumbers);
    Sections[SECTION_DN].ManageComponent(ch_bDamageNumbers);
    Sections[SECTION_DN].ManageComponent(cb_DMode);
    Sections[SECTION_DN].ManageComponent(nu_DNPosX);
    Sections[SECTION_DN].ManageComponent(nu_DNPosY);

    Sections[SECTION_DP].ManageComponent(cb_DPPoint);
    Sections[SECTION_DP].ManageComponent(i_DPPreview);
    Sections[SECTION_DP].ManageComponent(nu_DPValue);
    Sections[SECTION_DP].ManageComponent(sl_DPPitch);
    Sections[SECTION_DP].ManageComponent(b_PlaySound);
    Sections[SECTION_DP].ManageComponent(i_FillerRight);
    Sections[SECTION_DP].ManageComponent(nu_DPScale);
    Sections[SECTION_DP].ManageComponent(sl_DPRed);
    Sections[SECTION_DP].ManageComponent(sl_DPGreen);
    Sections[SECTION_DP].ManageComponent(sl_DPBlue);

    for (i = 0; i < class'HxSounds'.default.HitSounds.Length; ++i)
    {
        cb_HSHitSound.AddItem(string(class'HxSounds'.default.HitSounds[i]));
    }
    for (i = 0; i < ArrayCount(class'HxHitEffects'.default.EHxPitchModeNames); ++i)
    {
        cb_HSPitchMode.AddItem(class'HxHitEffects'.default.EHxPitchModeNames[i]);
    }
    for (i = 0; i < ArrayCount(class'HxHitEffects'.default.EHxDModeNames); ++i)
    {
        cb_DMode.AddItem(class'HxHitEffects'.default.EHxDModeNames[i]);
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
        if (!Initialize())
        {
            HideAllSections(true, HIDE_DUE_INIT);
            SetTimer(0.1, true);
        }
        else
        {
            UpdateAll();
        }
    }
}

event Timer()
{
    if (Initialize() && Agent.IsSynchronized())
    {
        KillTimer();
        UpdateAll();
    }
}

function InternalOnChange(GUIComponent C)
{
    if (Agent == None)
    {
        return;
    }
    switch(C)
    {
        case ch_bAllowHitSounds:
            if (Agent.SetAllowHitSounds(ch_bAllowHitSounds.IsChecked()))
            {
                SetTimer(0.1, true);
            }
            break;
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
        case cb_HSPitchMode:
            Agent.HitEffects.PitchMode = EHxPitchMode(cb_HSPitchMode.GetIndex());
            break;
        case ch_bAllowDamageNumbers:
            if (Agent.SetAllowDamageNumbers(ch_bAllowDamageNumbers.IsChecked()))
            {
                SetTimer(0.1, true);
            }
            break;
        case ch_bDamageNumbers:
            Agent.HitEffects.bDamageNumbers = ch_bDamageNumbers.IsChecked();
            UpdateDamageNumbers();
            UpdateDamagePoints();
            break;
        case cb_DMode:
            Agent.HitEffects.SetDMode(EHxDMode(cb_DMode.GetIndex()));
            break;
        case nu_DNPosX:
            Agent.HitEffects.SetPosX(nu_DNPosX.GetValue());
            break;
        case nu_DNPosY:
            Agent.HitEffects.SetPosY(nu_DNPosY.GetValue());
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
        case nu_DPScale:
            Agent.HitEffects.DamagePoints[DPIndex].Scale = nu_DPScale.GetValue();
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
    if (Agent != None)
    {
        return true;
    }
    Agent = class'HxAgent'.static.GetAgent(PlayerOwner());
    if (Agent != None)
    {
        SetHitSounds();
        SetDamageNumbers();
        SetDamagePoints();
        return true;
    }
    return false;
}

function UpdateAll()
{
    local bool bAdmin;

    bAdmin = IsAdmin();
    if (bAdmin)
    {
        EnableComponent(ch_bAllowHitSounds);
        EnableComponent(ch_bAllowDamageNumbers);
    }
    else
    {
        DisableComponent(ch_bAllowHitSounds);
        DisableComponent(ch_bAllowDamageNumbers);
    }
    if (!Agent.bAllowHitSounds)
    {
        DisableComponent(ch_bHitSounds);
    }
    else
    {
        EnableComponent(ch_bHitSounds);
    }
    if (!Agent.bAllowDamageNumbers)
    {
        DisableComponent(ch_bDamageNumbers);
    }
    else
    {
        EnableComponent(ch_bDamageNumbers);
    }
    UpdateHitSounds();
    UpdateDamageNumbers();
    UpdateDamagePoints();
    HideSection(SECTION_HS, !bAdmin && !Agent.bAllowHitSounds, HIDE_DUE_DISABLE);
    HideSection(SECTION_DN, !bAdmin && !Agent.bAllowDamageNumbers, HIDE_DUE_DISABLE);
    HideSection(
        SECTION_DP,
        !bAdmin && !Agent.bAllowHitSounds && !Agent.bAllowDamageNumbers,
        HIDE_DUE_DISABLE);
}

function UpdateHitSounds()
{
    if (Agent.bAllowHitSounds && Agent.HitEffects.bHitSounds)
    {
        EnableComponent(cb_HSHitSound);
        EnableComponent(sl_HSVolume);
        EnableComponent(cb_HSPitchMode);
        EnableComponent(sl_DPPitch);
        EnableComponent(b_PlaySound);
    }
    else
    {
        DisableComponent(cb_HSHitSound);
        DisableComponent(sl_HSVolume);
        DisableComponent(cb_HSPitchMode);
        DisableComponent(sl_DPPitch);
        DisableComponent(b_PlaySound);
    }
}

function UpdateDamageNumbers()
{
    if (Agent.bAllowDamageNumbers && Agent.HitEffects.bDamageNumbers)
    {
        EnableComponent(cb_DMode);
        EnableComponent(nu_DNPosX);
        EnableComponent(nu_DNPosY);
        EnableComponent(nu_DPScale);
        EnableComponent(sl_DPRed);
        EnableComponent(sl_DPGreen);
        EnableComponent(sl_DPBlue);
    }
    else
    {
        DisableComponent(cb_DMode);
        DisableComponent(nu_DNPosX);
        DisableComponent(nu_DNPosY);
        DisableComponent(nu_DPScale);
        DisableComponent(sl_DPRed);
        DisableComponent(sl_DPGreen);
        DisableComponent(sl_DPBlue);
    }
}

function UpdateDamagePoints()
{
    if ((Agent.bAllowHitSounds && Agent.HitEffects.bHitSounds)
        || (Agent.bAllowDamageNumbers && Agent.HitEffects.bDamageNumbers))
    {
        EnableComponent(cb_DPPoint);
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
        DisableComponent(cb_DPPoint);
        DisableComponent(nu_DPValue);
    }
}

function SetHitSounds()
{
    ch_bAllowHitSounds.Checked(Agent.bAllowHitSounds);
    ch_bHitSounds.Checked(Agent.HitEffects.bHitSounds);
    cb_HSHitSound.SetIndex(Agent.HitEffects.SelectedHitSound);
    sl_HSVolume.SetComponentValue(Agent.HitEffects.HitSoundVolume);
    cb_HSPitchMode.SetIndex(Agent.HitEffects.PitchMode);
}

function SetDamageNumbers()
{
    ch_bAllowDamageNumbers.Checked(Agent.bAllowDamageNumbers);
    ch_bDamageNumbers.Checked(Agent.HitEffects.bDamageNumbers);
    cb_DMode.SetIndex(Agent.HitEffects.DMode);
    nu_DNPosX.SetComponentValue(Agent.HitEffects.PosX);
    nu_DNPosY.SetComponentValue(Agent.HitEffects.PosY);
}

function SetDamagePoints()
{
    if (DPIndex == 0)
    {
        DisableComponent(nu_DPValue);
    }
    else
    {
        EnableComponent(nu_DPValue);
    }
    nu_DPValue.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Value);
    sl_DPPitch.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Pitch);
    nu_DPScale.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Scale);
    sl_DPRed.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.R);
    sl_DPGreen.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.G);
    sl_DPBlue.SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.B);
}

function DrawDPPreview(Canvas C)
{
    local string DamageNumber;
    local float SavedOrgX;
    local float SavedOrgY;
	local float SavedClipX;
    local float SavedClipY;
    local float XL;
    local float YL;

    if (Agent == None || !Agent.bAllowDamageNumbers || !Agent.HitEffects.bDamageNumbers)
    {
        return;
    }
   	SavedOrgX = C.OrgX;
	SavedOrgY = C.OrgY;
	SavedClipX = C.ClipX;
	SavedClipY = C.ClipY;

	C.OrgX = i_DPPReview.ActualLeft();
	C.OrgY = i_DPPReview.ActualTop();
	C.ClipX = i_DPPReview.ActualWidth();
	C.ClipY = i_DPPReview.ActualHeight();

    DamageNumber = string(Agent.HitEffects.DamagePoints[DPIndex].Value);
    C.DrawColor = Agent.HitEffects.DamagePoints[DPIndex].Color;
    C.Font = class'HxHitEffectsFont'.static.GetFont(SavedClipX);
    C.FontScaleX = Agent.HitEffects.ToAbsoluteScale(Agent.HitEffects.DamagePoints[DPIndex].Scale);
    C.FontScaleY = Agent.HitEffects.ToAbsoluteScale(Agent.HitEffects.DamagePoints[DPIndex].Scale);
    C.StrLen(DamageNumber, XL, YL);
    C.SetPos((C.ClipX - XL) * 0.5, (C.ClipY - YL) * 0.55);
    C.DrawTextClipped(DamageNumber);

    C.OrgX = SavedOrgX;
	C.OrgY = SavedOrgY;
	C.ClipX = SavedClipX;
	C.ClipY = SavedClipY;
}

function bool DPPointPreDraw(Canvas C)
{
    cb_DPPoint.WinWidth = i_FillerRight.WinLeft + i_FillerRight.WinWidth - cb_DPPoint.WinLeft;
    return false;
}

function bool PlaySoundOnClick(GUIComponent Sender)
{
    Agent.HitEffects.PlayHitSound(Agent.HitEffects.DamagePoints[DPIndex].Value);
    return true;
}

static function AddToMenu()
{
    class'HxMenu'.static.AddPanel(Default.Class, "Effects", "Hit Effect Options");
}

defaultproperties
{
    bDoubleColumn=true

    Begin Object class=AltSectionBackground Name=HSSection
        Caption="Hit Sounds"
        WinHeight=0.48
    End Object
    Sections(0)=HSSection

    Begin Object class=AltSectionBackground Name=DNSection
        Caption="Damage Numbers"
        WinHeight=0.48
    End Object
    Sections(1)=DNSection

    Begin Object class=AltSectionBackground Name=DPSection
        Caption="Customize Sound & Visuals"
    	WinHeight=0.48
        NumColumns=2
        bRemapStack=false
    End Object
    Sections(2)=DPSection

    Begin Object class=moCheckBox Name=AllowHitSounds
        Caption="Allow hit sounds"
        Hint="Requires server admin to change it"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=0
        OnChange=InternalOnChange
    End Object
    ch_bAllowHitSounds=AllowHitSounds

    Begin Object class=moCheckBox Name=HitSounds
        Caption="Enable hit sounds"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=1
        OnChange=InternalOnChange
    End Object
    ch_bHitSounds=HitSounds

    Begin Object class=moComboBox Name=HSHitSound
		Caption="Sound"
        ComponentWidth=0.70
        bReadOnly=true
        bAlwaysNotify=false
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=2
        OnChange=InternalOnChange
	End Object
    cb_HSHitSound=HSHitSound

    Begin Object class=moSlider Name=HSVolume
        Caption="Volume"
        MinValue=0
        MaxValue=1.0
        ComponentWidth=0.70
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=3
        OnChange=InternalOnChange
    End Object
    sl_HSVolume=HSVolume

    Begin Object class=moComboBox Name=HSPitchMode
        Caption="Pitch mode"
        ComponentWidth=0.70
        bReadOnly=true
        bAlwaysNotify=false
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=4
        OnChange=InternalOnChange
    End Object
    cb_HSPitchMode=HSPitchMode

    Begin Object class=moCheckBox Name=AllowDamageNumbers
        Caption="Allow damage numbers"
        Hint="Requires server admin to change it"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=5
        OnChange=InternalOnChange
    End Object
    ch_bAllowDamageNumbers=AllowDamageNumbers

    Begin Object class=moCheckBox Name=DamageNumbers
        Caption="Enable damage numbers"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=6
        OnChange=InternalOnChange
    End Object
    ch_bDamageNumbers=DamageNumbers

    Begin Object class=moComboBox Name=DMode
        Caption="Mode"
        ComponentWidth=0.70
        bReadOnly=true
        bAlwaysNotify=false
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=7
        OnChange=InternalOnChange
    End Object
    cb_DMode=DMode


    Begin Object class=moFloatEdit Name=DNPosX
        Caption="X position"
        MinValue=0.0
        MaxValue=1.0
        Step=0.010000
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.35
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=8
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
        ComponentWidth=0.35
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=9
        OnChange=InternalOnChange
    End Object
    nu_DNPosY=DNPosY

    Begin Object class=GUIComboBox Name=DPPoint
        bReadOnly=true
        bBoundToParent=true
        bScaleToParent=true
        bStandardized=true
        StandardHeight=0.03
        TabOrder=10
        OnPreDraw=DPPointPreDraw
        OnChange=InternalOnChange
	End Object
    cb_DPPoint=DPPoint

    Begin Object class=GUIImage Name=DPPreview
		Image=Material'2K4Menus.Controls.buttonSquare_b'
		ImageColor=(R=0,G=0,B=0,A=255)
		ImageStyle=ISTY_Stretched
		ImageRenderStyle=MSTY_Alpha
        bStandardized=true
        StandardHeight=0.032
        TabOrder=11
		OnRendered=DrawDPPreview
	End Object
	i_DPPReview=DPPreview

    Begin Object class=moNumericEdit Name=DPValue
        Caption="Damage value"
        MinValue=-300
        MaxValue=300
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.35
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=12
        OnChange=InternalOnChange
    End Object
    nu_DPValue=DPValue

    Begin Object class=moSlider Name=DPPitch
        Caption="Pitch"
        MinValue=0.0
        MaxValue=1.0
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.70
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=13
        OnChange=InternalOnChange
    End Object
    sl_DPPitch=DPPitch

    Begin Object class=GUIButton Name=PlaySound
        Caption="Play sound"
        bStandardized=true
        StandardHeight=0.032
        TabOrder=14
		OnClick=PlaySoundOnClick
        OnClickSound=CS_None
    End Object
    b_PlaySound=PlaySound

    Begin Object class=GUIImage Name=FillerRight
        bBoundToParent=true
        bScaleToParent=true
        bStandardized=true
        StandardHeight=0.03
	End Object
    i_FillerRight=FillerRight

    Begin Object class=moSlider Name=DPScale
        Caption="Scale"
        MinValue=0.00
        MaxValue=1.00
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.70
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=15
        OnChange=InternalOnChange
    End Object
    nu_DPScale=DPScale

    Begin Object class=moSlider Name=DPRed
        Caption="Red"
        MinValue=0
        MaxValue=255
       	bIntSlider=true
        LabelColor=(R=255,G=0,B=0,A=255)
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.70
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=16
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
        ComponentWidth=0.70
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=17
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
        ComponentWidth=0.70
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=18
        OnChange=InternalOnChange
    End Object
    sl_DPBlue=DPBlue

    DPIndex=0
}
