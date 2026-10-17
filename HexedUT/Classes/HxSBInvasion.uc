class HxSBInvasion extends HxScoreBoard;

var localized string TotalScoreLabel;

var protected int TotalScoreWidth;
var protected int TotalScoreHeight;

simulated function LoadDefaults()
{
    Super.LoadDefaults();
    ColumnConfigs = class'HxSBInvasion'.default.ColumnConfigs;
}

simulated function InitializeColumns()
{
    Columns[Columns.Length] = GetOutOfLivesColumnDefinition();
    Alignments[Alignments.Length] = TXTA_Center;
    Super.InitializeColumns();
}

simulated function DrawTables(Canvas C, int TableHeight)
{
    local int Left;

    if (!bCompactTeamScores)
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
    if (bCompactTeamScores)
    {
        C.DrawColor = HighlightTextColor;
        C.Font = MediumFont;
        DrawTextCell(C, TotalScoreLabel$int(GRI.Teams[0].Score), PlayerColumn, 0);
    }
}

simulated function DrawReservedColumn(Canvas C, int Table, int Index, int Column, int Top)
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

    if (!bCompactTeamScores)
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

simulated function HxSBColumnDefinition GetPlayerColumnDefinition()
{
    local HxSBColumnDefinition Def;

    Def = Super.GetPlayerColumnDefinition();
    if (bCompactTeamScores)
    {
        Def.Headings[0] = "";
    }
    return Def;
}

simulated function HxSBColumnDefinition GetOutOfLivesColumnDefinition()
{
    local HxSBColumnDefinition Def;

    Def.Types[0] = HX_SBS_Reserved;
    Def.MinWidthValues[0] = class'ScoreboardInvasion'.default.OutText;
    return Def;
}

defaultproperties
{
    ColumnConfigs(0)=(MainStat=HX_SBS_Score)
    ColumnConfigs(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    ColumnConfigs(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_Suicides)
    ColumnConfigs(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    ColumnConfigs(4)=(MainStat=HX_SBS_Rank)
    TotalScoreLabel="TOTAL SCORE: "
}
