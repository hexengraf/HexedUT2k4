class HxGUIServerMenuModifiersPanel extends HxGUIMenuPanel;

const SECTION_STARTING_VALUES = 0;
const SECTION_POWER_UPS = 2;
const SECTION_MOVEMENT = 1;

var automated array<GUIMenuOption> Options;

var private HxUTClient Client;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    for (i = 8; i < class'MutHexedUT'.default.PropertyInfoEntries.Length; ++i)
    {
        Options[i - 8].TabOrder = i - 8;
        Options[i - 8].Caption = class'MutHexedUT'.default.PropertyInfoEntries[i].Caption;
        Options[i - 8].Hint = class'MutHexedUT'.default.PropertyInfoEntries[i].Hint;
        Options[i - 8].INIOption = class'MutHexedUT'.default.PropertyInfoEntries[i].Name;
        Options[i - 8].OnLoadINI = ServerOptionOnLoadINI;
        Options[i - 8].OnChange = ServerOptionOnChange;
    }
    super.InitComponent(MyController, MyOwner);
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
    local int i;

    Super.Refresh();
    for (i = 0; i < Options.Length; ++i)
    {
        Options[i].LoadINI();
    }
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
        WinHeight=1.0
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

    bDoubleColumn=true
    bFillPanelHeight=false
    Sections(0)=StartingValuesSection
    Sections(1)=MovementSection
    Sections(2)=PowerUpsSection
    Sections(3)=None
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
}
