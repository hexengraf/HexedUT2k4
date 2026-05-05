class HxGUIMultiOptionListBox extends GUIMultiOptionListBox;

var float ComponentWidth;
var float ScrollbarWidth;
var bool bUseServerInfo;
var bool bShowSections;
var bool bStatusOnly;

var array<GUIMenuOption> Options;
var private array<HxClientReplicationInfo> CRIs;
var private array<PlayInfo> PIs;
var private array<byte> OptionModified;
var private int PropertyCount;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    DefaultListClass = string(class'HxGUIMultiOptionList');
    Super.InitComponent(MyController, MyOwner);
    HxGUIVertScrollBar(MyScrollBar).StandardWidth = ScrollbarWidth;
}

function InitBaseList(GUIListBase LocalList)
{
    Super.InitBaseList(LocalList);
    List.OnClickSound = CS_None;
}

function PopulateWithCRIs(array<HxClientReplicationInfo> NewCRIs)
{
    local int i;

    Clear();
    for (i = 0; i < NewCRIs.Length; ++i)
    {
        if (bUseServerInfo)
        {
            ProcessPI(NewCRIs[i].ServerInfo);
        }
        else
        {
            ProcessCRI(NewCRIs[i], i);
        }
    }
    Refresh();
}

function PopulateWithCRI(HxClientReplicationInfo NewCRI)
{
    Clear();
    if (bUseServerInfo)
    {
        ProcessPI(NewCRI.ServerInfo);
    }
    else
    {
        ProcessCRI(NewCRI);
    }
    Refresh();
}

function ProcessCRI(HxClientReplicationInfo CRI, optional int CRINumber)
{
    local GUIMenuOption Option;
    local string SectionCaption;
    local bool bSavedCurMenuInitialized;
    local bool bSectionAdded;
    local int i;
    local int j;

    CRIs[CRIs.Length] = CRI;
    if (CRI.ConfigClasses.Length == 0)
    {
        return;
    }
    bSavedCurMenuInitialized = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = false;
    for (i = 0; i < CRI.ConfigClasses.Length; ++i)
    {
        for (j = 0; j < CRI.ConfigClasses[i].default.DisplayInfo.Length; ++j)
        {
            if (ShouldHideProperty(CRI, CRI.ConfigClasses[i], j))
            {
                continue;
            }
            if (!bSectionAdded)
            {
                AddSection(CRI.MutatorClass.default.FriendlyName);
                bSectionAdded = true;
            }
            if (CRI.ConfigClasses[i].default.DisplayInfo[j].Section != SectionCaption)
            {
                AddSubSection(CRI.ConfigClasses[i].default.DisplayInfo[j].Section);
                SectionCaption = CRI.ConfigClasses[i].default.DisplayInfo[j].Section;
            }
            Option = AddConfigOption(CRI.ConfigClasses[i], j);
            if (Option != None)
            {
                Option.Tag = (CRINumber << 20) | (i << 10) | j;
                Options[Options.Length] = Option;
            }
        }
    }
    Controller.bCurMenuInitialized = bSavedCurMenuInitialized;
}

function bool ShouldHideProperty(HxClientReplicationInfo CRI,
                                 class<HxConfig> ConfigClass,
                                 int Index)
{
    return ConfigClass.default.DisplayInfo[Index].bHidden
        || (!Controller.bExpertMode && ConfigClass.default.DisplayInfo[Index].bAdvanced)
        || (ConfigClass.default.DisplayInfo[Index].Dependency != ""
            && !bool(CRI.GetServerProperty(ConfigClass.default.DisplayInfo[Index].Dependency)));
}

function ProcessPI(PlayInfo PI)
{
    local class<HxMutator> MutatorClass;
    local GUIMenuOption Option;
    local string HeaderCaption;
    local string SectionCaption;
    local bool bSavedCurMenuInitialized;
    local int i;

    PIs[PIs.Length] = PI;
    if (PI.Settings.Length == 0)
    {
        return;
    }
    bSavedCurMenuInitialized = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = false;
    for (i = 0; i < PI.Settings.Length; ++i)
    {
        if (!Controller.bExpertMode && PI.Settings[i].bAdvanced)
        {
            continue;
        }
        MutatorClass = class<HxMutator>(PI.Settings[i].ClassFrom);
        if (bShowSections && MutatorClass != None)
        {
            if (MutatorClass.default.FriendlyName != HeaderCaption)
            {
                AddSection(MutatorClass.default.FriendlyName);
                HeaderCaption = MutatorClass.default.FriendlyName;
            }
            if (MutatorClass.default.Properties[i].Section != SectionCaption)
            {
                AddSubSection(MutatorClass.default.Properties[i].Section);
                SectionCaption = MutatorClass.default.Properties[i].Section;
            }
        }
        else if (PI.Settings[i].Grouping != HeaderCaption)
        {
            AddSubSection(PI.Settings[i].Grouping);
            HeaderCaption = PI.Settings[i].Grouping;
        }
        if (bStatusOnly)
        {
            Option = List.AddItem(
                string(class'HxGUIMultiOptionListLabel'),, PI.Settings[i].DisplayName);
            if (Option != None)
            {
                Option.CaptionWidth = 0.2;
                Option.ComponentWidth = -1;
                Option.bAutoSizeCaption = true;
            }
        }
        else
        {
            Option = AddPIOption(PI.Settings[i]);
        }
        if (Option != None)
        {
            Option.Tag = PropertyCount + i;
            Options[Options.Length] = Option;
            OptionModified[OptionModified.Length] = 0;
        }
    }
    PropertyCount += PI.Settings.Length;
    Controller.bCurMenuInitialized = bSavedCurMenuInitialized;
}

function Refresh()
{
    local int i;

    for (i = 0; i < List.Elements.Length; ++i)
    {
        List.Elements[i].LoadINI();
    }
}

function GUIMenuOption AddConfigOption(class<HxConfig> ConfigClass, int Index)
{
    local GUIMenuOption Option;

    switch (ConfigClass.default.Properties[Index].Type)
    {
        case HX_PROPERTY_Bool:
            Option = List.AddItem(
                "XInterface.moCheckbox",, ConfigClass.default.DisplayInfo[Index].Caption);
            break;
        case HX_PROPERTY_Int:
            Option = AddNumericEdit(
                ConfigClass.default.DisplayInfo[Index].Caption,
                ConfigClass.default.Properties[Index].LowerLimit,
                ConfigClass.default.Properties[Index].UpperLimit,
                ConfigClass.default.DisplayInfo[Index].Step);
            break;
        case HX_PROPERTY_Float:
            Option = AddFloatEdit(
                ConfigClass.default.DisplayInfo[Index].Caption,
                ConfigClass.default.Properties[Index].LowerLimit,
                ConfigClass.default.Properties[Index].UpperLimit,
                ConfigClass.default.DisplayInfo[Index].Step);
            break;
        case HX_PROPERTY_String:
            Option = AddEditBox(
                ConfigClass.default.DisplayInfo[Index].Caption,
                ConfigClass.default.Properties[Index].UpperLimit);
            break;
        case HX_PROPERTY_Enum:
            Option = AddComboBoxConfig(
                ConfigClass.default.DisplayInfo[Index].Caption,
                ConfigClass.default.Properties[Index].EnumValues,
                ConfigClass.default.DisplayInfo[Index].EnumLabels);
            break;
        if (Option != None)
        {
            Option.SetHint(ConfigClass.default.DisplayInfo[Index].Hint);
        }
    }
    return Option;
}

function GUIMenuOption AddPIOption(PlayInfo.PlayInfoData PID)
{
    local GUIMenuOption Option;
    local array<string> Range;
    local string Width;
    local string Op;

    switch (PID.RenderType)
    {
        case PIT_Check:
            Option = List.AddItem("XInterface.moCheckbox",, PID.DisplayName);
            break;
        case PIT_Select:
            Option = AddComboBox(PID.DisplayName, PID.Data);
            break;
        case PIT_Text:
            if (!Divide(PID.Data, ";", Width, Op))
            {
                Width = PID.Data;
            }
            Split(Op, ":", Range);
            if (Range.Length > 1)
            {
                if (InStr(Range[0], ".") != -1)
                {
                    Option = AddFloatEdit(PID.DisplayName, Range[0], Range[1]);
                }
                else
                {
                    Option = AddNumericEdit(PID.DisplayName, Range[0], Range[1]);
                }
            }
            else if (PID.ArrayDim != -1)
            {
                Option = AddButton(PID.DisplayName);
            }
            else
            {
                Option = AddEditBox(PID.DisplayName, Width);
            }
            break;
    }
    if (Option != None)
    {
        Option.SetHint(PID.Description);
    }
    return Option;
}

function HxGUIMultiOptionListHeader AddSection(string Caption)
{
    local HxGUIMultiOptionListHeader Header;

    Header = AddHeader("");
    Header.SectionCaption = Caption;
    return Header;
}

function HxGUIMultiOptionListHeader AddSubSection(string Caption)
{
    local HxGUIMultiOptionListHeader Header;

    Header = AddHeader(Caption);
    Header.StandardHeight = 0.03;
    Header.Tag = -6;
    return Header;
}

function HxGUIMultiOptionListHeader AddHeader(string Caption)
{
    local HxGUIMultiOptionListHeader Header;
    local GUIMenuOption HeaderFiller;
    local int FillerCount;
    local int i;

    FillerCount = List.Elements.Length % NumColumns;
    while (FillerCount-- > 0)
    {
        List.AddItem("XInterface.GUIListSpacer");
    }
    Header = HxGUIMultiOptionListHeader(
        List.AddItem(string(class'HxGUIMultiOptionListHeader'),, Caption));
    for (i = 1; i < NumColumns; ++i)
    {
        HeaderFiller = List.AddItem(string(class'HxGUIMultiOptionListHeader'));
        HeaderFiller.Tag = -1;
    }
    return Header;
}

function GUIMenuOption AddFloatEdit(string Caption,
                                    coerce float Min,
                                    coerce float Max,
                                    optional coerce float Step)
{
    local moFloatEdit Option;

    Option = moFloatEdit(List.AddItem("XInterface.moFloatEdit",, Caption));
    if (Option != None)
    {
        Option.ComponentWidth = ComponentWidth;
        if (Step ~= 0)
        {
            Step = Option.MyNumericEdit.Step;
        }
        Option.Setup(Min, Max, Step);
    }
    return Option;
}

function GUIMenuOption AddNumericEdit(string Caption,
                                      coerce int Min,
                                      coerce int Max,
                                      optional coerce int Step)
{
    local moNumericEdit Option;

    Option = moNumericEdit(List.AddItem("XInterface.moNumericEdit",, Caption));
    if (Option != None)
    {
        if (Step == 0)
        {
            Step = Option.MyNumericEdit.Step;
        }
        Option.ComponentWidth = ComponentWidth;
        Option.Setup(Min, Max, Step);
    }
    return Option;
}

function GUIMenuOption AddButton(string Caption)
{
    local GUIMenuOption Option;

    Option = List.AddItem("XInterface.moButton",, Caption);
    if (Option != None)
    {
        Option.ComponentWidth = ComponentWidth;
        Option.OnChange = ArrayPropClicked;
    }
    return Option;
}

function GUIMenuOption AddEditBox(string Caption, string Width)
{
    local moEditbox Option;
    local int Pos;

    Option = moEditbox(List.AddItem("XInterface.moEditBox",, Caption));
    if (Option != None)
    {
        Pos = InStr(Width, ",");
        if (Pos != -1)
        {
            Width = Left(Width, Pos);
        }
        if (Width != "")
        {
            Option.MyEditBox.MaxWidth = int(Width);
        }
        Option.CaptionWidth = 0.5;
        Option.ComponentWidth = -1;
        Option.bAutoSizeCaption = true;
    }
    return Option;
}

function GUIMenuOption AddComboBox(string Caption, string Data)
{
    local moComboBox Option;
    local array<string> Range;
    local int i;

    Option = moComboBox(List.AddItem("XInterface.moComboBox",, Caption));
    if (Option != None)
    {
        Option.ReadOnly(true);
        if (Data ~= "CROSSHAIRS")
        {
            PopulateCrosshairsComboBox(Option);
        }
        else
        {
            Split(Data, ";", Range);
            for (i = 0; i + 1 < Range.Length; i += 2)
            {
                Option.AddItem(Range[i + 1],, Range[i]);
            }
        }
    }
    return Option;
}

function GUIMenuOption AddComboBoxConfig(string Caption,
                                         array<string> Values,
                                         array<string> Captions)
{
    local moComboBox Option;
    local int i;

    Option = moComboBox(List.AddItem("XInterface.moComboBox",, Caption));
    if (Option != None)
    {
        Option.ReadOnly(true);
    }
    if (Captions.Length == 1 && Captions[0] ~= "CROSSHAIRS")
    {
        PopulateCrosshairsComboBox(Option);
    }
    else
    {
        for (i = 0; i < Captions.Length; ++i)
        {
            Option.AddItem(Captions[i],, Values[i]);
        }
    }
    return Option;
}

function PopulateCrosshairsComboBox(moComboBox Option)
{
    local array<CacheManager.CrosshairRecord> Crosshairs;
    local int i;

    class'CacheManager'.static.GetCrosshairList(Crosshairs);
    Option.MyComboBox.MyListBox.MyList.bInitializeList = false;
    for (i = 0; i < Crosshairs.Length; ++i)
    {
        Option.AddItem(Crosshairs[i].FriendlyName,, string(i));
    }
}

function ArrayPropClicked(GUIComponent Sender)
{
    local PlayInfo PI;
    local GUIArrayPropPage ArrayPage;
    local string ArrayMenu;
    local int i;

    i = Sender.Tag;
    if (i < 0)
    {
        return;
    }
    PI = FindPI(i);
    if (PI == None)
    {
        return;
    }
    if (PI.Settings[i].ArrayDim > 1)
    {
        ArrayMenu = Controller.ArrayPropertyMenu;
    }
    else
    {
        ArrayMenu = Controller.DynArrayPropertyMenu;
    }
    if (Controller.OpenMenu(ArrayMenu, PI.Settings[i].DisplayName, PI.Settings[i].Value))
    {
        ArrayPage = GUIArrayPropPage(Controller.ActivePage);
        ArrayPage.Item = PI.Settings[i];
        ArrayPage.OnClose = ArrayPageClosed;
        ArrayPage.SetOwner(Sender);
    }
}

function ArrayPageClosed(optional bool bCancelled)
{
    local GUIArrayPropPage ArrayPage;
    local moButton CompOwner;

    if (!bCancelled)
    {
        ArrayPage = GUIArrayPropPage(Controller.ActivePage);
        if (ArrayPage != None)
        {
            CompOwner = moButton(ArrayPage.GetOwner());
            if (CompOwner != None)
            {
                CompOwner.SetComponentValue(ArrayPage.GetDataString());
            }
        }
    }
}

function ListLoadINI(GUIComponent Sender, string s)
{
    if (Sender.Tag > -1)
    {
        if (PIs.Length > 0)
        {
            LoadFromPI(GUIMenuOption(Sender));
        }
        else if (CRIs.Length > 0)
        {
            LoadFromCRI(GUIMenuOption(Sender));
        }
    }
}

function LoadFromCRI(GUIMenuOption Sender)
{
    local HxClientReplicationInfo CRI;
    local int ConfigIndex;
    local int PropertyIndex;

    ConfigIndex = Sender.Tag;
    CRI = FindCRI(ConfigIndex, PropertyIndex);
    if (CRI != None)
    {
        Sender.SetComponentValue(CRI.GetConfigProperty(ConfigIndex, PropertyIndex), true);
    }
}

function LoadFromPI(GUIMenuOption Sender)
{
    local PlayInfo PI;
    local int Index;

    Index = Sender.Tag;
    PI = FindPI(Index);
    if (PI != None)
    {
        Sender.SetComponentValue(PI.Settings[Index].Value, true);
    }
}

function ListCreateComponent(GUIMenuOption NewComp, GUIMultiOptionList Sender)
{
    NewComp.LabelJustification = TXTA_Left;
    NewComp.ComponentJustification = TXTA_Right;
    if (PIs.Length > 0)
    {
        NewComp.OnChange = OptionOnChangePI;
    }
    else if (CRIs.Length > 0)
    {
        NewComp.OnChange = OptionOnChangeCRI;
    }
    Super.ListCreateComponent(NewComp, Sender);
}

function OptionOnChangeCRI(GUIComponent Sender)
{
    local HxClientReplicationInfo CRI;
    local int ConfigIndex;
    local int PropertyIndex;


    if (Sender.Tag > -1)
    {
        ConfigIndex = Sender.Tag;
        CRI = FindCRI(ConfigIndex, PropertyIndex);
        if (CRI != None)
        {
            CRI.SetConfigProperty(
                ConfigIndex, PropertyIndex, GUIMenuOption(Sender).GetComponentValue());
        }
    }
}

function OptionOnChangePI(GUIComponent Sender)
{
    if (Sender.Tag > -1)
    {
        OptionModified[Sender.Tag] = 1;
    }
}

function HxClientReplicationInfo FindCRI(out int ConfigIndex, out int PropertyIndex)
{
    local int CRINumber;

    PropertyIndex = ConfigIndex & 0x3ff;
    CRINumber = ConfigIndex >> 20;
    ConfigIndex = (ConfigIndex >> 10) & 0x3ff;
    return CRIs[CRINumber];
}

function PlayInfo FindPI(out int FullTag)
{
    local int i;

    for (i = 0; i < PIs.Length; ++i)
    {
        if (FullTag < PIs[i].Settings.Length)
        {
            return PIs[i];
        }
        FullTag -= PIs[i].Settings.Length;
    }
    return None;
}

function bool IsModified(int Index)
{
    return OptionModified[Index] == 1;
}

function ResetModified(int Index)
{
    OptionModified[Index] = 0;
}

function Clear()
{
    Options.Remove(0, Options.Length);
    CRIs.Remove(0, CRIs.Length);
    PIs.Remove(0, PIs.Length);
    OptionModified.Remove(0, OptionModified.Length);
    PropertyCount = 0;
    List.Clear();
}

function LevelChanged()
{
    Clear();
    Super.LevelChanged();
}

defaultproperties
{
    Begin Object Class=HxGUIVertScrollBar Name=HxScrollbar
        bScaleToParent=true
        ScrollZoneStyleName="HxOptionList"
    End Object
    MyScrollBar=HxScrollbar

    StyleName="HxOptionList"
    ComponentWidth=0.25
    ScrollbarWidth=0.016
    bShowSections=true
}
