class HxGeneralPanel extends HxPanel;

const SECTION_STARTING_VALUES = 0;
const SECTION_SPAWN_PROTECTION = 1;

var automated moNumericEdit nu_SVStartingHealth;
var automated moNumericEdit nu_SVStartingShield;
var automated moNumericEdit nu_SVStartingGrenades;

var automated moCheckBox ch_SPbShowTimer;
var automated moFloatEdit nu_SPTimerPosX;
var automated moFloatEdit nu_SPTimerPosY;

var HxAgent Agent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);

    Sections[SECTION_STARTING_VALUES].ManageComponent(nu_SVStartingHealth);
    Sections[SECTION_STARTING_VALUES].ManageComponent(nu_SVStartingShield);
    Sections[SECTION_STARTING_VALUES].ManageComponent(nu_SVStartingGrenades);

    Sections[SECTION_SPAWN_PROTECTION].ManageComponent(ch_SPbShowTimer);
    Sections[SECTION_SPAWN_PROTECTION].ManageComponent(nu_SPTimerPosX);
    Sections[SECTION_SPAWN_PROTECTION].ManageComponent(nu_SPTimerPosY);
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
    return Agent.StartingHealth == nu_SVStartingHealth.GetValue()
        && Agent.StartingShield == nu_SVStartingShield.GetValue()
        && Agent.StartingGrenades == nu_SVStartingGrenades.GetValue();
}

function StartingValuesSectionOnChange(GUIComponent C)
{
    if (Agent == None || !IsAdmin())
    {
        return;
    }
    switch(C)
    {
        case nu_SVStartingHealth:
            Agent.ServerSetStartingHealth(nu_SVStartingHealth.GetValue());
            break;
        case nu_SVStartingShield:
            Agent.ServerSetStartingShield(nu_SVStartingShield.GetValue());
            break;
        case nu_SVStartingGrenades:
            Agent.ServerSetStartingGrenades(nu_SVStartingGrenades.GetValue());
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
        return true;
    }
    return false;
}

function UpdateAll()
{
    UpdateStartingValuesSection();
    UpdateSpawnProtectionSection();
    HideSection(SECTION_STARTING_VALUES, false);
    HideSection(SECTION_SPAWN_PROTECTION, false);
}

function UpdateStartingValuesSection()
{
    local bool bAdmin;

    bAdmin = IsAdmin();
    if (bAdmin)
    {
        EnableComponent(nu_SVStartingHealth);
        EnableComponent(nu_SVStartingShield);
        EnableComponent(nu_SVStartingGrenades);
    }
    else
    {
        DisableComponent(nu_SVStartingHealth);
        DisableComponent(nu_SVStartingShield);
        DisableComponent(nu_SVStartingGrenades);
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

function SetStartingValuesSection()
{
    nu_SVStartingHealth.SetValue(Agent.StartingHealth);
    nu_SVStartingShield.SetValue(Agent.StartingShield);
    nu_SVStartingGrenades.SetValue(Agent.StartingGrenades);
}

function SetSpawnProtectionSection()
{
    ch_SPbShowTimer.Checked(Agent.SpawnProtectionTimer.bShowTimer);
    nu_SPTimerPosX.SetValue(Agent.SpawnProtectionTimer.PosX);
    nu_SPTimerPosY.SetValue(Agent.SpawnProtectionTimer.PosY);
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

    Begin Object class=moNumericEdit Name=StartingHealth
        Caption="Health"
        MinValue=1
        MaxValue=199
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.25
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=0
        OnChange=StartingValuesSectionOnChange
    End Object
    nu_SVStartingHealth=StartingHealth

    Begin Object class=moNumericEdit Name=StartingShield
        Caption="Shield"
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
    nu_SVStartingShield=StartingShield

    Begin Object class=moNumericEdit Name=StartingGrenades
        Caption="AR grenades"
        MinValue=0
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
    nu_SVStartingGrenades=StartingGrenades


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
}
