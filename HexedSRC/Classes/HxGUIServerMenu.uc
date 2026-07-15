class HxGUIServerMenu extends HxGUIFloatingWindow;

struct HxModifiedMutatorOptions
{
    var array<GUIMenuOption> Senders;
};

var automated HxGUIFramedSection Section;
var automated HxGUIMultiOptionListBox lb_Options;
var automated moCheckBox ch_Advanced;

var private HxClientManager ClientManager;
var private array<HxModifiedMutatorOptions> ModifiedMutators;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    Section.Insert(lb_Options);
    Section.Insert(ch_Advanced, 0.015, 0.015);
    ForEach PlayerOwner().DynamicActors(class'HxClientManager', ClientManager) break;
}

event Opened(GUIComponent Sender)
{
    Super.Opened(Sender);
    ch_Advanced.Checked(Controller.bExpertMode);
    Refresh();
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    if (IsAdmin())
    {
        UpdateServerProperties();
    }
    Super.Closed(Sender, bCancelled);
}

function UpdateServerProperties()
{
    local int i;
    local int j;

    for (i = 0; i < ModifiedMutators.Length; ++i)
    {
        for (j = 0; j < ModifiedMutators[i].Senders.Length; ++j)
        {
            if (ModifiedMutators[i].Senders[j] != None)
            {
                ClientManager.CRIs[i].ServerUpdateProperty(
                    j, ModifiedMutators[i].Senders[j].GetComponentValue());
                ModifiedMutators[i].Senders[j] = None;
            }
        }
    }
}

function Refresh()
{
    PopulateOptionList();
}

function PopulateOptionList()
{
    local bool bSavedCurMenuInitialized;
    local int i;

    lb_Options.Clear();
    bSavedCurMenuInitialized = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = false;
    for (i = 0; i < ClientManager.CRIs.Length; ++i)
    {
        if (ClientManager.CRIs[i] != None)
        {
            ModifiedMutators.Insert(ModifiedMutators.Length, 1);
            ProcessMutatorOptions(ClientManager.CRIs[i], i);
        }
    }
    Controller.bCurMenuInitialized = bSavedCurMenuInitialized;
    lb_Options.Refresh();
}

function ProcessMutatorOptions(HxClientReplicationInfo CRI, optional int Index)
{
    local string SectionCaption;
    local bool bSectionAdded;
    local int i;

    ModifiedMutators[Index].Senders.Length = CRI.MutatorClass.default.DisplayInfo.Length;
    for (i = 0; i < CRI.MutatorClass.default.DisplayInfo.Length; ++i)
    {
        if (lb_Options.ShouldHideMutatorProperty(CRI.MutatorClass, i))
        {
            continue;
        }
        if (!bSectionAdded)
        {
            lb_Options.AddSection(CRI.MutatorClass.default.FriendlyName);
            bSectionAdded = true;
        }
        if (CRI.MutatorClass.default.DisplayInfo[i].Section != SectionCaption)
        {
            lb_Options.AddSubSection(CRI.MutatorClass.default.DisplayInfo[i].Section);
            SectionCaption = CRI.MutatorClass.default.DisplayInfo[i].Section;
        }
        lb_Options.AddMutatorOption(CRI.MutatorClass, i, ClientManager.EncodeTag(Index, i));
    }
}

function OptionsOnLoadINI(GUIComponent Sender, string s)
{
    local HxClientReplicationInfo CRI;
    local int Index;

    if (ClientManager.DecodeServerTag(Sender.Tag, CRI, Index) > -1)
    {
        GUIMenuOption(Sender).SetComponentValue(CRI.GetServerPropertyByIndex(Index), true);
    }
}

function OptionsOnChange(GUIComponent Sender)
{
    local int CRINumber;
    local int Index;

    CRINumber = ClientManager.DecodeServerTag(Sender.Tag,, Index);
    if (CRINumber > -1)
    {
        ModifiedMutators[CRINumber].Senders[Index] = GUIMenuOption(Sender);
    }
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputAction Action;

    Action = EInputAction(State);
    switch (EInputKey(Key))
    {
        case IK_MouseWheelUp:
        case IK_MouseWheelDown:
            if (!lb_Options.bHasFocus)
            {
                lb_Options.SetFocus(None);
            }
            break;
    }
    return false;
}

function InternalOnChange(GUIComponent Sender)
{
    if (Sender == ch_Advanced)
    {
        Controller.bExpertMode = ch_Advanced.IsChecked();
        Controller.SaveConfig();
        Refresh();
    }
}

function bool IsAdmin()
{
    local PlayerController PC;

    PC = PlayerOwner();
    return PC != None
        && (PC.Level.NetMode == NM_Standalone
            || (PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo.bAdmin));
}

function LevelChanged()
{
    ClientManager = None;
    Super.LevelChanged();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=ConfigListSection
        WinLeft=0.03
        WinTop=0.06
        WinWidth=0.94
        WinHeight=0.91
        LeftPadding=0
        TopPadding=0
        RightPadding=0
        bNoHeader=true
        ExpandIndices=(0)
    End Object
    Section=ConfigListSection

    Begin Object Class=HxGUIMultiOptionListBox Name=ConfigListBox
        bVisibleWhenEmpty=true
        NumColumns=1
        OnLoadINI=OptionsOnLoadINI
        OnChange=OptionsOnChange
        TabOrder=1
    End Object
    lb_Options=ConfigListBox

    Begin Object Class=moCheckBox Name=AdvancedCheckBox
        Caption="View Advanced Options"
        Hint="Toggles whether advanced properties are displayed"
        TabOrder=2
        OnChange=InternalOnChange
    End Object
    ch_Advanced=AdvancedCheckBox

    WindowName="HexedMenu - Server Options"
    WinLeft=0.29
    WinTop=0.19
    WinWidth=0.42
    WinHeight=0.62
    OnKeyEvent=InternalOnKeyEvent
}
