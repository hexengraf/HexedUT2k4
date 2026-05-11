class HxVTClient extends HxClientReplicationInfo
    config(User);

struct HxMapEntry
{
    var string Name;
    var string Label;
    var string Author;
    var int MinPlayers;
    var int MaxPlayers;
    var int Played;
    var int Sequence;
    var HxFavorites.EHxTag Tag;
};

struct HxMapResources
{
    var string PreviewName;
    var Material Preview;
    var string Description;
    var bool bDescriptionReady;
    var bool bPreviewReady;
};

var VotingReplicationInfo VRI;
var array<HxMapEntry> Maps;

var private PlayerController PC;
var private GUIController GC;
var private HxFavorites Favorites;
var private array<HxMapResources> Resources;
var private array<class<Object> > PreviewLoaders;
var private int PreviewLoadersSent;
var private int MapEntryResponseCount;
var private string CustomMapVoteMenu;
var private bool bPreviewLoadersReady;
var private bool bReplaceMapVoteMenu;
var private bool bInitialized;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientReceivePreviewLoader,
        ClientReceiveMapEntry,
        ClientReceivePreviewAndLabel,
        ClientReceivePlayersAndAuthor,
        ClientReceiveMapDescription;

    reliable if (Role < ROLE_Authority)
        ServerRequestMapEntry,
        ServerRequestMapDescription;
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    CustomMapVoteMenu = string(class'HxMapVotingPage');
    if (Level.NetMode != NM_DedicatedServer)
    {
        Favorites = new(None, "Maps") class'HxFavorites';
    }
}

simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (!bInitialized)
        {
            bInitialized = InitializeClient();
        }
        else
        {
            if (bReplaceMapVoteMenu)
            {
                TryReplaceMapVoteMenu();
            }
            if (Maps.Length < VRI.MapList.Length)
            {
                PopulateMapEntries();
            }
        }
    }
    if (Level.NetMode != NM_Client && !bPreviewLoadersReady)
    {
        SendPreviewLoaders();
    }
}

simulated function bool InitializeClient()
{
    PC = PlayerController(Owner);
    if (PC != None)
    {
        if (PC.Player != None)
        {
            GC = GUIController(PC.Player.GUIController);
            bReplaceMapVoteMenu = !GC.SetPropertyText("CustomMapVotingMenu", CustomMapVoteMenu);
        }
        VRI = VotingReplicationInfo(PC.VoteReplicationInfo);
    }
    return PC != None && GC != None;
}

simulated function PopulateMapEntries()
{
    local CacheManager.MapRecord Record;
    local int Limit;
    local int i;

    Limit = Maps.Length + Min(VRI.MapList.Length - Maps.Length, 8 * REQUESTS_PER_TICK);
    for (i = Maps.Length; i < Limit; ++i)
    {
        Maps.Insert(Maps.Length, 1);
        Resources.Insert(Resources.Length, 1);
        Maps[i].Name = VRI.MapList[i].MapName;
        Maps[i].Played = VRI.MapList[i].PlayCount;
        Maps[i].Sequence = VRI.MapList[i].Sequence;
        Maps[i].Tag = Favorites.Get(VRI.MapList[i].MapName);
        Record = class'CacheManager'.static.GetMapRecord(VRI.MapList[i].MapName);
        if (Record.MapName != "")
        {
            Maps[i].Label = Record.FriendlyName;
            Maps[i].Author = Record.Author;
            Maps[i].MinPlayers = Record.PlayerCountMin;
            Maps[i].MaxPlayers = Record.PlayerCountMax;
            Resources[i].Description = GetMapDescriptionFromRecord(Record);
            Resources[i].bDescriptionReady = true;
            Resources[i].PreviewName = Record.ScreenshotRef;
            MapEntryResponseCount += 2;
        }
        else
        {
            ServerRequestMapEntry(i);
        }
    }
}

function SendPreviewLoaders()
{
    local MutHexedVOTE HexedVOTE;
    local int Limit;
    local int i;

    HexedVOTE = MutHexedVOTE(MutatorOwner);
    if (HexedVOTE.MapPreviewLoaders.Length > 0)
    {
        Limit = Min(HexedVOTE.MapPreviewLoaders.Length - PreviewLoadersSent, REQUESTS_PER_TICK);
        for (i = 0; i < Limit; ++i)
        {
            ClientReceivePreviewLoader(
                HexedVOTE.MapPreviewLoaders[PreviewLoadersSent + i],
                PreviewLoadersSent + i == HexedVOTE.MapPreviewLoaders.Length - 1);
        }
        PreviewLoadersSent += Limit;
        bPreviewLoadersReady = PreviewLoadersSent == HexedVOTE.MapPreviewLoaders.Length;
    }
    else
    {
        ClientReceivePreviewLoader("", true);
        bPreviewLoadersReady = true;
    }
}

simulated function ClientReceivePreviewLoader(string LoaderName, bool bLast)
{
    local class<Object> LoaderClass;

    if (LoaderName != "")
    {
        LoaderClass = class<Object>(DynamicLoadObject(LoaderName, class'Class', true));
        if (LoaderClass != None)
        {
            PreviewLoaders[PreviewLoaders.Length] = LoaderClass;
        }
    }
    if (bLast)
    {
        bPreviewLoadersReady = true;
        NotifyResourcesUpdated();
    }
}

function ServerRequestMapEntry(int Index)
{
    local xVotingHandler VH;
    local CacheManager.MapRecord Record;

    VH = xVotingHandler(Level.Game.VotingHandler);
    if (VH != None)
    {
        Record = class'CacheManager'.static.GetMapRecord(VH.MapList[Index].MapName);
        if (StringByteSize(Record.FriendlyName$Record.ScreenshotRef$Record.Author) <= PKG_STR_LIMIT)
        {
            ClientReceiveMapEntry(
                Index,
                Record.PlayerCountMin,
                Record.PlayerCountMax,
                Record.FriendlyName,
                Record.Author,
                Record.ScreenshotRef);
        }
        else
        {
            ClientReceivePreviewAndLabel(Index, Record.ScreenshotRef, Record.FriendlyName);
            ClientReceivePlayersAndAuthor(
                Index, Record.PlayerCountMin, Record.PlayerCountMax, Record.Author);
        }
    }
}

simulated function ClientReceiveMapEntry(int MapIndex,
                                         int MinPlayers,
                                         int MaxPlayers,
                                         string Label,
                                         string Author,
                                         string PreviewName)
{
    ClientReceivePreviewAndLabel(MapIndex, PreviewName, Label);
    ClientReceivePlayersAndAuthor(MapIndex, MinPlayers, MaxPlayers, Author);
}

simulated function ClientReceivePreviewAndLabel(int MapIndex, string PreviewName, string Label)
{
    Maps[MapIndex].Label = Label;
    Resources[MapIndex].PreviewName = PreviewName;
    ++MapEntryResponseCount;
}

simulated function ClientReceivePlayersAndAuthor(int MapIndex,
                                                 int MinPlayers,
                                                 int MaxPlayers,
                                                 string Author)
{
    Maps[MapIndex].Author = Author;
    Maps[MapIndex].MinPlayers = MinPlayers;
    Maps[MapIndex].MaxPlayers = MaxPlayers;
    ++MapEntryResponseCount;
}

function ServerRequestMapDescription(int MapIndex)
{
    local xVotingHandler VH;
    local CacheManager.MapRecord Record;
    local string Description;
    local int Remaining;
    local int PartSize;

    VH = xVotingHandler(Level.Game.VotingHandler);
    if (VH != None)
    {
        Record = class'CacheManager'.static.GetMapRecord(VH.MapList[MapIndex].MapName);
        Description = GetMapDescriptionFromRecord(Record);
        Remaining = StringByteSize(Description);
        if (Remaining != 0)
        {
            while (Remaining > 0)
            {
                PartSize = Min(Remaining, PKG_STR_LIMIT);
                Remaining -= PartSize;
                ClientReceiveMapDescription(
                    MapIndex, ExtractBytes(Description, PartSize), Remaining == 0);
            }
        }
        else
        {
            ClientReceiveMapDescription(MapIndex, Description, true);
        }
    }
}

simulated function ClientReceiveMapDescription(int MapIndex, string Description, bool bLast)
{
    Resources[MapIndex].Description $= Description;
    if (bLast)
    {
        Resources[MapIndex].bDescriptionReady = true;
        NotifyResourcesUpdated();
    }
}

simulated function NotifyResourcesUpdated()
{
    local HxMapVotingPage VoteMenu;

    if (GC != None && GC.ActivePage != None)
    {
        if (HxMapVotingPage(GC.ActivePage) != None)
        {
            VoteMenu = HxMapVotingPage(GC.ActivePage);
        }
        else if (HxMapVotingPage(GC.ActivePage.ParentPage) != None)
        {
            VoteMenu = HxMapVotingPage(GC.ActivePage.ParentPage);
        }
        if (VoteMenu != None)
        {
            VoteMenu.MapBanner.Refresh();
        }
    }
}

simulated function TryReplaceMapVoteMenu()
{
    if (GC.ActivePage != None)
    {
        if (GC.ActivePage.Class == class'MapVotingPage')
        {
            GC.ReplaceMenu(CustomMapVoteMenu);
        }
        else if (GC.ActivePage.ParentPage != None
            && GC.ActivePage.ParentPage.Class == class'MapVotingPage')
        {
            if (GC.CloseMenu(true))
            {
                GC.ReplaceMenu(CustomMapVoteMenu);
            }
        }
    }
}

simulated function UpdateMapVoteMenuBackgrounds()
{
    class'HxMapVotingPage'.default.VoteListCustomBG = GetServerProperty("VoteListCustomBG");
    class'HxMapVotingPage'.default.MapListCustomBG = GetServerProperty("MapListCustomBG");
    class'HxMapVotingPage'.default.PreviewCustomBG = GetServerProperty("PreviewCustomBG");
    class'HxMapVotingPage'.default.ChatBoxCustomBG = GetServerProperty("ChatBoxCustomBG");
}

simulated function ServerInfoReady()
{
    UpdateMapVoteMenuBackgrounds();
}

simulated function ServerPropertyChanged(int Index, string OldValue)
{
    UpdateMapVoteMenuBackgrounds();
}

simulated function bool SendMapVote(int GameType, int Map)
{
    if (VRI.MapList[Map].bEnabled || PC.PlayerReplicationInfo.bAdmin)
    {
        VRI.SendMapVote(Map, GameType);
        return true;
    }
    return false;
}

simulated final function string GetMapDescription(int MapIndex)
{
    if (!Resources[MapIndex].bDescriptionReady)
    {
        ServerRequestMapDescription(MapIndex);
    }
    return Resources[MapIndex].Description;
}

simulated final function Material GetMapPreview(int MapIndex)
{
    local int i;

    if (!Resources[MapIndex].bPreviewReady)
    {
        if (Resources[MapIndex].PreviewName != "")
        {
            Resources[MapIndex].Preview = Material(
                DynamicLoadObject(Resources[MapIndex].PreviewName, class'Material', true));
            Resources[MapIndex].bPreviewReady = Resources[MapIndex].Preview != None;
        }
        if (!Resources[MapIndex].bPreviewReady)
        {
            for (i = 0; i < PreviewLoaders.Length; ++i)
            {
                Resources[MapIndex].PreviewName =
                    PreviewLoaders[i].static.GetItemName(Maps[MapIndex].Name);
                if (Resources[MapIndex].PreviewName != "")
                {
                    break;
                }
            }
            if (Resources[MapIndex].PreviewName != "")
            {
                Resources[MapIndex].Preview = Material(
                    DynamicLoadObject(Resources[MapIndex].PreviewName, class'Material', true));
            }
            Resources[MapIndex].bPreviewReady =
                Resources[MapIndex].Preview != None || bPreviewLoadersReady;
        }
    }
    return Resources[MapIndex].Preview;
}

simulated final function string GetGameTypePrefix(int GameType)
{
    return VRI.GameConfig[GameType].Prefix;
}

simulated final function string GetGameTypeName(int GameType)
{
    return VRI.GameConfig[GameType].GameName;
}

simulated final function int GetGameTypeCount()
{
    return VRI.GameConfig.Length;
}

simulated final function int GetCurrentGameType()
{
    return VRI.CurrentGameConfig;
}

simulated final function byte GetMapVoteMode()
{
    return VRI.Mode;
}

simulated final function string GetLoadingStatus()
{
    return Min(VRI.MapList.Length, MapEntryResponseCount / 2)$"/"$VRI.MapCount;
}

simulated final function bool IsEnabled(int Index)
{
    return VRI.MapList[Index].bEnabled;
}

simulated final function bool IsInitialized()
{
    return bInitialized && VRI != None;
}

simulated final function bool IsLoadingMapData()
{
    return VRI.GameConfig.Length < VRI.GameConfigCount
        || VRI.MapList.Length < VRI.MapCount
        || MapEntryResponseCount < (VRI.MapCount * 2);
}

simulated final function bool IsMapVoteEnabled()
{
    return VRI.bMapVote;
}

simulated final function SetMapTag(int Index, HxFavorites.EHxTag Tag)
{
    if (Maps[Index].Tag == Tag)
    {
        Tag = HX_TAG_None;
    }
    Favorites.Save(VRI.MapList[Index].MapName, Tag);
    Maps[Index].Tag = Tag;
}

static private final function string GetMapDescriptionFromRecord(CacheManager.MapRecord Record)
{
    local DecoText Deco;
    local string Description;
    local string PackageName;
    local string DecoTextName;
    local int i;

    if (class'CacheManager'.static.Is2003Content(Record.MapName) && Record.TextName != "")
    {
        if (!Divide(Record.TextName, ".", PackageName, DecoTextName))
        {
            PackageName = "XMaps";
            DecoTextName = Record.TextName;
        }
        Deco = class'xUtil'.static.LoadDecoText(PackageName, DecoTextName);
        if (Deco != None)
        {
            for (i = 0; i < Deco.Rows.Length; ++i)
            {
                if (Description != "")
                {
                    Description $= "|";
                }
                Description $= Deco.Rows[i];
            }
            return Description;
        }
    }
    return Record.Description;
}


defaultproperties
{
    MutatorClass=class'MutHexedVOTE'
    Order=232
}
