class HxGUIServerMenuGeneralPanel extends HxGUIMenuPanel;

const SECTION_HIT_EFFECTS = 0;
const SECTION_SKIN_HIGHLIGHT = 1;
const SECTION_INTERFACE = 2;
const SECTION_HEALTH_LEECH = 3;

var automated array<GUIMenuOption> Options;

var private HxUTClient Client;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;
    local int Order;

    for (i = 0; i < Options.Length; ++i)
    {
        Options[i].TabOrder = Order++;
        Options[i].Caption = class'MutHexedUT'.default.PropertyInfoEntries[i].Caption;
        Options[i].Hint = class'MutHexedUT'.default.PropertyInfoEntries[i].Hint;
        Options[i].INIOption = class'MutHexedUT'.default.PropertyInfoEntries[i].Name;
        Options[i].OnLoadINI = ServerOptionOnLoadINI;
        Options[i].OnChange = ServerOptionOnChange;
    }
    super.InitComponent(MyController, MyOwner);
    for (i = 0; i < 2; ++i)
    {
        Sections[SECTION_HIT_EFFECTS].Insert(Options[i]);
    }
    for (i = 2; i < 4; ++i)
    {
        Sections[SECTION_INTERFACE].Insert(Options[i]);
    }
    for (i = 4; i < 6; ++i)
    {
        Sections[SECTION_SKIN_HIGHLIGHT].Insert(Options[i]);
    }
    for (i = 6; i < 8; ++i)
    {
        Sections[SECTION_HEALTH_LEECH].Insert(Options[i]);
    }
}

function bool Initialize()
{
    if (Client != None)
    {
        return Client.SPTimer != None;
    }
    Client = class'HxUTClient'.static.GetClient(PlayerOwner());
    return Client != None && Client.SPTimer != None;
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

function ServerOptionOnChange(GUIComponent Sender)
{
    local GUIMenuOption Option;

    Option = GUIMenuOption(Sender);
    if (Client != None && Option != None && IsAdmin())
    {
        Client.RemoteSetProperty(Option.INIOption, Option.GetComponentValue());
    }
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=InterfaceSection
        Caption="Interface"
        WinHeight=0.5
        LineSpacing=0.02
        bAutoSpacing=false
    End Object

    Begin Object class=HxGUIFramedSection Name=HitEffectsSection
        Caption="Hit Effects"
        WinHeight=0.5
        LineSpacing=0.02
        bAutoSpacing=false
    End Object

    Begin Object class=HxGUIFramedSection Name=SkinHighlightSection
        Caption="Skin Highlight"
        WinHeight=0.5
        LineSpacing=0.02
        bAutoSpacing=false
    End Object

    Begin Object class=HxGUIFramedSection Name=HealthLeechSection
        Caption="Health leech"
        WinHeight=0.5
        LineSpacing=0.02
        bAutoSpacing=false
    End Object

    Begin Object class=moCheckBox Name=AllowHitSoundsCheckBox
    End Object

    Begin Object class=moCheckBox Name=AllowDamageNumbersCheckBox
    End Object

    Begin Object class=moCheckBox Name=AllowSpawnProtectionTimerCheckBox
    End Object

    Begin Object class=moCheckBox Name=ColoredDeathMessagesCheckBox
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

    bDoubleColumn=true
    bFillPanelHeight=false
    Sections(0)=HitEffectsSection
    Sections(1)=SkinHighlightSection
    Sections(2)=InterfaceSection
    Sections(3)=HealthLeechSection
    Options(0)=AllowHitSoundsCheckBox
    Options(1)=AllowDamageNumbersCheckBox
    Options(2)=AllowSpawnProtectionTimerCheckBox
    Options(3)=ColoredDeathMessagesCheckBox
    Options(4)=AllowSkinHighlightCheckBox
    Options(5)=SkinHighlightFactorFloatEdit
    Options(6)=HealthLeechRatioFloatEdit
    Options(7)=HealthLeechLimitNumericEdit
}
