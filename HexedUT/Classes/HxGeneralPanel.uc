class HxGeneralPanel extends HxPanel;

const SECTION_SP = 0;

var automated moCheckBox ch_SPbShowTimer;
var automated moFloatEdit nu_SPTimerPosX;
var automated moFloatEdit nu_SPTimerPosY;

var HxAgent Agent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);

    Sections[SECTION_SP].ManageComponent(ch_SPbShowTimer);
    Sections[SECTION_SP].ManageComponent(nu_SPTimerPosX);
    Sections[SECTION_SP].ManageComponent(nu_SPTimerPosY);
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
        SetSpawnProtectionSection();
        return true;
    }
    return false;
}

function UpdateAll()
{
    UpdateSpawnProtectionSection();
    HideSection(SECTION_SP, false);
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

    Begin Object class=AltSectionBackground Name=SPSection
        Caption="Spawn Protection"
        WinHeight=0.288
    End Object
    Sections(0)=SPSection

    Begin Object class=moCheckBox Name=SPShowTimer
        Caption="Show timer"
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=0
        OnChange=InternalOnChange
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
        TabOrder=1
        OnChange=InternalOnChange
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
        TabOrder=2
        OnChange=InternalOnChange
    End Object
    nu_SPTimerPosY=SPTimerPosY
}
