class HxServerMenuPanel extends HxMenuPanel;

const SECTION_MOVEMENT = 0;
const SECTION_HIT_EFFECTS = 1;
const SECTION_STARTING_VALUES = 3;

var automated array<HxMenuOption> Options;
var HxAgent Agent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);

    for (i = 0; i < 5; ++i)
    {
        Sections[SECTION_MOVEMENT].ManageComponent(Options[i]);
    }
    for (i = 5; i < 7; ++i)
    {
        Sections[SECTION_HIT_EFFECTS].ManageComponent(Options[i]);
    }
    for (i = 7; i < 10; ++i)
    {
        Sections[SECTION_STARTING_VALUES].ManageComponent(Options[i]);
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

static function AddToMenu()
{
    class'HxMenu'.static.AddPanel(Default.Class, "Server", "Server options (admin only)", true);
}

defaultproperties
{
    Begin Object class=AltSectionBackground Name=MovementSection
        Caption="Movement"
        WinHeight=0.405
    End Object

    Begin Object class=AltSectionBackground Name=HitEffectsSection
        Caption="Hit Effects"
        WinHeight=0.16
    End Object

    Begin Object class=AltSectionBackground Name=StartingValuesSection
        Caption="Starting Values"
        WinHeight=0.24
    End Object

    Begin Object class=HxMenuFloatEdit Name=MaxSpeedMultiplier
        Caption="Maximum speed multiplier"
        PropertyName="MaxSpeedMultiplier"
        MinValue=-100.0
        MaxValue=+100.0
        Step=10.0
        TabOrder=0
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=AirControlMultiplier
        Caption="Air control multiplier"
        PropertyName="AirControlMultiplier"
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        TabOrder=1
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=BaseJumpMultiplier
        Caption="Base jump multiplier"
        PropertyName="BaseJumpMultiplier"
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        TabOrder=2
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=MultiJumpMultiplier
        Caption="Multi-jump multiplier"
        PropertyName="MultiJumpMultiplier"
        MinValue=-100.0
        MaxValue=+100.0
        Step=1.0
        TabOrder=3
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=BonusMultiJumps
        Caption="Bonus multi-jumps"
        PropertyName="BonusMultiJumps"
        MinValue=-1
        MaxValue=99
        TabOrder=4
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=AllowHitSounds
        Caption="Allow hit sounds"
        PropertyName="bAllowHitSounds"
        TabOrder=5
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=AllowDamageNumbers
        Caption="Allow damage numbers"
        PropertyName="bAllowDamageNumbers"
        TabOrder=6
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=BonusStartingHealth
        Caption="Bonus health"
        PropertyName="BonusStartingHealth"
        MinValue=-99
        MaxValue=99
        TabOrder=7
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=BonusStartingShield
        Caption="Bonus shield"
        PropertyName="BonusStartingShield"
        MinValue=0
        MaxValue=150
        TabOrder=8
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuNumericEdit Name=BonusStartingGrenades
        Caption="Bonus AR grenades"
        PropertyName="BonusStartingGrenades"
        MinValue=-4
        MaxValue=99
        TabOrder=9
        OnChange=RemoteOnChange
    End Object

    bDoubleColumn=true
    Sections(0)=MovementSection
    Sections(1)=HitEffectsSection
    Sections(2)=None
    Sections(3)=StartingValuesSection
    Options(0)=MaxSpeedMultiplier
    Options(1)=AirControlMultiplier
    Options(2)=BaseJumpMultiplier
    Options(3)=MultiJumpMultiplier
    Options(4)=BonusMultiJumps
    Options(5)=AllowHitSounds
    Options(6)=AllowDamageNumbers
    Options(7)=BonusStartingHealth
    Options(8)=BonusStartingShield
    Options(9)=BonusStartingGrenades
}
