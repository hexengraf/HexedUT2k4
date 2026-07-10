class HxUTClient extends HxClientReplicationInfo
    config(User);

struct HxDamageInfo
{
    var int Value;
    var float Timestamp;
};

const DAMAGE_CLUSTERING_INTERVAL = 0.02;

var private HxHitEffects HitEffects;
var private HxColors SkinHighlightColors;
var private HxUTPlayer Player;
var private HxSPTimer SPTimer;
var private HxDamageInfo Damage;
var private class<ScoreBoard> OriginalScoreBoardClass;
var private bool bAllowEnhancedScoreBoards;
var private bool bInitialized;

replication
{
    reliable if (Role == ROLE_Authority)
        ClientUpdateHitEffects,
        ClientNotifySpawn;
}

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (Level.NetMode != NM_DedicatedServer)
    {
        SkinHighlightColors = HxColors(Manager.LoadObject(class'HxColors', "HxSkinHighlight"));
        class'HxSkinHighlight'.static.PopulateReservedNames(SkinHighlightColors);
        HxSkinHighlightConfig(Configs[1]).ValidateColors(SkinHighlightColors);
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
    }
    ServerTick(DeltaTime);
}

function ServerTick(float DeltaTime)
{
    if (Damage.Value > 0 && Level.TimeSeconds - Damage.Timestamp >= DAMAGE_CLUSTERING_INTERVAL)
    {
        ClientUpdateHitEffects(Damage.Value);
        Damage.Value = 0;
    }
}

function UpdateDamage(int Value, Pawn Injured, Pawn Inflictor, class<DamageType> Type)
{
    Damage.Timestamp = Level.TimeSeconds;
    Damage.Value += Value;
}

simulated function ClientUpdateHitEffects(int Damage)
{
    if (Level.NetMode != NM_DedicatedServer && HitEffects != None)
    {
        HitEffects.Update(Damage);
    }
}

simulated function PlayHitSoundPreview(int Index)
{
    if (HitEffects != None)
    {
        HitEffects.PlayHitSoundPreview(Index);
    }
}

simulated function DrawDamageNumberPreview(Canvas C, int Index)
{
    if (HitEffects != None)
    {
        HitEffects.DrawPreview(C, Index);
    }
}

function NotifySpawn(Pawn Spawned)
{
    if (DeathMatch(Level.Game) != None)
    {
        ClientNotifySpawn(DeathMatch(Level.Game).SpawnProtectionTime);
    }
}

simulated function ClientNotifySpawn(float SpawnProtectionTime)
{
    if (Level.NetMode != NM_DedicatedServer && SPTimer != None)
    {
        SPTimer.SetProtected(SpawnProtectionTime);
    }
}

simulated function bool InitializeClient()
{
    local PlayerController PC;

    PC = PlayerController(Owner);
    if (PC != None && PC.GameReplicationInfo != None)
    {
        if (Player == None)
        {
            Player = HxUTPlayer(SpawnUnique(class'HxUTPlayer', PC));
            Player.ApplyServerConfiguration(Self);
        }
        if (PC.myHUD != None)
        {
            UpdateScoreBoard();
            if (HitEffects == None)
            {
                HitEffects = HxHitEffects(SpawnOverlay(PC.myHUD, class'HxHitEffects'));
                HitEffects.ApplyServerConfiguration(Self);
            }
            if (SPTimer == None)
            {
                SPTimer = HxSPTimer(SpawnOverlay(PC.myHUD, class'HxSPTimer'));
            }
        }
    }
    return Player != None && HitEffects != None && SPTimer != None;
}

simulated function ReplaceScoreBoard()
{
    local PlayerController PC;

    PC = PlayerController(Owner);
    if (PC != None && PC.myHUD != None && PC.GameReplicationInfo != None
        && !PC.myHUD.ScoreBoard.IsA('HxScoreBoard'))
    {
        OriginalScoreBoardClass = PC.myHUD.ScoreBoard.Class;
        switch (PC.myHUD.ScoreBoard.Class)
        {
            case class'ScoreBoard_Assault':
                PC.MyHUD.SetScoreBoardClass(class'HxSBAssault');
                break;
            case class'ScoreBoardDeathMatch':
                PC.MyHUD.SetScoreBoardClass(class'HxSBDeathMatch');
                break;
            case class'ScoreBoardInvasion':
                PC.MyHUD.SetScoreBoardClass(class'HxSBInvasion');
                break;
            case class'ScoreBoardLMS':
                PC.MyHUD.SetScoreBoardClass(class'HxSBLastManStanding');
                break;
            case class'MutantScoreboard':
                PC.MyHUD.SetScoreBoardClass(class'HxSBMutant');
                break;
            case class'ScoreBoardTeamDeathMatch':
                if (PC.GameReplicationInfo.GameClass ~= "XGame.xTeamGame")
                {
                    PC.MyHUD.SetScoreBoardClass(class'HxSBTeamDeathMatch');
                }
                else if (PC.GameReplicationInfo.GameClass ~= "XGame.xBombingRun")
                {
                    PC.MyHUD.SetScoreBoardClass(class'HxSBBombingRun');
                }
                else if (PC.GameReplicationInfo.GameClass ~= "XGame.xDoubleDom")
                {
                    PC.MyHUD.SetScoreBoardClass(class'HxSBDoubleDomination');
                }
                else if (PC.GameReplicationInfo.GameClass ~= "Onslaught.ONSOnslaughtGame")
                {
                    PC.MyHUD.SetScoreBoardClass(class'HxSBOnslaught');
                }
                else if (PC.GameReplicationInfo.GameClass ~= "XGame.xCTFGame"
                    || PC.GameReplicationInfo.GameClass ~= "XGame.InstagibCTF"
                    || PC.GameReplicationInfo.GameClass ~= "XGame.xVehicleCTFGame")
                {
                    PC.MyHUD.SetScoreBoardClass(class'HxSBCaptureTheFlag');
                }
                break;
        }
    }
}

simulated function RestoreScoreBoard()
{
    local PlayerController PC;

    PC = PlayerController(Owner);
    if (PC != None && PC.myHUD != None && PC.myHUD.ScoreBoard.IsA('HxScoreBoard'))
    {
        if (OriginalScoreBoardClass != None)
        {
            PC.MyHUD.SetScoreBoardClass(OriginalScoreBoardClass);
        }
        else
        {
            switch (PC.myHUD.ScoreBoard.Class)
            {
                case class'HxSBAssault':
                    break;
                case class'HxSBDeathMatch':
                    PC.MyHUD.SetScoreBoardClass(class'ScoreBoardDeathMatch');
                    break;
                case class'HxSBInvasion':
                    PC.MyHUD.SetScoreBoardClass(class'ScoreBoardInvasion');
                    break;
                case class'HxSBLastManStanding':
                    PC.MyHUD.SetScoreBoardClass(class'ScoreBoardLMS');
                    break;
                case class'HxSBMutant':
                    PC.MyHUD.SetScoreBoardClass(class'MutantScoreboard');
                    break;
                case class'HxSBTeamDeathMatch':
                case class'HxSBBombingRun':
                case class'HxSBCaptureTheFlag':
                case class'HxSBDoubleDomination':
                case class'HxSBOnslaught':
                    PC.MyHUD.SetScoreBoardClass(class'ScoreBoardTeamDeathMatch');
                    break;
            }
        }
    }
}

simulated function UpdateScoreBoard()
{
    local HxScoreBoardConfig Config;

    if (bAllowEnhancedScoreBoards)
    {
        Config = HxScoreBoardConfig(FindConfig(class'HxScoreBoardConfig'));
        if (Config.bEnabled)
        {
            ReplaceScoreBoard();
        }
    }
    else
    {
        RestoreScoreBoard();
    }
}

simulated function ServerInfoReady()
{
    if (Player != None)
    {
        Player.ApplyServerConfiguration(Self);
    }
    if (HitEffects != None)
    {
        HitEffects.ApplyServerConfiguration(Self);
    }
    bAllowEnhancedScoreBoards = bool(GetServerProperty("bAllowEnhancedScoreBoards"));
    UpdateScoreBoard();
}

simulated function ServerPropertyChanged(int Index, string OldValue)
{
    ServerInfoReady();
}

simulated function bool SetProperty(int ConfigIndex, int PropertyIndex, string Value)
{
    local PlayerController PC;

    if (Super.SetProperty(ConfigIndex, PropertyIndex, Value))
    {
        PC = PlayerController(Owner);
        switch (ConfigClasses[ConfigIndex])
        {
            case class'HxHitEffectsConfig':
                if (HitEffects != None)
                {
                    HitEffects.SetProperty(
                        Configs[ConfigIndex].Properties[PropertyIndex].Name, Value);
                }
                break;
            case class'HxUTPlayerConfig':
                if (Player != None)
                {
                    Player.SetPropertyText(
                        Configs[ConfigIndex].Properties[PropertyIndex].Name, Value);
                }
                break;
            case class'HxScoreBoardConfig':
                if (Configs[ConfigIndex].Properties[PropertyIndex].Name ~= "bEnabled")
                {
                    UpdateScoreBoard();
                }
                else if (HxScoreBoard(PC.MyHUD.ScoreBoard) != None)
                {
                    HxScoreBoard(PC.MyHUD.ScoreBoard).Init();
                }
                break;
            case class'HxSPTimerConfig':
                if (SPTimer != None)
                {
                    SPTimer.SetPropertyText(
                        Configs[ConfigIndex].Properties[PropertyIndex].Name, Value);
                }
                break;
        }
        return true;
    }
    return false;
}

simulated function HxColors GetSkinHighlightColors()
{
    return SkinHighlightColors;
}

defaultproperties
{
    MutatorClass=class'MutHexedUT'
    ConfigClasses(0)=class'HxHitEffectsConfig'
    ConfigClasses(1)=class'HxSkinHighlightConfig'
    ConfigClasses(2)=class'HxUTPlayerConfig'
    ConfigClasses(3)=class'HxScoreBoardConfig'
    ConfigClasses(4)=class'HxSPTimerConfig'
    PanelClasses(0)=class'HxGUIMenuHUDPanel'
    PanelClasses(1)=class'HxGUIMenuHitEffectsPanel'
    PanelClasses(2)=class'HxGUIMenuSkinHighlightPanel'
    Order=0
}
