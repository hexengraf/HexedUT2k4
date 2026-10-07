class HxClientManager extends HxInteraction
    DependsOn(HxTypes)
    DependsOn(HxMutator)
    config(HexedCache);

struct HxMutatorEntry
{
    var class<HxMutator> MutatorClass;
    var HxMutatorInfo MutatorInfo;
    var array<HxConfig> Configs;
    var array<int> DelayedIndices;
    var bool bHasDelayedConfigs;
};

struct HxDelayedUpdate
{
    var int Tag;
    var string Value;
};

struct HxNotification
{
    var string FullMessage;
    var float Duration;
    var array<string> Lines;
    var Font Font;
    var float Fade;
    var float Width;
    var float Height;
    var float LineHeight;
};

const RSVD_UID = 1023;
const RSVD_INDEX = 1023;

var config bool bFirstRun;
var config string MenuKeybind;
var float MinimumNotifyDuration;
var HxMutator.EHxNotifyRunning NotifyRunning;
var HxMutator.EHxVerbosityLevel StatusVerbosity;

var const localized string PlatformLabel;
var const localized string ActiveMutatorsLabel;
var const localized string RunningMessage;
var const localized string OpenMenuMessage;
var const localized string PressMessage;
var const localized string ExecMessage;
var const string ProjectName;
var const string MenuCommand;

var const private class<HxGUIFloatingWindow> MenuClass;
var const private class<HxGUITheme> ThemeClass;
var const private Color BaseColor;
var const private Color HighlightColor;
var private HxClientChannel Channel;
var private array<HxMutatorEntry> Entries;
var private array<HxDelayedUpdate> DelayedQueue;
var private array<int> DelayedGlobalIndices;
var private array<HxNotification> PendingNotifications;
var private HxNotification Notification;
var private array<HxConfig> ConfigPool;
var private array<Object> ObjectPool;
var private string LastServerName;
var private bool bReceivedMutators;
var private bool bIsFirstRun;

event Initialized()
{
    local int i;

    if (bFirstRun)
    {
        bIsFirstRun = true;
        bFirstRun = false;
        SaveConfig();
    }
    DelayedGlobalIndices.Length = class'HxMutator'.default.GlobalProperties.Length;
    for (i = 0; i < DelayedGlobalIndices.Length; ++i)
    {
        DelayedGlobalIndices[i] = -1;
    }
    ThemeClass.static.RegisterStyles(GUIController(ViewportOwner.GUIController));
    // TODO: remove this in v11
    UpdateMenuKeybinds();
    ValidateMenuKeybind();
}

event NotifyLevelChange()
{
    local int i;

    for (i = 0; i < Entries.Length; ++i)
    {
        Entries[i].MutatorInfo.NotifyLevelChange();
    }
    Entries.Remove(0, Entries.Length);
    for (i = 0; i < ConfigPool.Length; ++i)
    {
        ConfigPool[i].Destroy();
    }
    ConfigPool.Remove(0, ConfigPool.Length);
    ObjectPool.Remove(0, ObjectPool.Length);
    Super.NotifyLevelChange();
}

function Setup(HxClientChannel Channel)
{
    Self.Channel = Channel;
}

function EnqueueNotification(string Message)
{
    local HxNotification NewNotification;

    NewNotification.FullMessage = Message;
    NewNotification.Duration =
        FMax(MinimumNotifyDuration, Len(Message) * 0.05) * ViewportOwner.Actor.Level.TimeDilation;
    PendingNotifications[PendingNotifications.Length] = NewNotification;
    if (!IsInState('DisplayNotification'))
    {
        GotoState('DisplayNotification');
    }
}

state DisplayNotification
{
    function BeginState()
    {
        bVisible = true;
        bRequiresTick = true;
        if (PendingNotifications.Length == 0)
        {
            GotoState('');
        }
        else
        {
            Notification = PendingNotifications[0];
            PendingNotifications.Remove(0, 1);
            if (Len(Notification.FullMessage) == 0)
            {
                GotoState('');
            }
        }
    }

    function EndState()
    {
        bVisible = false;
        bRequiresTick = false;
        if (PendingNotifications.Length > 0)
        {
            GotoState('DisplayNotification');
        }
    }

    function Tick(float DeltaTime)
    {
        Notification.Duration -= DeltaTime;
        if (Notification.Duration <= 0)
        {
            GotoState('');
        }
        else
        {
            Notification.Fade = FMin(Notification.Duration / 0.5, 1.0);
        }
    }

    function PreRender(Canvas C)
    {
        local float TextWidth;
        local float TextHeight;
        local Font SavedFont;
        local int i;

        if (Notification.Font == None)
        {
            Notification.Font = class'HxGUIFontMidGame'.static.GetMediumFont(C);
            SavedFont = C.Font;
            C.Font = Notification.Font;
            C.WrapStringToArray(Notification.FullMessage, Notification.Lines, C.ClipX * 0.3, "|");
            for (i = 0; i < Notification.Lines.Length; ++i)
            {
                C.TextSize(Notification.Lines[i], TextWidth, TextHeight);
                if (TextWidth > Notification.Width)
                {
                    Notification.Width = TextWidth;
                }
                Notification.Height += TextHeight;
            }
            C.TextSize("W0", TextWidth, Notification.LineHeight);
            C.Font = SavedFont;
        }
    }

    function PostRender(Canvas C)
    {
        local Font SavedFont;
        local Color SavedColor;
        local float SavedW;
        local byte SavedStyle;
        local float Left;
        local float Top;
        local float FullWidth;
        local float FullHeight;
        local float LineSpacing;
        local int i;

        SavedFont = C.Font;
        SavedColor = C.DrawColor;
        SavedStyle = C.Style;
        SavedW = C.ColorModulate.W;
        C.DrawColor = class'HUD'.default.WhiteColor;
        C.ColorModulate.W = Notification.Fade;
        C.Style = 5; // STY_Alpha
        Left = (C.ClipX - Notification.Width) / 2;
        Top = C.ClipY * 0.16 + Notification.LineHeight;
        LineSpacing = Notification.LineHeight / 2;
        FullWidth = Notification.Width + Notification.LineHeight * 2;
        FullHeight = Notification.Height + Notification.LineHeight * 2
            + LineSpacing * (Notification.Lines.Length - 1);
        C.SetPos(Left - Notification.LineHeight, Top - Notification.LineHeight);
		C.DrawTileStretched(Texture'InterfaceContent.Menu.BorderBoxD', FullWidth, FullHeight);
        C.DrawColor = BaseColor;
        C.Font = Notification.Font;
        for (i = 0; i < Notification.Lines.Length; ++i)
        {
            C.DrawTextJustified(
                Notification.Lines[i],
                1,
                Left,
                Top,
                Left + Notification.Width,
                Top + Notification.LineHeight);
            Top += Notification.LineHeight + LineSpacing;
        }
        C.Font = SavedFont;
        C.Style = SavedStyle;
        C.DrawColor = SavedColor;
        C.ColorModulate.W = SavedW;
    }

    event NotifyLevelChange()
    {
        Global.NotifyLevelChange();
        GotoState('');
    }
}

function ReceiveMutatorClass(class<HxMutator> MutatorClass, coerce bool bLast)
{
    local int UID;
    local int i;

    if (!bReceivedMutators)
    {
        UID = Entries.Length;
        Entries.Insert(UID, 1);
        Entries[UID].MutatorClass = MutatorClass;
        Entries[UID].MutatorInfo = new (None) MutatorClass.default.MutatorInfoClass;
        Entries[UID].MutatorInfo.Setup(MutatorClass, Channel.Level, Channel.PlayerOwner);
        Entries[UID].Configs.Length = MutatorClass.default.ConfigClasses.Length;
        for (i = 0; i < Entries[UID].Configs.Length; ++i)
        {
            Entries[UID].Configs[i] = LoadConfig(MutatorClass, i);
            Entries[UID].Configs[i].Setup(Channel.Level, Self);
        }
        Entries[UID].DelayedIndices.Length = MutatorClass.default.Properties.Length;
        for (i = 0; i < Entries[UID].DelayedIndices.Length; ++i)
        {
            Entries[UID].DelayedIndices[i] = -1;
        }
        bReceivedMutators = bLast;
    }
}

function ReceiveGlobalProperty(int Index, string Value)
{
    SetPropertyText(class'HxMutator'.default.GlobalProperties[Index].Name, Value);
    if (class'HxMutator'.default.GlobalProperties[Index].Name == "NotifyRunning")
    {
        CheckNotifyRunning(Channel.ServerName);
    }
    RefreshConfigurationMenu();
}

function ReceiveMutatorProperty(int UID,
                                int Index,
                                string Value,
                                optional HxClientReplicationInfo CRI)
{
    local int i;

    if (Entries[UID].MutatorClass.default.Properties[Index].Type != HX_PROPERTY_Array)
    {
        Entries[UID].MutatorInfo.SetByIndex(Index, Value);
    }
    if (Entries[UID].MutatorInfo.IsInitialized())
    {
        Entries[UID].MutatorClass.static.ClientMutatorPropertyChanged(
            Entries[UID].MutatorInfo, Index);
        if (CRI != None)
        {
            CRI.NotifyMutatorPropertyChanged(Index);
        }
        for (i = 0; i < Entries[UID].Configs.Length; ++i)
        {
            Entries[UID].Configs[i].NotifyMutatorPropertyChanged(Index);
        }
        RefreshConfigurationMenu();
    }
    else if (Entries[UID].MutatorInfo.IsLast(Index))
    {
        Entries[UID].MutatorInfo.Initialized();
        Entries[UID].MutatorClass.static.ClientInitialized(Entries[UID].MutatorInfo);
        if (CRI != None)
        {
            CRI.SetMutatorInfo(Entries[UID].MutatorInfo);
        }
        for (i = 0; i < Entries[UID].Configs.Length; ++i)
        {
            Entries[UID].Configs[i].SetMutatorInfo(Entries[UID].MutatorInfo);
        }
        RefreshConfigurationMenu();
    }
}

function ReceiveMutatorArrayElement(int UID, int Index, int ElementIndex, string Value)
{
    Entries[UID].MutatorInfo.SetArrayElementByIndex(Index, ElementIndex, Value);
}

exec function HexedMenu()
{
    if (Channel != None)
    {
        ViewportOwner.GUIController.OpenMenu(string(MenuClass));
    }
}

function CheckNotifyRunning(string ServerName)
{
    switch (NotifyRunning)
    {
        case HX_NRUN_PerVersion:
            if (bIsFirstRun)
            {
                EnqueueRunningNotification();
            }
            break;
        case HX_NRUN_PerSession:
            if (default.LastServerName != ServerName)
            {
                EnqueueRunningNotification();
                default.LastServerName = ServerName;
            }
            break;
        case HX_NRUN_Always:
            EnqueueRunningNotification();
            break;
    }
}

function EnqueueRunningNotification()
{
    local string Message;
    local string MenuKeyName;
    local string Version;
    local string Highlight;
    local string Base;

    Highlight = class'GUIComponent'.static.MakeColorCode(HighlightColor);
    Base = class'GUIComponent'.static.MakeColorCode(BaseColor);
    class'HxTypes'.static.ExtractVersion(Class, Version);
    Message = Repl(RunningMessage, "%", Highlight$ProjectName$" v"$Version$Base)$"|";
    if (MenuKeybind != "")
    {
        MenuKeyName = Execute("LOCALIZEDKEYNAME"@Execute("KEYNUMBER"@MenuKeybind));
        Message $= Repl(OpenMenuMessage, "%", PressMessage@Highlight$MenuKeyName$Base);
    }
    else
    {
        Message $= Repl(OpenMenuMessage, "%", ExecMessage@Highlight$MenuCommand$Base);
    }
    EnqueueNotification(Message);
}

function RefreshConfigurationMenu()
{
    local GUIController GC;

    GC = GUIController(ViewportOwner.GUIController);
    if (GC != None)
    {
        if (HxGUIMenu(GC.ActivePage) != None)
        {
            HxGUIMenu(GC.ActivePage).Refresh();
        }
        else if (HxGUIServerMenu(GC.ActivePage) != None)
        {
            if (HxGUIMenu(GC.ActivePage.ParentPage) != None)
            {
                HxGUIMenu(GC.ActivePage).Refresh();
            }
            HxGUIServerMenu(GC.ActivePage).Refresh();
        }
    }
}

function PopulateConfigProperties(HxGUIMultiOptionListBox List)
{
    local string SectionCaption;
    local bool bMutatorSectionAdded;
    local int UID;
    local int i;
    local int j;

    for (UID = 0; UID < Entries.Length; ++UID)
    {
        if (!Entries[UID].MutatorInfo.IsInitialized())
        {
            continue;
        }
        SectionCaption = "";
        bMutatorSectionAdded = false;
        for (i = 0; i < Entries[UID].Configs.Length; ++i)
        {
            for (j = 0; j < Entries[UID].Configs[i].DisplayInfo.Length; ++j)
            {
                if (List.ShouldHideConfigProperty(Entries[UID].Configs[i].Class, j)
                    || Entries[UID].Configs[i].IsMissingDependency(j))
                {
                    continue;
                }
                if (!bMutatorSectionAdded)
                {
                    List.AddSection(Entries[UID].MutatorClass.default.QualifiedName);
                    bMutatorSectionAdded = true;
                }
                if (Entries[UID].Configs[i].DisplayInfo[j].Section != SectionCaption)
                {
                    SectionCaption = Entries[UID].Configs[i].DisplayInfo[j].Section;
                    List.AddSubSection(SectionCaption);
                }
                List.AddConfigOption(
                    Entries[UID].Configs[i].Class,
                    j,
                    class'HxClientChannel'.static.EncodeTag(UID, j, i));
            }
        }
    }
}

function PopulateMutatorProperties(HxGUIMultiOptionListBox List)
{
    local string HeaderCaption;
    local string SectionCaption;
    local int UID;
    local int i;

    for (i = 0; i < class'HxMutator'.default.GlobalProperties.Length; ++i)
    {
        if (!List.ShouldHideGlobalProperty(i))
        {
            if (class'HxMutator'.default.GlobalDisplayInfo[i].Section != HeaderCaption)
            {
                HeaderCaption = class'HxMutator'.default.GlobalDisplayInfo[i].Section;
                List.AddSection(HeaderCaption);
            }
            List.AddGlobalOption(i, class'HxClientChannel'.static.EncodeTag(RSVD_UID, i));
        }
    }
    for (UID = 0; UID < Entries.Length; ++UID)
    {
        if (!Entries[UID].MutatorInfo.IsInitialized())
        {
            continue;
        }
        HeaderCaption = "";
        SectionCaption = "";
        for (i = 0; i < Entries[UID].MutatorClass.default.DisplayInfo.Length; ++i)
        {
            if (!List.ShouldHideServerProperty(Entries[UID].MutatorClass, i))
            {
                if (Entries[UID].MutatorClass.default.QualifiedName != HeaderCaption)
                {
                    HeaderCaption = Entries[UID].MutatorClass.default.QualifiedName;
                    List.AddSection(HeaderCaption);
                }
                if (Entries[UID].MutatorClass.default.DisplayInfo[i].Section != SectionCaption)
                {
                    SectionCaption = Entries[UID].MutatorClass.default.DisplayInfo[i].Section;
                    List.AddSubSection(SectionCaption);
                }
                List.AddMutatorOption(
                    Entries[UID].MutatorClass, i, class'HxClientChannel'.static.EncodeTag(UID, i));
            }
        }
    }
}

function PopulateMutatorStatus(HxGUIMultiOptionListBox List)
{
    local string HeaderCaption;
    local string SectionCaption;
    local int UID;
    local int i;

    PopulateGeneralStatus(List);
    for (UID = 0; UID < Entries.Length; ++UID)
    {
        if (!Entries[UID].MutatorInfo.IsInitialized())
        {
            continue;
        }
        HeaderCaption = "";
        SectionCaption = "";
        for (i = 0; i < Entries[UID].MutatorClass.default.DisplayInfo.Length; ++i)
        {
            if (List.ShouldHideServerProperty(Entries[UID].MutatorClass, i)
                || ShouldHideMutatorPropertyFromStatus(UID, i))
            {
                continue;
            }
            if (Entries[UID].MutatorClass.default.QualifiedName != HeaderCaption)
            {
                HeaderCaption = Entries[UID].MutatorClass.default.QualifiedName;
                List.AddSection(HeaderCaption);
            }
            if (Entries[UID].MutatorClass.default.DisplayInfo[i].Section != SectionCaption)
            {
                SectionCaption = Entries[UID].MutatorClass.default.DisplayInfo[i].Section;
                List.AddSubSection(SectionCaption);
            }
            List.AddLabel(
                Entries[UID].MutatorClass.default.DisplayInfo[i].Caption,
                class'HxClientChannel'.static.EncodeTag(UID, i));
        }
    }
}

function PopulateGeneralStatus(HxGUIMultiOptionListBox List)
{
    local string HeaderCaption;
    local int i;

    HeaderCaption = class'HxMutator'.default.GlobalDisplayInfo[0].Section;
    List.AddSection(HeaderCaption);
    for (i = 0; i < Entries.Length; ++i)
    {
        if (i == 0)
        {
            List.AddLabel(
                ActiveMutatorsLabel,
                class'HxClientChannel'.static.EncodeTag(RSVD_UID, RSVD_INDEX));
        }
        else
        {
            List.AddLabel("", class'HxClientChannel'.static.EncodeTag(RSVD_UID, RSVD_INDEX, i));
        }
    }
    List.AddLabel(
        PlatformLabel, class'HxClientChannel'.static.EncodeTag(RSVD_UID, RSVD_INDEX, i));
    for (i = 0; i < class'HxMutator'.default.GlobalProperties.Length; ++i)
    {
        if (List.ShouldHideGlobalProperty(i) || ShouldHideGlobalPropertyFromStatus(i))
        {
            continue;
        }
        if (class'HxMutator'.default.GlobalDisplayInfo[i].Section != HeaderCaption)
        {
            HeaderCaption = class'HxMutator'.default.GlobalDisplayInfo[i].Section;
            List.AddSection(HeaderCaption);
        }
        List.AddLabel(
            class'HxMutator'.default.GlobalDisplayInfo[i].Caption,
            class'HxClientChannel'.static.EncodeTag(RSVD_UID, i));
    }
}

function array<HxMutatorInfo> GetPopulatedMutatorInfos()
{
    local array<HxMutatorInfo> MutatorInfos;
    local int UID;

    for (UID = 0; UID < Entries.Length; ++UID)
    {
        if (Entries[UID].MutatorInfo.IsInitialized())
        {
            MutatorInfos[MutatorInfos.Length] = Entries[UID].MutatorInfo;
        }
    }
    return MutatorInfos;
}

function string GetMutatorPropertyByTag(int Tag)
{
    local int UID;
    local int Index;

    if (class'HxClientChannel'.static.DecodeTag(Tag, UID, Index))
    {
        if (UID == RSVD_UID)
        {
            return GetPropertyText(class'HxMutator'.default.GlobalProperties[Index].Name);
        }
        return Entries[UID].MutatorInfo.GetByIndex(Index);
    }
    return "";
}

function string GetMutatorStatus(int Tag)
{
    local HxTypes.EHxPropertyType Type;
    local int UID;
    local int Index;
    local int ExtraIndex;
    local string Value;

    if (class'HxClientChannel'.static.DecodeTag(Tag, UID, Index, ExtraIndex))
    {
        if (UID == RSVD_UID)
        {
            if (Index == RSVD_INDEX)
            {
                return GetGeneralStatus(ExtraIndex);
            }
            Type = class'HxMutator'.default.GlobalProperties[Index].Type;
            Value = GetPropertyText(class'HxMutator'.default.GlobalProperties[Index].Name);
        }
        else
        {
            Type = Entries[UID].MutatorClass.default.Properties[Index].Type;
            Value = Entries[UID].MutatorInfo.GetByIndex(Index);
        }
        switch (Type)
        {
            case HX_PROPERTY_Float:
                Value = Left(Value, Len(Value) - 4);
                break;
            case HX_PROPERTY_Enum:
                if (UID == RSVD_UID)
                {
                    Value = class'HxMutator'.static.GetGlobalEnumLabel(Index, Value);
                }
                else
                {
                    Value = Entries[UID].MutatorClass.static.GetEnumLabel(Index, Value);
                }
                break;
        }
        return Value;
    }
    return "";
}

function string GetGeneralStatus(int Index)
{
    local string PackageName;
    local string Version;

    if (Index < Entries.Length)
    {
        return Entries[Index].MutatorClass.default.FriendlyName;
    }
    if (class'HxTypes'.static.ExtractVersion(Class, Version, PackageName))
    {
        return PackageName@"v"$Version;
    }
    return "";
}

function string GetConfigPropertyByTag(int Tag)
{
    local int UID;
    local int Index;
    local int ConfigIndex;

    if (class'HxClientChannel'.static.DecodeTag(Tag, UID, Index, ConfigIndex))
    {
        return Entries[UID].Configs[ConfigIndex].GetProperty(Index);
    }
    return "";
}

function SetMutatorPropertyDelayed(int Tag, string Value)
{
    local int UID;
    local int Index;
    local int QueueIndex;

    if (Channel != None && Channel.DecodeTag(Tag, UID, Index))
    {
        if (UID == RSVD_UID)
        {
            if (DelayedGlobalIndices[Index] > -1)
            {
                QueueIndex = DelayedGlobalIndices[Index];
            }
            else
            {
                QueueIndex = DelayedQueue.Length;
                DelayedQueue.Insert(QueueIndex, 1);
                DelayedGlobalIndices[Index] = QueueIndex;
            }
        }
        else
        {
            if (Entries[UID].DelayedIndices[Index] > -1)
            {
                QueueIndex = Entries[UID].DelayedIndices[Index];
            }
            else
            {
                QueueIndex = DelayedQueue.Length;
                DelayedQueue.Insert(QueueIndex, 1);
                Entries[UID].DelayedIndices[Index] = QueueIndex;
            }
        }
        DelayedQueue[QueueIndex].Tag = Tag;
        DelayedQueue[QueueIndex].Value = Value;
    }
}

function SetConfigPropertyDelayed(int Tag, string Value)
{
    local int UID;
    local int Index;
    local int ConfigIndex;

    if (class'HxClientChannel'.static.DecodeTag(Tag, UID, Index, ConfigIndex))
    {
        Entries[UID].bHasDelayedConfigs = true;
        Entries[UID].Configs[ConfigIndex].SetPropertyDelayed(Index, Value);
    }
}

function DispatchDelayedMutatorUpdates()
{
    local int UID;
    local int Index;
    local int i;

    if (Channel != None)
    {
        for (i = 0; i < DelayedQueue.Length; ++i)
        {
            if (Channel.DecodeTag(DelayedQueue[i].Tag, UID, Index))
            {
                if (UID == RSVD_UID)
                {
                    DelayedGlobalIndices[Index] = -1;
                    Channel.RequestGlobalPropertyUpdate(Index, DelayedQueue[i].Value);
                }
                else
                {
                    Entries[UID].DelayedIndices[Index] = -1;
                    Channel.RequestMutatorPropertyUpdate(
                        DelayedQueue[i].Tag, DelayedQueue[i].Value);
                }
            }
        }
    }
    DelayedQueue.Remove(0, DelayedQueue.Length);
}

function DispatchDelayedConfigUpdates()
{
    local int UID;
    local int i;

    for (UID = 0; UID < Entries.Length; ++UID)
    {
        if (Entries[UID].bHasDelayedConfigs)
        {
            for (i = 0; i < Entries[UID].Configs.Length; ++i)
            {
                Entries[UID].Configs[i].ApplyDelayedUpdates();
            }
            Entries[UID].bHasDelayedConfigs = false;
        }
    }
}

final function bool ShouldHideMutatorPropertyFromStatus(int UID, int Index)
{
    return !IsAdmin()
        && (StatusVerbosity == HX_VERB_Lowest
            || Entries[UID].MutatorClass.default.DisplayInfo[Index].Verbosity > StatusVerbosity
            || (StatusVerbosity < HX_VERB_High
                && Entries[UID].MutatorClass.default.Properties[Index].Type == HX_PROPERTY_Bool
                && !bool(Entries[UID].MutatorInfo.GetByIndex(Index))));
}

final function bool ShouldHideGlobalPropertyFromStatus(int Index)
{
    return !IsAdmin()
        && (StatusVerbosity == HX_VERB_Lowest
            || class'HxMutator'.default.GlobalDisplayInfo[Index].Verbosity > StatusVerbosity
            || (StatusVerbosity < HX_VERB_High
                && class'HxMutator'.default.GlobalProperties[Index].Type == HX_PROPERTY_Bool
                && !bool(GetPropertyText(class'HxMutator'.default.GlobalProperties[Index].Name))));
}

final function bool IsFirstRun()
{
    return bIsFirstRun;
}

final function bool IsAdmin()
{
    return ViewportOwner.Actor != None
        && (ViewportOwner.Actor.Level.NetMode == NM_Standalone
            || (ViewportOwner.Actor.PlayerReplicationInfo != None
                && ViewportOwner.Actor.PlayerReplicationInfo.bAdmin));
}

final function bool FindMutatorInfo(class<HxMutator> MutatorClass, out HxMutatorInfo MutatorInfo)
{
    local int UID;

    for (UID = 0; UID < Entries.Length; ++UID)
    {
        if (Entries[UID].MutatorClass == MutatorClass)
        {
            MutatorInfo = Entries[UID].MutatorInfo;
            return Entries[UID].MutatorInfo.IsInitialized();
        }
    }
    return false;
}

final function HxConfig FindConfig(class<HxMutator> MutatorClass, class<HxConfig> ConfigClass)
{
    local int UID;
    local int i;

    for (UID = 0; UID < Entries.Length; ++UID)
    {
        if (Entries[UID].MutatorClass == MutatorClass)
        {
            for (i = 0; i < Entries[UID].Configs.Length; ++i)
            {
                if (Entries[UID].Configs[i].Class == ConfigClass)
                {
                    return Entries[UID].Configs[i];
                }
            }
        }
    }
    return None;
}

final function HxInteraction LoadInteraction(class<HxInteraction> InteractionClass)
{
    return AddInteraction(ViewportOwner, InteractionClass);
}

final function Object LoadObject(class<Object> ObjectClass, optional string Name)
{
    local int i;

    for (i = 0; i < ObjectPool.Length; ++i)
    {
        if (ObjectPool[i].Class == ObjectClass)
        {
            if (Name == "" || Name ~= string(ObjectPool[i].Name))
            {
                return ObjectPool[i];
            }
        }
    }
    ObjectPool[i] = new (None, Name) ObjectClass;
    return ObjectPool[i];
}

private function HxConfig LoadConfig(class<HxMutator> MutatorClass, int Index)
{
    local class<HxConfig> ConfigClass;
    local int i;

    ConfigClass = MutatorClass.default.ConfigClasses[Index];
    for (i = 0; i < ConfigPool.Length; ++i)
    {
        if (ConfigPool[i].Class == ConfigClass)
        {
            return ConfigPool[i];
        }
    }
    ConfigPool[i] = new(None, MutatorClass.default.QualifiedName) ConfigClass;
    return ConfigPool[i];
}

private function ValidateMenuKeybind()
{
    local string KeyName;
    local int i;

    if (MenuKeybind == "" || (!IsMenuKeybind(MenuKeybind) && !TrySetKeybind(MenuKeybind)))
    {
        MenuKeybind = "";
        for (i = 0; i < 255; ++i)
        {
            KeyName = Execute("KEYNAME"@i);
            if (IsMenuKeybind(KeyName))
            {
                MenuKeybind = KeyName;
                break;
            }
        }
        SaveConfig();
    }
}

// TODO: remove this in v11
private function UpdateMenuKeybinds()
{
    local string KeyName;
    local int i;

    for (i = 0; i < 255; ++i)
    {
        KeyName = Execute("KEYNAME"@i);
        if (InStr(Caps(Execute("KEYBINDING"@KeyName)), "MUTATE HEXEDMENU") > -1)
        {
            Execute("SET INPUT"@KeyName@"HexedMenu");
        }
    }
}

private function bool IsMenuKeybind(string KeyName)
{
    return InStr(Caps(Execute("KEYBINDING"@KeyName)), "HEXEDMENU") > -1;
}

private function bool TrySetKeybind(string Keybind)
{
    if (Execute("KEYBINDING"@Keybind) == "")
    {
        Execute("SET INPUT"@Keybind@"HexedMenu");
        return true;
    }
    return false;
}

private function string Execute(string Command)
{
    return ViewportOwner.Actor.ConsoleCommand(Command);
}

static function HxClientManager Get(Player Owner)
{
    if (Owner != None)
    {
        return HxClientManager(AddInteraction(Owner, default.Class));
    }
    return None;
}

defaultproperties
{
    bActive=false
    MenuClass=class'HxGUIMenu'
    ThemeClass=class'HxGUIThemeDefault'
    bFirstRun=true
    MenuKeybind="H"
    ProjectName="HexedUT2k4"
    MenuCommand="HexedMenu"
    BaseColor=(R=240,G=240,B=240,A=255)
    HighlightColor=(R=255,G=210,B=0,A=255)
    PlatformLabel="Platform Version"
    ActiveMutatorsLabel="Active Mutators"
    RunningMessage="This server is running %!"
    OpenMenuMessage="% to open the configuration menu."
    PressMessage="Press"
    ExecMessage="Execute"
}
