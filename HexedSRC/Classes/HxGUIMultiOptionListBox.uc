class HxGUIMultiOptionListBox extends GUIMultiOptionListBox;

var float ComponentWidth;
var float ScrollbarWidth;

var private HxClientReplicationInfo CRI;
var private PlayInfo Info;
var private array<byte> OptionModified;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    DefaultListClass = string(class'HxGUIMultiOptionList');
    Super.InitComponent(MyController, MyOwner);
    MyScrollBar.WinWidth = ScrollbarWidth;
}

function PopulateWithCRI(HxClientReplicationInfo NewCRI)
{
    local GUIMenuOption Option;
    local string HeaderCaption;
    local int i;

    List.Clear();
    CRI = NewCRI;
    for (i = 0; i <CRI.Properties.Length; ++i)
    {
        if ((!Controller.bExpertMode && CRI.Properties[i].bAdvanced)
            || (CRI.Properties[i].Dependency != ""
                && !bool(CRI.GetServerProperty(CRI.Properties[i].Dependency))))
        {
            continue;
        }
        if (CRI.Properties[i].Section != HeaderCaption)
        {
            AddHeader(CRI.Properties[i].Section);
            HeaderCaption = CRI.Properties[i].Section;
        }
        Option = AddCRIOption(CRI.Properties[i]);
        if (Option != None)
        {
            Option.Tag = i;
        }
    }
    bInit = true;
    Refresh();
}

function PopulateWithPlayInfo(PlayInfo NewInfo)
{
    local class<HxMutator> MutatorClass;
    local GUIMenuOption Option;
    local string HeaderCaption;
    local int i;

    List.Clear();
    OptionModified.Length = 0;
    Info = NewInfo;
    if (Info.InfoClasses.Length == 1)
    {
        MutatorClass = class<HxMutator>(Info.InfoClasses[0]);
    }
    for (i = 0; i < Info.Settings.Length; ++i)
    {
        if (!Controller.bExpertMode && Info.Settings[i].bAdvanced)
        {
            continue;
        }
        if (MutatorClass != None)
        {
            if (MutatorClass.default.Properties[i].Section != HeaderCaption)
            {
                AddHeader(MutatorClass.default.Properties[i].Section);
                HeaderCaption = MutatorClass.default.Properties[i].Section;
            }
        }
        else if (Info.Settings[i].Grouping != HeaderCaption)
        {
            AddHeader(Info.Settings[i].Grouping);
            HeaderCaption = Info.Settings[i].Grouping;
        }
        Option = AddPlayInfoOption(Info.Settings[i]);
        if (Option != None)
        {
            Option.Tag = i;
        }
    }
    OptionModified.Length = Info.Settings.Length;
    bInit = true;
    Refresh();
}

function Refresh()
{
    local int i;

    for (i = 0; i < List.Elements.Length; ++i)
    {
        List.Elements[i].LoadINI();
    }
}

function AddHeader(string Caption)
{
    local int FillerCount;
    local int i;

    FillerCount = List.Elements.Length % NumColumns;
    while (FillerCount-- > 0)
    {
        List.AddItem("XInterface.GUIListSpacer");
    }
    List.AddItem(string(class'HxGUIMultiOptionListHeader'),, Caption);
    for (i = 1; i < NumColumns; ++i)
    {
        List.AddItem(string(class'HxGUIMultiOptionListHeader'));
    }
}

function GUIMenuOption AddCRIOption(HxClientReplicationInfo.HxClientProperty Prop)
{
    local GUIMenuOption Option;
    local array<string> Range;
    local string Width;
    local string Op;
    local bool bTemp;

    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = false;
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
            if (Range.Length > 1)
            {
                if (InStr(Range[0], ".") != -1)
                {
                    Option = AddFloatEdit(Prop.Caption, float(Range[0]), float(Range[1]));
                }
                else
                {
                    Option = AddNumericEdit(Prop.Caption, int(Range[0]), int(Range[1]));
                }
            }
            else
            {
                Option = AddEditBox(Prop.Caption, Width);
            }
            break;
    }
    if (Option != None)
    {
        Option.SetHint(Prop.Hint);
    }
    Controller.bCurMenuInitialized = bTemp;
    return Option;
}

function GUIMenuOption AddPlayInfoOption(PlayInfo.PlayInfoData PID)
{
    local GUIMenuOption Option;
    local array<string> Range;
    local string Width;
    local string Op;
    local bool bTemp;

    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = false;
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
    Controller.bCurMenuInitialized = bTemp;
    return Option;
}

function GUIMenuOption AddFloatEdit(string Caption, float Min, float Max)
{
    local moFloatEdit Option;

    Option = moFloatEdit(List.AddItem("XInterface.moFloatEdit",, Caption));
    if (Option != None)
    {
        Option.ComponentWidth = ComponentWidth;
        Option.Setup(Min, Max, Option.MyNumericEdit.Step);
    }
    return Option;
}

function GUIMenuOption AddNumericEdit(string Caption, int Min, int Max)
{
    local moNumericEdit Option;

    Option = moNumericEdit(List.AddItem("XInterface.moNumericEdit",, Caption));
    if (Option != None)
    {
        Option.ComponentWidth = ComponentWidth;
        Option.Setup(Min, Max, Option.MyNumericEdit.Step);
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
    local GUIArrayPropPage ArrayPage;
    local string ArrayMenu;
    local int i;

    i = Sender.Tag;
    if (i < 0)
    {
        return;
    }
    if (Info.Settings[i].ArrayDim > 1)
    {
        ArrayMenu = Controller.ArrayPropertyMenu;
    }
    else
    {
        ArrayMenu = Controller.DynArrayPropertyMenu;
    }
    if (Controller.OpenMenu(ArrayMenu, Info.Settings[i].DisplayName, Info.Settings[i].Value))
    {
        ArrayPage = GUIArrayPropPage(Controller.ActivePage);
        ArrayPage.Item = Info.Settings[i];
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
        if (Info != None)
        {
            GUIMenuOption(Sender).SetComponentValue(Info.Settings[Sender.Tag].Value);
        }
        else if (CRI != None)
        {
            GUIMenuOption(Sender).SetComponentValue(CRI.GetProperty(Sender.Tag));
        }
    }
}

function ListCreateComponent(GUIMenuOption NewComp, GUIMultiOptionList Sender)
{
    NewComp.LabelJustification = TXTA_Left;
    NewComp.ComponentJustification = TXTA_Right;
    NewComp.OnChange = OptionOnChange;
    Super.ListCreateComponent(NewComp, Sender);
}

function OptionOnChange(GUIComponent Sender)
{
    if (Sender.Tag > -1)
    {
        if (Info != None)
        {
            OptionModified[Sender.Tag] = 1;
        }
        else if (CRI != None)
        {
            CRI.SetProperty(Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
        }
    }
}

function bool IsModified(int Index)
{
    return OptionModified[Index] == 1;
}

function ResetModified(int Index)
{
    OptionModified[Index] = 0;
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
    ScrollbarWidth=0.03
}
