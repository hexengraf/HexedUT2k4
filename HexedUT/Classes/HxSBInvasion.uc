class HxSBInvasion extends HxScoreBoard;

var localized string TotalScoreLabel;

var protected int TotalScoreWidth;
var protected int TotalScoreHeight;

simulated function DrawTables(Canvas C, int TableHeight)
{
    local int Left;

    if (TeamScoreStyle == HX_SB_TSCORE_FullSize)
    {
        Left = (C.ClipX - TotalScoreWidth) / 2;
        if (Border > 0)
        {
            C.DrawColor = BorderColor;
            DrawBorder(C, Left, 0, TotalScoreWidth, TotalScoreHeight);
        }
        C.DrawColor = HeaderColor;
        DrawBox(C, Left, 0, TotalScoreWidth, TotalScoreHeight);
        C.DrawColor = HighlightTextColor;
        C.Font = MediumFont;
        DrawTextCentered(
            C,
            TotalScoreLabel$int(GRI.Teams[0].Score),
            TXTA_Center,
            Left,
            0,
            TotalScoreWidth,
            RowHeight);
    }
    Super.DrawTables(C, TableHeight);
}

simulated function DrawHeadings(Canvas C, int Table)
{
    Super.DrawHeadings(C, Table);
    if (TeamScoreStyle == HX_SB_TSCORE_Compact)
    {
        C.DrawColor = HighlightTextColor;
        C.Font = MediumFont;
        DrawTextCell(C, TotalScoreLabel$int(GRI.Teams[0].Score), PlayerColumn, 0);
    }
}

simulated function DrawPlayerLives(Canvas C, int Table, int Index, int Column, int Top)
{
    C.Font = MediumFont;
    if (Tables[Table].PRIs[Index].bOutOfLives)
    {
        DrawTextCell(C, class'ScoreBoardDeathMatch'.default.OutText, Column, Top);
    }
}

simulated function UpdateTablePaddings(Canvas C)
{
    local float TextWidth;
    local float TextHeight;

    if (TeamScoreStyle == HX_SB_TSCORE_FullSize)
    {
        C.Font = MediumFont;
        C.StrLen(TotalScoreLabel$"99999999", TextWidth, TextHeight);
        TotalScoreWidth = (TextWidth * 1.2 + 1) & ~1;
        TotalScoreHeight = RowHeight;
        TableTopPadding = TotalScoreHeight + OuterSpacing;
    }
}

simulated function string GetTitleText()
{
    local InvasionGameReplicationInfo GameInfo;

    GameInfo = InvasionGameReplicationInfo(GRI);
    return class'ScoreboardInvasion'.default.SkillLevel[Clamp(GameInfo.BaseDifficulty, 0, 7)]
        @GRI.GameName
        @class'ScoreboardInvasion'.default.WaveString
        @(GameInfo.WaveNumber + 1)
        $class'ScoreboardInvasion'.default.MapName
        $Level.Title;
}

simulated function HxSBColumnConfig GetPlayerColumnConfig()
{
    local HxSBColumnConfig Config;

    Config = Super.GetPlayerColumnConfig();
    if (TeamScoreStyle == HX_SB_TSCORE_Compact)
    {
        Config.Heading = "";
    }
    return Config;
}

simulated function HxSBColumnConfig GetLivesColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_Lives;
    Config.MinWidthValue = class'ScoreboardInvasion'.default.OutText;
    return Config;
}

defaultproperties
{
    ColumnTypes(3)=HX_SBCOL_Lives
    ColumnTypes(4)=HX_SBCOL_Score
    ColumnTypes(5)=HX_SBCOL_FragsAndEfficiency
    ColumnTypes(6)=HX_SBCOL_DeathsAndSuicides
    ColumnTypes(7)=HX_SBCOL_PingAndLoss
    ColumnTypes(8)=HX_SBCOL_PPHAndTime
    TotalScoreLabel="TOTAL SCORE: "
}
