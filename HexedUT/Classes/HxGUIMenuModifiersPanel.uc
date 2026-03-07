class HxGUIMenuModifiersPanel extends HxGUIMenuBasePanel;

const SECTION_STARTING_VALUES = 0;
const SECTION_POWER_UPS = 2;
const SECTION_MOVEMENT = 1;
const SECTION_HEALTH_LEECH = 3;

var automated array<GUIMenuOption> Options;

var private HxUTClient Client;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);
    for (i = 0; i < Options.Length; ++i)
    {
        Options[i].OnLoadINI = ServerOptionOnLoadINI;
        Options[i].OnChange = ServerOptionOnChange;
    }
    for (i = 0; i < 5; ++i)
    {
        Sections[SECTION_STARTING_VALUES].Insert(Options[i]);
    }
    for (i = 5; i < 10; ++i)
    {
        Sections[SECTION_POWER_UPS].Insert(Options[i]);
    }
    for (i = 10; i < 19; ++i)
    {
        Sections[SECTION_MOVEMENT].Insert(Options[i]);
    }
    for (i = 19; i < 21; ++i)
    {
        Sections[SECTION_HEALTH_LEECH].Insert(Options[i]);
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
    Super.Refresh();
    HideAllSections(!IsAdmin(), HIDE_DUE_ADMIN);
}

function ServerOptionOnLoadINI(GUIComponent Sender, string s)
{
    local GUIMenuOption Option;

    Option = GUIMenuOption(Sender);
    if (Client != None && Option != None)
    {
        Option.SetComponentValue(Client.GetPropertyText(Option.INIOption));
    }
}

function ServerOptionOnChange(GUIComponent C)
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
        for (i = 6; i < class'MutHexedUT'.default.PropertyInfoEntries.Length; ++i)
        {
            default.Options[i - 6].TabOrder = Order++;
            default.Options[i - 6].Caption =
                class'MutHexedUT'.default.PropertyInfoEntries[i].Caption;
            default.Options[i - 6].Hint = class'MutHexedUT'.default.PropertyInfoEntries[i].Hint;
            default.Options[i - 6].INIOption =
                class'MutHexedUT'.default.PropertyInfoEntries[i].Name;
        }
        return true;
    }
    return false;
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=StartingValuesSection
        Caption="Starting Values"
        WinHeight=0.5
    End Object

    begin Object class=HxGUIFramedSection Name=PowerUpsSection
        Caption="Power-Ups"
        WinHeight=0.5
    End Object

    Begin Object class=HxGUIFramedSection Name=MovementSection
        Caption="Movement"
        WinHeight=0.77
    End Object

    Begin Object class=HxGUIFramedSection Name=HealthLeechSection
        Caption="Health leech"
        WinHeight=0.23
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

    PanelCaption="Modifiers"
    PanelHint="Game modifiers and custom behavior options (admin only)"
    bInsertFront=true
    bDoubleColumn=true
    bFillPanelHeight=false
    Sections(0)=StartingValuesSection
    Sections(1)=MovementSection
    Sections(2)=PowerUpsSection
    Sections(3)=HealthLeechSection
    Options(0)=BonusStartingHealthNumericEdit
    Options(1)=BonusStartingShieldNumericEdit
    Options(2)=BonusStartingGrenadesNumericEdit
    Options(3)=BonusStartingAdrenalineNumericEdit
    Options(4)=BonusAdrenalineOnSpawnNumericEdit
    Options(5)=DisableSpeedComboCheckBox
    Options(6)=DisableBerserkComboCheckBox
    Options(7)=DisableBoosterComboCheckBox
    Options(8)=DisableInvisibleComboCheckBox
    Options(9)=DisableUDamageCheckBox
    Options(10)=MaxSpeedMultiplierFloatEdit
    Options(11)=AirControlMultiplierFloatEdit
    Options(12)=BaseJumpMultiplierFloatEdit
    Options(13)=MultiJumpMultiplierFloatEdit
    Options(14)=BonusMultiJumpsNumericEdit
    Options(15)=DodgeMultiplierFloatEdit
    Options(16)=DodgeSpeedMultiplierFloatEdit
    Options(17)=DisableWallDodgeCheckBox
    Options(18)=DisableDodgeJumpCheckBox
    Options(19)=HealthLeechRatioFloatEdit
    Options(20)=HealthLeechLimitNumericEdit
}
