class HxMutator extends Mutator
    abstract;

struct PropertyInfoEntry
{
    var string Name;
    var localized string Caption;
    var localized string Hint;
    var string PIType;
    var string PIExtras;
    var bool bMultiplayerOnly;
    var bool bAdvanced;
};

var localized string MutatorGroup;
var array<PropertyInfoEntry> PropertyInfoEntries;

var protected class<HxClientReplicationInfo> CRIClass;
var protected array<HxClientReplicationInfo> CRIs;

function Mutate(string Command, PlayerController Sender)
{
    if (Command ~= "HexedMenu")
    {
        OpenMenu(Sender);
    }
    else
    {
        Super.Mutate(Command, Sender);
    }
}

function OpenMenu(PlayerController Sender)
{
    local HxClientReplicationInfo CRI;

    CRI = GetClientReplicationInfo(Sender);
    if (CRI != None)
    {
        CRI.ClientOpenMenu();
    }
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
    local int i;
    local PropertyInfoEntry Entry;

    super.FillPlayInfo(PlayInfo);

    for (i = 0; i < default.PropertyInfoEntries.Length; ++i)
    {
        Entry = default.PropertyInfoEntries[i];
        PlayInfo.AddSetting(
            default.MutatorGroup, Entry.Name, Entry.Caption, 0, 1, Entry.PIType, Entry.PIExtras);
    }
}

static event string GetDescriptionText(string PropertyName)
{
    local int i;

    i = GetPropertyIndex(PropertyName);
    if (i >= 0)
    {
        return default.PropertyInfoEntries[i].Hint;
    }
    return Super.GetDescriptionText(PropertyName);
}

static simulated function int GetPropertyIndex(string PropertyName)
{
    local int i;

    for (i = 0; i < default.PropertyInfoEntries.Length; ++i)
    {
        if (PropertyName == default.PropertyInfoEntries[i].Name)
        {
            return i;
        }
    }
    return -1;
}

function SetProperty(string PropertyName, string PropertyValue)
{
    SetPropertyText(PropertyName, PropertyValue);
    PropertyChanged(PropertyName, PropertyValue);
    SaveConfig();
}

function PropertyChanged(string PropertyName, string PropertyValue)
{
    local int i;

    for (i = 0; i < CRIs.Length; ++i)
    {
        CRIs[i].UpdateProperty(PropertyName, PropertyValue);
    }
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local HxClientReplicationInfo CRI;

    if (Other.IsA('PlayerController') && !Other.IsA('MessagingSpectator'))
    {
        CRI = Other.Spawn(CRIClass, Other);
        CRI.MutatorOwner = Self;
        CRI.UpdateAll();
        CRIs[CRIs.Length] = CRI;
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
        }
    }
    Super.NotifyLogout(Exiting);
}

function HxClientReplicationInfo GetClientReplicationInfo(PlayerController PC)
{
    local int i;

    for (i = 0; i < CRIs.Length; ++i)
    {
        if (CRIs[i].Owner == PC)
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

defaultproperties
{
    MutatorGroup="HexedMutator"
}
