class HxGeneralPanel extends HxPanel;

const SECTION_STARTING_VALUES = 0;
const SECTION_SPAWN_PROTECTION = 1;
const SECTION_MOVEMENT = 2;

var automated moNumericEdit nu_SVBonusStartingHealth;
var automated moNumericEdit nu_SVBonusStartingShield;
var automated moNumericEdit nu_SVBonusStartingGrenades;

var automated moCheckBox ch_SPbShowTimer;
var automated moFloatEdit nu_SPTimerPosX;
var automated moFloatEdit nu_SPTimerPosY;

var automated moFloatEdit nu_MVMaxSpeedMultiplier;
var automated moFloatEdit nu_MVAirControlMultiplier;
var automated moFloatEdit nu_MVBaseJumpMultiplier;
var automated moFloatEdit nu_MVMultiJumpMultiplier;
var automated moNumericEdit nu_MVBonusMultiJumps;

var HxAgent Agent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);

    Sections[SECTION_STARTING_VALUES].ManageComponent(nu_SVBonusStartingHealth);
    Sections[SECTION_STARTING_VALUES].ManageComponent(nu_SVBonusStartingShield);
    Sections[SECTION_STARTING_VALUES].ManageComponent(nu_SVBonusStartingGrenades);

    Sections[SECTION_SPAWN_PROTECTION].ManageComponent(ch_SPbShowTimer);
    Sections[SECTION_SPAWN_PROTECTION].ManageComponent(nu_SPTimerPosX);
    Sections[SECTION_SPAWN_PROTECTION].ManageComponent(nu_SPTimerPosY);

    Sections[SECTION_MOVEMENT].ManageComponent(nu_MVMaxSpeedMultiplier);
    Sections[SECTION_MOVEMENT].ManageComponent(nu_MVAirControlMultiplier);
    Sections[SECTION_MOVEMENT].ManageComponent(nu_MVBaseJumpMultiplier);
    Sections[SECTION_MOVEMENT].ManageComponent(nu_MVMultiJumpMultiplier);
    Sections[SECTION_MOVEMENT].ManageComponent(nu_MVBonusMultiJumps);
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
    if (Initialize() && IsSynchronized())
    {
        KillTimer();
        UpdateAll();
    }
}

function bool IsSynchronized()
{
    return Agent.BonusStartingHealth == nu_SVBonusStartingHealth.GetValue()
        && Agent.BonusStartingShield == nu_SVBonusStartingShield.GetValue()
        && Agent.BonusStartingGrenades == nu_SVBonusStartingGrenades.GetValue()
        && Agent.MaxSpeedMultiplier == nu_MVMaxSpeedMultiplier.GetValue()
        && Agent.AirControlMultiplier == nu_MVAirControlMultiplier.GetValue()
        && Agent.BaseJumpMultiplier == nu_MVBaseJumpMultiplier.GetValue()
        && Agent.MultiJumpMultiplier == nu_MVMultiJumpMultiplier.GetValue()
        && Agent.BonusMultiJumps == nu_MVBonusMultiJumps.GetValue();
}

function StartingValuesSectionOnChange(GUIComponent C)
{
    if (Agent == None || !IsAdmin())
    {
        return;
    }
    switch(C)
    {
        case nu_SVBonusStartingHealth:
            Agent.ServerSetBonusStartingHealth(nu_SVBonusStartingHealth.GetValue());
            break;
        case nu_SVBonusStartingShield:
            Agent.ServerSetBonusStartingShield(nu_SVBonusStartingShield.GetValue());
            break;
        case nu_SVBonusStartingGrenades:
            Agent.ServerSetBonusStartingGrenades(nu_SVBonusStartingGrenades.GetValue());
            break;
        default:
            break;
    }
    SetTimer(0.1, true);
}

function SpawnProtectionSectionOnChange(GUIComponent C)
{
    if (Agent == None)
    {
        return;
    }
    switch(C)
    {
        case ch_SPbShowTimer:
            Agent.SpawnProtectionTimer.SetShowTimer(ch_SPbShowTimer.IsChecked());
            UpdateSpawnProtectionSection();
            break;
        case nu_SPTimerPosX:
            Agent.SpawnProtectionTimer.SetPosX(nu_SPTimerPosX.GetValue());
            break;
        case nu_SPTimerPosY:
            Agent.SpawnProtectionTimer.SetPosY(nu_SPTimerPosY.GetValue());
            break;
        default:
            break;
    }
    Agent.SpawnProtectionTimer.SaveConfig();
}

function MovementSectionOnChange(GUIComponent C)
{
    if (Agent == None || !IsAdmin())
    {
        return;
    }
    switch(C)
    {
        case nu_MVMaxSpeedMultiplier:
            Agent.ServerSetMaxSpeedMultiplier(nu_MVMaxSpeedMultiplier.GetValue());
            break;
        case nu_MVAirControlMultiplier:
            Agent.ServerSetAirControlMultiplier(nu_MVAirControlMultiplier.GetValue());
            break;
        case nu_MVBaseJumpMultiplier:
            Agent.ServerSetBaseJumpMultiplier(nu_MVBaseJumpMultiplier.GetValue());
            break;
        case nu_MVMultiJumpMultiplier:
            Agent.ServerSetMultiJumpMultiplier(nu_MVMultiJumpMultiplier.GetValue());
            break;
        case nu_MVBonusMultiJumps:
            Agent.ServerSetBonusMultiJumps(nu_MVBonusMultiJumps.GetValue());
            break;
        default:
            break;
    }
    SetTimer(0.1, true);
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
        SetStartingValuesSection();
        SetSpawnProtectionSection();
        SetMovementSection();
        return true;
    }
    return false;
}

function UpdateAll()
{
    local bool bAdmin;

    bAdmin = IsAdmin();
    UpdateStartingValuesSection(bAdmin);
    UpdateSpawnProtectionSection();
    UpdateMovementSection(bAdmin);
    HideSection(SECTION_STARTING_VALUES, false);
    HideSection(SECTION_SPAWN_PROTECTION, false);
    HideSection(SECTION_MOVEMENT, false);
}

function UpdateStartingValuesSection(bool bAdmin)
{
    if (bAdmin)
    {
        EnableComponent(nu_SVBonusStartingHealth);
        EnableComponent(nu_SVBonusStartingShield);
        EnableComponent(nu_SVBonusStartingGrenades);
    }
    else
    {
        DisableComponent(nu_SVBonusStartingHealth);
        DisableComponent(nu_SVBonusStartingShield);
        DisableComponent(nu_SVBonusStartingGrenades);
    }
}

function UpdateSpawnProtectionSection()
{
    if (Agent.SpawnProtectionTimer.bShowTimer)
    {
        EnableComponent(nu_SPTimerPosX);
        EnableComponent(nu_SPTimerPosY);
    }
    else
    {
        DisableComponent(nu_SPTimerPosX);
        DisableComponent(nu_SPTimerPosY);
    }
}

function UpdateMovementSection(bool bAdmin)
{
    if (bAdmin)
    {
        EnableComponent(nu_MVMaxSpeedMultiplier);
        EnableComponent(nu_MVAirControlMultiplier);
        EnableComponent(nu_MVBaseJumpMultiplier);
        EnableComponent(nu_MVMultiJumpMultiplier);
        EnableComponent(nu_MVBonusMultiJumps);
    }
    else
    {
        DisableComponent(nu_MVMaxSpeedMultiplier);
        DisableComponent(nu_MVAirControlMultiplier);
        DisableComponent(nu_MVBaseJumpMultiplier);
        DisableComponent(nu_MVMultiJumpMultiplier);
        DisableComponent(nu_MVBonusMultiJumps);
    }
}

function SetStartingValuesSection()
{
    nu_SVBonusStartingHealth.SetComponentValue(Agent.BonusStartingHealth);
    nu_SVBonusStartingShield.SetComponentValue(Agent.BonusStartingShield);
    nu_SVBonusStartingGrenades.SetComponentValue(Agent.BonusStartingGrenades);
}

function SetSpawnProtectionSection()
{
    ch_SPbShowTimer.Checked(Agent.SpawnProtectionTimer.bShowTimer);
    nu_SPTimerPosX.SetComponentValue(Agent.SpawnProtectionTimer.PosX);
    nu_SPTimerPosY.SetComponentValue(Agent.SpawnProtectionTimer.PosY);
}

function SetMovementSection()
{
    nu_MVMaxSpeedMultiplier.SetComponentValue(Agent.MaxSpeedMultiplier);
    nu_MVAirControlMultiplier.SetComponentValue(Agent.AirControlMultiplier);
    nu_MVBaseJumpMultiplier.SetComponentValue(Agent.BaseJumpMultiplier);
    nu_MVMultiJumpMultiplier.SetComponentValue(Agent.MultiJumpMultiplier);
    nu_MVBonusMultiJumps.SetComponentValue(Agent.BonusMultiJumps);
}

static function AddToMenu()
{
    class'HxMenu'.static.AddPanel(Default.Class, "General", "General options");
}

defaultproperties
{
    bDoubleColumn=true

    Begin Object class=AltSectionBackground Name=SVSection
        Caption="Starting Values"
        WinHeight=0.288
    End Object
    Sections(0)=SVSection


    Begin Object class=AltSectionBackground Name=SPSection
        Caption="Spawn Protection"
        WinHeight=0.288
    End Object
    Sections(1)=SPSection

    Begin Object class=AltSectionBackground Name=JVSection
        Caption="Movement"
        WinHeight=0.48
    End Object
    Sections(2)=JVSection

    Begin Object class=moNumericEdit Name=BonusStartingHealth
        Caption="Bonus health"
        MinValue=-99
        MaxValue=99
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=0
        OnChange=StartingValuesSectionOnChange
    End Object
    nu_SVBonusStartingHealth=BonusStartingHealth

    Begin Object class=moNumericEdit Name=BonusStartingShield
        Caption="Bonus shield"
        MinValue=0
        MaxValue=150
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=1
        OnChange=StartingValuesSectionOnChange
    End Object
    nu_SVBonusStartingShield=BonusStartingShield

    Begin Object class=moNumericEdit Name=BonusStartingGrenades
        Caption="Bonus AR grenades"
        MinValue=-4
        MaxValue=99
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=2
        OnChange=StartingValuesSectionOnChange
    End Object
    nu_SVBonusStartingGrenades=BonusStartingGrenades

    Begin Object class=moCheckBox Name=SPShowTimer
        Caption="Show timer"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=3
        OnChange=SpawnProtectionSectionOnChange
    End Object
    ch_SPbShowTimer=SPShowTimer

    Begin Object class=moFloatEdit Name=SPTimerPosX
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
        TabOrder=4
        OnChange=SpawnProtectionSectionOnChange
    End Object
    nu_SPTimerPosX=SPTimerPosX

    Begin Object class=moFloatEdit Name=SPTimerPosY
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
        TabOrder=5
        OnChange=SpawnProtectionSectionOnChange
    End Object
    nu_SPTimerPosY=SPTimerPosY

    Begin Object class=moFloatEdit Name=MaxSpeedMultiplier
        Caption="Maximum speed multiplier"
        MinValue=-100.0
        MaxValue=+100.0
        Step=10.0
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=6
        OnChange=MovementSectionOnChange
    End Object
    nu_MVMaxSpeedMultiplier=MaxSpeedMultiplier

    Begin Object class=moFloatEdit Name=AirControlMultiplier
        Caption="Air control multiplier"
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=7
        OnChange=MovementSectionOnChange
    End Object
    nu_MVAirControlMultiplier=AirControlMultiplier

    Begin Object class=moFloatEdit Name=BaseJumpMultiplier
        Caption="Base jump multiplier"
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=8
        OnChange=MovementSectionOnChange
    End Object
    nu_MVBaseJumpMultiplier=BaseJumpMultiplier

    Begin Object class=moFloatEdit Name=MultiJumpMultiplier
        Caption="Multi-jump multiplier"
        MinValue=-100.0
        MaxValue=+100.0
        Step=1.0
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=9
        OnChange=MovementSectionOnChange
    End Object
    nu_MVMultiJumpMultiplier=MultiJumpMultiplier

    Begin Object class=moNumericEdit Name=BonusMultiJumps
        Caption="Bonus multi-jumps"
        MinValue=-1
        MaxValue=99
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=10
        OnChange=MovementSectionOnChange
    End Object
    nu_MVBonusMultiJumps=BonusMultiJumps
}
