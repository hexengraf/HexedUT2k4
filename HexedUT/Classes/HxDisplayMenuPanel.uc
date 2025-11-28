class HxDisplayMenuPanel extends HxMenuPanel;

const SECTION_SPAWN_PROTECTION = 0;
const SECTION_HIT_SOUNDS = 2;
const SECTION_DAMAGE_NUMBERS = 3;
const SECTION_CUSTOMIZE = 4;

var automated array<HxMenuOption> SpawnProtectionOptions;
var automated array<HxMenuOption> HitEffectsOptions;
var automated array<HxMenuOption> DamageNumbersOptions;
var automated array<HxMenuOption> CustomizeOptions;

var automated GUIImage i_DPPReview;
var automated GUIButton b_PlaySound;
var automated GUIImage i_FillerRight;

var int DPIndex;
var HxAgent Agent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);

    for (i = 0; i < SpawnProtectionOptions.Length; ++i)
    {
        Sections[SECTION_SPAWN_PROTECTION].ManageComponent(SpawnProtectionOptions[i]);
    }
    for (i = 0; i < 4; ++i)
    {
        Sections[SECTION_HIT_SOUNDS].ManageComponent(HitEffectsOptions[i]);
    }
    for (i = 4; i < HitEffectsOptions.Length; ++i)
    {
        Sections[SECTION_DAMAGE_NUMBERS].ManageComponent(HitEffectsOptions[i]);
    }
    for (i = 0; i < CustomizeOptions.Length; ++i)
    {
        Sections[SECTION_CUSTOMIZE].ManageComponent(CustomizeOptions[i]);
        if (i == 0)
        {
            Sections[SECTION_CUSTOMIZE].ManageComponent(i_DPPreview);
        }
        if (i == 2)
        {
            Sections[SECTION_CUSTOMIZE].ManageComponent(b_PlaySound);
            Sections[SECTION_CUSTOMIZE].ManageComponent(i_FillerRight);
        }
    }
    for (i = 0; i < class'HxSounds'.default.HitSounds.Length; ++i)
    {
        HxMenuComboBox(HitEffectsOptions[1]).AddItem(string(class'HxSounds'.default.HitSounds[i]));
    }
}

function bool Initialize()
{
    local int i;

    if (Agent != None)
    {
        return true;
    }
    Agent = class'HxAgent'.static.GetAgent(PlayerOwner());
    if (Agent != None)
    {
        for (i = 0; i < SpawnProtectionOptions.Length; ++i)
        {
            SpawnProtectionOptions[i].Target = Agent.SpawnProtectionTimer;
        }
        for (i = 0; i < HitEffectsOptions.Length; ++i)
        {
            HitEffectsOptions[i].Target = Agent.HitEffects;
        }
        CustomizeOptions[0].Target = Self;
        return true;
    }
    return false;
}

function Refresh()
{
    local int i;

    for (i = 0; i < SpawnProtectionOptions.Length; ++i)
    {
        SpawnProtectionOptions[i].GetValueFromTarget();
    }
    for (i = 0; i < HitEffectsOptions.Length; ++i)
    {
        HitEffectsOptions[i].GetValueFromTarget();
    }
    SpawnProtectionAfterChange();
    HitSoundsAfterChange();
    DamageNumbersAfterChange();
    RefreshCustomizeSection();
    HideSection(SECTION_SPAWN_PROTECTION, false);
    HideSection(SECTION_HIT_SOUNDS, !Agent.bAllowHitSounds, HIDE_DUE_DISABLE);
    HideSection(SECTION_DAMAGE_NUMBERS, !Agent.bAllowDamageNumbers, HIDE_DUE_DISABLE);
    HideSection(
        SECTION_CUSTOMIZE, !Agent.bAllowHitSounds && !Agent.bAllowDamageNumbers, HIDE_DUE_DISABLE);
}

function SpawnProtectionAfterChange()
{
    local int i;

    for (i = 1; i < SpawnProtectionOptions.Length; ++i)
    {
        SpawnProtectionOptions[i].SetEnable(Agent.SpawnProtectionTimer.bShowTimer);
    }
}

function HitSoundsAfterChange()
{
    local int i;
    local bool bHitSoundsEnabled;
    local bool bAnyEffectEnabled;

    bHitSoundsEnabled = Agent.bAllowHitSounds && Agent.HitEffects.bHitSounds;
    bAnyEffectEnabled = bHitSoundsEnabled
        || (Agent.bAllowDamageNumbers && Agent.HitEffects.bDamageNumbers);

    for (i = 1; i < 4; ++i)
    {
        HitEffectsOptions[i].SetEnable(Agent.HitEffects.bHitSounds);
    }
    CustomizeOptions[0].SetEnable(bAnyEffectEnabled);
    CustomizeOptions[1].SetEnable(DPIndex != 0 && bAnyEffectEnabled);
    CustomizeOptions[2].SetEnable(bHitSoundsEnabled);
    if (bHitSoundsEnabled)
    {
        EnableComponent(b_PlaySound);
    }
    else
    {
        DisableComponent(b_PlaySound);
    }
}

function DamageNumbersAfterChange()
{
    local int i;
    local bool bDamageNumbersEnabled;
    local bool bAnyEffectEnabled;

    bDamageNumbersEnabled = Agent.bAllowDamageNumbers && Agent.HitEffects.bDamageNumbers;
    bAnyEffectEnabled = bDamageNumbersEnabled
        || (Agent.bAllowHitSounds && Agent.HitEffects.bHitSounds);

    for (i = 5; i < HitEffectsOptions.Length; ++i)
    {
        HitEffectsOptions[i].SetEnable(Agent.HitEffects.bDamageNumbers);
    }
    for (i = 3; i < CustomizeOptions.Length; ++i)
    {
        CustomizeOptions[i].SetEnable(bDamageNumbersEnabled);
    }
    CustomizeOptions[0].SetEnable(bAnyEffectEnabled);
    CustomizeOptions[1].SetEnable(DPIndex != 0 && bAnyEffectEnabled);
}

function SpawnProtectionOnChange(GUIComponent C)
{
    Super.TargetOnChange(C);
    SpawnProtectionAfterChange();

}

function HitSoundsOnChange(GUIComponent C)
{
    Super.TargetOnChange(C);
    HitSoundsAfterChange();
}

function DamageNumbersOnChange(GUIComponent C)
{
    Super.TargetOnChange(C);
    DamageNumbersAfterChange();
}

function CustomizeOnChange(GUIComponent C)
{
    local HxMenuOption Option;

    Option = HxMenuOption(C);
    if (Agent == None || Option == None)
    {
        return;
    }
    switch(Option)
    {
        case CustomizeOptions[0]:
            Super.TargetOnChange(C);
            RefreshCustomizeSection();
            break;
        case CustomizeOptions[1]:
            Agent.HitEffects.DamagePoints[DPIndex].Value = int(Option.GetComponentValue());
            break;
        case CustomizeOptions[2]:
            Agent.HitEffects.DamagePoints[DPIndex].Pitch = float(Option.GetComponentValue());
            break;
        case CustomizeOptions[3]:
            Agent.HitEffects.DamagePoints[DPIndex].Scale = float(Option.GetComponentValue());
            break;
        case CustomizeOptions[4]:
            Agent.HitEffects.DamagePoints[DPIndex].Color.R = int(Option.GetComponentValue());
            break;
        case CustomizeOptions[5]:
            Agent.HitEffects.DamagePoints[DPIndex].Color.G = int(Option.GetComponentValue());
            break;
        case CustomizeOptions[6]:
            Agent.HitEffects.DamagePoints[DPIndex].Color.B = int(Option.GetComponentValue());
            break;
    }
    Agent.HitEffects.SaveConfig();
}

function RefreshCustomizeSection()
{
    CustomizeOptions[1].SetEnable(DPIndex != 0);
    CustomizeOptions[1].SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Value);
    CustomizeOptions[2].SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Pitch);
    CustomizeOptions[3].SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Scale);
    CustomizeOptions[4].SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.R);
    CustomizeOptions[5].SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.G);
    CustomizeOptions[6].SetComponentValue(Agent.HitEffects.DamagePoints[DPIndex].Color.B);
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
    CustomizeOptions[0].WinWidth =
        i_FillerRight.WinLeft + i_FillerRight.WinWidth - CustomizeOptions[0].WinLeft;
    return false;
}

function bool PlaySoundOnClick(GUIComponent Sender)
{
    Agent.HitEffects.PlayHitSound(Agent.HitEffects.DamagePoints[DPIndex].Value);
    return true;
}

defaultproperties
{
    Begin Object class=AltSectionBackground Name=SpawnProtectionSection
        Caption="Spawn Protection"
        WinHeight=0.24
    End Object

    Begin Object class=AltSectionBackground Name=HitSoundsSection
        Caption="Hit Sounds"
        WinHeight=0.32
    End Object

    Begin Object class=AltSectionBackground Name=DamageNumbersSection
        Caption="Damage Numbers"
        WinHeight=0.32
    End Object

    Begin Object class=AltSectionBackground Name=DPSection
        Caption="Customize Hit Sounds & Damage Numbers"
        WinHeight=0.40
        NumColumns=2
        bRemapStack=false
    End Object

    Begin Object class=HxMenuCheckBox Name=SPShowTimer
        Caption="Show timer"
        PropertyName="bShowTimer"
        TabOrder=0
        OnChange=SpawnProtectionOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=SPTimerPosX
        Caption="X position"
        PropertyName="PosX"
        TabOrder=1
        OnChange=TargetOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=SPTimerPosY
        Caption="Y position"
        PropertyName="PosY"
        TabOrder=2
        OnChange=TargetOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=HitSounds
        Caption="Enable hit sounds"
        PropertyName="bHitSounds"
        TabOrder=3
        OnChange=HitSoundsOnChange
    End Object

    Begin Object class=HxMenuComboBox Name=SelectedHitSound
        Caption="Sound"
        PropertyName="SelectedHitSound"
        TabOrder=4
        OnChange=TargetOnChange
    End Object

    Begin Object class=HxMenuSlider Name=HSVolume
        Caption="Volume"
        PropertyName="HitSoundVolume"
        TabOrder=5
        OnChange=TargetOnChange
    End Object

    Begin Object class=HxMenuEnumComboBox Name=HSPitchMode
        Caption="Pitch mode"
        PropertyName="PitchMode"
        EnumType=enum'EHxPitchMode'
        DisplayNames=("Disabled","Low to high","High to low")
        TabOrder=6
        OnChange=TargetOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DamageNumbers
        Caption="Enable damage numbers"
        PropertyName="bDamageNumbers"
        TabOrder=7
        OnChange=DamageNumbersOnChange
    End Object

    Begin Object class=HxMenuEnumComboBox Name=DMode
        Caption="Mode"
        PropertyName="DMode"
        EnumType=enum'EHxDMode'
        DisplayNames=("Static per hit","Static total","Static per hit & total","Float per hit","Float per hit & total")
        TabOrder=8
        OnChange=TargetOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=DNPosX
        Caption="X position"
        PropertyName="PosX"
        TabOrder=9
        OnChange=TargetOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=DNPosY
        Caption="Y position"
        PropertyName="PosY"
        TabOrder=10
        OnChange=TargetOnChange
    End Object

    Begin Object class=HxMenuComboBox Name=DPPoint
        PropertyName="DPIndex"
        DisplayNames=("Zero damage","Low damage","Medium damage","High damage","Extreme damage")
        ComponentWidth=1.00
        TabOrder=11
        OnPreDraw=DPPointPreDraw
        OnChange=CustomizeOnChange
    End Object

    Begin Object class=GUIImage Name=DPPreview
        Image=Material'2K4Menus.Controls.buttonSquare_b'
        ImageColor=(R=0,G=0,B=0,A=255)
        ImageStyle=ISTY_Stretched
        ImageRenderStyle=MSTY_Alpha
        bStandardized=true
        StandardHeight=0.032
        TabOrder=12
        OnRendered=DrawDPPreview
    End Object

    Begin Object class=HxMenuNumericEdit Name=DPValue
        Caption="Damage value"
        MinValue=-300
        MaxValue=300
        TabOrder=13
        OnChange=CustomizeOnChange
    End Object

    Begin Object class=HxMenuSlider Name=DPPitch
        Caption="Pitch"
        TabOrder=14
        OnChange=CustomizeOnChange
    End Object

    Begin Object class=GUIButton Name=PlaySound
        Caption="Play sound"
        bStandardized=true
        StandardHeight=0.032
        TabOrder=15
        OnClick=PlaySoundOnClick
        OnClickSound=CS_None
    End Object

    Begin Object class=GUIImage Name=FillerRight
        bBoundToParent=true
        bScaleToParent=true
        bStandardized=true
        StandardHeight=0.03
    End Object

    Begin Object class=HxMenuSlider Name=DPScale
        Caption="Scale"
        TabOrder=16
        OnChange=CustomizeOnChange
    End Object

    Begin Object class=HxMenuSlider Name=DPRed
        Caption="Red"
        MinValue=0
        MaxValue=255
        bIntSlider=true
        LabelColor=(R=255,G=0,B=0,A=255)
        TabOrder=17
        OnChange=CustomizeOnChange
    End Object

    Begin Object class=HxMenuSlider Name=DPGreen
        Caption="Green"
        MinValue=0
        MaxValue=255
        bIntSlider=true
        LabelColor=(R=0,G=255,B=0,A=255)
        TabOrder=18
        OnChange=CustomizeOnChange
    End Object

    Begin Object class=HxMenuSlider Name=DPBlue
        Caption="Blue"
        MinValue=0
        MaxValue=255
        bIntSlider=true
        LabelColor=(R=0,G=0,B=255,A=255)
        TabOrder=19
        OnChange=CustomizeOnChange
    End Object

    PanelCaption="Display"
    PanelHint="Display options"
    bInsertFront=true
    bDoubleColumn=true
    Sections(0)=SpawnProtectionSection
    Sections(1)=None
    Sections(2)=HitSoundsSection
    Sections(3)=DamageNumbersSection
    Sections(4)=DPSection
    SpawnProtectionOptions(0)=SPShowTimer
    SpawnProtectionOptions(1)=SPTimerPosX
    SpawnProtectionOptions(2)=SPTimerPosY
    HitEffectsOptions(0)=HitSounds
    HitEffectsOptions(1)=SelectedHitSound
    HitEffectsOptions(2)=HSVolume
    HitEffectsOptions(3)=HSPitchMode
    HitEffectsOptions(4)=DamageNumbers
    HitEffectsOptions(5)=DMode
    HitEffectsOptions(6)=DNPosX
    HitEffectsOptions(7)=DNPosY
    CustomizeOptions(0)=DPPoint
    CustomizeOptions(1)=DPValue
    CustomizeOptions(2)=DPPitch
    CustomizeOptions(3)=DPScale
    CustomizeOptions(4)=DPRed
    CustomizeOptions(5)=DPGreen
    CustomizeOptions(6)=DPBlue
    i_DPPReview=DPPreview
    b_PlaySound=PlaySound
    i_FillerRight=FillerRight
    DPIndex=0
}
