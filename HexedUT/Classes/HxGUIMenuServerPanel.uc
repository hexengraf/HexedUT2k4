class HxGUIMenuServerPanel extends HxGUIMenuBasePanel;

const SECTION_INDICATORS = 0;
const SECTION_MOVEMENT = 1;
const SECTION_STARTING_VALUES = 2;
const SECTION_POWER_UPS = 3;

var automated array<GUIMenuOption> Options;
var HxUTClient Client;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);
    for (i = 0; i < Options.Length; ++i)
    {
        Options[i].OnLoadINI = InternalOnLoadINI;
        Options[i].OnChange = InternalOnChange;
    }
    for (i = 0; i < 8; ++i)
    {
        Sections[SECTION_INDICATORS].Insert(Options[i]);
    }
    for (i = 8; i < 13; ++i)
    {
        Sections[SECTION_STARTING_VALUES].Insert(Options[i]);
    }
    for (i = 13; i < 22; ++i)
    {
        Sections[SECTION_MOVEMENT].Insert(Options[i]);
    }
    for (i = 22; i < 27; ++i)
    {
        Sections[SECTION_POWER_UPS].Insert(Options[i]);
    }
}

function bool Initialize()
{
    if (Client != None)
    {
        return true;
    }
    Client = class'HxUTClient'.static.GetClient(PlayerOwner());
    return Client != None;
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
    if (Client != None && Option != None)
    {
        Option.SetComponentValue(Client.GetPropertyText(Option.INIOption));
    }
}

function InternalOnChange(GUIComponent C)
{
    local GUIMenuOption Option;

    Option = GUIMenuOption(C);
    if (Client != None && Option != None && IsAdmin())
    {
        Client.RemoteSetProperty(Option.INIOption, Option.GetComponentValue());
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
    Begin Object class=HxGUIFramedSection Name=GeneralSection
        Caption="General"
    End Object

    Begin Object class=HxGUIFramedSection Name=StartingValuesSection
        Caption="Starting Values"
    End Object

    Begin Object class=HxGUIFramedSection Name=MovementSection
        Caption="Movement"
    End Object

    begin Object class=HxGUIFramedSection Name=PowerUpsSection
        Caption="Power-Ups"
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

    Begin Object class=moCheckBox Name=AllowSpawnProtectionTimerCheckBox
    End Object

    Begin Object class=moCheckBox Name=ColoredDeathMessagesCheckBox
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
    Options(4)=AllowSpawnProtectionTimerCheckBox
    Options(5)=ColoredDeathMessagesCheckBox
    Options(6)=HealthLeechRatioFloatEdit
    Options(7)=HealthLeechLimitNumericEdit
    Options(8)=BonusStartingHealthNumericEdit
    Options(9)=BonusStartingShieldNumericEdit
    Options(10)=BonusStartingGrenadesNumericEdit
    Options(11)=BonusStartingAdrenalineNumericEdit
    Options(12)=BonusAdrenalineOnSpawnNumericEdit
    Options(13)=MaxSpeedMultiplierFloatEdit
    Options(14)=AirControlMultiplierFloatEdit
    Options(15)=BaseJumpMultiplierFloatEdit
    Options(16)=MultiJumpMultiplierFloatEdit
    Options(17)=BonusMultiJumpsNumericEdit
    Options(18)=DodgeMultiplierFloatEdit
    Options(19)=DodgeSpeedMultiplierFloatEdit
    Options(20)=DisableWallDodgeCheckBox
    Options(21)=DisableDodgeJumpCheckBox
    Options(22)=DisableSpeedComboCheckBox
    Options(23)=DisableBerserkComboCheckBox
    Options(24)=DisableBoosterComboCheckBox
    Options(25)=DisableInvisibleComboCheckBox
    Options(26)=DisableUDamageCheckBox
}
