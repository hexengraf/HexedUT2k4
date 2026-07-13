class HxGUIMultiOptionListBox extends GUIMultiOptionListBox;

var float ComponentWidth;
var float ScrollbarWidth;

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
                "XInterface.moCheckbox",, MutatorClass.default.DisplayInfo[Index].Caption);
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

function HxGUIMultiOptionListLabel AddLabel(string Caption, int Tag)
{
    local HxGUIMultiOptionListLabel Label;

    Label = HxGUIMultiOptionListLabel(
        List.AddItem(string(class'HxGUIMultiOptionListLabel'),, Caption));
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

function GUIMenuOption AddComboBox(string Caption,
                                   int LowerLimit,
                                   Object EnumType,
                                   array<string> Captions)
{
    local moComboBox Option;
    local int i;

    Option = moComboBox(List.AddItem("XInterface.moComboBox",, Caption));
    if (Option != None)
    {
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
    List.Clear();
}

final function bool ShouldHideConfigProperty(HxClientReplicationInfo CRI,
                                             class<HxConfig> ConfigClass,
                                             int Index)
{
    return ConfigClass.default.DisplayInfo[Index].bHidden
        || ConfigClass.default.Properties[Index].Type == HX_PROPERTY_Array
        || ConfigClass.default.Properties[Index].Type == HX_PROPERTY_Color
        || ConfigClass.default.Properties[Index].Type == HX_PROPERTY_Struct
        || (!Controller.bExpertMode && ConfigClass.default.DisplayInfo[Index].bAdvanced)
        || (ConfigClass.default.DisplayInfo[Index].Dependency != ""
            && !bool(CRI.GetServerProperty(ConfigClass.default.DisplayInfo[Index].Dependency)));
}

final function bool ShouldHideMutatorProperty(class<HxMutator> MutatorClass, int Index)
{
    return MutatorClass.default.DisplayInfo[Index].bHidden
        || MutatorClass.default.Properties[Index].Type == HX_PROPERTY_Array
        || MutatorClass.default.Properties[Index].Type == HX_PROPERTY_Color
        || MutatorClass.default.Properties[Index].Type == HX_PROPERTY_Struct
        || (!Controller.bExpertMode && MutatorClass.default.DisplayInfo[Index].bAdvanced);
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
