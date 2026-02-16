class HxPlayerHighlightMenuPanel extends HxMenuPanel;

const SECTION_HIGHLIGHTS = 0;
const SECTION_CUSTOMIZE_COLORS = 1;

const NO_HIGHLIGHT = "";
const RANDOM_HIGHLIGHT = "*";

var automated array<GUIComponent> Options;

var private moComboBox co_EditColor;
var private moEditBox ed_ColorName;
var private moSlider sl_ColorRed;
var private moSlider sl_ColorGreen;
var private moSlider sl_ColorBlue;
var private HxClientProxy Proxy;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);
    for (i = 0; i < 5; ++i)
    {
        Sections[SECTION_HIGHLIGHTS].ManageComponent(Options[i]);
    }
    for (i = 5; i < 10; ++i)
    {
        Sections[SECTION_CUSTOMIZE_COLORS].ManageComponent(Options[i]);
    }
    co_EditColor = moComboBox(Options[5]);
    ed_ColorName = moEditBox(Options[6]);
    sl_ColorRed = moSlider(Options[7]);
    sl_ColorGreen = moSlider(Options[8]);
    sl_ColorBlue = moSlider(Options[9]);
    ed_ColorName.MyEditBox.bAlwaysNotify = false;
    PopulateHighlightComboBoxes();
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
    HideSection(SECTION_HIGHLIGHTS, !Proxy.bAllowPlayerHighlight, HIDE_DUE_DISABLE);
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    if (GUIMenuOption(Sender) != None)
    {
        GUIMenuOption(Sender).SetComponentValue(s, true);
    }
}

function CustomizeColorOnLoadINI(GUIComponent Sender, string s)
{
    local Color C;

    if (Sender == ed_ColorName)
    {
        ed_ColorName.SetComponentValue(co_EditColor.GetComponentValue(), true);
    }
    else
    {
        C = class'HxPlayerHighlight'.static.FindColor(co_EditColor.GetComponentValue());
        switch (Sender)
        {
            case sl_ColorRed:
                sl_ColorRed.SetComponentValue(C.R, true);
                break;
            case sl_ColorGreen:
                sl_ColorGreen.SetComponentValue(C.G, true);
                break;
            case sl_ColorBlue:
                sl_ColorBlue.SetComponentValue(C.B, true);
                break;
        }
    }
}

function InternalOnChange(GUIComponent Sender)
{
    switch (Sender)
    {
        case Options[0]:
            class'HxPlayerHighlight'.default.YourTeam = moComboBox(Sender).GetExtra();
            break;
        case Options[1]:
            class'HxPlayerHighlight'.default.EnemyTeam = moComboBox(Sender).GetExtra();
            break;
        case Options[2]:
            class'HxPlayerHighlight'.default.SoloPlayer = moComboBox(Sender).GetExtra();
            break;
        case Options[3]:
            class'HxPlayerHighlight'.default.bDisableOnDeadBodies = moCheckBox(Sender).IsChecked();
            break;
        case Options[4]:
            class'HxPlayerHighlight'.default.bForceNormalSkins = moCheckBox(Sender).IsChecked();
            break;
    }
    UpdateOutstandingHighlights(PlayerOwner());
    class'HxPlayerHighlight'.static.StaticSaveConfig();
}

function CustomizeColorOnChange(GUIComponent Sender)
{
    local int Index;

    Index = co_EditColor.GetIndex();
    if (Sender == co_EditColor)
    {
        UpdateCustomizeColorSection();
    }
    else if (Sender == ed_ColorName)
    {
        if (class'HxPlayerHighlight'.static.ChangeColorName(Index, ed_ColorName.GetComponentValue()))
        {
            PopulateHighlightComboBoxes();
            UpdateOutstandingHighlights(PlayerOwner());
        }
    }
    else if (Index < class'HxPlayerHighlight'.default.Colors.Length)
    {
        switch (Sender)
        {
            case sl_ColorRed:
                class'HxPlayerHighlight'.default.Colors[Index].Color.R = sl_ColorRed.GetValue();
                break;
            case sl_ColorGreen:
                class'HxPlayerHighlight'.default.Colors[Index].Color.G = sl_ColorGreen.GetValue();
                break;
            case sl_ColorBlue:
                class'HxPlayerHighlight'.default.Colors[Index].Color.B = sl_ColorBlue.GetValue();
                break;
        }
        UpdateOutstandingHighlights(PlayerOwner());
    }
}

function PopulateHighlightComboBoxes()
{
    local array<moComboBox> co_Highlights;
    local array<int> HighlightIndices;
    local string ColorName;
    local int i;
    local int j;

    co_Highlights[co_Highlights.Length] = co_EditColor;
    co_Highlights[co_Highlights.Length] = moComboBox(Options[0]);
    co_Highlights[co_Highlights.Length] = moComboBox(Options[1]);
    co_Highlights[co_Highlights.Length] = moComboBox(Options[2]);

    for (i = 0; i < co_Highlights.Length; ++i)
    {
        HighlightIndices[HighlightIndices.Length] = co_Highlights[i].GetIndex();
        co_Highlights[i].bIgnoreChange = true;
        co_Highlights[i].ResetComponent();
        if (i > 0)
        {
            co_Highlights[i].AddItem("Default",,NO_HIGHLIGHT);
            co_Highlights[i].AddItem("Random",,RANDOM_HIGHLIGHT);
        }
    }
    for (i = 0; i < class'HxPlayerHighlight'.default.Colors.Length; ++i)
    {
        ColorName = class'HxPlayerHighlight'.default.Colors[i].Name;
        for (j = 0; j < co_Highlights.Length; ++j)
        {
            co_Highlights[j].AddItem(ColorName,,ColorName);

        }
    }
    for (i = 0; i < co_Highlights.Length; ++i)
    {
        if (HighlightIndices[i] > -1)
        {
            co_Highlights[i].SilentSetIndex(HighlightIndices[i]);
        }
        co_Highlights[i].bIgnoreChange = false;
    }
}

function UpdateOutstandingHighlights(PlayerController PC)
{
    local HxPlayerHighlight PlayerHighlight;

    if (PC != None)
    {
        ForEach PC.DynamicActors(class'HxPlayerHighlight', PlayerHighlight)
        {
            PlayerHighlight.Reinitialize();
        }
    }
}

function UpdateCustomizeColorSection()
{
    local string ColorName;
    local Color C;

    ColorName = co_EditColor.GetComponentValue();
    ed_ColorName.SetComponentValue(ColorName, true);
    C = class'HxPlayerHighlight'.static.FindColor(ColorName);
    sl_ColorRed.SetComponentValue(C.R, true);
    sl_ColorGreen.SetComponentValue(C.G, true);
    sl_ColorBlue.SetComponentValue(C.B, true);
}

static function bool AddToMenu()
{
    local int i;

    if (Super.AddToMenu())
    {
        for (i = 0; i < default.Options.Length; ++i)
        {
            default.Options[i].TabOrder = i;
        }
        return true;
    }
    return false;
}

defaultproperties
{
    Begin Object class=AltSectionBackground Name=HighlightsSection
        Caption="Highlights"
    End Object

    Begin Object class=AltSectionBackground Name=CustomizeColorsSection
        Caption="Customize Colors"
    End Object

    Begin Object class=moComboBox Name=YourTeamComboBox
        Caption="Your team"
        INIOption="HxPlayerHighlight YourTeam"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
    End Object

    Begin Object class=moComboBox Name=EnemyTeamComboBox
        Caption="Enemy team"
        INIOption="HxPlayerHighlight EnemyTeam"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bAlwaysNotify=false
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
    End Object

    Begin Object class=moComboBox Name=SoloPlayerComboBox
        Caption="Solo player"
        INIOption="HxPlayerHighlight SoloPlayer"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bAlwaysNotify=false
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
    End Object

    Begin Object class=moCheckBox Name=DisableOnDeadBodiesCheckBox
        Caption="Disable highlight on dead bodies"
        INIOption="HxPlayerHighlight bDisableOnDeadBodies"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=-1
        CaptionWidth=0.8
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
    End Object

    Begin Object class=moCheckBox Name=ForceNormalSkinsCheckBox
        Caption="Force normal (uncolored) skins"
        INIOption="HxPlayerHighlight bForceNormalSkins"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=-1
        CaptionWidth=0.8
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
    End Object

    Begin Object class=moComboBox Name=EditColorComboBox
        Caption="Color"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        bAlwaysNotify=false
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnChange=CustomizeColorOnChange
    End Object

    Begin Object class=moEditBox Name=ColorNameEditBox
        Caption="Name"
        INIOption="@INTERNAL"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
    End Object

    Begin Object class=moSlider Name=ColorRedSlider
        Caption="Red"
        INIOption="@INTERNAL"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        MinValue=0
        MaxValue=255
        bIntSlider=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
    End Object

    Begin Object class=moSlider Name=ColorGreenSlider
        Caption="Green"
        INIOption="@INTERNAL"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        MinValue=0
        MaxValue=255
        bIntSlider=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
    End Object

    Begin Object class=moSlider Name=ColorBlueSlider
        Caption="Blue"
        INIOption="@INTERNAL"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        MinValue=0
        MaxValue=255
        bIntSlider=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
    End Object

    PanelCaption="Player Highlight"
    PanelHint="Player highlight options"
    bInsertFront=true
    bDoubleColumn=true
    Sections(0)=HighlightsSection
    Sections(1)=CustomizeColorsSection
    Options(0)=YourTeamComboBox
    Options(1)=EnemyTeamComboBox
    Options(2)=SoloPlayerComboBox
    Options(3)=DisableOnDeadBodiesCheckBox
    Options(4)=ForceNormalSkinsCheckBox
    Options(5)=EditColorComboBox
    Options(6)=ColorNameEditBox
    Options(7)=ColorRedSlider
    Options(8)=ColorGreenSlider
    Options(9)=ColorBlueSlider
}
