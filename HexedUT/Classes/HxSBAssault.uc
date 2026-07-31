class HxSBAssault extends HxTeamScoreBoard;

var private int TrophySize;

simulated function DrawRow(Canvas C, int Table, int Index, int Row, int Top)
{
    Super.DrawRow(C, Table, Index, Row, Top);
    DrawTrophies(C, ASPlayerReplicationInfo(Tables[Table].PRIs[Index]), Top);
}

simulated function DrawTrophies(Canvas C, ASPlayerReplicationInfo ASPRI, int Top)
{
    local Color PreviousColor;
    local int Left;

    if (ASPRI == None)
    {
        return;
    }
    PreviousColor = C.DrawColor;
    C.DrawColor = TextColor;
    C.Font = TinyFont;
    Left = ColumnLefts[PlayerColumn + 1];
    if (ASPRI.DestroyedVehicles > 0)
    {
        Left -= TrophySize;
        DrawTrophyTexture(C, Texture'HudContent.Generic.HUD', Left, Top, 226, 400, 55, 50);
        if (ASPRI.DestroyedVehicles > 1)
        {
            C.DrawColor = TextColor;
            DrawTextCentered(
                C, ASPRI.DestroyedVehicles, TXTA_Center, Left, Top, TrophySize, RowHeight);
        }
    }
    if (ASPRI.DisabledObjectivesCount > 0)
    {
        Left -= TrophySize;
        DrawTrophyIcon(C, Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Final', Left, Top);
        if (ASPRI.DisabledObjectivesCount > 1)
        {
            C.DrawColor = TextColor;
            DrawTextCentered(
                C, ASPRI.DisabledObjectivesCount, TXTA_Center, Left, Top, TrophySize, RowHeight);
        }
    }
    if (ASPRI.DisabledFinalObjective > 0)
    {
        Left -= TrophySize;
        DrawTrophyIcon(C, Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Single', Left, Top);
        if (ASPRI.DisabledFinalObjective > 1)
        {
            C.DrawColor = TextColor;
            DrawTextCentered(
                C, ASPRI.DisabledFinalObjective, TXTA_Center, Left, Top, TrophySize, RowHeight);
        }
    }
    C.DrawColor = PreviousColor;
}

simulated final function DrawTrophyIcon(Canvas C, Material Icon, float Left, float Top)
{
    C.DrawColor = HUDClass.default.WhiteColor;
    C.SetPos(C.OrgX + Left, C.OrgY + Top);
    C.DrawTileJustified(Icon, 1, TrophySize, RowHeight);
}

simulated final function DrawTrophyTexture(Canvas C,
                                           Texture Texture,
                                           float Left,
                                           float Top,
                                           float U,
                                           float V,
                                           float UL,
                                           float VL)
{
    C.DrawColor = HUDClass.default.WhiteColor;
    C.CurX = Left;
    C.CurY = Top + (RowHeight - TrophySize) / 2.0;
    C.DrawTile(Texture, TrophySize, TrophySize, U, V, UL, VL);
}

simulated function UpdateExtraSizes(Canvas C)
{
    local float TextWidth;
    local float TextHeight;

    Super.UpdateExtraSizes(C);
    C.Font = SmallFont;
    C.TextSize("999", TextWidth, TextHeight);
    TrophySize = Min(RowHeight, (TextWidth + 1) & ~1);
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

simulated function HxSBColumnConfig GetPlayerColumnConfig()
{
    local HxSBColumnConfig Config;

    Config = Super.GetPlayerColumnConfig();
    Config.MinWidthValue $= "99999";
    return Config;
}

defaultproperties
{
    ColumnTypes(4)=HX_SBCOL_FragsAndEfficiency
    ColumnTypes(5)=HX_SBCOL_DeathsAndSuicides
    ColumnTypes(6)=HX_SBCOL_PingAndLoss
    ColumnTypes(7)=HX_SBCOL_PPHAndTime
}
