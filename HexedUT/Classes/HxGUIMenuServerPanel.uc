class HxGUIMenuServerPanel extends HxGUIMenuBasePanel;

const SECTION_INDICATORS = 0;
const SECTION_MOVEMENT = 1;
const SECTION_STARTING_VALUES = 2;
const SECTION_POWER_UPS = 3;

var automated array<GUIMenuOption> Options;
var HxClientProxy Proxy;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    for (i = 0; i < Options.Length; ++i)
    {
        Options[i].OnLoadINI = InternalOnLoadINI;
        Options[i].OnChange = InternalOnChange;
    }
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
    HideAllSections(!IsAdmin(), HIDE_DUE_ADMIN);
    Super.Refresh();
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    local GUIMenuOption Option;

    Option = GUIMenuOption(Sender);
    if (Proxy != None && Option != None)
    {
        Option.SetComponentValue(Proxy.GetPropertyText(Option.INIOption));
    }
}

function InternalOnChange(GUIComponent C)
{
    local GUIMenuOption Option;

    Option = GUIMenuOption(C);
    if (Proxy != None && Option != None && IsAdmin())
    {
        Proxy.RemoteSetProperty(Option.INIOption, Option.GetComponentValue());
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
            default.Options[i].INIOption = class'MutHexedUT'.default.PropertyInfoEntries[i].Name;
        }
        return true;
    }
    return false;
}

defaultproperties
{
    Begin Object class=AltSectionBackground Name=GeneralSection
        Caption="General"
        bRemapStack=false
    End Object

    Begin Object class=AltSectionBackground Name=StartingValuesSection
        Caption="Starting Values"
        bRemapStack=false
    End Object

    Begin Object class=AltSectionBackground Name=MovementSection
        Caption="Movement"
        bRemapStack=false
    End Object

    begin Object class=AltSectionBackground Name=PowerUpsSection
        Caption="Power-Ups"
        bRemapStack=false
    End Object

    Begin Object class=moCheckBox Name=AllowHitSoundsCheckBox
    End Object

    Begin Object class=moCheckBox Name=AllowDamageNumbersCheckBox
    End Object

    Begin Object class=moCheckBox Name=AllowSkinHighlightCheckBox
    End Object

    Begin Object class=moFloatEdit Name=SkinHighlightFactorFloatEdit
        MinValue=0.0
        MaxValue=1.0
        Step=0.01
        ComponentWidth=0.25
    End Object

    Begin Object class=moFloatEdit Name=HealthLeechRatioFloatEdit
        MinValue=0.0
        MaxValue=5.0
        Step=0.01
        ComponentWidth=0.25
    End Object

    Begin Object class=moNumericEdit Name=HealthLeechLimitNumericEdit
        MinValue=0
        MaxValue=199
        Step=10
        ComponentWidth=0.25
    End Object

    Begin Object class=moNumericEdit Name=BonusStartingHealthNumericEdit
        MinValue=-99
        MaxValue=99
        Step=10
        ComponentWidth=0.25
    End Object

    Begin Object class=moNumericEdit Name=BonusStartingShieldNumericEdit
        MinValue=0
        MaxValue=150
        Step=10
        ComponentWidth=0.25
    End Object

    Begin Object class=moNumericEdit Name=BonusStartingGrenadesNumericEdit
        MinValue=-4
        MaxValue=99
        Step=1
        ComponentWidth=0.25
    End Object

    Begin Object class=moNumericEdit Name=BonusStartingAdrenalineNumericEdit
        MinValue=0
        MaxValue=100
        Step=10
        ComponentWidth=0.25
    End Object

    Begin Object class=moNumericEdit Name=BonusAdrenalineOnSpawnNumericEdit
        MinValue=-100
        MaxValue=100
        Step=10
        ComponentWidth=0.25
    End Object

    Begin Object class=moFloatEdit Name=MaxSpeedMultiplierFloatEdit
        MinValue=-100.0
        MaxValue=+100.0
        Step=10.0
        ComponentWidth=0.25
    End Object

    Begin Object class=moFloatEdit Name=AirControlMultiplierFloatEdit
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        ComponentWidth=0.25
    End Object

    Begin Object class=moFloatEdit Name=BaseJumpMultiplierFloatEdit
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        ComponentWidth=0.25
    End Object

    Begin Object class=moFloatEdit Name=MultiJumpMultiplierFloatEdit
        MinValue=-100.0
        MaxValue=+100.0
        Step=1.0
        ComponentWidth=0.25
    End Object

    Begin Object class=moNumericEdit Name=BonusMultiJumpsNumericEdit
        MinValue=-1
        MaxValue=99
        Step=1
        ComponentWidth=0.25
    End Object

    Begin Object class=moFloatEdit Name=DodgeMultiplierFloatEdit
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        ComponentWidth=0.25
    End Object

    Begin Object class=moFloatEdit Name=DodgeSpeedMultiplierFloatEdit
        MinValue=-10.0
        MaxValue=+10.0
        Step=0.25
        ComponentWidth=0.25
    End Object

    Begin Object class=moCheckBox Name=DisableWallDodgeCheckBox
    End Object

    Begin Object class=moCheckBox Name=DisableDodgeJumpCheckBox
    End Object

    Begin Object class=moCheckBox Name=ColoredDeathMessagesCheckBox
    End Object

    Begin Object class=moCheckBox Name=DisableSpeedComboCheckBox
    End Object

    Begin Object class=moCheckBox Name=DisableBerserkComboCheckBox
    End Object

    Begin Object class=moCheckBox Name=DisableBoosterComboCheckBox
    End Object

    Begin Object class=moCheckBox Name=DisableInvisibleComboCheckBox
    End Object

    Begin Object class=moCheckBox Name=DisableUDamageCheckBox
    End Object

    PanelCaption="Server"
    PanelHint="Server options (admin only)"
    bInsertFront=true
    bDoubleColumn=true
    Sections(0)=GeneralSection
    Sections(1)=MovementSection
    Sections(2)=StartingValuesSection
    Sections(3)=PowerUpsSection
    Options(0)=AllowHitSoundsCheckBox
    Options(1)=AllowDamageNumbersCheckBox
    Options(2)=AllowSkinHighlightCheckBox
    Options(3)=SkinHighlightFactorFloatEdit
    Options(4)=ColoredDeathMessagesCheckBox
    Options(5)=HealthLeechRatioFloatEdit
    Options(6)=HealthLeechLimitNumericEdit
    Options(7)=BonusStartingHealthNumericEdit
    Options(8)=BonusStartingShieldNumericEdit
    Options(9)=BonusStartingGrenadesNumericEdit
    Options(10)=BonusStartingAdrenalineNumericEdit
    Options(11)=BonusAdrenalineOnSpawnNumericEdit
    Options(12)=MaxSpeedMultiplierFloatEdit
    Options(13)=AirControlMultiplierFloatEdit
    Options(14)=BaseJumpMultiplierFloatEdit
    Options(15)=MultiJumpMultiplierFloatEdit
    Options(16)=BonusMultiJumpsNumericEdit
    Options(17)=DodgeMultiplierFloatEdit
    Options(18)=DodgeSpeedMultiplierFloatEdit
    Options(19)=DisableWallDodgeCheckBox
    Options(20)=DisableDodgeJumpCheckBox
    Options(21)=DisableSpeedComboCheckBox
    Options(22)=DisableBerserkComboCheckBox
    Options(23)=DisableBoosterComboCheckBox
    Options(24)=DisableInvisibleComboCheckBox
    Options(25)=DisableUDamageCheckBox
}
