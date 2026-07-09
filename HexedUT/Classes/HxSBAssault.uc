class HxSBAssault extends HxTeamScoreBoard;

simulated function ConfigureColumns()
{
    Columns[Columns.Length] = GetPositionColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetPlayerColumnConfig();
    Alignments[Alignments.Length] = TXTA_Left;
    Columns[Columns.Length] = GetTrophyColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetTrophyColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetTrophyColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetScoreColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetFragsColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetDeathsColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetPingColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetPPHColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
}

simulated function DrawRow(Canvas C, int Table, int Index, int Row, int Top)
{
    DrawPlayerPosition(C, Table, Index, 0, Top);
    DrawPlayerName(C, Table, Index, 1, Top);
    DrawTrophies(C, ASPlayerReplicationInfo(Tables[Table].PRIs[Index]), 4, Top);
    C.Font = MediumFont;
    DrawTextCell(C, int(Tables[Table].PRIs[Index].Score), 5, Top);
    DrawPlayerFrags(C, Table, Index, 6, Top);
    DrawPlayerDeaths(C, Table, Index, 7, Top);
    DrawPlayerPing(C, Table, Index, 8, Top);
    DrawPlayerPPH(C, Table, Index, 9, Top);
}

simulated function DrawTrophies(Canvas C, ASPlayerReplicationInfo ASPRI, int Column, int Top)
{
    local Color PreviousColor;

    if (ASPRI == None)
    {
        return;
    }
    PreviousColor = C.DrawColor;
    C.DrawColor = TextColor;
    C.Font = SmallFont;
    if (ASPRI.DestroyedVehicles > 0)
    {
        DrawTextureCell(C, Texture'HudContent.Generic.HUD', Column, Top, 227, 404, 53, 42);
        if (ASPRI.DestroyedVehicles > 1)
        {
            DrawTextCell(C, ASPRI.DestroyedVehicles, Column, Top);
        }
        --Column;
    }
    if (ASPRI.DisabledObjectivesCount > 0)
    {
        DrawIconCell(C, Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Final', Column, Top);
        if (ASPRI.DisabledObjectivesCount > 1)
        {
            DrawTextCell(C, ASPRI.DisabledObjectivesCount, Column, Top);
        }
        --Column;
    }
    if (ASPRI.DisabledFinalObjective > 0)
    if (true)
    {
        DrawIconCell(C, Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Single', Column, Top);
        if (ASPRI.DisabledFinalObjective > 1)
        {
            DrawTextCell(C, ASPRI.DisabledFinalObjective, Column, Top);
        }
        --Column;
    }
    C.DrawColor = PreviousColor;
}

function string GetTitleText()
{
    if (OwnerTable > -1)
    {
        if (OwnerTable == int(ASGameReplicationInfo(GRI).bTeamZeroIsAttacking))
        {
            return Super.GetTitleText()@class'ScoreBoard_Assault'.default.Defender;
        }
        return Super.GetTitleText()@class'ScoreBoard_Assault'.default.Attacker;
    }
    return Super.GetTitleText();
}

simulated function bool GetStatusText(out string StatusText)
{
    local ASGameReplicationInfo ASGRI;

    ASGRI = ASGameReplicationInfo(GRI);
    if (ASGRI.RoundWinner != ERW_None)
    {
        StatusText = ASGRI.GetRoundWinnerString();
        return true;
    }
    if (PC.IsDead())
    {
        if (ASPlayerReplicationInfo(PC.PlayerReplicationInfo).bAutoRespawn
            && !PC.IsInState('PlayerWaiting'))
        {
            StatusText = class'ScoreBoard_Assault'.default.AutoRespawn@ASGRI.ReinforcementCountDown;
            return true;
        }
        if (ASGRI.ReinforcementCountDown > 0 && !PC.IsInState('PlayerWaiting'))
        {
            StatusText = class'ScoreBoard_Assault'.default.WaitForReinforcements
                @ASGRI.ReinforcementCountDown;
            return true;
        }
    }
    return Super.GetStatusText(StatusText);
}

simulated function string GetLevelInfoText()
{
    local ASGameReplicationInfo ASGRI;
    local string LevelInfoText;
    local int RemainingTime;

    ASGRI = ASGameReplicationInfo(GRI);
    if (ASGRI.RoundTimeLimit > 0 && ASGRI.RoundWinner == ERW_None)
    {
        RemainingTime = Max(0, ASGRI.RoundTimeLimit - ASGRI.RoundStartTime + ASGRI.RemainingTime);
        LevelInfoText = class'ScoreBoard_Assault'.default.RemainingRoundTime
            @FormatTime(RemainingTime)$SpacerText;
    }
    return LevelInfoText$class'ScoreBoard_Assault'.default.CurrentRound@ASGRI.CurrentRound
        $class'ScoreBoard_Assault'.default.RoundSeparator$ASGRI.MaxRounds;
}

simulated function HxSBColumnConfig GetTrophyColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.MinWidthValue = "9";
    Config.MaxWidthValue = "99";
    Config.bSmall = true;
    return Config;
}

defaultproperties
{
}
