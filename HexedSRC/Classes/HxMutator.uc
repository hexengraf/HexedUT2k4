class HxMutator extends Mutator
    abstract
    config(HexedMutators);

enum EHxNotifyRunning
{
    HX_NRUN_Never,
    HX_NRUN_PerVersion,
    HX_NRUN_PerSession,
    HX_NRUN_Always,
};

enum EHxVerbosityLevel
{
    HX_VERB_Lowest,
    HX_VERB_Low,
    HX_VERB_Medium,
    HX_VERB_High,
};

// TODO: engine bug? if extending HxTypes.HxDisplayProperty the server crashes on init
struct HxMutatorDisplayProperty
{
    // From HxTypes.HxDisplayProperty
    var const localized string Section;
    var const localized string Caption;
    var const localized string Hint;
    var const localized array<string> EnumLabels;
    var const string Step;
    var const string Dependency;
    var const string ConfigPage;
    var const bool bMPOnly;
    var const bool bAdvanced;
    // New properties
    var const string Privileges;
    var const int SecLevel;
    var const EHxVerbosityLevel Verbosity;
};

var globalconfig float MinimumNotifyDuration;
// Engine bug: NEVER use an enum from a different class as config (unless it is perobjectconfig)
var globalconfig EHxNotifyRunning NotifyRunning;
var globalconfig EHxVerbosityLevel StatusVerbosity;

var const localized string GlobalSettingsGroup;
var const array<HxTypes.HxProperty> GlobalProperties;
var const array<HxMutatorDisplayProperty> GlobalDisplayInfo;
var const string QualifiedName;
var const class<HxMutatorInfo> MutatorInfoClass;
var const class<HxClientReplicationInfo> ClientReplicationInfoClass;
var const array<HxTypes.HxProperty> Properties;
var const array<HxMutatorDisplayProperty> DisplayInfo;
var const array<class<HxConfig> > ConfigClasses;
var const array<class<HxGUIMenuPanel> > PanelClasses;
var const byte Priority;
var int UID;

var protected const bool bAllowURLOptions;
var protected const bool bDisableTick;
var protected array<HxClientChannel> Channels;
var private HxMutator Leader;
var private array<int> LoadedURLOptions;
var private bool bInitialized;

function Initialized();
function PropertyChanged(int Index);

event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (bAllowURLOptions)
    {
        ParseURLOptions(GetURLOptions(Level.GetLocalURL()));
    }
    Leader = Self;
}

function AddMutator(Mutator M)
{
    Super.AddMutator(M);
    if (HxMutator(M) != None && Leader == Self)
    {
        HxMutator(M).Leader = Self;
    }
}

event Tick(float DeltaTime)
{
    if (!bInitialized)
    {
        ClearURLOptions();
        TriggerLocalPostNetReceive();
        bInitialized = true;
        Initialized();
        if (bDisableTick)
        {
            Disable('Tick');
        }
    }
}

function ParseURLOptions(string Options)
{
    local PlayInfo PI;
    local string Value;
    local int i;

    PI = new(None) class'PlayInfo';
    FillOwnedPlayInfo(PI);
    for (i = 0; i < Properties.Length; ++i)
    {
        Value = class'GameInfo'.static.ParseOption(Options, Properties[i].Name);
        if (Value != "")
        {
            PI.StoreSetting(i, Value);
            SetPropertyText(Properties[i].Name, PI.Settings[i].Value);
            LoadedURLOptions[LoadedURLOptions.Length] = i;
        }
    }
}

function ClearURLOptions()
{
    local int i;

    for (i = 0; i < LoadedURLOptions.Length; ++i)
    {
        UpdateURL(Properties[LoadedURLOptions[i]].Name, "", false);
    }
}

function TriggerLocalPostNetReceive()
{
    Local HxClientChannel Channel;

    if (Level.NetMode != NM_DedicatedServer)
    {
        Channel = GetClientChannel(Level.GetLocalPlayerController());
        if (Channel != None)
        {
            Channel.LocalPostNetReceive();
        }
    }
}

function Mutate(string Command, PlayerController Sender)
{
    if (Command ~= "HexedMenu")
    {
        OpenConfigurationMenu(Sender);
    }
    else
    {
        Super.Mutate(Command, Sender);
    }
}

function OpenConfigurationMenu(PlayerController Sender)
{
    local HxClientChannel Channel;

    Channel = GetClientChannel(Sender);
    if (Channel != None)
    {
        Channel.ClientOpenConfigurationMenu();
    }
}

function SetProperty(int Index, string Value)
{
    local int i;

    SetPropertyText(Properties[Index].Name, Value);
    PropertyChanged(Index);
    for (i = 0; i < Channels.Length; ++i)
    {
        Channels[i].EnqueueMutatorPropertyUpdate(UID, Index);
    }
    SaveConfig();
}

function SetGlobalProperty(int Index, string Value)
{
    local int i;

    SetPropertyText(GlobalProperties[Index].Name, Value);
    for (i = 0; i < Channels.Length; ++i)
    {
        Channels[i].EnqueueGlobalPropertyUpdate(Index, Value);
    }
    SaveConfig();
}

function array<string> GetArrayProperty(int Index)
{
    local array<string> ArrayProperty;

    return ArrayProperty;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (Other.IsA('PlayerController'))
    {
        if (Leader == Self && !Other.IsA('MessagingSpectator'))
        {
            SpawnClientChannel(PlayerController(Other));
        }
    }
    else if (Other.IsA('HxClientChannel'))
    {
        HxClientChannel(Other).AddMutator(Self);
        Channels[Channels.Length] = HxClientChannel(Other);
    }
    return true;
}

function NotifyLogout(Controller Exiting)
{
    local int i;

    for (i = Channels.Length - 1; i >= 0; --i)
    {
        if (Channels[i] == None)
        {
            Channels.Remove(i, 1);
        }
        else if (Channels[i].Owner == Exiting)
        {
            if (Leader == Self)
            {
                Channels[i].Destroy();
            }
            Channels.Remove(i, 1);
            break;
        }
    }
    Super.NotifyLogout(Exiting);
}

function ValidateClientChannels()
{
    local Controller P;
    local int i;

    if (Leader == Self)
    {
        for (P = Level.ControllerList; P != None; P = P.nextController)
        {
            if (P.IsA('PlayerController') && !P.IsA('MessagingSpectator'))
            {
                SpawnClientChannel(PlayerController(P));
            }
        }
    }
    else
    {
        Channels = Leader.Channels;
        for (i = 0; i < Channels.Length; ++i)
        {
            Channels[i].AddMutator(Self);
        }
    }
}

function SpawnClientChannel(PlayerController ClientOwner)
{
    ClientOwner.Spawn(class'HxClientChannel', ClientOwner,, ClientOwner.Location);
}

function HxClientChannel GetClientChannel(PlayerController ClientOwner)
{
    local int i;

    if (ClientOwner != None)
    {
        for (i = 0; i < Channels.Length; ++i)
        {
            if (Channels[i].Owner == ClientOwner)
            {
                return Channels[i];
            }
        }
    }
    return None;
}

function HxClientReplicationInfo GetClientReplicationInfo(PlayerController ClientOwner)
{
    local HxClientChannel Channel;

    Channel = GetClientChannel(ClientOwner);
    if (Channel != None)
    {
        return Channel.GetClientReplicationInfo(UID);
    }
    return None;
}

function LinkedReplicationInfo SpawnLinkedPRI(PlayerReplicationInfo PRI,
                                              class<LinkedReplicationInfo> LinkedPRIClass)
{
    local LinkedReplicationInfo LinkedPRI;

    if (MessagingSpectator(PRI.Owner) != None)
    {
        return LinkedPRI;
    }
    if (PRI.CustomReplicationInfo == None)
    {
        PRI.CustomReplicationInfo = Self.Spawn(LinkedPRIClass, Self);
        PRI.NetUpdateTime = PRI.Level.TimeSeconds - 1;
        return PRI.CustomReplicationInfo;
    }
    LinkedPRI = PRI.CustomReplicationInfo;
    while (LinkedPRI.NextReplicationInfo != None)
    {
        LinkedPRI = LinkedPRI.NextReplicationInfo;
    }
    LinkedPRI.NextReplicationInfo = Self.Spawn(LinkedPRIClass, Self);
    LinkedPRI.NetUpdateTime = PRI.Level.TimeSeconds - 1;
    LinkedPRI.NextReplicationInfo.NetUpdateTime = PRI.Level.TimeSeconds - 1;
    return LinkedPRI.NextReplicationInfo;
}

function bool DestroyLinkedPRI(PlayerReplicationInfo PRI,
                               class<LinkedReplicationInfo> LinkedPRIClass)
{
    local LinkedReplicationInfo LinkedPRI;
    local LinkedReplicationInfo NextLinkedPRI;

    if (PRI == None || MessagingSpectator(PRI.Owner) != None || PRI.CustomReplicationInfo == None)
    {
        return false;
    }
    if (PRI.CustomReplicationInfo.Class == LinkedPRIClass)
    {
        NextLinkedPRI = PRI.CustomReplicationInfo.NextReplicationInfo;
        PRI.CustomReplicationInfo.Destroy();
        PRI.CustomReplicationInfo = NextLinkedPRI;
        return true;
    }
    LinkedPRI = PRI.CustomReplicationInfo;
    while (LinkedPRI.NextReplicationInfo != None)
    {
        if (LinkedPRI.NextReplicationInfo.Class == LinkedPRIClass)
        {
            NextLinkedPRI = LinkedPRI.NextReplicationInfo.NextReplicationInfo;
            LinkedPRI.NextReplicationInfo.Destroy();
            LinkedPRI.NextReplicationInfo = NextLinkedPRI;
            return true;
        }
        LinkedPRI = LinkedPRI.NextReplicationInfo;
    }
    return false;
}

function string GetGlobalProperty(int Index)
{
    return GetPropertyText(GlobalProperties[Index].Name);
}

static function string GetURLOptions(string FullURL)
{
    return Right(FullURL, Len(FullURL) - InStr(FullURL, "?"));
}

static function string GetEnumLabel(int Index, string Value)
{
    return Value;
}

static function string GetGlobalEnumLabel(int Index, string Value)
{
    if (default.GlobalProperties[Index].Name == "NotifyRunning")
    {
        switch (Value)
        {
            case "HX_NRUN_Never":
                return default.GlobalDisplayInfo[Index].EnumLabels[0];
            case "HX_NRUN_PerVersion":
                return default.GlobalDisplayInfo[Index].EnumLabels[1];
            case "HX_NRUN_PerSession":
                return default.GlobalDisplayInfo[Index].EnumLabels[2];
            case "HX_NRUN_Always":
                return default.GlobalDisplayInfo[Index].EnumLabels[3];
        }
    }
    if (default.GlobalProperties[Index].Name == "StatusVerbosity")
    {
        switch (Value)
        {
            case "HX_VERB_Lowest":
                return default.GlobalDisplayInfo[Index].EnumLabels[0];
            case "HX_VERB_Low":
                return default.GlobalDisplayInfo[Index].EnumLabels[1];
            case "HX_VERB_Medium":
                return default.GlobalDisplayInfo[Index].EnumLabels[2];
            case "HX_VERB_High":
                return default.GlobalDisplayInfo[Index].EnumLabels[3];
        }
    }
    return Value;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
    local int i;

    FillOwnedPlayInfo(PlayInfo);
    for (i = 0; i < PlayInfo.InfoClasses.Length; ++i)
    {
        if (PlayInfo.InfoClasses[i] == class'HxMutator')
        {
            break;
        }
    }
    if (i == PlayInfo.InfoClasses.Length)
    {
        FillGlobalPlayInfo(PlayInfo);
        PlayInfo.PopClass();
    }
}

static function FillOwnedPlayInfo(PlayInfo PlayInfo)
{
    local int i;

    Super.FillPlayInfo(PlayInfo);
    for (i = 0; i < default.DisplayInfo.Length; ++i)
    {
        PlayInfo.AddSetting(
            default.FriendlyName,
            default.Properties[i].Name,
            default.DisplayInfo[i].Caption,
            default.DisplayInfo[i].SecLevel,
            i,
            GetPlayInfoType(default.Properties[i].Type),
            GetOwnedData(i),
            default.DisplayInfo[i].Privileges,
            default.DisplayInfo[i].bMPOnly,
            default.DisplayInfo[i].bAdvanced);
    }
}

static function FillGlobalPlayInfo(PlayInfo PlayInfo)
{
    local int i;

    PlayInfo.AddClass(class'HxMutator');
    for (i = 0; i < default.GlobalDisplayInfo.Length; ++i)
    {
        PlayInfo.AddSetting(
            default.GlobalSettingsGroup,
            default.GlobalProperties[i].Name,
            default.GlobalDisplayInfo[i].Caption,
            default.GlobalDisplayInfo[i].SecLevel,
            i,
            GetPlayInfoType(default.GlobalProperties[i].Type),
            GetGlobalData(i),
            default.GlobalDisplayInfo[i].Privileges,
            default.GlobalDisplayInfo[i].bMPOnly,
            default.GlobalDisplayInfo[i].bAdvanced);
    }
}

static event string GetDescriptionText(string PropertyName)
{
    local int i;

    i = GetPropertyIndex(PropertyName);
    if (i >= 0)
    {
        return default.DisplayInfo[i].Hint;
    }
    i = GetGlobalPropertyIndex(PropertyName);
    if (i >= 0)
    {
        return default.GlobalDisplayInfo[i].Hint;
    }
    return Super.GetDescriptionText(PropertyName);
}

static simulated function int GetPropertyIndex(string PropertyName)
{
    local int i;

    for (i = 0; i < default.Properties.Length; ++i)
    {
        if (PropertyName == default.Properties[i].Name)
        {
            return i;
        }
    }
    return -1;
}

static simulated function int GetGlobalPropertyIndex(string PropertyName)
{
    local int i;

    for (i = 0; i < default.GlobalProperties.Length; ++i)
    {
        if (PropertyName == default.GlobalProperties[i].Name)
        {
            return i;
        }
    }
    return -1;
}

static final protected function string GetPlayInfoType(HxTypes.EHxPropertyType Type)
{
    switch (Type)
    {
        case HX_PROPERTY_Bool:
            return "Check";
        case HX_PROPERTY_Enum:
            return "Select";
        case HX_PROPERTY_Array:
            return "Custom";
    }
    return "Text";
}

static final protected function string GetOwnedData(int Index)
{
    switch (default.Properties[Index].Type)
    {
        case HX_PROPERTY_Int:
        case HX_PROPERTY_Float:
            return "8;"$default.Properties[Index].LowerLimit$":"
                $default.Properties[Index].UpperLimit;
        case HX_PROPERTY_String:
            return default.Properties[Index].UpperLimit;
        case HX_PROPERTY_Enum:
            return GetOwnedEnumData(Index);
        case HX_PROPERTY_Array:
            return ";;"$default.DisplayInfo[Index].ConfigPage;
    }
    return "";
}

static final protected function string GetGlobalData(int Index)
{
    switch (default.GlobalProperties[Index].Type)
    {
        case HX_PROPERTY_Int:
        case HX_PROPERTY_Float:
            return "8;"$default.GlobalProperties[Index].LowerLimit$":"
                $default.GlobalProperties[Index].UpperLimit;
        case HX_PROPERTY_String:
            return default.GlobalProperties[Index].UpperLimit;
        case HX_PROPERTY_Enum:
            return GetGlobalEnumData(Index);
        case HX_PROPERTY_Array:
            return ";;"$default.GlobalDisplayInfo[Index].ConfigPage;
    }
    return "";
}

static final protected function string GetOwnedEnumData(int Index)
{
    local string Data;
    local int Start;
    local int Limit;
    local int i;

    Limit = int(default.Properties[Index].UpperLimit);
    Start = int(default.Properties[Index].LowerLimit);
    for (i = Start; i < Limit; ++i)
    {
        if (i > Start)
        {
            Data $= ";";
        }
        Data $= GetEnum(default.Properties[Index].EnumType, i)$";"
            $default.DisplayInfo[Index].EnumLabels[i];
    }
    return Data;
}

static final protected function string GetGlobalEnumData(int Index)
{
    local string Data;
    local int Start;
    local int Limit;
    local int i;

    Limit = int(default.GlobalProperties[Index].UpperLimit);
    Start = int(default.GlobalProperties[Index].LowerLimit);
    for (i = Start; i < Limit; ++i)
    {
        if (i > Start)
        {
            Data $= ";";
        }
        Data $= GetEnum(default.GlobalProperties[Index].EnumType, i)$";"
            $default.GlobalDisplayInfo[Index].EnumLabels[i];
    }
    return Data;
}

static function ClientInitialized(HxMutatorInfo Info);
static function ClientMutatorPropertyChanged(HxMutatorInfo Info, int Index);

defaultproperties
{
    GlobalSettingsGroup="Hexed Settings"
    GlobalProperties(0)=(Name="MinimumNotifyDuration",Type=HX_PROPERTY_Float,LowerLimit="1.0",UpperLimit="10.0")
    GlobalProperties(1)=(Name="NotifyRunning",Type=HX_PROPERTY_Enum,UpperLimit="4",EnumType=enum'EHxNotifyRunning')
    GlobalProperties(2)=(Name="StatusVerbosity",Type=HX_PROPERTY_Enum,UpperLimit="3",EnumType=enum'EHxVerbosityLevel')
    GlobalDisplayInfo(0)=(Section="General",Caption="Minimum Notify Duration",Hint="Minimum duration of notifications (in seconds). Actual duration might be higher depending the amount of text displayed.",bAdvanced=true,Verbosity=HX_VERB_High)
    GlobalDisplayInfo(1)=(Section="General",Caption="Notify Running",Hint="Frequency to notify the mutators are running after a map loads.",EnumLabels=("Never","Per Version","Per Session","Always"),bAdvanced=true,Verbosity=HX_VERB_High)
    GlobalDisplayInfo(2)=(Section="General",Caption="Status Verbosity",Hint="Level of information to be displayed in the server status for each mutator.",EnumLabels=("Lowest","Low","Medium","High"),bAdvanced=true,Verbosity=HX_VERB_High)
    MutatorInfoClass=class'HxMutatorInfo'
    Priority=255
    bAllowURLOptions=true
    MinimumNotifyDuration=5.0
    NotifyRunning=HX_NRUN_PerVersion
    StatusVerbosity=HX_VERB_Medium
}
