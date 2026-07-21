class HxSBInvasion extends HxScoreBoard;

var localized string TotalScoreLabel;

var protected int TotalScoreWidth;
var protected int TotalScoreHeight;

simulated function ConfigureColumns()
{
    Columns[Columns.Length] = GetPositionColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetPlayerColumnConfig();
    Alignments[Alignments.Length] = TXTA_Left;
    Columns[Columns.Length] = GetOutColumnConfig();
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

simulated function DrawRow(Canvas C, int Table, int Index, int Row, int Top)
{
    DrawPlayerPosition(C, Table, Index, 0, Top);
    DrawTeamPlayerName(C, Table, Index, 1, Top);
    C.Font = MediumFont;
    if (Tables[Table].PRIs[Index].bOutOfLives)
    {
        DrawTextCell(C, class'ScoreboardInvasion'.default.OutText, 2, Top);
    }
    DrawTextCell(C, int(Tables[Table].PRIs[Index].Score), 3, Top);
    DrawPlayerFrags(C, Table, Index, 4, Top);
    DrawPlayerDeaths(C, Table, Index, 5, Top);
    DrawPlayerPing(C, Table, Index, 6, Top);
    DrawPlayerPPH(C, Table, Index, 7, Top);
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

simulated function HxSBColumnConfig GetOutColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.MinWidthValue = class'ScoreboardInvasion'.default.OutText;
    return Config;
}

defaultproperties
{
    TotalScoreLabel="TOTAL SCORE: "
}
