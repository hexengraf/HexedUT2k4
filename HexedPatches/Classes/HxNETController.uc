class HxNETController extends Interaction
    config(User);

enum EHxMasterServer
{
    HX_MASTER_SERVER_333networks,
    HX_MASTER_SERVER_OpenSpy,
};

struct HxMasterServerEntry
{
    var array<string> Addresses;
    var array<int> Ports;
};

const KEEP_ALIVE_TIME = "IpDrv.TcpNetDriver KeepAliveTime";

var config bool bValidateKeepAliveTime;
var config int CustomNetSpeed;
var config EHxMasterServer MasterServer;

var HxMasterServerEntry MasterServerEntries[2];
var bool bExecutedOnce;

event NotifyLevelChange()
{
    if (!bExecutedOnce)
    {
        bExecutedOnce = true;
        ValidateKeepAliveTime();
        UpdateMasterServer();
    }
    UpdateCustomNetSpeed();
}

function UpdateCustomNetSpeed()
{
    if (CustomNetSpeed != 0
        && (ViewportOwner.ConfiguredInternetSpeed != CustomNetSpeed
            || ViewportOwner.ConfiguredLanSpeed != CustomNetSpeed))
    {
        ViewportOwner.ConfiguredInternetSpeed = CustomNetSpeed;
        ViewportOwner.ConfiguredLanSpeed = CustomNetSpeed;
        ConsoleCommand("NetSpeed"@CustomNetSpeed);
        ViewportOwner.SaveConfig();
        Log(Name@": Updating NetSpeed to"@CustomNetSpeed);
    }
}

function UpdateMasterServer()
{
    local HxMasterServerEntry Entry;
    local int i;

    Entry = MasterServerEntries[MasterServer];
    if (class'IpDrv.MasterServerLink'.default.MasterServerList.Length == 0
        || class'IpDrv.MasterServerLink'.default.MasterServerList[0].Address != Entry.Addresses[0])
    {
        class'IpDrv.MasterServerLink'.default.MasterServerList.Length = Entry.Addresses.Length;
        for (i = 0; i < Entry.Addresses.Length; ++i)
        {
            class'IpDrv.MasterServerLink'.default.MasterServerList[i].Address = Entry.Addresses[i];
            class'IpDrv.MasterServerLink'.default.MasterServerList[i].Port = Entry.Ports[i];
        }
        class'IpDrv.MasterServerLink'.static.StaticSaveConfig();
    }
}

function ValidateKeepAliveTime()
{
    if (bValidateKeepAliveTime
        && (ViewportOwner.Actor == None
            || float(ViewportOwner.Actor.ConsoleCommand("get"@KEEP_ALIVE_TIME)) != 0.2))
    {
        ConsoleCommand("set"@KEEP_ALIVE_TIME@"0.2");
        Log(Name@": Updating KeepAliveTime to 0.2");
    }
}

defaultproperties
{
    bValidateKeepAliveTime=true
    CustomNetSpeed=1000000
    MasterServer=HX_MASTER_SERVER_333networks
    MasterServerEntries(0)=(Addresses=("ut2004master.333networks.com","ut2004master.errorist.eu"),Ports=(28902,28902))
    MasterServerEntries(1)=(Addresses=("utmaster.openspy.net"),Ports=(28902))
}
