class HxScoreBoardConfig extends HxConfig
    PerObjectConfig
    config(User);

var config bool bEnabled;
var config HxTypes.EHxVertAlignment BoardAlignment;
var config HxTypes.EHxVertAlignment HeadingAlignment;
var config float BorderSize;
var config float DividerSize;
var config int FontSizeModifier;
var config bool bAlternateRowColors;
var config bool bCompactTeamScores;
var config bool bShowSecondaryStats;
var config bool bPreferVerticalLayout;
var config bool bAbbreviateHeadings;
var config bool bShowPlayerPortraits;
var config bool bShowBotCallSigns;
var config bool bShowBotOrders;
var config bool bShowShortcuts;
var config bool bShowTimestamp;
var config Color HeaderColor;
var config Color RedTeamHeaderColor;
var config Color BlueTeamHeaderColor;
var config Color RowColor;
var config Color RedTeamRowColor;
var config Color BlueTeamRowColor;
var config Color AltRowColor;
var config Color RedTeamAltRowColor;
var config Color BlueTeamAltRowColor;
var config Color BorderColor;
var config Color RedTeamBorderColor;
var config Color BlueTeamBorderColor;
var config Color DividerColor;
var config Color RedTeamDividerColor;
var config Color BlueTeamDividerColor;
var config Color ScrollThumbColor;
var config Color RedTeamScrollThumbColor;
var config Color BlueTeamScrollThumbColor;
var config Color RedTeamColor;
var config Color BlueTeamColor;
var config Color TextColor;
var config Color SecondTextColor;
var config Color HighlightTextColor;
var config Color ReadyColor;
var config array<HxScoreBoard.HxSBColumnConfig> AssaultColumns;
var config array<HxScoreBoard.HxSBColumnConfig> BombingRunColumns;
var config array<HxScoreBoard.HxSBColumnConfig> CaptureTheFlagColumns;
var config array<HxScoreBoard.HxSBColumnConfig> DeathMatchColumns;
var config array<HxScoreBoard.HxSBColumnConfig> DoubleDominationColumns;
var config array<HxScoreBoard.HxSBColumnConfig> InvasionColumns;
var config array<HxScoreBoard.HxSBColumnConfig> LastManStandingColumns;
var config array<HxScoreBoard.HxSBColumnConfig> MutantColumns;
var config array<HxScoreBoard.HxSBColumnConfig> OnslaughtColumns;
var config array<HxScoreBoard.HxSBColumnConfig> TeamDeathMatchColumns;

var const array<class<GameInfo> > GameTypes;
var private bool bAllowed;
var private class<ScoreBoard> OriginalScoreBoardClass;

function InitializeProperties()
{
    class'HxScoreBoard'.default.BoardAlignment = BoardAlignment;
    class'HxScoreBoard'.default.HeadingAlignment = HeadingAlignment;
    class'HxScoreBoard'.default.BorderSize = BorderSize;
    class'HxScoreBoard'.default.DividerSize = DividerSize;
    class'HxScoreBoard'.default.FontSizeModifier = FontSizeModifier;
    class'HxScoreBoard'.default.bAlternateRowColors = bAlternateRowColors;
    class'HxScoreBoard'.default.bCompactTeamScores = bCompactTeamScores;
    class'HxScoreBoard'.default.bShowSecondaryStats = bShowSecondaryStats;
    class'HxScoreBoard'.default.bPreferVerticalLayout = bPreferVerticalLayout;
    class'HxScoreBoard'.default.bAbbreviateHeadings = bAbbreviateHeadings;
    class'HxScoreBoard'.default.bShowPlayerPortraits = bShowPlayerPortraits;
    class'HxScoreBoard'.default.bShowBotCallSigns = bShowBotCallSigns;
    class'HxScoreBoard'.default.bShowBotOrders = bShowBotOrders;
    class'HxScoreBoard'.default.bShowShortcuts = bShowShortcuts;
    class'HxScoreBoard'.default.bShowTimestamp = bShowTimestamp;
    class'HxScoreBoard'.default.HeaderColor = HeaderColor;
    class'HxTeamScoreBoard'.default.TeamHeaderColors[0] = RedTeamHeaderColor;
    class'HxTeamScoreBoard'.default.TeamHeaderColors[1] = BlueTeamHeaderColor;
    class'HxScoreBoard'.default.RowColor = RowColor;
    class'HxTeamScoreBoard'.default.TeamRowColors[0] = RedTeamRowColor;
    class'HxTeamScoreBoard'.default.TeamRowColors[1] = BlueTeamRowColor;
    class'HxScoreBoard'.default.AltRowColor = AltRowColor;
    class'HxTeamScoreBoard'.default.TeamAltRowColors[0] = RedTeamAltRowColor;
    class'HxTeamScoreBoard'.default.TeamAltRowColors[1] = BlueTeamAltRowColor;
    class'HxScoreBoard'.default.BorderColor = BorderColor;
    class'HxTeamScoreBoard'.default.TeamBorderColors[0] = RedTeamBorderColor;
    class'HxTeamScoreBoard'.default.TeamBorderColors[1] = BlueTeamBorderColor;
    class'HxScoreBoard'.default.DividerColor = DividerColor;
    class'HxTeamScoreBoard'.default.TeamDividerColors[0] = RedTeamDividerColor;
    class'HxTeamScoreBoard'.default.TeamDividerColors[1] = BlueTeamDividerColor;
    class'HxScoreBoard'.default.ScrollThumbColor = ScrollThumbColor;
    class'HxTeamScoreBoard'.default.TeamScrollThumbColors[0] = RedTeamScrollThumbColor;
    class'HxTeamScoreBoard'.default.TeamScrollThumbColors[1] = BlueTeamScrollThumbColor;
    class'HxTeamScoreBoard'.default.TeamColors[0] = RedTeamColor;
    class'HxTeamScoreBoard'.default.TeamColors[1] = BlueTeamColor;
    class'HxScoreBoard'.default.TextColor = TextColor;
    class'HxScoreBoard'.default.SecondTextColor = SecondTextColor;
    class'HxScoreBoard'.default.HighlightTextColor = HighlightTextColor;
    class'HxScoreBoard'.default.ReadyColor = ReadyColor;
    class'HxSBAssault'.default.ColumnConfigs = AssaultColumns;
    class'HxSBBombingRun'.default.ColumnConfigs = BombingRunColumns;
    class'HxSBCaptureTheFlag'.default.ColumnConfigs = CaptureTheFlagColumns;
    class'HxSBDeathMatch'.default.ColumnConfigs = DeathMatchColumns;
    class'HxSBDoubleDomination'.default.ColumnConfigs = DoubleDominationColumns;
    class'HxSBInvasion'.default.ColumnConfigs = InvasionColumns;
    class'HxSBLastManStanding'.default.ColumnConfigs = LastManStandingColumns;
    class'HxSBMutant'.default.ColumnConfigs = MutantColumns;
    class'HxSBOnslaught'.default.ColumnConfigs = OnslaughtColumns;
    class'HxSBTeamDeathMatch'.default.ColumnConfigs = TeamDeathMatchColumns;
    UpdateScoreBoard();
}

function ValidateArray(int Index)
{
    switch (Index)
    {
        case 40:
            if (AssaultColumns.Length > 0 && AssaultColumns[0].MainStat == HX_SBS_None)
            {
                ResetProperty(Index);
            }
            break;
        case 41:
            if (BombingRunColumns.Length > 0 && BombingRunColumns[0].MainStat == HX_SBS_None)
            {
                ResetProperty(Index);
            }
            break;
        case 42:
            if (CaptureTheFlagColumns.Length > 0 && CaptureTheFlagColumns[0].MainStat == HX_SBS_None)
            {
                ResetProperty(Index);
            }
            break;
        case 43:
            if (DeathMatchColumns.Length > 0 && DeathMatchColumns[0].MainStat == HX_SBS_None)
            {
                ResetProperty(Index);
            }
            break;
        case 44:
            if (DoubleDominationColumns.Length > 0 && DoubleDominationColumns[0].MainStat == HX_SBS_None)
            {
                ResetProperty(Index);
            }
            break;
        case 45:
            if (InvasionColumns.Length > 0 && InvasionColumns[0].MainStat == HX_SBS_None)
            {
                ResetProperty(Index);
            }
            break;
        case 46:
            if (LastManStandingColumns.Length > 0 && LastManStandingColumns[0].MainStat == HX_SBS_None)
            {
                ResetProperty(Index);
            }
            break;
        case 47:
            if (MutantColumns.Length > 0 && MutantColumns[0].MainStat == HX_SBS_None)
            {
                ResetProperty(Index);
            }
            break;
        case 48:
            if (OnslaughtColumns.Length > 0 && OnslaughtColumns[0].MainStat == HX_SBS_None)
            {
                ResetProperty(Index);
            }
            break;
        case 49:
            if (TeamDeathMatchColumns.Length > 0 && TeamDeathMatchColumns[0].MainStat == HX_SBS_None)
            {
                ResetProperty(Index);
            }
            break;
    }
}

function ApplyProperty(int Index)
{
    local bool bReapplyLayout;

    switch (Index)
    {
        case 1:
            class'HxScoreBoard'.default.BoardAlignment = BoardAlignment;
            break;
        case 2:
            class'HxScoreBoard'.default.HeadingAlignment = HeadingAlignment;
            break;
        case 3:
            class'HxScoreBoard'.default.BorderSize = BorderSize;
            break;
        case 4:
            class'HxScoreBoard'.default.DividerSize = DividerSize;
            break;
        case 5:
            class'HxScoreBoard'.default.FontSizeModifier = FontSizeModifier;
            break;
        case 6:
            class'HxScoreBoard'.default.bAlternateRowColors = bAlternateRowColors;
            break;
        case 7:
            class'HxScoreBoard'.default.bCompactTeamScores = bCompactTeamScores;
            break;
        case 8:
            class'HxScoreBoard'.default.bShowSecondaryStats = bShowSecondaryStats;
            break;
        case 9:
            bReapplyLayout = true;
            class'HxScoreBoard'.default.bPreferVerticalLayout = bPreferVerticalLayout;
            break;
        case 10:
            class'HxScoreBoard'.default.bAbbreviateHeadings = bAbbreviateHeadings;
            break;
        case 11:
            class'HxScoreBoard'.default.bShowPlayerPortraits = bShowPlayerPortraits;
            break;
        case 12:
            class'HxScoreBoard'.default.bShowBotCallSigns = bShowBotCallSigns;
            break;
        case 13:
            class'HxScoreBoard'.default.bShowBotOrders = bShowBotOrders;
            break;
        case 14:
            class'HxScoreBoard'.default.bShowShortcuts = bShowShortcuts;
            break;
        case 15:
            class'HxScoreBoard'.default.bShowTimestamp = bShowTimestamp;
            break;
        case 16:
            class'HxScoreBoard'.default.HeaderColor = HeaderColor;
            break;
        case 17:
            class'HxTeamScoreBoard'.default.TeamHeaderColors[0] = RedTeamHeaderColor;
            break;
        case 18:
            class'HxTeamScoreBoard'.default.TeamHeaderColors[1] = BlueTeamHeaderColor;
            break;
        case 19:
            class'HxScoreBoard'.default.RowColor = RowColor;
            break;
        case 20:
            class'HxTeamScoreBoard'.default.TeamRowColors[0] = RedTeamRowColor;
            break;
        case 21:
            class'HxTeamScoreBoard'.default.TeamRowColors[1] = BlueTeamRowColor;
            break;
        case 22:
            class'HxScoreBoard'.default.AltRowColor = AltRowColor;
            break;
        case 23:
            class'HxTeamScoreBoard'.default.TeamAltRowColors[0] = RedTeamAltRowColor;
            break;
        case 24:
            class'HxTeamScoreBoard'.default.TeamAltRowColors[1] = BlueTeamAltRowColor;
            break;
        case 25:
            class'HxScoreBoard'.default.BorderColor = BorderColor;
            break;
        case 26:
            class'HxTeamScoreBoard'.default.TeamBorderColors[0] = RedTeamBorderColor;
            break;
        case 27:
            class'HxTeamScoreBoard'.default.TeamBorderColors[1] = BlueTeamBorderColor;
            break;
        case 28:
            class'HxScoreBoard'.default.DividerColor = DividerColor;
            break;
        case 29:
            class'HxTeamScoreBoard'.default.TeamDividerColors[0] = RedTeamDividerColor;
            break;
        case 30:
            class'HxTeamScoreBoard'.default.TeamDividerColors[1] = BlueTeamDividerColor;
            break;
        case 31:
            class'HxScoreBoard'.default.ScrollThumbColor = ScrollThumbColor;
            break;
        case 32:
            class'HxTeamScoreBoard'.default.TeamScrollThumbColors[0] = RedTeamScrollThumbColor;
            break;
        case 33:
            class'HxTeamScoreBoard'.default.TeamScrollThumbColors[1] = BlueTeamScrollThumbColor;
            break;
        case 34:
            class'HxTeamScoreBoard'.default.TeamColors[0] = RedTeamColor;
            break;
        case 35:
            class'HxTeamScoreBoard'.default.TeamColors[1] = BlueTeamColor;
            break;
        case 36:
            class'HxScoreBoard'.default.TextColor = TextColor;
            break;
        case 37:
            class'HxScoreBoard'.default.SecondTextColor = SecondTextColor;
            break;
        case 38:
            class'HxScoreBoard'.default.HighlightTextColor = HighlightTextColor;
            break;
        case 39:
            class'HxScoreBoard'.default.ReadyColor = ReadyColor;
            break;
        case 40:
            class'HxSBAssault'.default.ColumnConfigs = AssaultColumns;
            break;
        case 41:
            class'HxSBBombingRun'.default.ColumnConfigs = BombingRunColumns;
            break;
        case 42:
            class'HxSBCaptureTheFlag'.default.ColumnConfigs = CaptureTheFlagColumns;
            break;
        case 43:
            class'HxSBDeathMatch'.default.ColumnConfigs = DeathMatchColumns;
            break;
        case 44:
            class'HxSBDoubleDomination'.default.ColumnConfigs = DoubleDominationColumns;
            break;
        case 45:
            class'HxSBInvasion'.default.ColumnConfigs = InvasionColumns;
            break;
        case 46:
            class'HxSBLastManStanding'.default.ColumnConfigs = LastManStandingColumns;
            break;
        case 47:
            class'HxSBMutant'.default.ColumnConfigs = MutantColumns;
            break;
        case 48:
            class'HxSBOnslaught'.default.ColumnConfigs = OnslaughtColumns;
            break;
        case 49:
            class'HxSBTeamDeathMatch'.default.ColumnConfigs = TeamDeathMatchColumns;
            break;
    }
    UpdateScoreBoard(bReapplyLayout);
}

function bool ResetProperty(int Index)
{
    switch (Index)
    {
        case 0:
            bEnabled = default.bEnabled;
            return true;
        case 1:
            BoardAlignment = default.BoardAlignment;
            class'HxScoreBoard'.default.BoardAlignment = BoardAlignment;
            return true;
        case 2:
            HeadingAlignment = default.HeadingAlignment;
            class'HxScoreBoard'.default.HeadingAlignment = HeadingAlignment;
            return true;
        case 3:
            BorderSize = default.BorderSize;
            class'HxScoreBoard'.default.BorderSize = BorderSize;
            return true;
        case 4:
            DividerSize = default.DividerSize;
            class'HxScoreBoard'.default.DividerSize = DividerSize;
            return true;
        case 5:
            FontSizeModifier = default.FontSizeModifier;
            class'HxScoreBoard'.default.FontSizeModifier = FontSizeModifier;
            return true;
        case 6:
            bAlternateRowColors = default.bAlternateRowColors;
            class'HxScoreBoard'.default.bAlternateRowColors = bAlternateRowColors;
            return true;
        case 7:
            bCompactTeamScores = default.bCompactTeamScores;
            class'HxScoreBoard'.default.bCompactTeamScores = bCompactTeamScores;
            return true;
        case 8:
            bShowSecondaryStats = default.bShowSecondaryStats;
            class'HxScoreBoard'.default.bShowSecondaryStats = bShowSecondaryStats;
            return true;
        case 9:
            bPreferVerticalLayout = default.bPreferVerticalLayout;
            class'HxScoreBoard'.default.bPreferVerticalLayout = bPreferVerticalLayout;
            return true;
        case 10:
            bAbbreviateHeadings = default.bAbbreviateHeadings;
            class'HxScoreBoard'.default.bAbbreviateHeadings = bAbbreviateHeadings;
            return true;
        case 11:
            bShowPlayerPortraits = default.bShowPlayerPortraits;
            class'HxScoreBoard'.default.bAbbreviateHeadings = bAbbreviateHeadings;
            return true;
        case 12:
            bShowBotCallSigns = default.bShowBotCallSigns;
            class'HxScoreBoard'.default.bShowBotCallSigns = bShowBotCallSigns;
            return true;
        case 13:
            bShowBotOrders = default.bShowBotOrders;
            class'HxScoreBoard'.default.bShowBotOrders = bShowBotOrders;
            return true;
        case 14:
            bShowShortcuts = default.bShowShortcuts;
            class'HxScoreBoard'.default.bShowShortcuts = bShowShortcuts;
            return true;
        case 15:
            bShowTimestamp = default.bShowTimestamp;
            class'HxScoreBoard'.default.bShowTimestamp = bShowTimestamp;
            return true;
        case 16:
            HeaderColor = default.HeaderColor;
            class'HxScoreBoard'.default.HeaderColor = HeaderColor;
            return true;
        case 17:
            RedTeamHeaderColor = default.RedTeamHeaderColor;
            class'HxTeamScoreBoard'.default.TeamHeaderColors[0] = RedTeamHeaderColor;
            return true;
        case 18:
            BlueTeamHeaderColor = default.BlueTeamHeaderColor;
            class'HxTeamScoreBoard'.default.TeamHeaderColors[1] = BlueTeamHeaderColor;
            return true;
        case 19:
            RowColor = default.RowColor;
            class'HxScoreBoard'.default.RowColor = RowColor;
            return true;
        case 20:
            RedTeamRowColor = default.RedTeamRowColor;
            class'HxTeamScoreBoard'.default.TeamRowColors[0] = RedTeamRowColor;
            return true;
        case 21:
            BlueTeamRowColor = default.BlueTeamRowColor;
            class'HxTeamScoreBoard'.default.TeamRowColors[1] = BlueTeamRowColor;
            return true;
        case 22:
            AltRowColor = default.AltRowColor;
            class'HxScoreBoard'.default.AltRowColor = AltRowColor;
            return true;
        case 23:
            RedTeamAltRowColor = default.RedTeamAltRowColor;
            class'HxTeamScoreBoard'.default.TeamAltRowColors[0] = RedTeamAltRowColor;
            return true;
        case 24:
            BlueTeamAltRowColor = default.BlueTeamAltRowColor;
            class'HxTeamScoreBoard'.default.TeamAltRowColors[1] = BlueTeamAltRowColor;
            return true;
        case 25:
            BorderColor = default.BorderColor;
            class'HxScoreBoard'.default.BorderColor = BorderColor;
            return true;
        case 26:
            RedTeamBorderColor = default.RedTeamBorderColor;
            class'HxTeamScoreBoard'.default.TeamBorderColors[0] = RedTeamBorderColor;
            return true;
        case 27:
            BlueTeamBorderColor = default.BlueTeamBorderColor;
            class'HxTeamScoreBoard'.default.TeamBorderColors[1] = BlueTeamBorderColor;
            return true;
        case 28:
            DividerColor = default.DividerColor;
            class'HxScoreBoard'.default.DividerColor = DividerColor;
            return true;
        case 29:
            RedTeamDividerColor = default.RedTeamDividerColor;
            class'HxTeamScoreBoard'.default.TeamDividerColors[0] = RedTeamDividerColor;
            return true;
        case 30:
            BlueTeamDividerColor = default.BlueTeamDividerColor;
            class'HxTeamScoreBoard'.default.TeamDividerColors[1] = BlueTeamDividerColor;
            return true;
        case 31:
            ScrollThumbColor = default.ScrollThumbColor;
            class'HxScoreBoard'.default.ScrollThumbColor = ScrollThumbColor;
            return true;
        case 32:
            RedTeamScrollThumbColor = default.RedTeamScrollThumbColor;
            class'HxTeamScoreBoard'.default.TeamScrollThumbColors[0] = RedTeamScrollThumbColor;
            return true;
        case 33:
            BlueTeamScrollThumbColor = default.BlueTeamScrollThumbColor;
            class'HxTeamScoreBoard'.default.TeamScrollThumbColors[1] = BlueTeamScrollThumbColor;
            return true;
        case 34:
            RedTeamColor = default.RedTeamColor;
            class'HxTeamScoreBoard'.default.TeamColors[0] = RedTeamColor;
            return true;
        case 35:
            BlueTeamColor = default.BlueTeamColor;
            class'HxTeamScoreBoard'.default.TeamColors[1] = BlueTeamColor;
            return true;
        case 36:
            TextColor = default.TextColor;
            class'HxScoreBoard'.default.TextColor = TextColor;
            return true;
        case 37:
            SecondTextColor = default.SecondTextColor;
            class'HxScoreBoard'.default.SecondTextColor = SecondTextColor;
            return true;
        case 38:
            HighlightTextColor = default.HighlightTextColor;
            class'HxScoreBoard'.default.HighlightTextColor = HighlightTextColor;
            return true;
        case 39:
            ReadyColor = default.ReadyColor;
            class'HxScoreBoard'.default.ReadyColor = ReadyColor;
            return true;
        case 40:
            AssaultColumns = default.AssaultColumns;
            class'HxSBAssault'.default.ColumnConfigs = AssaultColumns;
            return true;
        case 41:
            BombingRunColumns = default.BombingRunColumns;
            class'HxSBBombingRun'.default.ColumnConfigs = BombingRunColumns;
            return true;
        case 42:
            CaptureTheFlagColumns = default.CaptureTheFlagColumns;
            class'HxSBCaptureTheFlag'.default.ColumnConfigs = CaptureTheFlagColumns;
            return true;
        case 43:
            DeathMatchColumns = default.DeathMatchColumns;
            class'HxSBDeathMatch'.default.ColumnConfigs = DeathMatchColumns;
            return true;
        case 44:
            DoubleDominationColumns = default.DoubleDominationColumns;
            class'HxSBDoubleDomination'.default.ColumnConfigs = DoubleDominationColumns;
            return true;
        case 45:
            InvasionColumns = default.InvasionColumns;
            class'HxSBInvasion'.default.ColumnConfigs = InvasionColumns;
            return true;
        case 46:
            LastManStandingColumns = default.LastManStandingColumns;
            class'HxSBLastManStanding'.default.ColumnConfigs = LastManStandingColumns;
            return true;
        case 47:
            MutantColumns = default.MutantColumns;
            class'HxSBMutant'.default.ColumnConfigs = MutantColumns;
            return true;
        case 48:
            OnslaughtColumns = default.OnslaughtColumns;
            class'HxSBOnslaught'.default.ColumnConfigs = OnslaughtColumns;
            return true;
        case 49:
            TeamDeathMatchColumns = default.TeamDeathMatchColumns;
            class'HxSBTeamDeathMatch'.default.ColumnConfigs = TeamDeathMatchColumns;
            return true;
    }
    return false;
}

function NotifyMutatorInfoReady()
{
    bAllowed = bool(MutatorInfo.Get("bAllowEnhancedScoreBoards"));
    UpdateScoreBoard();
}

function NotifyMutatorPropertyChanged(int Index)
{
    switch (MutatorInfo.GetName(Index))
    {
        case "bAllowEnhancedScoreBoards":
            bAllowed = bool(MutatorInfo.Get("bAllowEnhancedScoreBoards"));
            UpdateScoreBoard();
            break;
    }
}

function UpdateScoreBoard(optional bool bReapplyLayout)
{
    local PlayerController PC;

    if (Level != None)
    {
        PC = Level.GetLocalPlayerController();
        if (PC != None && PC.myHUD != None && PC.GameReplicationInfo != None)
        {
            if (bAllowed && bEnabled)
            {
                ReplaceScoreBoard(PC);
            }
            else
            {
                RestoreScoreBoard(PC);
            }
            if (PC.myHUD.ScoreBoard.IsA('HxScoreBoard'))
            {
                if (bReapplyLayout)
                {
                    HxScoreBoard(PC.MyHUD.ScoreBoard).ReapplyLayout();
                }
                HxScoreBoard(PC.MyHUD.ScoreBoard).Init();
            }
        }
    }
}

function ReplaceScoreBoard(PlayerController PC)
{
    if (!PC.myHUD.ScoreBoard.IsA('HxScoreBoard'))
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
        if (!PC.myHUD.ScoreBoard.IsA('HxScoreBoard'))
        {
            OriginalScoreBoardClass = None;
        }
    }
}

function RestoreScoreBoard(PlayerController PC)
{
    if (OriginalScoreBoardClass != None)
    {
        PC.MyHUD.SetScoreBoardClass(OriginalScoreBoardClass);
        OriginalScoreBoardClass = None;
    }
}

static function int GetGameTypeIndex(class<GameInfo> GameClass)
{
    local int i;

    if (GameClass != None)
    {
        for (i = 0; i < default.GameTypes.Length; ++i)
        {
            if (ClassIsChildOf(GameClass, default.GameTypes[i]))
            {
                return i;
            }
        }
    }
    return -1;
}

defaultproperties
{
    Properties(0)=(Name="bEnabled",Type=HX_PROPERTY_Bool)
    Properties(1)=(Name="BoardAlignment",Type=HX_PROPERTY_Enum,UpperLimit="3",EnumType=enum'EHxVertAlignment')
    Properties(2)=(Name="HeadingAlignment",Type=HX_PROPERTY_Enum,UpperLimit="3",EnumType=enum'EHxVertAlignment')
    Properties(3)=(Name="BorderSize",Type=HX_PROPERTY_Float,LowerLimit="0",UpperLimit="0.5");
    Properties(4)=(Name="DividerSize",Type=HX_PROPERTY_Float,LowerLimit="0",UpperLimit="0.5");
    Properties(5)=(Name="FontSizeModifier",Type=HX_PROPERTY_Int,LowerLimit="-2",UpperLimit="2")
    Properties(6)=(Name="bAlternateRowColors",Type=HX_PROPERTY_Bool)
    Properties(7)=(Name="bCompactTeamScores",Type=HX_PROPERTY_Bool)
    Properties(8)=(Name="bShowSecondaryStats",Type=HX_PROPERTY_Bool)
    Properties(9)=(Name="bPreferVerticalLayout",Type=HX_PROPERTY_Bool)
    Properties(10)=(Name="bAbbreviateHeadings",Type=HX_PROPERTY_Bool)
    Properties(11)=(Name="bShowPlayerPortraits",Type=HX_PROPERTY_Bool)
    Properties(12)=(Name="bShowBotCallSigns",Type=HX_PROPERTY_Bool)
    Properties(13)=(Name="bShowBotOrders",Type=HX_PROPERTY_Bool)
    Properties(14)=(Name="bShowShortcuts",Type=HX_PROPERTY_Bool)
    Properties(15)=(Name="bShowTimestamp",Type=HX_PROPERTY_Bool)
    Properties(16)=(Name="HeaderColor",Type=HX_PROPERTY_Color)
    Properties(17)=(Name="RedTeamHeaderColor",Type=HX_PROPERTY_Color)
    Properties(18)=(Name="BlueTeamHeaderColor",Type=HX_PROPERTY_Color)
    Properties(19)=(Name="RowColor",Type=HX_PROPERTY_Color)
    Properties(20)=(Name="RedTeamRowColor",Type=HX_PROPERTY_Color)
    Properties(21)=(Name="BlueTeamRowColor",Type=HX_PROPERTY_Color)
    Properties(22)=(Name="AltRowColor",Type=HX_PROPERTY_Color)
    Properties(23)=(Name="RedTeamAltRowColor",Type=HX_PROPERTY_Color)
    Properties(24)=(Name="BlueTeamAltRowColor",Type=HX_PROPERTY_Color)
    Properties(25)=(Name="BorderColor",Type=HX_PROPERTY_Color)
    Properties(26)=(Name="RedTeamBorderColor",Type=HX_PROPERTY_Color)
    Properties(27)=(Name="BlueTeamBorderColor",Type=HX_PROPERTY_Color)
    Properties(28)=(Name="DividerColor",Type=HX_PROPERTY_Color)
    Properties(29)=(Name="RedTeamDividerColor",Type=HX_PROPERTY_Color)
    Properties(30)=(Name="BlueTeamDividerColor",Type=HX_PROPERTY_Color)
    Properties(31)=(Name="ScrollThumbColor",Type=HX_PROPERTY_Color)
    Properties(32)=(Name="RedTeamScrollThumbColor",Type=HX_PROPERTY_Color)
    Properties(33)=(Name="BlueTeamScrollThumbColor",Type=HX_PROPERTY_Color)
    Properties(34)=(Name="RedTeamColor",Type=HX_PROPERTY_Color)
    Properties(35)=(Name="BlueTeamColor",Type=HX_PROPERTY_Color)
    Properties(36)=(Name="TextColor",Type=HX_PROPERTY_Color)
    Properties(37)=(Name="SecondTextColor",Type=HX_PROPERTY_Color)
    Properties(38)=(Name="HighlightTextColor",Type=HX_PROPERTY_Color)
    Properties(39)=(Name="ReadyColor",Type=HX_PROPERTY_Color)
    Properties(40)=(Name="AssaultColumns",Type=Hx_PROPERTY_Array);
    Properties(41)=(Name="BombingRunColumns",Type=Hx_PROPERTY_Array);
    Properties(42)=(Name="CaptureTheFlagColumns",Type=Hx_PROPERTY_Array);
    Properties(43)=(Name="DeathMatchColumns",Type=Hx_PROPERTY_Array);
    Properties(44)=(Name="DoubleDominationColumns",Type=Hx_PROPERTY_Array);
    Properties(45)=(Name="InvasionColumns",Type=Hx_PROPERTY_Array);
    Properties(46)=(Name="LastManStandingColumns",Type=Hx_PROPERTY_Array);
    Properties(47)=(Name="MutantColumns",Type=Hx_PROPERTY_Array);
    Properties(48)=(Name="OnslaughtColumns",Type=Hx_PROPERTY_Array);
    Properties(49)=(Name="TeamDeathMatchColumns",Type=Hx_PROPERTY_Array);

    bEnabled=true
    BoardAlignment=HX_VALIGN_Top
    HeadingAlignment=HX_VALIGN_Center
    BorderSize=0.25
    DividerSize=0.2
    FontSizeModifier=0
    bAlternateRowColors=false
    bCompactTeamScores=false
    bShowSecondaryStats=false
    bPreferVerticalLayout=false
    bAbbreviateHeadings=false
    bShowPlayerPortraits=true
    bShowBotCallSigns=false
    bShowBotOrders=true
    bShowShortcuts=true
    bShowTimestamp=true
    HeaderColor=(R=0,G=0,B=20,A=196)
    RedTeamHeaderColor=(R=42,G=0,B=0,A=196)
    BlueTeamHeaderColor=(R=0,G=0,B=42,A=196)
    RowColor=(R=130,G=130,B=140,A=142)
    RedTeamRowColor=(R=160,G=100,B=100,A=142)
    BlueTeamRowColor=(R=100,G=100,B=160,A=142)
    AltRowColor=(R=100,G=100,B=110,A=112)
    RedTeamAltRowColor=(R=140,G=80,B=80,A=112)
    BlueTeamAltRowColor=(R=80,G=80,B=140,A=112)
    BorderColor=(R=220,G=220,B=230,A=220)
    RedTeamBorderColor=(R=255,G=160,B=160,A=220)
    BlueTeamBorderColor=(R=160,G=160,B=255,A=220)
    DividerColor=(R=220,G=220,B=230,A=172)
    RedTeamDividerColor=(R=255,G=160,B=160,A=172)
    BlueTeamDividerColor=(R=160,G=160,B=255,A=172)
    ScrollThumbColor=(R=220,G=220,B=230,A=172)
    RedTeamScrollThumbColor=(R=255,G=160,B=160,A=172)
    BlueTeamScrollThumbColor=(R=160,G=160,B=255,A=172)
    RedTeamColor=(R=255,G=120,B=120,A=255)
    BlueTeamColor=(R=120,G=120,B=255,A=255)
    TextColor=(R=255,G=255,B=255,A=255)
    SecondTextColor=(R=200,G=210,B=220,A=255)
    HighlightTextColor=(R=255,G=255,B=0,A=255)
    ReadyColor=(R=64,G=255,B=64,A=255)
    AssaultColumns(0)=(MainStat=HX_SBS_Score)
    AssaultColumns(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    AssaultColumns(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_TeamKills)
    AssaultColumns(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    AssaultColumns(4)=(MainStat=HX_SBS_Rank)
    BombingRunColumns(0)=(MainStat=HX_SBS_Score)
    BombingRunColumns(1)=(MainStat=HX_SBS_Goals,SecStat=HX_SBS_Touches)
    BombingRunColumns(2)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    BombingRunColumns(3)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_TeamKills)
    BombingRunColumns(4)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    BombingRunColumns(5)=(MainStat=HX_SBS_Rank)
    CaptureTheFlagColumns(0)=(MainStat=HX_SBS_Score)
    CaptureTheFlagColumns(1)=(MainStat=HX_SBS_Captures,SecStat=HX_SBS_Touches)
    CaptureTheFlagColumns(2)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    CaptureTheFlagColumns(3)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_TeamKills)
    CaptureTheFlagColumns(4)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    CaptureTheFlagColumns(5)=(MainStat=HX_SBS_Rank)
    DeathMatchColumns(0)=(MainStat=HX_SBS_Score)
    DeathMatchColumns(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    DeathMatchColumns(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_Suicides)
    DeathMatchColumns(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    DeathMatchColumns(4)=(MainStat=HX_SBS_Rank)
    DoubleDominationColumns(0)=(MainStat=HX_SBS_Score)
    DoubleDominationColumns(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    DoubleDominationColumns(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_TeamKills)
    DoubleDominationColumns(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    DoubleDominationColumns(4)=(MainStat=HX_SBS_Rank)
    InvasionColumns(0)=(MainStat=HX_SBS_Score)
    InvasionColumns(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    InvasionColumns(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_Suicides)
    InvasionColumns(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    InvasionColumns(4)=(MainStat=HX_SBS_Rank)
    LastManStandingColumns(0)=(MainStat=HX_SBS_Lives)
    LastManStandingColumns(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    LastManStandingColumns(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_Suicides)
    LastManStandingColumns(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    LastManStandingColumns(4)=(MainStat=HX_SBS_Rank)
    MutantColumns(0)=(MainStat=HX_SBS_Score)
    MutantColumns(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    MutantColumns(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_Suicides)
    MutantColumns(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    MutantColumns(4)=(MainStat=HX_SBS_Rank)
    OnslaughtColumns(0)=(MainStat=HX_SBS_Score)
    OnslaughtColumns(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    OnslaughtColumns(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_TeamKills)
    OnslaughtColumns(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    OnslaughtColumns(4)=(MainStat=HX_SBS_Rank)
    TeamDeathMatchColumns(0)=(MainStat=HX_SBS_Score)
    TeamDeathMatchColumns(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    TeamDeathMatchColumns(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_TeamKills)
    TeamDeathMatchColumns(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    TeamDeathMatchColumns(4)=(MainStat=HX_SBS_Rank)
    GameTypes(0)=class'ASGameInfo'
    GameTypes(1)=class'xBombingRun'
    GameTypes(2)=class'xCTFGame'
    GameTypes(3)=class'xDeathMatch'
    GameTypes(4)=class'xDoubleDom'
    GameTypes(5)=class'Invasion'
    GameTypes(6)=class'xLastManStandingGame'
    GameTypes(7)=class'xMutantGame'
    GameTypes(8)=class'ONSOnslaughtGame'
    GameTypes(9)=class'xTeamGame'
}
