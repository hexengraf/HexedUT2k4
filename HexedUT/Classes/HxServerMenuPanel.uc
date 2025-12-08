class HxServerMenuPanel extends HxMenuPanel;

const SECTION_INDICATORS= 0;
const SECTION_STARTING_VALUES = 1;
const SECTION_MOVEMENT = 2;
const SECTION_POWER_UPS = 3;

var automated array<HxMenuOption> Options;
var HxAgent Agent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    for (i = 0; i < 5; ++i)
    {
        Sections[SECTION_INDICATORS].ManageComponent(Options[i]);
    }
    for (i = 5; i < 14; ++i)
    {
        Sections[SECTION_MOVEMENT].ManageComponent(Options[i]);
    }
    for (i = 14; i < 19; ++i)
    {
        Sections[SECTION_STARTING_VALUES].ManageComponent(Options[i]);
    }
    for (i = 19; i < 24; ++i)
    {
        Sections[SECTION_POWER_UPS].ManageComponent(Options[i]);
    }
    super.InitComponent(MyController, MyOwner);
}

function bool Initialize()
{
    if (Agent != None)
    {
        return true;
    }
    Agent = class'HxAgent'.static.GetAgent(PlayerOwner());
    return Agent != None;
}

function Refresh()
{
    local int i;

    for (i = 0; i < Options.Length; ++i)
    {
        Options[i].GetValueFrom(Agent);
    }
    HideAllSections(!IsAdmin(), HIDE_DUE_ADMIN);
}

function RemoteOnChange(GUIComponent C)
{
    local HxMenuOption Option;

    Option = HxMenuOption(C);
    if (Agent != None && Option != None && IsAdmin())
    {
        Agent.RemoteSetProperty(Option.PropertyName, Option.GetComponentValue());
    }
}

static function bool AddToMenu()
{
    local int i;
    local int Order;

    if (Super.AddToMenu())
    {
        for (i = 0; i < default.Options.Length; ++i)
        {
            default.Options[i].TabOrder = Order++;
            default.Options[i].Caption = class'MutHexedUT'.default.PropertyInfoEntries[i].Caption;
            default.Options[i].Hint = class'MutHexedUT'.default.PropertyInfoEntries[i].Hint;
            default.Options[i].PropertyName = class'MutHexedUT'.default.PropertyInfoEntries[i].Name;
        }
        return true;
    }
    return false;
}

defaultproperties
{
    Begin Object class=AltSectionBackground Name=GeneralSection
        Caption="General"
    End Object

    Begin Object class=AltSectionBackground Name=StartingValuesSection
        Caption="Starting Values"
    End Object

    begin Object class=AltSectionBackground Name=PowerUpsSection
        Caption="Power-Ups"
    End Object

    Begin Object class=AltSectionBackground Name=MovementSection
        Caption="Movement"
    End Object

    Begin Object class=HxMenuCheckBox Name=AllowHitSounds
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=AllowDamageNumbers
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=HealthLeechRatio
        MinValue=0.0
        MaxValue=5.0
        Step=0.01
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=HealthLeechLimit
        MinValue=0
        MaxValue=199
        Step=10
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=MaxSpeedMultiplier
        MinValue=-100.0
        MaxValue=+100.0
        Step=10.0
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=AirControlMultiplier
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=BaseJumpMultiplier
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=MultiJumpMultiplier
        MinValue=-100.0
        MaxValue=+100.0
        Step=1.0
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=BonusMultiJumps
        MinValue=-1
        MaxValue=99
        Step=1
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=DodgeMultiplier
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=DodgeSpeedMultiplier
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DisableWallDodge
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DisableDodgeJump
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=ColoredDeathMessages
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=BonusStartingHealth
        MinValue=-99
        MaxValue=99
        Step=10
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=BonusStartingShield
        MinValue=0
        MaxValue=150
        Step=10
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=BonusStartingGrenades
        MinValue=-4
        MaxValue=99
        Step=1
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=BonusStartingAdrenaline
        MinValue=0
        MaxValue=100
        Step=10
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=BonusAdrenalineOnSpawn
        MinValue=-100
        MaxValue=100
        Step=10
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DisableSpeedCombo
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DisableBerserkCombo
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DisableBoosterCombo
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DisableInvisibleCombo
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DisableUDamage
        OnChange=RemoteOnChange
    End Object

    PanelCaption="Server"
    PanelHint="Server options (admin only)"
    bInsertFront=true
    bDoubleColumn=true
    Sections(0)=GeneralSection
    Sections(1)=StartingValuesSection
    Sections(2)=MovementSection
    Sections(3)=PowerUpsSection
    Options(0)=AllowHitSounds
    Options(1)=AllowDamageNumbers
    Options(2)=ColoredDeathMessages
    Options(3)=HealthLeechRatio
    Options(4)=HealthLeechLimit
    Options(5)=MaxSpeedMultiplier
    Options(6)=AirControlMultiplier
    Options(7)=BaseJumpMultiplier
    Options(8)=MultiJumpMultiplier
    Options(9)=BonusMultiJumps
    Options(10)=DodgeMultiplier
    Options(11)=DodgeSpeedMultiplier
    Options(12)=DisableWallDodge
    Options(13)=DisableDodgeJump
    Options(14)=BonusStartingHealth
    Options(15)=BonusStartingShield
    Options(16)=BonusStartingGrenades
    Options(17)=BonusStartingAdrenaline
    Options(18)=BonusAdrenalineOnSpawn
    Options(19)=DisableSpeedCombo
    Options(20)=DisableBerserkCombo
    Options(21)=DisableBoosterCombo
    Options(22)=DisableInvisibleCombo
    Options(23)=DisableUDamage
}
