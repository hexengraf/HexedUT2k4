class HxServerMenuPanel extends HxMenuPanel;

const SECTION_HIT_EFFECTS = 0;
const SECTION_STARTING_VALUES = 2;
const SECTION_POWER_UPS = 3;
const SECTION_MOVEMENT = 4;

var automated array<HxMenuOption> Options;
var HxAgent Agent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);

    for (i = 0; i < 2; ++i)
    {
        Sections[SECTION_HIT_EFFECTS].ManageComponent(Options[i]);
    }
    for (i = 2; i < 7; ++i)
    {
        Sections[SECTION_STARTING_VALUES].ManageComponent(Options[i]);
    }
    for (i = 7; i < 17; ++i)
    {
        Sections[SECTION_MOVEMENT].ManageComponent(Options[i]);
    }
    for (i = 17; i < Options.Length; ++i)
    {
        Sections[SECTION_POWER_UPS].ManageComponent(Options[i]);
    }
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
    Begin Object class=AltSectionBackground Name=HitEffectsSection
        Caption="Hit Effects"
        WinHeight=0.16
    End Object

    Begin Object class=AltSectionBackground Name=StartingValuesSection
        Caption="Starting Values"
        WinHeight=0.40
    End Object

    begin Object class=AltSectionBackground Name=PowerUpsSection
        Caption="Power-Ups"
        WinHeight=0.40
    End Object

    Begin Object class=AltSectionBackground Name=MovementSection
        Caption="Movement"
        NumColumns=2
        WinHeight=0.40
    End Object

    Begin Object class=HxMenuCheckBox Name=AllowHitSounds
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=AllowDamageNumbers
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

    Begin Object class=HxMenuCheckBox Name=CanBoostDodge
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DisableWallDodge
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DisableDodgeJump
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
    Sections(0)=HitEffectsSection
    Sections(1)=None
    Sections(2)=StartingValuesSection
    Sections(3)=PowerUpsSection
    Sections(4)=MovementSection
    Options(0)=AllowHitSounds
    Options(1)=AllowDamageNumbers
    Options(2)=BonusStartingHealth
    Options(3)=BonusStartingShield
    Options(4)=BonusStartingGrenades
    Options(5)=BonusStartingAdrenaline
    Options(6)=BonusAdrenalineOnSpawn
    Options(7)=MaxSpeedMultiplier
    Options(8)=AirControlMultiplier
    Options(9)=BaseJumpMultiplier
    Options(10)=MultiJumpMultiplier
    Options(11)=BonusMultiJumps
    Options(12)=DodgeMultiplier
    Options(13)=DodgeSpeedMultiplier
    Options(14)=CanBoostDodge
    Options(15)=DisableWallDodge
    Options(16)=DisableDodgeJump
    Options(17)=DisableSpeedCombo
    Options(18)=DisableBerserkCombo
    Options(19)=DisableBoosterCombo
    Options(20)=DisableInvisibleCombo
    Options(21)=DisableUDamage
}
