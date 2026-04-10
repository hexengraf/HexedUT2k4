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
            ProcessCRI(NewCRIs[i]);
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

function ProcessCRI(HxClientReplicationInfo CRI)
{
    local GUIMenuOption Option;
    local string SectionCaption;
    local bool bSavedCurMenuInitialized;
    local bool bSectionAdded;
    local int i;

    CRIs[CRIs.Length] = CRI;
    if (CRI.Properties.Length == 0)
    {
        return;
    }
    bSavedCurMenuInitialized = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = false;
    for (i = 0; i < CRI.Properties.Length; ++i)
    {
        if ((!Controller.bExpertMode && CRI.Properties[i].bAdvanced)
            || (CRI.Properties[i].Dependency != ""
                && !bool(CRI.GetServerProperty(CRI.Properties[i].Dependency))))
        {
            continue;
        }
        if (!bSectionAdded)
        {
            AddSection(CRI.MutatorClass.default.FriendlyName);
            bSectionAdded = true;
        }
        if (CRI.Properties[i].Section != SectionCaption)
        {
            AddSubSection(CRI.Properties[i].Section);
            SectionCaption = CRI.Properties[i].Section;
        }
        Option = AddCRIOption(CRI.Properties[i]);
        if (Option != None)
        {
            Option.Tag = PropertyCount + i;
            Options[Options.Length] = Option;
        }
    }
    PropertyCount += CRI.Properties.Length;
    Controller.bCurMenuInitialized = bSavedCurMenuInitialized;
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

function GUIMenuOption AddCRIOption(HxClientReplicationInfo.HxClientProperty Prop)
{
    local GUIMenuOption Option;
    local array<string> Range;
    local string Width;
    local string Op;

    switch (Prop.Type)
    {
        case PIT_Check:
            Option = List.AddItem("XInterface.moCheckbox",, Prop.Caption);
            break;
        case PIT_Select:
            Option = AddComboBox(Prop.Caption, Prop.Data);
            break;
        case PIT_Text:
            if (!Divide(Prop.Data, ";", Width, Op))
            {
                Width = Prop.Data;
            }
            Split(Op, ":", Range);
            if (Range.Length < 2)
            {
                Option = AddEditBox(Prop.Caption, Width);
            }
            else if (InStr(Range[0], ".") != -1)
            {
                Option = AddFloatEdit(Prop.Caption, float(Range[0]), float(Range[1]), Prop.Step);
            }
            else
            {
                Option = AddNumericEdit(Prop.Caption, int(Range[0]), int(Range[1]), Prop.Step);
            }
            break;
    }
    if (Option != None)
    {
        Option.SetHint(Prop.Hint);
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
                    Option = AddFloatEdit(PID.DisplayName, float(Range[0]), float(Range[1]));
                }
                else
                {
                    Option = AddNumericEdit(PID.DisplayName, int(Range[0]), int(Range[1]));
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

function GUIMenuOption AddFloatEdit(string Caption, float Min, float Max, optional float Step)
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

function GUIMenuOption AddNumericEdit(string Caption, int Min, int Max,  optional int Step)
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
        Split(Data, ";", Range);
        for (i = 0; i + 1 < Range.Length; i += 2)
        {
            Option.AddItem(Range[i + 1],, Range[i]);
        }
    }
    return Option;
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
    local int Index;

    Index = Sender.Tag;
    CRI = FindCRI(Index);
    if (CRI != None)
    {
        Sender.SetComponentValue(CRI.GetProperty(Index), true);
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
    local int Index;

    if (Sender.Tag > -1)
    {
        Index = Sender.Tag;
        CRI = FindCRI(Index);
        if (CRI != None)
        {
            CRI.SetProperty(Index, GUIMenuOption(Sender).GetComponentValue());
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

function HxClientReplicationInfo FindCRI(out int FullTag)
{
    local int i;

    for (i = 0; i < CRIs.Length; ++i)
    {
        if (FullTag < CRIs[i].Properties.Length)
        {
            return CRIs[i];
        }
        FullTag -= CRIs[i].Properties.Length;
    }
    return None;
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
