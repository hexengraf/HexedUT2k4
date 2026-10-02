class HxMutator extends Mutator
    abstract
    DependsOn(HxTypes);

var const string UniqueObjectName;
var const class<HxMutatorInfo> MutatorInfoClass;
var const class<HxClientReplicationInfo> ClientReplicationInfoClass;
var const array<HxTypes.HxProperty> Properties;
var const array<HxTypes.HxDisplayProperty> DisplayInfo;
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
    FillPlayInfo(PI);
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

function UpdateServerInfo(PlayInfo ServerInfo)
{
    local int Index;
    local int i;

    for (i = 0; i < LoadedURLOptions.Length; ++i)
    {
        Index = LoadedURLOptions[i];
        ServerInfo.StoreSetting(Index, GetPropertyText(Properties[Index].Name));
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

static function FillPlayInfo(PlayInfo PlayInfo)
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
            GetPlayInfoType(i),
            GetData(i),
            default.DisplayInfo[i].Privileges,
            default.DisplayInfo[i].bMPOnly,
            default.DisplayInfo[i].bAdvanced);
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

static function string GetURLOptions(string FullURL)
{
    return Right(FullURL, Len(FullURL) - InStr(FullURL, "?"));
}

static function string GetEnumLabel(int Index, string Value)
{
    return Value;
}

static final protected function string GetPlayInfoType(int Index)
{
    switch (default.Properties[Index].Type)
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

static final protected function string GetData(int Index)
{
    switch (default.Properties[Index].Type)
    {
        case HX_PROPERTY_Int:
        case HX_PROPERTY_Float:
            return GetNumericData(Index);
        case HX_PROPERTY_String:
            return default.Properties[Index].UpperLimit;
        case HX_PROPERTY_Enum:
            return GetEnumData(Index);
        case HX_PROPERTY_Array:
            return ";;"$default.DisplayInfo[Index].ConfigPage;
    }
    return "";
}

static final protected function string GetNumericData(int Index)
{
    return "8;"$default.Properties[Index].LowerLimit$":"$default.Properties[Index].UpperLimit;
}

static final protected function string GetEnumData(int Index)
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

static function ClientInitialized(HxMutatorInfo Info);
static function ClientMutatorPropertyChanged(HxMutatorInfo Info, int Index);

defaultproperties
{
    MutatorInfoClass=class'HxMutatorInfo'
    Priority=255
    bAllowURLOptions=true
}
