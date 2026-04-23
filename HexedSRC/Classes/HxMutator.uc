class HxMutator extends Mutator
    abstract
    DependsOn(HxTypes);

var const array<HxTypes.HxMutatorProperty> Properties;

var protected const class<HxClientReplicationInfo> CRIClass;
var protected array<HxClientReplicationInfo> CRIs;
var protected const bool bAllowURLOptions;
var protected const bool bDisableTick;

var private array<int> LoadedURLOptions;
var private bool bInitialized;

function Initialized();
function PropertyChanged(int Index, string OldValue);

event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (bAllowURLOptions)
    {
        ParseURLOptions(GetURLOptions(Level.GetLocalURL()));
    }
}

event Tick(float DeltaTime)
{
    if (!bInitialized)
    {
        ClearURLOptions();
        bInitialized = true;
        Initialized();
    }
    else if (bDisableTick)
    {
        Disable('Tick');
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
    local HxClientReplicationInfo CRI;

    CRI = GetClientReplicationInfo(Sender);
    if (CRI != None)
    {
        CRI.ClientOpenConfigurationMenu();
    }
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
    local HxTypes.HxMutatorProperty Prop;
    local int i;

    super.FillPlayInfo(PlayInfo);

    for (i = 0; i < default.Properties.Length; ++i)
    {
        Prop = default.Properties[i];
        PlayInfo.AddSetting(
            default.FriendlyName,
            Prop.Name,
            Prop.Caption,
            0,
            i,
            Prop.Type,
            Prop.Data,,
            Prop.bMPOnly,
            Prop.bAdvanced);
    }
}

static event string GetDescriptionText(string PropertyName)
{
    local int i;

    i = GetPropertyIndex(PropertyName);
    if (i >= 0)
    {
        return default.Properties[i].Hint;
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
    local string OldValue;
    local int i;

    OldValue = GetPropertyText(Properties[Index].Name);
    SetPropertyText(Properties[Index].Name, Value);
    for (i = 0; i < CRIs.Length; ++i)
    {
        CRIs[i].SetServerProperty(Index, Value);
    }
    PropertyChanged(Index, OldValue);
    SaveConfig();
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (Other.IsA('PlayerController') && !Other.IsA('MessagingSpectator'))
    {
        SpawnClientReplicationInfo(Other);
    }
    return true;
}

function NotifyLogout(Controller Exiting)
{
    local int i;

    for (i = 0; i < CRIs.Length; ++i)
    {
        if (CRIs[i].Owner == Exiting)
        {
            CRIs[i].Destroy();
            CRIs.Remove(i, 1);
            break;
        }
    }
    Super.NotifyLogout(Exiting);
}

function ValidateClientReplicationInfos()
{
    local HxClientReplicationInfo CRI;
    local Controller P;

    for (P = Level.ControllerList; P != None; P = P.nextController)
    {
        if (P.IsA('PlayerController') && !P.IsA('MessagingSpectator'))
        {
            CRI = GetClientReplicationInfo(P);
            if (CRI == None)
            {
                SpawnClientReplicationInfo(P);
            }
        }
    }
}

function SpawnClientReplicationInfo(Actor ClientOwner)
{
    local HxClientReplicationInfo CRI;

    CRI = ClientOwner.Spawn(CRIClass, ClientOwner);
    CRI.SetupServer(Self);
    CRI.NetUpdateTime = Level.TimeSeconds - 1;
    CRIs[CRIs.Length] = CRI;
}

function HxClientReplicationInfo GetClientReplicationInfo(Actor ClientOwner)
{
    local int i;

    for (i = 0; i < CRIs.Length; ++i)
    {
        if (CRIs[i].Owner == ClientOwner)
        {
            return CRIs[i];
        }
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

defaultproperties
{
}
