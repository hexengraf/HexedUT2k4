class HxServerMenuPanel extends HxMenuPanel;

const SECTION_INDICATORS = 0;
const SECTION_MOVEMENT = 1;
const SECTION_STARTING_VALUES = 2;
const SECTION_POWER_UPS = 3;

var automated array<HxMenuOption> Options;
var HxClientProxy Proxy;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    for (i = 0; i < 7; ++i)
    {
        Sections[SECTION_INDICATORS].ManageComponent(Options[i]);
    }
    for (i = 7; i < 12; ++i)
    {
        Sections[SECTION_STARTING_VALUES].ManageComponent(Options[i]);
    }
    for (i = 12; i < 21; ++i)
    {
        Sections[SECTION_MOVEMENT].ManageComponent(Options[i]);
    }
    for (i = 21; i < 26; ++i)
    {
        Sections[SECTION_POWER_UPS].ManageComponent(Options[i]);
    }
    super.InitComponent(MyController, MyOwner);
}

function bool Initialize()
{
    if (Proxy != None)
    {
        return true;
    }
    Proxy = class'HxClientProxy'.static.GetClientProxy(PlayerOwner());
    return Proxy != None;
}

function Refresh()
{
    local int i;

    for (i = 0; i < Options.Length; ++i)
    {
        Options[i].GetValueFrom(Proxy);
    }
    HideAllSections(!IsAdmin(), HIDE_DUE_ADMIN);
}

function RemoteOnChange(GUIComponent C)
{
    local HxMenuOption Option;

    Option = HxMenuOption(C);
    if (Proxy != None && Option != None && IsAdmin())
    {
        Proxy.RemoteSetProperty(Option.PropertyName, Option.GetComponentValue());
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

    Begin Object class=AltSectionBackground Name=MovementSection
        Caption="Movement"
    End Object

    begin Object class=AltSectionBackground Name=PowerUpsSection
        Caption="Power-Ups"
    End Object

    Begin Object class=HxMenuCheckBox Name=AllowHitSounds
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=AllowDamageNumbers
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=AllowPlayerHighlight
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuFloatEdit Name=PlayerHighlightFactor
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
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

    Begin Object class=HxMenuCheckBox Name=DisableWallDodge
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=DisableDodgeJump
        OnChange=RemoteOnChange
    End Object

    Begin Object class=HxMenuCheckBox Name=ColoredDeathMessages
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
    Options(2)=AllowPlayerHighlight
    Options(3)=PlayerHighlightFactor
    Options(4)=ColoredDeathMessages
    Options(5)=HealthLeechRatio
    Options(6)=HealthLeechLimit
    Options(7)=BonusStartingHealth
    Options(8)=BonusStartingShield
    Options(9)=BonusStartingGrenades
    Options(10)=BonusStartingAdrenaline
    Options(11)=BonusAdrenalineOnSpawn
    Options(12)=MaxSpeedMultiplier
    Options(13)=AirControlMultiplier
    Options(14)=BaseJumpMultiplier
    Options(15)=MultiJumpMultiplier
    Options(16)=BonusMultiJumps
    Options(17)=DodgeMultiplier
    Options(18)=DodgeSpeedMultiplier
    Options(19)=DisableWallDodge
    Options(20)=DisableDodgeJump
    Options(21)=DisableSpeedCombo
    Options(22)=DisableBerserkCombo
    Options(23)=DisableBoosterCombo
    Options(24)=DisableInvisibleCombo
    Options(25)=DisableUDamage
}
