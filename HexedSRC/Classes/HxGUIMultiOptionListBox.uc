class HxGUIMultiOptionListBox extends GUIMultiOptionListBox;

var float ComponentWidth;
var float ScrollbarWidth;

var private array<HxGUIMultiOptionListLabel> StatusElements;

var private array<GUIMenuOption> HeaderPool;
var private array<GUIMenuOption> SpacerPool;
var private array<GUIMenuOption> LabelPool;
var private array<GUIMenuOption> CheckBoxPool;
var private array<GUIMenuOption> ComboBoxPool;
var private array<GUIMenuOption> NumericEditPool;
var private array<GUIMenuOption> FloatEditPool;
var private array<GUIMenuOption> TextEditPool;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    DefaultListClass = string(class'HxGUIMultiOptionList');
    Super.InitComponent(MyController, MyOwner);
    HxGUIVertScrollBar(MyScrollBar).StandardWidth = ScrollbarWidth;
}

event Opened(GUIComponent Sender)
{
    if (Controller.ViewportOwner != None && Controller.ViewportOwner.Actor != None)
    {
        SetTimer(Controller.ViewportOwner.Actor.Level.TimeDilation * 2, true);
    }
    else
    {
        SetTimer(2.2, true);
    }
    Super.Opened(Sender);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    KillTimer();
    Super.Closed(Sender, bCancelled);
}

event Timer()
{
    local int i;

    for (i = 0; i < StatusElements.Length; ++i)
    {
        StatusElements[i].LoadINI();
    }
    Super.Timer();
}

function InitBaseList(GUIListBase LocalList)
{
    Super.InitBaseList(LocalList);
    List.OnClickSound = CS_None;
}

function Refresh()
{
    local int i;

    for (i = 0; i < List.Elements.Length; ++i)
    {
        List.Elements[i].LoadINI();
    }
}

function GUIMenuOption AddConfigOption(class<HxConfig> ConfigClass, int Index, int Tag)
{
    local GUIMenuOption Option;

    switch (ConfigClass.default.Properties[Index].Type)
    {
        case HX_PROPERTY_Bool:
            Option = List.AddItem(
                string(class'HxGUImoCheckBox'),
                GetFromCheckBoxPool(),
                ConfigClass.default.DisplayInfo[Index].Caption);
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
            Option = AddComboBox(
                ConfigClass.default.DisplayInfo[Index].Caption,
                int(ConfigClass.default.Properties[Index].LowerLimit),
                ConfigClass.default.Properties[Index].EnumType,
                ConfigClass.default.DisplayInfo[Index].EnumLabels);
            break;
    }
    if (Option != None)
    {
        Option.SetHint(ConfigClass.default.DisplayInfo[Index].Hint);
        Option.Tag = Tag;
    }
    return Option;
}

function GUIMenuOption AddMutatorOption(class<HxMutator> MutatorClass, int Index, int Tag)
{
    local GUIMenuOption Option;

    switch (MutatorClass.default.Properties[Index].Type)
    {
        case HX_PROPERTY_Bool:
            Option = List.AddItem(
                string(class'HxGUImoCheckBox'),
                GetFromCheckBoxPool(),
                MutatorClass.default.DisplayInfo[Index].Caption);
            break;
        case HX_PROPERTY_Int:
            Option = AddNumericEdit(
                MutatorClass.default.DisplayInfo[Index].Caption,
                MutatorClass.default.Properties[Index].LowerLimit,
                MutatorClass.default.Properties[Index].UpperLimit,
                MutatorClass.default.DisplayInfo[Index].Step);
            break;
        case HX_PROPERTY_Float:
            Option = AddFloatEdit(
                MutatorClass.default.DisplayInfo[Index].Caption,
                MutatorClass.default.Properties[Index].LowerLimit,
                MutatorClass.default.Properties[Index].UpperLimit,
                MutatorClass.default.DisplayInfo[Index].Step);
            break;
        case HX_PROPERTY_String:
            Option = AddEditBox(
                MutatorClass.default.DisplayInfo[Index].Caption,
                MutatorClass.default.Properties[Index].UpperLimit);
            break;
        case HX_PROPERTY_Enum:
            Option = AddComboBox(
                MutatorClass.default.DisplayInfo[Index].Caption,
                int(MutatorClass.default.Properties[Index].LowerLimit),
                MutatorClass.default.Properties[Index].EnumType,
                MutatorClass.default.DisplayInfo[Index].EnumLabels);
            break;
    }
    if (Option != None)
    {
        Option.SetHint(MutatorClass.default.DisplayInfo[Index].Hint);
        Option.Tag = Tag;
    }
    return Option;
}

function GUIMenuOption AddGlobalOption(int Index, int Tag)
{
    local GUIMenuOption Option;

    switch (class'HxMutator'.default.GlobalProperties[Index].Type)
    {
        case HX_PROPERTY_Bool:
            Option = List.AddItem(
                string(class'HxGUImoCheckBox'),
                GetFromCheckBoxPool(),
                class'HxMutator'.default.GlobalDisplayInfo[Index].Caption);
            break;
        case HX_PROPERTY_Int:
            Option = AddNumericEdit(
                class'HxMutator'.default.GlobalDisplayInfo[Index].Caption,
                class'HxMutator'.default.GlobalProperties[Index].LowerLimit,
                class'HxMutator'.default.GlobalProperties[Index].UpperLimit,
                class'HxMutator'.default.GlobalDisplayInfo[Index].Step);
            break;
        case HX_PROPERTY_Float:
            Option = AddFloatEdit(
                class'HxMutator'.default.GlobalDisplayInfo[Index].Caption,
                class'HxMutator'.default.GlobalProperties[Index].LowerLimit,
                class'HxMutator'.default.GlobalProperties[Index].UpperLimit,
                class'HxMutator'.default.GlobalDisplayInfo[Index].Step);
            break;
        case HX_PROPERTY_String:
            Option = AddEditBox(
                class'HxMutator'.default.GlobalDisplayInfo[Index].Caption,
                class'HxMutator'.default.GlobalProperties[Index].UpperLimit);
            break;
        case HX_PROPERTY_Enum:
            Option = AddComboBox(
                class'HxMutator'.default.GlobalDisplayInfo[Index].Caption,
                int(class'HxMutator'.default.GlobalProperties[Index].LowerLimit),
                class'HxMutator'.default.GlobalProperties[Index].EnumType,
                class'HxMutator'.default.GlobalDisplayInfo[Index].EnumLabels);
            break;
    }
    if (Option != None)
    {
        Option.SetHint(class'HxMutator'.default.GlobalDisplayInfo[Index].Hint);
        Option.Tag = Tag;
    }
    return Option;
}

function HxGUIMultiOptionListLabel AddStatus(string Caption, int Tag)
{
    local HxGUIMultiOptionListLabel Label;

    Label = HxGUIMultiOptionListLabel(
        List.AddItem(string(class'HxGUIMultiOptionListLabel'), GetFromLabelPool(), Caption));
    if (Label != None)
    {
        Label.Tag = Tag;
        Label.CaptionWidth = 0.2;
        Label.ComponentWidth = -1;
        Label.bAutoSizeCaption = true;
        StatusElements[StatusElements.Length] = Label;
    }
    return Label;
}

function HxGUIMultiOptionListLabel AddLabel(string Caption, int Tag)
{
    local HxGUIMultiOptionListLabel Label;

    Label = HxGUIMultiOptionListLabel(
        List.AddItem(string(class'HxGUIMultiOptionListLabel'), GetFromLabelPool(), Caption));
    if (Label != None)
    {
        Label.Tag = Tag;
        Label.CaptionWidth = 0.2;
        Label.ComponentWidth = -1;
        Label.bAutoSizeCaption = true;
    }
    return Label;
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
    local string HeaderClass;
    local int FillerCount;
    local int i;

    HeaderClass = string(class'HxGUIMultiOptionListHeader');
    FillerCount = List.Elements.Length % NumColumns;
    while (FillerCount-- > 0)
    {
        List.AddItem(string(class'HxGUIListSpacer'), GetFromSpacerPool());
    }
    Header = HxGUIMultiOptionListHeader(List.AddItem(HeaderClass, GetFromHeaderPool(), Caption));
    for (i = 1; i < NumColumns; ++i)
    {
        HeaderFiller = List.AddItem(HeaderClass, GetFromHeaderPool());
        HeaderFiller.Tag = -1;
    }
    return Header;
}

function GUIMenuOption AddFloatEdit(string Caption,
                                    coerce float Min,
                                    coerce float Max,
                                    optional coerce float Step)
{
    local HxGUImoFloatEdit Option;

    Option = HxGUImoFloatEdit(List.AddItem(
        string(class'HxGUImoFloatEdit'), GetFromFloatEditPool(), Caption));
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
    local HxGUImoNumericEdit Option;

    Option = HxGUImoNumericEdit(List.AddItem(
        string(class'HxGUImoNumericEdit'), GetFromNumericEditPool(), Caption));
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

function GUIMenuOption AddEditBox(string Caption, string Width)
{
    local HxGUImoEditBox Option;
    local int Pos;

    Option = HxGUImoEditBox(List.AddItem(
        string(class'HxGUImoEditBox'), GetFromTextEditPool(), Caption));
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

function GUIMenuOption AddComboBox(string Caption,
                                   int LowerLimit,
                                   Object EnumType,
                                   array<string> Captions)
{
    local moComboBox Option;
    local int i;

    Option = moComboBox(List.AddItem(
        string(class'HxGUImoComboBox'), GetFromComboBoxPool(), Caption));
    if (Option != None)
    {
        if (Caption == "")
        {
            Option.CaptionWidth = 0;
        }
        Option.ReadOnly(true);
    }
    Option.MyComboBox.MyListBox.MyList.bInitializeList = false;
    for (i = 0; i < Captions.Length; ++i)
    {
        Option.AddItem(Captions[i],, string(GetEnum(EnumType, LowerLimit + i)));
    }
    return Option;
}

function ListCreateComponent(GUIMenuOption NewComp, GUIMultiOptionList Sender)
{
    NewComp.LabelJustification = TXTA_Left;
    NewComp.ComponentJustification = TXTA_Right;
    NewComp.OnChange = InternalOnChange;
    Super.ListCreateComponent(NewComp, Sender);
}

function Clear()
{
    local int i;

    StatusElements.Remove(0, StatusElements.Length);
    for (i = 0; i < List.Elements.Length; ++i)
    {
        List.Elements[i].SetCaption("");
        switch (List.Elements[i].Class)
        {
            case class'HxGUIMultiOptionListHeader':
                HxGUIMultiOptionListHeader(List.Elements[i]).SectionCaption = "";
                List.Elements[i].Tag = class'HxGUIMultiOptionListHeader'.default.Tag;
                HeaderPool[HeaderPool.Length] = List.Elements[i];
                break;
            case class'HxGUIListSpacer':
                SpacerPool[SpacerPool.Length] = List.Elements[i];
                break;
            case class'HxGUIMultiOptionListLabel':
                LabelPool[LabelPool.Length] = List.Elements[i];
                break;
            case class'HxGUImoCheckBox':
                CheckBoxPool[CheckBoxPool.Length] = List.Elements[i];
                break;
            case class'HxGUImoComboBox':
                List.Elements[i].ResetComponent();
                ComboBoxPool[ComboBoxPool.Length] = List.Elements[i];
                break;
            case class'HxGUImoNumericEdit':
                NumericEditPool[NumericEditPool.Length] = List.Elements[i];
                break;
            case class'HxGUImoFloatEdit':
                FloatEditPool[FloatEditPool.Length] = List.Elements[i];
                break;
            case class'HxGUImoEditBox':
                TextEditPool[TextEditPool.Length] = List.Elements[i];
                break;
        }
    }
    List.Clear();
}

event Free()
{
    local int i;

    for (i = 0; i < HeaderPool.Length; ++i)
    {
        HeaderPool[i].Free();
    }
    HeaderPool.Remove(0, HeaderPool.Length);
    for (i = 0; i < SpacerPool.Length; ++i)
    {
        SpacerPool[i].Free();
    }
    SpacerPool.Remove(0, SpacerPool.Length);
    for (i = 0; i < LabelPool.Length; ++i)
    {
        LabelPool[i].Free();
    }
    LabelPool.Remove(0, LabelPool.Length);
    for (i = 0; i < CheckBoxPool.Length; ++i)
    {
        CheckBoxPool[i].Free();
    }
    CheckBoxPool.Remove(0, CheckBoxPool.Length);
    for (i = 0; i < ComboBoxPool.Length; ++i)
    {
        ComboBoxPool[i].Free();
    }
    ComboBoxPool.Remove(0, ComboBoxPool.Length);
    for (i = 0; i < NumericEditPool.Length; ++i)
    {
        NumericEditPool[i].Free();
    }
    NumericEditPool.Remove(0, NumericEditPool.Length);
    for (i = 0; i < FloatEditPool.Length; ++i)
    {
        FloatEditPool[i].Free();
    }
    FloatEditPool.Remove(0, FloatEditPool.Length);
    for (i = 0; i < TextEditPool.Length; ++i)
    {
        TextEditPool[i].Free();
    }
    TextEditPool.Remove(0, TextEditPool.Length);
    Super.Free();
}

function GUIMenuOption GetFromHeaderPool()
{
    local GUIMenuOption Option;
    local int i;

    if (HeaderPool.Length > 0)
    {
        i = HeaderPool.Length - 1;
        Option = HeaderPool[i];
        HeaderPool.Remove(i, 1);
    }
    return Option;
}

function GUIMenuOption GetFromSpacerPool()
{
    local GUIMenuOption Option;
    local int i;

    if (SpacerPool.Length > 0)
    {
        i = SpacerPool.Length - 1;
        Option = SpacerPool[i];
        SpacerPool.Remove(i, 1);
    }
    return Option;
}

function GUIMenuOption GetFromLabelPool()
{
    local GUIMenuOption Option;
    local int i;

    if (LabelPool.Length > 0)
    {
        i = LabelPool.Length - 1;
        Option = LabelPool[i];
        LabelPool.Remove(i, 1);
    }
    return Option;
}

function GUIMenuOption GetFromCheckBoxPool()
{
    local GUIMenuOption Option;
    local int i;

    if (CheckBoxPool.Length > 0)
    {
        i = CheckBoxPool.Length - 1;
        Option = CheckBoxPool[i];
        CheckBoxPool.Remove(i, 1);
    }
    return Option;
}

function GUIMenuOption GetFromComboBoxPool()
{
    local GUIMenuOption Option;
    local int i;

    if (ComboBoxPool.Length > 0)
    {
        i = ComboBoxPool.Length - 1;
        Option = ComboBoxPool[i];
        ComboBoxPool.Remove(i, 1);
    }
    return Option;
}

function GUIMenuOption GetFromNumericEditPool()
{
    local GUIMenuOption Option;
    local int i;

    if (NumericEditPool.Length > 0)
    {
        i = NumericEditPool.Length - 1;
        Option = NumericEditPool[i];
        NumericEditPool.Remove(i, 1);
    }
    return Option;
}

function GUIMenuOption GetFromFloatEditPool()
{
    local GUIMenuOption Option;
    local int i;

    if (FloatEditPool.Length > 0)
    {
        i = FloatEditPool.Length - 1;
        Option = FloatEditPool[i];
        FloatEditPool.Remove(i, 1);
    }
    return Option;
}

function GUIMenuOption GetFromTextEditPool()
{
    local GUIMenuOption Option;
    local int i;

    if (TextEditPool.Length > 0)
    {
        i = TextEditPool.Length - 1;
        Option = TextEditPool[i];
        TextEditPool.Remove(i, 1);
    }
    return Option;
}

final function bool ShouldHideConfigProperty(class<HxConfig> ConfigClass, int Index)
{
    return ConfigClass.default.Properties[Index].Type == HX_PROPERTY_Array
        || ConfigClass.default.Properties[Index].Type == HX_PROPERTY_Color
        || ConfigClass.default.Properties[Index].Type == HX_PROPERTY_Struct
        || (!Controller.bExpertMode && ConfigClass.default.DisplayInfo[Index].bAdvanced);
}

final function bool ShouldHideServerProperty(class<HxMutator> MutatorClass, int Index)
{
    return MutatorClass.default.Properties[Index].Type == HX_PROPERTY_Array
        || MutatorClass.default.Properties[Index].Type == HX_PROPERTY_Color
        || MutatorClass.default.Properties[Index].Type == HX_PROPERTY_Struct
        || (!Controller.bExpertMode && MutatorClass.default.DisplayInfo[Index].bAdvanced);
}

final function bool ShouldHideGlobalProperty(int Index)
{
    return class'HxMutator'.default.GlobalProperties[Index].Type == HX_PROPERTY_Array
        || class'HxMutator'.default.GlobalProperties[Index].Type == HX_PROPERTY_Color
        || class'HxMutator'.default.GlobalProperties[Index].Type == HX_PROPERTY_Struct
        || (!Controller.bExpertMode && class'HxMutator'.default.GlobalDisplayInfo[Index].bAdvanced);
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
}
