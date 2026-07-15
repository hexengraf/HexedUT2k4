class HxTeamScoreBoard extends HxScoreBoard
    abstract;

var Color TeamHeaderColors[2];
var Color TeamRowColors[2];
var Color TeamAltRowColors[2];
var Color TeamBorderColors[2];
var Color TeamDividerColors[2];
var Color TeamScrollThumbColors[2];
var Color TeamColors[2];

var protected int OwnerTable;
var private int BannerWidth;
var private int BannerHeight;
var private int IconSize;
var private int IconPadding;
var private float ScorePadding;
var private bool bDrawSymbols;

simulated function Init()
{
    TeamHeaderColors[0] = class'HxTeamScoreBoard'.default.TeamHeaderColors[0];
    TeamHeaderColors[1] = class'HxTeamScoreBoard'.default.TeamHeaderColors[1];
    TeamRowColors[0] = class'HxTeamScoreBoard'.default.TeamRowColors[0];
    TeamRowColors[1] = class'HxTeamScoreBoard'.default.TeamRowColors[1];
    TeamAltRowColors[0] = class'HxTeamScoreBoard'.default.TeamAltRowColors[0];
    TeamAltRowColors[1] = class'HxTeamScoreBoard'.default.TeamAltRowColors[1];
    TeamBorderColors[0] = class'HxTeamScoreBoard'.default.TeamBorderColors[0];
    TeamBorderColors[1] = class'HxTeamScoreBoard'.default.TeamBorderColors[1];
    TeamDividerColors[0] = class'HxTeamScoreBoard'.default.TeamDividerColors[0];
    TeamDividerColors[1] = class'HxTeamScoreBoard'.default.TeamDividerColors[1];
    TeamScrollThumbColors[0] = class'HxTeamScoreBoard'.default.TeamScrollThumbColors[0];
    TeamScrollThumbColors[1] = class'HxTeamScoreBoard'.default.TeamScrollThumbColors[1];
    TeamColors[0] = class'HxTeamScoreBoard'.default.TeamColors[0];
    TeamColors[1] = class'HxTeamScoreBoard'.default.TeamColors[1];
    Super.Init();
}

simulated function DrawTables(Canvas C, int TableHeight)
{
    if (TeamScoreStyle == HX_SB_TSCORE_FullSize)
    {
        if (bVerticalLayout)
        {
            C.Font = ScoreFont;
            DrawTeamScoreSide(C, 0, 0);
            DrawTeamScoreSide(C, 1, BannerHeight + OuterSpacing);
        }
        else
        {
            C.Font = ScoreFont;
            DrawTeamScoreTop(C, 0, TableWidth - BannerWidth);
            DrawTeamScoreTop(C, 1, TableWidth + OuterSpacing);
        }
    }
    Super.DrawTables(C, TableHeight);
}

simulated function DrawHeadings(Canvas C, int Table)
{
    Super.DrawHeadings(C, Table);
    if (TeamScoreStyle == HX_SB_TSCORE_Compact)
    {
        C.DrawColor = TeamColors[Table];
        C.CurX = C.OrgX + IconPadding;
        C.CurY = C.OrgY + IconPadding;
        C.DrawTileJustified(GRI.TeamSymbols[Table], 1, IconSize, IconSize);
        C.CurX = ColumnLefts[1];
        C.CurY = ScorePadding;
        C.Font = MediumFont;
        C.DrawTextClipped(Repl(TeamNameLabels[Table], "%", Tables[Table].PRIs.Length));
        C.CurX = ColumnLefts[1];
        C.CurY = ScorePadding + MediumFontHeight;
        C.Font = BigFont;
        C.DrawTextClipped(string(int(GRI.Teams[Table].Score)));
    }
}

simulated function SetTableColors(int Table)
{
    HeaderColor = TeamHeaderColors[Table];
    RowColor = TeamRowColors[Table];
    AltRowColor = TeamAltRowColors[Table];
    BorderColor = TeamBorderColors[Table];
    DividerColor = TeamDividerColors[Table];
    ScrollThumbColor = TeamScrollThumbColors[Table];
}

simulated function DrawTeamScoreTop(Canvas C, int Team, int Left)
{
    local string Score;

    if (Border > 0)
    {
        C.DrawColor = TeamBorderColors[Team];
        DrawBorder(C, Left, 0, BannerWidth, BannerHeight);
    }
    C.DrawColor = TeamHeaderColors[Team];
    DrawBox(C, Left, 0, BannerWidth, BannerHeight);
    C.DrawColor = TeamColors[Team];
    Score = string(int(GRI.Teams[Team].Score));
    C.CurY = (BannerHeight - ScoreFontHeight) / 2 + ScoreFontHeight * 0.05;
    if (Team == 1)
    {
        DrawTextClipped(C, Score, TXTA_Left, Left + ScorePadding, BannerWidth - ScorePadding);
        C.CurX = C.OrgX + Left + BannerWidth - IconSize - IconPadding;
    }
    else
    {
        DrawTextClipped(C, Score, TXTA_Right, Left, BannerWidth - ScorePadding);
        C.CurX = C.OrgX + Left + IconPadding;
    }
    if (bDrawSymbols)
    {
        C.CurY = C.OrgY + (BannerHeight - IconSize) / 2;
        C.DrawTileJustified(GRI.TeamSymbols[Team], 1, IconSize, IconSize);
    }
}

simulated function DrawTeamScoreSide(Canvas C, int Team, int Top)
{
    local string Score;

    if (Border > 0)
    {
        C.DrawColor = TeamBorderColors[Team];
        DrawBorder(C, 0, Top, BannerWidth, BannerHeight);
    }
    C.DrawColor = TeamHeaderColors[Team];
    DrawBox(C, 0, Top, BannerWidth, BannerHeight);
    C.DrawColor = TeamColors[Team];
    Score = string(int(GRI.Teams[Team].Score));
    if (bDrawSymbols)
    {
        if (Team == 0)
        {
            C.CurY = Top + BannerHeight - ScorePadding - ScoreFontHeight;
            DrawTextClipped(C, Score, TXTA_Center, 0, BannerWidth);
            C.CurY = C.OrgY + Top + IconPadding;
        }
        else
        {
            C.CurY = Top + ScorePadding + ScoreFontHeight * 0.09;
            DrawTextClipped(C, Score, TXTA_Center, 0, BannerWidth);
            C.CurY = C.OrgY + Top + BannerHeight - IconSize - IconPadding;
        }
        C.CurX = C.OrgX + (BannerWidth - IconSize) / 2;
        C.DrawTileJustified(GRI.TeamSymbols[Team], 1, IconSize, IconSize);
    }
    else
    {
        C.CurY = Top + ScorePadding;
        DrawTextClipped(C, Score, TXTA_Center, 0, BannerWidth);
    }
}

simulated function DrawPlayerName(Canvas C, int Table, int Index, int Column, int Top)
{
    if (Table == OwnerTable)
    {
        DrawTeamPlayerName(C, Table, Index, Column, Top);
    }
    else
    {
        Super.DrawPlayerName(C, Table, Index, Column, Top);
    }
}

simulated function UpdateTablePaddings(Canvas C)
{
    if (TeamScoreStyle == HX_SB_TSCORE_Compact)
    {
        TableLeftPadding = 0;
        TableTopPadding = 0;
    }
    else if (bVerticalLayout)
    {
        BannerWidth = (ScoreFontHeight * 2.5 + 1) & ~1;
        TableLeftPadding = BannerWidth + OuterSpacing;
        TableTopPadding = 0;
    }
    else
    {
        BannerHeight = (ScoreFontHeight * 1.75 + 1) & ~1;
        TableLeftPadding = 0;
        TableTopPadding = BannerHeight + OuterSpacing;
    }
}

simulated function UpdateExtraSizes(Canvas C)
{
    if (TeamScoreStyle == HX_SB_TSCORE_Compact)
    {
        HeaderHeight = Max(HeaderHeight, ColumnWidths[0]);
        IconSize = (HeaderHeight * 0.8 + 1) & ~1;
        IconPadding = (HeaderHeight - IconSize) / 2;
        ScorePadding = FMax(
            0, (SmallRowPadding + HeaderHeight - MediumFontHeight - BigFontHeight) / 2);
    }
    else if (bVerticalLayout)
    {
        IconSize = (BannerWidth * 0.65 + 1) & ~1;
    }
    else
    {
        BannerWidth = Min(TableWidth, (BannerHeight + ScoreFontHeight * 4.5 + 1) & ~1);
        IconSize = (BannerHeight * 0.9 + 1) & ~1;
        IconPadding = (BannerHeight - IconSize) / 2;
        ScorePadding = ScoreFontHeight / 2;
        bDrawSymbols = true;
    }
}

simulated function UpdateVisibleRows(Canvas C)
{
    local float MinimumHeight;

    Super.UpdateVisibleRows(C);
    if (TeamScoreStyle == HX_SB_TSCORE_FullSize && bVerticalLayout)
    {
        IconPadding = (BannerWidth - IconSize) / 3;
        ScorePadding = ScoreFontHeight / 3;
        MinimumHeight = IconSize + IconPadding * 2 - HeaderHeight + ScoreFontHeight + ScorePadding;
        BannerHeight = HeaderHeight + VisibleRows * FullRowHeight;
        bDrawSymbols = VisibleRows >= Max(0, Ceil(MinimumHeight / FullRowHeight));
        if (!bDrawSymbols)
        {
            IconPadding = 0;
            ScorePadding = (BannerHeight - ScoreFontHeight) / 2 + ScoreFontHeight * 0.065;
        }
    }
}

simulated function UpdatePRIs()
{
    Super.UpdatePRIs();
    if (PC.PlayerReplicationInfo != None)
    {
        if (PC.PlayerReplicationInfo.bOnlySpectator)
        {
            OwnerTable = -1;
        }
        else if (PC.PlayerReplicationInfo.Team != None)
        {
            OwnerTable = PC.PlayerReplicationInfo.Team.TeamIndex;
        }
    }
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

defaultproperties
{
    Tables(0)=(TeamIndex=0)
    Tables(1)=(TeamIndex=1)
    bShowBotCallSigns=false
    bShowBotOrders=true
    TeamHeaderColors(0)=(R=42,G=0,B=0,A=196)
    TeamHeaderColors(1)=(R=0,G=0,B=42,A=196)
    TeamRowColors(0)=(R=160,G=100,B=100,A=142)
    TeamRowColors(1)=(R=100,G=100,B=160,A=142)
    TeamAltRowColors(0)=(R=140,G=80,B=80,A=112)
    TeamAltRowColors(1)=(R=80,G=80,B=140,A=112)
    TeamBorderColors(0)=(R=255,G=160,B=160,A=220)
    TeamBorderColors(1)=(R=160,G=160,B=255,A=220)
    TeamDividerColors(0)=(R=255,G=160,B=160,A=172)
    TeamDividerColors(1)=(R=160,G=160,B=255,A=172)
    TeamScrollThumbColors(0)=(R=255,G=160,B=160,A=172)
    TeamScrollThumbColors(1)=(R=160,G=160,B=255,A=172)
    TeamColors(0)=(R=255,G=120,B=120,A=255)
    TeamColors(1)=(R=120,G=120,B=255,A=255)
    OwnerTable=-1
}
