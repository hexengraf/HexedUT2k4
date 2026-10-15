class HxPlayerReplicationInfo extends LinkedReplicationInfo;

struct HxWeaponStats
{
    var class<Weapon> WeaponClass;
    var int Hits;
    var int Total;
};

const STATS_WEAPON = 1;
const STATS_KILL = 2;

var int PlayerID;
var PlayerReplicationInfo BasePRI;
var HxLinkedReplicationInfo LinkedReplicationInfo;
var byte AvailableStats;
var byte Accuracy;
var int MaxSpree;
var int TeamKills;
var array<HxWeaponStats> WeaponStats;

var private float LastStatsUpdate;

replication
{
    reliable if (Role == ROLE_Authority && bNetInitial)
        PlayerID, BasePRI, LinkedReplicationInfo;

    unreliable if (Role == ROLE_Authority)
        AvailableStats;
}

function UpdateStats()
{
    local int i;
    local int Hits;
    local int Total;

    if (Level.TimeSeconds - LastStatsUpdate > Level.TimeDilation)
    {
        for (i = 0; i < WeaponStats.Length; ++i)
        {
            if (ClassIsChildOf(WeaponStats[i].WeaponClass, class'SuperShockRifle'))
            {
                Hits += BasePRI.Kills;
            }
            else
            {
                Hits += WeaponStats[i].Hits;
            }
            Total += WeaponStats[i].Total;
        }
        if (Total > 0)
        {
            Accuracy = byte((float(Hits) / Total) * 100);
        }
        LastStatsUpdate = Level.TimeSeconds;
    }
}

function IncrementWeaponShots(class<Weapon> WeaponClass, int Shots)
{
    local int i;

    for (i = 0; i < WeaponStats.Length; ++i)
    {
        if (WeaponStats[i].WeaponClass == WeaponClass)
        {
            WeaponStats[i].Total += Shots;
            return;
        }
    }
    WeaponStats.Insert(i, 1);
    WeaponStats[i].WeaponClass = WeaponClass;
    WeaponStats[i].Total = Shots;
}

function bool ValidateWeaponStats(class<Weapon> WeaponClass, int ExpectedIndex)
{
    local int i;

    if (WeaponStats.Length == ExpectedIndex)
    {
        WeaponStats.Insert(ExpectedIndex, 1);
        WeaponStats[ExpectedIndex].WeaponClass = WeaponClass;
        return true;
    }
    if (WeaponStats.Length > ExpectedIndex)
    {
        if (WeaponStats[ExpectedIndex].WeaponClass == WeaponClass)
        {
            return true;
        }
        WeaponStats.Insert(ExpectedIndex, 1);
        WeaponStats[ExpectedIndex].WeaponClass = WeaponClass;
        for (i = 0; i < WeaponStats.Length; ++i)
        {
            if (WeaponStats[i].WeaponClass == WeaponClass)
            {
                WeaponStats[ExpectedIndex].Hits = WeaponStats[i].Hits;
                WeaponStats[ExpectedIndex].Total = WeaponStats[i].Total;
                WeaponStats.Remove(i, 1);
                break;
            }
        }
        return true;
    }
    return false;
}

function SetWeaponStatsAvailability(bool bValue)
{
    if (bValue)
    {
        AvailableStats = AvailableStats | STATS_WEAPON;
    }
    else
    {
        AvailableStats = AvailableStats & ~STATS_WEAPON;
    }
}

function SetKillStatsAvailability(bool bValue)
{
    if (bValue)
    {
        AvailableStats = AvailableStats | STATS_KILL;
    }
    else
    {
        AvailableStats = AvailableStats & ~STATS_KILL;
    }
}

simulated function bool HasWeaponStats()
{
    return (AvailableStats & STATS_WEAPON) != 0;
}

simulated function bool HasKillStats()
{
    return (AvailableStats & STATS_KILL) != 0;
}

event Destroyed()
{
    local HxLinkedReplicationInfo LinkedPRI;
    local HxLinkedReplicationInfo NextPRI;

    LinkedPRI = LinkedReplicationInfo;
    while (LinkedPRI != None)
    {
        NextPRI = LinkedPRI.NextReplicationInfo;
        LinkedPRI.PrevReplicationInfo = None;
        LinkedPRI.NextReplicationInfo = None;
        LinkedPRI.Destroy();
        LinkedPRI = NextPRI;
    }
}

function HxLinkedReplicationInfo SpawnLinkedPRI(HxMutator MutatorOwner,
                                                class<HxLinkedReplicationInfo> LinkedPRIClass)
{
    local HxLinkedReplicationInfo LinkedPRI;

    if (LinkedReplicationInfo == None)
    {
        LinkedReplicationInfo = Spawn(LinkedPRIClass, MutatorOwner);
        LinkedReplicationInfo.HexedPRI = Self;
        NetUpdateTime = Level.TimeSeconds - 1;
        LinkedReplicationInfo.NetUpdateTime = NetUpdateTime;
        return LinkedReplicationInfo;
    }
    LinkedPRI = LinkedReplicationInfo;
    while (LinkedPRI.NextReplicationInfo != None)
    {
        LinkedPRI = LinkedPRI.NextReplicationInfo;
    }
    LinkedPRI.NextReplicationInfo = Spawn(LinkedPRIClass, MutatorOwner);
    LinkedPRI.NextReplicationInfo.HexedPRI = Self;
    LinkedPRI.NextReplicationInfo.PrevReplicationInfo = LinkedPRI;
    LinkedPRI.NetUpdateTime = Level.TimeSeconds - 1;
    LinkedPRI.NextReplicationInfo.NetUpdateTime = LinkedPRI.NetUpdateTime;
    return LinkedPRI.NextReplicationInfo;
}

static function HxLinkedReplicationInfo FindLinkedPRI(PlayerReplicationInfo PRI,
                                                      class<HxLinkedReplicationInfo> TargetClass)
{
    local HxPlayerReplicationInfo HxPRI;
    local HxLinkedReplicationInfo LinkedPRI;

    HxPRI = Get(PRI);
    if (HxPRI != None)
    {
        LinkedPRI = HxPRI.LinkedReplicationInfo;
        while (LinkedPRI != None && LinkedPRI.Class != TargetClass)
        {
            LinkedPRI = LinkedPRI.NextReplicationInfo;
        }
    }
    return LinkedPRI;
}

static function HxPlayerReplicationInfo Get(PlayerReplicationInfo PRI)
{
    local LinkedReplicationInfo LinkedPRI;

    if (PRI != None)
    {
        LinkedPRI = PRI.CustomReplicationInfo;
        while (LinkedPRI != None && LinkedPRI.Class != default.Class)
        {
            LinkedPRI = LinkedPRI.NextReplicationInfo;
        }
    }
    return HxPlayerReplicationInfo(LinkedPRI);
}

static function HxPlayerReplicationInfo Create(PlayerReplicationInfo PRI)
{
    local HxPlayerReplicationInfo HexedPRI;
    local LinkedReplicationInfo LinkedPRI;

    if (PRI == None || MessagingSpectator(PRI.Owner) != None)
    {
        return None;
    }
    HexedPRI = Get(PRI);
    if (HexedPRI == None)
    {
        if (PRI.CustomReplicationInfo == None)
        {
            PRI.CustomReplicationInfo = PRI.Spawn(class'HxPlayerReplicationInfo', PRI.Owner);
            PRI.NetUpdateTime = PRI.Level.TimeSeconds - 1;
            PRI.CustomReplicationInfo.NetUpdateTime = PRI.NetUpdateTime;
            HexedPRI = HxPlayerReplicationInfo(PRI.CustomReplicationInfo);
            HexedPRI.BasePRI = PRI;
        }
        else
        {
            LinkedPRI = PRI.CustomReplicationInfo;
            while (LinkedPRI.NextReplicationInfo != None)
            {
                LinkedPRI = LinkedPRI.NextReplicationInfo;
            }
            LinkedPRI.NextReplicationInfo = PRI.Spawn(class'HxPlayerReplicationInfo', PRI.Owner);
            LinkedPRI.NetUpdateTime = PRI.Level.TimeSeconds - 1;
            LinkedPRI.NextReplicationInfo.NetUpdateTime = LinkedPRI.NetUpdateTime;
            HexedPRI = HxPlayerReplicationInfo(LinkedPRI.NextReplicationInfo);
            HexedPRI.BasePRI = PRI;
        }
    }
    return HexedPRI;
}

static function int Delete(PlayerReplicationInfo PRI)
{
    local LinkedReplicationInfo NextLinkedPRI;
    local LinkedReplicationInfo LinkedPRI;
    local int DeletedID;

    if (PRI == None || MessagingSpectator(PRI.Owner) != None || PRI.CustomReplicationInfo == None)
    {
        return -1;
    }
    if (PRI.CustomReplicationInfo.Class == class'HxPlayerReplicationInfo')
    {
        NextLinkedPRI = PRI.CustomReplicationInfo.NextReplicationInfo;
        DeletedID = HxPlayerReplicationInfo(PRI.CustomReplicationInfo).PlayerID;
        PRI.CustomReplicationInfo.Destroy();
        PRI.CustomReplicationInfo = NextLinkedPRI;
        return DeletedID;
    }
    LinkedPRI = PRI.CustomReplicationInfo;
    while (LinkedPRI.NextReplicationInfo != None)
    {
        if (LinkedPRI.NextReplicationInfo.Class == class'HxPlayerReplicationInfo')
        {
            NextLinkedPRI = LinkedPRI.NextReplicationInfo.NextReplicationInfo;
            DeletedID = HxPlayerReplicationInfo(LinkedPRI.NextReplicationInfo).PlayerID;
            LinkedPRI.NextReplicationInfo.Destroy();
            LinkedPRI.NextReplicationInfo = NextLinkedPRI;
            return DeletedID;
        }
        LinkedPRI = LinkedPRI.NextReplicationInfo;
    }
    return -1;
}

defaultproperties
{
    NetUpdateFrequency=1
    bOnlyDirtyReplication=true
}
