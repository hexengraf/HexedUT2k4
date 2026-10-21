class HxScoreBoard extends ScoreBoard
    abstract;

enum EHxSBStatType
{
    HX_SBS_None,
    HX_SBS_Score,
    HX_SBS_Frags,
    HX_SBS_Deaths,
    HX_SBS_Lives,
    HX_SBS_TeamKills,
    HX_SBS_Suicides,
    HX_SBS_Goals,
    HX_SBS_Captures,
    HX_SBS_Touches,
    HX_SBS_MaxSpree,
    HX_SBS_Accuracy,
    HX_SBS_Efficiency,
    HX_SBS_PPH,
    HX_SBS_PlayTime,
    HX_SBS_Rank,
    HX_SBS_Reserved,
};

struct HxSBColumnDefinition
{
    var EHxSBStatType Types[2];
    var string Headings[2];
    var string MinWidthValues[2];
    var string MaxWidthValues[2];
    var bool bCanHide;
    var bool bSmall;
};

struct HxSBTable
{
    var int TeamIndex;
    var array<PlayerReplicationInfo> PRIs;
    var array<TeamPlayerReplicationInfo> TeamPRIs;
    var array<HxPlayerReplicationInfo> HxPRIs;
    var array<Material> Portraits;
    var array<HxTypes.HxImageCrop> PortraitCrops;
    var array<string> CharacterNames;
    var array<string> Pings;
    var array<string> PLs;
};

struct HxPortraitCrop
{
    var string ModelName;
    var HxTypes.HxImageCrop Crop;
};

struct HxSBColumnConfig
{
    var EHxSBStatType MainStat;
    var EHxSBStatType SecStat;
};

struct HxSBStatData
{
    var const localized array<string> MainLabel;
    var const localized array<string> SecLabel;
    var const string MinWidthValue;
    var const string MaxWidthValue;
};

const POSITION_COLUMN = 0;
const PORTRAIT_COLUMN = 1;

var const HxSBStatData StatData[15];
var localized string ReadyLabel;
var localized string PlayerLabel;
var localized string LocationLabel;
var localized string PingLabel;
var localized string PacketLossLabel;
var localized string SpectatingLabel;
var localized string ElapsedTimeLabel;
var localized string RemainingTimeLabel;
var localized string ScoreLimitLabel;
var localized string MatchIDLabel;
var localized string BotLabel;
var localized string OutFireLabel;
var localized string RestartLabel;
var localized string DetailedStatsLabel;
var localized string SwitchLayoutLabel;
var localized string ShortSupportOrderLabel;
var localized string ShortFreelanceOrderLabel;
var localized string ShortDefendOrderLabel;
var localized string ShortAttackOrderLabel;
var localized string ShortHoldOrderLabel;
var localized array<string> TeamNameLabels;
var localized string SpacerText;
var localized string CommaText;
var localized string MinNameWidthTestText;
var localized string MaxNameWidthTestText;

var HxTypes.EHxVertAlignment BoardAlignment;
var HxTypes.EHxVertAlignment HeadingAlignment;
var float BorderSize;
var float DividerSize;
var int FontSizeModifier;
var bool bAlternateRowColors;
var bool bCompactTeamScores;
var bool bShowSecondaryStats;
var bool bPreferVerticalLayout;
var bool bAbbreviateHeadings;
var bool bShowPlayerPortraits;
var bool bShowBotCallSigns;
var bool bShowBotOrders;
var bool bShowShortcuts;
var bool bShowTimestamp;
var Color HeaderColor;
var Color RowColor;
var Color AltRowColor;
var Color BorderColor;
var Color DividerColor;
var Color ScrollThumbColor;
var Color TextColor;
var Color SecondTextColor;
var Color HighlightTextColor;
var Color ReadyColor;
var array<HxSBColumnConfig> ColumnConfigs;

var protected const array<HxSBTable> Tables;
var protected array<HxSBColumnDefinition> Columns;
var protected array<GUI.eTextAlign> Alignments;
var protected int PlayerColumn;
var protected bool bVerticalLayout;

var protected int Border;
var protected int Divider;
var protected int OuterSpacing;
var protected int TableWidth;
var protected int HeaderHeight;
var protected int RowWidth;
var protected int RowHeight;
var protected int FullRowHeight;
var protected int TableLeftPadding;
var protected int TableTopPadding;
var protected array<int> ColumnLefts;
var protected array<int> ColumnWidths;
var protected int TableRegion[4];
var protected int ScrollPadding;
var protected int ScrollThumbWidth;
var protected int ScrollZoneWidth;
var protected int ScrollZoneHeight;
var protected int VisibleRows;

var protected font TinyFont;
var protected font SmallFont;
var protected font MediumFont;
var protected font BigFont;
var protected font ScoreFont;
var protected float ScreenWidth;
var protected float ScreenHeight;
var protected float TinyFontHeight;
var protected float SmallFontHeight;
var protected float MediumFontHeight;
var protected float BigFontHeight;
var protected float ScoreFontHeight;
var protected float SmallRowPadding;

var protected UnrealPlayer PC;
var protected HxClientManager ClientManager;
var protected array<PlayerReplicationInfo> ActivePRIs;
var protected array<PlayerReplicationInfo> SpectatingPRIs;
var protected bool bHasWeaponStats;
var protected bool bHasKillStats;
var protected bool bHasRank;

var private float ElapsedTime;
var private float LastUpdateTime;
var private bool bApplyPreferredLayout;
var private bool bShowScrollbar;
var private int MaxVisibleRows;
var private int RowCount;
var private int FocusedTable;
var private int FocusedIndex;
var private int TopIndex;
var private int FontIndex;
var private int SpectatingRegionHeight;
var private int PortraitSize;
var private string SpectatingPlayers;
var private string DetailedStatsHint;
var private HxScoreBoardInteraction Interaction;
var private const array<HxPortraitCrop> BestPortraitCrops;
var private const HxTypes.HxImageCrop FallbackPortraitCrop;
var private const HxTypes.HxImageCrop UnknownPortraitCrop;

simulated function UpdateTablePaddings(Canvas C);
simulated function UpdateExtraSizes(Canvas C);
simulated function SetTableColors(int Table);
simulated function DrawReservedColumn(Canvas C, int Table, int Index, int Column, int Top);

simulated function Init()
{
    Super.Init();
    LoadDefaults();
    ScreenWidth = 0;
    ScreenHeight = 0;
    Columns.Length = 0;
    Alignments.Length = 0;
    if (Tables.Length == 1)
    {
        bVerticalLayout = true;
    }
    Columns[Columns.Length] = GetPositionColumnDefinition();
    Alignments[Alignments.Length] = TXTA_Center;
    if (bShowPlayerPortraits)
    {
        Columns[Columns.Length] = GetPortraitColumnDefinition();
        Alignments[Alignments.Length] = TXTA_Center;
    }
    PlayerColumn = Columns.Length;
    Columns[Columns.Length] = GetPlayerColumnDefinition();
    Alignments[Alignments.Length] = TXTA_Left;
    InitializeColumns();
    Columns[Columns.Length] = GetPingColumnDefinition();
    Alignments[Alignments.Length] = TXTA_Center;
}

simulated function LoadDefaults()
{
    BoardAlignment = class'HxScoreBoard'.default.BoardAlignment;
    HeadingAlignment = class'HxScoreBoard'.default.HeadingAlignment;
    BorderSize = class'HxScoreBoard'.default.BorderSize;
    DividerSize = class'HxScoreBoard'.default.DividerSize;
    FontSizeModifier = class'HxScoreBoard'.default.FontSizeModifier;
    bAlternateRowColors = class'HxScoreBoard'.default.bAlternateRowColors;
    bCompactTeamScores = class'HxScoreBoard'.default.bCompactTeamScores;
    bShowSecondaryStats = class'HxScoreBoard'.default.bShowSecondaryStats;
    bPreferVerticalLayout = class'HxScoreBoard'.default.bPreferVerticalLayout;
    bAbbreviateHeadings = class'HxScoreBoard'.default.bAbbreviateHeadings;
    bShowPlayerPortraits = class'HxScoreBoard'.default.bShowPlayerPortraits;
    bShowBotCallSigns = class'HxScoreBoard'.default.bShowBotCallSigns;
    bShowBotOrders = class'HxScoreBoard'.default.bShowBotOrders;
    bShowShortcuts = class'HxScoreBoard'.default.bShowShortcuts;
    bShowTimestamp = class'HxScoreBoard'.default.bShowTimestamp;
    HeaderColor = class'HxScoreBoard'.default.HeaderColor;
    RowColor = class'HxScoreBoard'.default.RowColor;
    AltRowColor = class'HxScoreBoard'.default.AltRowColor;
    BorderColor = class'HxScoreBoard'.default.BorderColor;
    DividerColor = class'HxScoreBoard'.default.DividerColor;
    ScrollThumbColor = class'HxScoreBoard'.default.ScrollThumbColor;
    TextColor = class'HxScoreBoard'.default.TextColor;
    SecondTextColor = class'HxScoreBoard'.default.SecondTextColor;
    HighlightTextColor = class'HxScoreBoard'.default.HighlightTextColor;
    ReadyColor = class'HxScoreBoard'.default.ReadyColor;
    if (default.bApplyPreferredLayout)
    {
        default.bVerticalLayout = bPreferVerticalLayout;
        bVerticalLayout = bPreferVerticalLayout;
        default.bApplyPreferredLayout = false;
    }
}

simulated function ReapplyLayout()
{
    default.bApplyPreferredLayout = true;
}

simulated function InitializeColumns()
{
    local int i;

    for (i = 0; i < ColumnConfigs.Length; ++i)
    {
        if (IsStatAvailable(ColumnConfigs[i].MainStat))
        {
            Columns[Columns.Length] = GetColumnDefinition(
                ColumnConfigs[i].MainStat, ColumnConfigs[i].SecStat);
            Alignments[Alignments.Length] = TXTA_Center;
        }
    }
}

simulated function bool Initialized()
{
    PC = UnrealPlayer(Owner);
    if (PC == None || PC.PlayerReplicationInfo == None)
    {
        return false;
    }
    if (ClientManager == None)
    {
        ClientManager = class'HxClientManager'.static.Get(PC.Player);
    }
    if (Interaction == None)
    {
        Interaction = class'HxScoreBoardInteraction'.static.Add(PC.Player);
    }
    if (GRI == None)
    {
        GRI = PC.GameReplicationInfo;
        return GRI != None;
    }
    return true;
}

simulated event Destroyed()
{
    if (Interaction != None)
    {
        PC = UnrealPlayer(Owner);
        if (PC != None && PC.Player != None)
        {
            PC.Player.InteractionMaster.RemoveInteraction(Interaction);
        }
        Interaction = None;
    }
}

simulated event DrawScoreboard(Canvas C)
{
    local int SpectatingCount;
    local float TimeSinceLastUpdate;
    local bool bUpdateVisible;

    if (Initialized())
    {
        if (GRI.ElapsedTime > 0 && (ElapsedTime == 0 || GRI.Winner == None))
        {
            ElapsedTime = GRI.ElapsedTime;
        }
        TimeSinceLastUpdate = Level.TimeSeconds - LastUpdateTime;
        SpectatingCount = Len(SpectatingPlayers);
        if (TimeSinceLastUpdate > Level.TimeDilation)
        {
            if (TimeSinceLastUpdate > 3 * Level.TimeDilation)
            {
                CenterOnFocused();
                DetailedStatsHint = class'GameInfo'.static.GetKeyBindName("ShowStats", PC);
                if (DetailedStatsHint != "")
                {
                    DetailedStatsHint = Repl(DetailedStatsLabel, "%", DetailedStatsHint);
                }
            }
            UpdatePRIs();
            bUpdateVisible = UpdateTables();
        }
        if (ScreenWidth != C.ClipX || ScreenHeight != C.ClipY
            || SpectatingCount != Len(SpectatingPlayers))
        {
            UpdateSizes(C);
        }
        else if (bUpdateVisible)
        {
            UpdateVisibleRows(C);
        }
        UpdateScoreBoard(C);
    }
}

simulated event UpdateScoreBoard(Canvas C)
{
    local float SavedOrgX;
    local float SavedOrgY;
    local int TableHeight;
    local int TotalHeight;

    SavedOrgX = C.OrgX;
    SavedOrgY = C.OrgY;
    C.OrgX = TableRegion[0];
    C.OrgY = TableRegion[1];
    C.ClipX = TableRegion[2];
    C.ClipY = TableRegion[3];
    C.Style = ERenderStyle.STY_Alpha;
    TableHeight = VisibleRows * FullRowHeight + HeaderHeight;
    if (BoardAlignment != HX_VALIGN_Top)
    {
        if (bVerticalLayout)
        {
            TotalHeight = (TableHeight + OuterSpacing) * Tables.Length - OuterSpacing;
        }
        else
        {
            TotalHeight = (TableHeight + OuterSpacing) * Ceil(Tables.Length / 2.0) - OuterSpacing;
        }
        if (BoardAlignment == HX_VALIGN_Center)
        {
            C.OrgY += Max(0, TableRegion[3] - TableTopPadding - TotalHeight) / 2;
        }
        else
        {
            C.OrgY += Max(0, TableRegion[3] - TableTopPadding - TotalHeight);
        }
    }
    DrawTables(C, TableHeight);
    DrawMapInfo(C);
    C.OrgX = SavedOrgX;
    C.OrgY = SavedOrgY;
    C.ClipX = ScreenWidth;
    C.ClipY = ScreenHeight;
}

simulated function DrawTables(Canvas C, int TableHeight)
{
    local bool bSavedCenter;
    local int i;

    C.OrgX += TableLeftPadding;
    C.OrgY += TableTopPadding;
    C.ClipX = TableWidth + OuterSpacing;
    C.ClipY = TableHeight + OuterSpacing;
    for (i = 0; i < Tables.Length; ++i)
    {
        SetTableColors(i);
        C.DrawColor = HeaderColor;
        DrawBox(C, 0, 0, TableWidth, HeaderHeight);
        if (Border > 0)
        {
            C.DrawColor = BorderColor;
            DrawBorder(C, 0, 0, TableWidth, TableHeight);
        }
        DrawHeadings(C, i);
        DrawRows(C, i);
        if (bShowScrollbar)
        {
            DrawScrollThumb(C);
        }
        if (bVerticalLayout || (i + 1) % 2 == 0)
        {
            C.OrgY += C.ClipY;
        }
        else
        {
            C.OrgX += C.ClipX;
        }
    }
    C.OrgY -= OuterSpacing;
    if (SpectatingPRIs.Length > 0)
    {
        bSavedCenter = C.bCenter;
        C.OrgX = TableRegion[0];
        C.OrgY += SmallRowPadding;
        C.ClipX = TableRegion[2];
        C.ClipY = SpectatingRegionHeight;
        C.CurX = 0;
        C.CurY = 0;
        C.bCenter = true;
        C.DrawColor = SecondTextColor;
        C.Font = TinyFont;
        C.DrawText(SpectatingPlayers, true);
        C.OrgY += C.ClipY;
        C.bCenter = bSavedCenter;
    }
    bDisplayMessages = C.OrgY < (ScreenHeight / 2);
}

simulated function DrawScrollThumb(Canvas C)
{
    local float Top;
    local int Height;

    Height = ScrollZoneHeight * FMax(0.03, ScrollZoneHeight / float(RowCount * FullRowHeight));
    Top = int((ScrollZoneHeight - Height) * (TopIndex / float(RowCount - MaxVisibleRows)));
    C.DrawColor = ScrollThumbColor;
    DrawBox(
        C,
        RowWidth + ScrollPadding,
        Top + HeaderHeight + ScrollPadding + Divider,
        ScrollThumbWidth,
        Height);
}

simulated function DrawMapInfo(Canvas C)
{
    local string StatusText;
    local float Left;
    local float Top;
    local float Right;
    local float Bottom;

    C.DrawColor = HighlightTextColor;
    C.Font = BigFont;
    C.DrawTextJustified(GetTitleText(), 1, 0, 0, ScreenWidth, TableRegion[1]);
    Left = OuterSpacing;
    Bottom = ScreenHeight - MediumFontHeight * 0.1;
    Top = Bottom - MediumFontHeight;
    Right = ScreenWidth - Left;
    C.Font = MediumFont;
    C.DrawTextJustified(GetLevelInfoText(), 1, 0, Top, ScreenWidth, Bottom);
    C.Font = SmallFont;
    if (bShowTimestamp)
    {
        C.DrawTextJustified(GetTimestampText(), 2, 0, Top, Right, Bottom);
        if (GRI.MatchID != 0)
        {
            C.DrawTextJustified(MatchIDLabel$GRI.MatchID, 2, 0, Top - SmallFontHeight, Right, Top);
        }
    }
    else if (GRI.MatchID != 0)
    {
        C.DrawTextJustified(MatchIDLabel$GRI.MatchID, 2, 0, Top, Right, Top);
    }
    if (bShowShortcuts)
    {
        if (Tables.Length > 1)
        {
            C.DrawTextJustified(SwitchLayoutLabel, 0, Left, Top, Right, Bottom);
            if (DetailedStatsHint != "")
            {
                C.DrawTextJustified(DetailedStatsHint, 0, Left, Top - SmallFontHeight, Right, Top);
            }
        }
        else if (DetailedStatsHint != "")
        {
            C.DrawTextJustified(DetailedStatsHint, 0, Left, Top, Right, Bottom);
        }
    }
    if (GetStatusText(StatusText))
    {
        C.Font = MediumFont;
        C.DrawTextJustified(StatusText, 1, 0, Top - MediumFontHeight * 1.25, ScreenWidth, Top);
    }
}

simulated function DrawHeadings(Canvas C, int Table)
{
    local float UpperTop;
    local float MiddleTop;
    local int i;

    if (Columns[PlayerColumn].Headings[0] != "")
    {
        Columns[PlayerColumn].Headings[0] = Repl(PlayerLabel, "%", Tables[Table].PRIs.Length);
    }
    UpperTop = Max(0, (HeaderHeight - RowHeight) / 2) + SmallRowPadding;
    C.Font = SmallFont;
    C.DrawColor = TextColor;
    switch (HeadingAlignment)
    {
        case HX_VALIGN_Top:
            MiddleTop = UpperTop;
            break;
        case HX_VALIGN_Center:
            MiddleTop = UpperTop + (SmallFontHeight / 2);
            break;
        case HX_VALIGN_Bottom:
            MiddleTop = UpperTop + SmallFontHeight;
            break;
    }
    for (i = 0; i < Columns.Length; ++i)
    {
        if (ColumnWidths[i] > 0 && Columns[i].Headings[0] != "")
        {
            if (Columns[i].Headings[1] != "")
            {
                C.CurY = UpperTop;
                DrawTextClipped(
                    C, Columns[i].Headings[0], Alignments[i], ColumnLefts[i], ColumnWidths[i]);
                C.DrawColor = SecondTextColor;
                DrawTextClipped(
                    C, Columns[i].Headings[1], Alignments[i], ColumnLefts[i], ColumnWidths[i]);
                C.DrawColor = TextColor;
            }
            else
            {
                C.CurY = MiddleTop;
                DrawTextClipped(
                    C, Columns[i].Headings[0], Alignments[i], ColumnLefts[i], ColumnWidths[i]);
            }
        }
    }
}

simulated function DrawRows(Canvas C, int Table)
{
    local int Index;
    local int Top;
    local int i;

    Top = HeaderHeight + Divider;
    C.Font = MediumFont;
    for (i = 0; i < VisibleRows; ++i)
    {
        Index = TopIndex + i;
        if (!bAlternateRowColors || Index % 2 == 0)
        {
            C.DrawColor = RowColor;
        }
        else
        {
            C.DrawColor = AltRowColor;
        }
        DrawBox(C, 0, Top, RowWidth, RowHeight);
        if (Index < Tables[Table].PRIs.Length && Tables[Table].PRIs[Index] != None)
        {
            if (Table == FocusedTable && Index == FocusedIndex)
            {
                C.DrawColor = HighlightTextColor;
            }
            else
            {
                C.DrawColor = TextColor;
            }
            DrawRow(C, Table, Index, i, Top);
        }
        Top += FullRowHeight;
    }
    if (Divider > 0)
    {
        Top = HeaderHeight;
        C.DrawColor = DividerColor;
        DrawBox(C, 0, Top, TableWidth, Divider);
        for (i = 1; i < VisibleRows; ++i)
        {
            Top += FullRowHeight;
            DrawBox(C, 0, Top, RowWidth, Divider);
        }
        if (Border == 0)
        {
            DrawBox(C, 0, Top + FullRowHeight, TableWidth, Divider);
        }
    }
}

simulated function DrawRow(Canvas C, int Table, int Index, int Row, int Top)
{
    local int i;

    DrawPlayerPosition(C, Table, Index, POSITION_COLUMN, Top);
    if (bShowPlayerPortraits && ColumnWidths[PORTRAIT_COLUMN] > 0)
    {
        DrawPlayerPortrait(C, Table, Index, PORTRAIT_COLUMN, Top);
    }
    DrawPlayerName(C, Table, Index, PlayerColumn, Top);
    for (i = PlayerColumn + 1; i < Columns.Length - 1; ++i)
    {
        if (ColumnWidths[i] > 0)
        {
            if (Columns[i].Types[0] == HX_SBS_Reserved)
            {
                DrawReservedColumn(C, Table, Index, i, Top);
            }
            else
            {
                DrawColumn(C, Table, Index, i, Top);
            }
        }
    }
    DrawPlayerPing(C, Table, Index, i, Top);
}

simulated function DrawPlayerPosition(Canvas C, int Table, int Index, int Column, int Top)
{
    local Color PreviousColor;

    C.Font = SmallFont;
    if (!GRI.bMatchHasBegun)
    {
        PreviousColor = C.DrawColor;
        if (Tables[Table].PRIs[Index].bReadyToPlay)
        {
            C.DrawColor = ReadyColor;
        }
        else
        {
            C.DrawColor = RowColor;
        }
        DrawTextCell(C, ReadyLabel, Column, Top);
        C.DrawColor = PreviousColor;
    }
    else if (!DrawPlayerMarker(C, Table, Index, Column, Top))
    {
        DrawTextCell(C, Index + 1, Column, Top);
    }
}

simulated function bool DrawPlayerMarker(Canvas C, int Table, int Index, int Column, int Top)
{
    return false;
}

simulated function DrawPlayerPortrait(Canvas C, int Table, int Index, int Column, int Top)
{
    local Color PreviousColor;
    local Material Portrait;

    Portrait = Tables[Table].Portraits[Index];
    if (Portrait != None)
    {
        PreviousColor = C.DrawColor;
        C.Style = ERenderStyle.STY_Normal;
        C.DrawColor = HUDClass.default.WhiteColor;
        C.CurX = ColumnLefts[Column];
        C.CurY = Top + (RowHeight - PortraitSize) / 2.0;
        C.DrawTile(
            Portrait,
            PortraitSize,
            PortraitSize,
            Tables[Table].PortraitCrops[Index].Left,
            Tables[Table].PortraitCrops[Index].Top,
            Tables[Table].PortraitCrops[Index].Width,
            Tables[Table].PortraitCrops[Index].Height);
        C.DrawColor = PreviousColor;
        C.Style = ERenderStyle.STY_Alpha;
    }
}

simulated function DrawPlayerName(Canvas C, int Table, int Index, int Column, int Top)
{
    local float TextWidth;
    local float TextHeight;

    C.StrLen(Tables[Table].PRIs[Index].PlayerName, TextWidth, TextHeight);
    if (TextWidth > ColumnWidths[Column])
    {
        C.Font = SmallFont;
    }
    else
    {
        C.Font = MediumFont;
    }
    DrawTextCell(C, Tables[Table].PRIs[Index].PlayerName, Column, Top);
}

simulated function DrawTeamPlayerName(Canvas C, int Table, int Index, int Column, int Top)
{
    local TeamPlayerReplicationInfo TeamPRI;
    local Color PreviousColor;
    local string Name;
    local string Zone;
    local float TextWidth;
    local float TextHeight;

    Name = Tables[Table].PRIs[Index].PlayerName;
    Zone = Tables[Table].PRIs[Index].GetLocationName();
    TeamPRI = TeamPlayerReplicationInfo(Tables[Table].PRIs[Index]);
    if (Tables[Table].PRIs[Index].bBot && TeamPRI != None && TeamPRI.Squad != None)
    {
        if (bShowBotCallSigns)
        {
            Name @= "["$TeamPRI.GetCallSign()$"]";
        }
        if (bShowBotOrders)
        {
            if (bVerticalLayout)
            {
                Zone = "["$GetOrderFor(TeamPRI)$"]"@Zone;
            }
            else
            {
                Zone = "["$GetShortOrdersFor(TeamPRI)$"]"@Zone;
            }
        }
    }
    C.StrLen(Name, TextWidth, TextHeight);
    if (TextWidth > ColumnWidths[Column])
    {
        C.Font = SmallFont;
    }
    else
    {
        C.Font = MediumFont;
    }
    C.CurY = Top + SmallRowPadding * 0.75;
    DrawTextClipped(C, Name, Alignments[Column], ColumnLefts[Column], ColumnWidths[Column]);
    C.Font = TinyFont;
    PreviousColor = C.DrawColor;
    C.DrawColor = SecondTextColor;
    DrawTextClipped(C, Zone, Alignments[Column], ColumnLefts[Column], ColumnWidths[Column]);
    C.DrawColor = PreviousColor;
}

simulated function DrawPlayerPing(Canvas C, int Table, int Index, int Column, float Top)
{
    local Color PreviousColor;

    if (Tables[Table].PRIs[Index].bBot)
    {
        C.Font = SmallFont;
        PreviousColor = C.DrawColor;
        C.DrawColor = SecondTextColor;
        C.CurY = Top + (RowHeight - SmallFontHeight) / 2 + SmallFontHeight * 0.04;
        DrawTextClipped(C, BotLabel, Alignments[Column], ColumnLefts[Column], ColumnWidths[Column]);
        C.DrawColor = PreviousColor;
    }
    else if (bShowSecondaryStats)
    {
        DrawTextCellDual(C, Tables[Table].Pings[Index], Tables[Table].PLs[Index], Column, Top);
    }
    else
    {
        C.Font = MediumFont;
        DrawTextCell(C, Tables[Table].Pings[Index], Column, Top);
    }
}

simulated function DrawColumn(Canvas C, int Table, int Index, int Column, int Top)
{
    if (Columns[Column].Types[1] != HX_SBS_None)
    {
        C.Font = SmallFont;
        DrawTextCellDual(
            C,
            GetField(Columns[Column].Types[0], Table, Index),
            GetField(Columns[Column].Types[1], Table, Index),
            Column,
            Top);
    }
    else
    {
        C.Font = MediumFont;
        DrawTextCell(C, GetField(Columns[Column].Types[0], Table, Index), Column, Top);
    }
}

simulated final function DrawBox(Canvas C, int Left, int Top, int Width, int Height)
{
    C.SetPos(Left, Top);
    C.DrawTile(Material'engine.WhiteSquareTexture', Width, Height, 0, 0, 2, 2);
}

simulated final function DrawBorder(Canvas C, int Left, int Top, int Width, int Height)
{
    Top -= Border;
    Height += 2 * Border;
    C.SetPos(Left, Top);
    C.DrawTile(Texture'engine.WhiteSquareTexture', Width, Border, 0, 0, 2, 2);
    C.DrawTile(Texture'engine.WhiteSquareTexture', Border, Height, 0, 0, 2, 2);
    C.SetPos(Left - Border, Top);
    C.DrawTile(Texture'engine.WhiteSquareTexture', Border, Height, 0, 0, 2, 2);
    C.SetPos(Left, Top + Height - Border);
    C.DrawTile(Texture'engine.WhiteSquareTexture', Width, Border, 0, 0, 2, 2);
}

simulated final function DrawTextCellDual(Canvas C,
                                          coerce string MainText,
                                          coerce string SubText,
                                          int Column,
                                          float Top)
{
    local Color PreviousColor;

    C.Font = SmallFont;
    C.CurY = Top + SmallRowPadding;
    DrawTextClipped(C, MainText, Alignments[Column], ColumnLefts[Column], ColumnWidths[Column]);
    PreviousColor = C.DrawColor;
    C.DrawColor = SecondTextColor;
    DrawTextClipped(C, SubText, Alignments[Column], ColumnLefts[Column], ColumnWidths[Column]);
    C.DrawColor = PreviousColor;
}

simulated final function DrawTextCell(Canvas C, coerce string Text, int Column, float Top)
{
    DrawTextCentered(
        C, Text, Alignments[Column], ColumnLefts[Column], Top, ColumnWidths[Column], RowHeight);
}

simulated final function DrawTextCentered(Canvas C,
                                          coerce string Text,
                                          GUI.eTextAlign Alignment,
                                          float Left,
                                          float Top,
                                          float Width,
                                          float Height)
{
    local float SavedClipX;
    local float TextWidth;
    local float TextHeight;

    SavedClipX = C.ClipX;
    C.CurX = Left;
    C.ClipX = Left + Width;
    C.TextSize(Text, TextWidth, TextHeight);
    C.CurY = Top + (Height - TextHeight) / 2 + TextHeight * 0.065;
    switch (Alignment)
    {
        case TXTA_Center:
            C.CurX += FMax(0, (Width - TextWidth) / 2);
            break;
        case TXTA_Right:
            C.CurX = C.ClipX - TextWidth;
            break;
    }
    C.DrawTextClipped(Text);
    C.CurY += TextHeight;
    C.ClipX = SavedClipX;
}

simulated final function DrawTextClipped(Canvas C,
                                         coerce string Text,
                                         GUI.eTextAlign Alignment,
                                         float Left,
                                         float Width)
{
    local float SavedClipX;
    local float TextWidth;
    local float TextHeight;

    SavedClipX = C.ClipX;
    C.CurX = Left;
    C.ClipX = Left + Width;
    C.TextSize(Text, TextWidth, TextHeight);
    switch (Alignment)
    {
        case TXTA_Center:
            C.CurX += FMax(0, (Width - TextWidth) / 2);
            break;
        case TXTA_Right:
            C.CurX = C.ClipX - TextWidth;
            break;
    }
    C.DrawTextClipped(Text);
    C.CurY += TextHeight;
    C.ClipX = SavedClipX;
}

simulated final function DrawIconCell(Canvas C, Material Icon, int Column, Float Top)
{
    local Color PreviousColor;

    PreviousColor = C.DrawColor;
    C.DrawColor = HUDClass.default.WhiteColor;
    C.SetPos(C.OrgX + ColumnLefts[Column], C.OrgY + Top);
    C.DrawTileJustified(Icon, 1, ColumnWidths[Column], RowHeight);
    C.DrawColor = PreviousColor;
}

simulated function UpdateSizes(Canvas C)
{
    local int MaxHeight;
    local int WidthReduction;
    local int BottomPadding;
    local int VerticalTableCount;

    ScreenWidth = C.ClipX;
    ScreenHeight = C.ClipY;
    UpdateFontSizes(C);
    Border = Round(C.SizeY * (BorderSize / 100));
    Divider = Round(C.SizeY * (DividerSize / 100));
    OuterSpacing = (C.SizeY * 0.013 + 1) & ~1;
    HeaderHeight = SmallFontHeight * 2.4;
    RowHeight = (SmallFontHeight * 1.1 + MediumFontHeight + 1) & ~1;
    FullRowHeight = RowHeight + Divider;
    SmallRowPadding = (RowHeight - SmallFontHeight * 2) / 2 + SmallFontHeight * 0.065;
    BottomPadding = (MediumFontHeight * 2.5 + 1) & ~1;
    ScrollZoneWidth = (C.ClipY * 0.013 + 1) & ~1;
    ScrollPadding = Ceil(ScrollZoneWidth * 0.12);
    ScrollThumbWidth = ScrollZoneWidth - ScrollPadding - int(Border > 0) * ScrollPadding;
    bShowScrollbar = false;
    TableRegion[1] = (BigFontHeight * 1.3 + 1) & ~1;
    TableRegion[2] = Min(ScreenWidth - OuterSpacing * 2, ScreenHeight * 1.75) & ~1;
    TableRegion[3] = ScreenHeight - TableRegion[1] - BottomPadding - Border - Max(Divider, Border);
    TableRegion[0] = ((ScreenWidth - TableRegion[2]) / 2) + Border;
    TableRegion[1] += Border;
    TableRegion[2] -= Border * 2;
    UpdateTablePaddings(C);
    if (Divider == 0)
    {
        PortraitSize = (RowHeight * 0.97 + 1) & ~1;
    }
    else
    {
        PortraitSize = RowHeight;
    }
    if (bVerticalLayout)
    {
        TableWidth = TableRegion[2] - TableLeftPadding;
        VerticalTableCount = Tables.Length;
        WidthReduction = UpdateColumnWidths(C);
        TableRegion[0] += WidthReduction / 2;
        TableRegion[2] -= WidthReduction;
    }
    else
    {
        TableWidth = (TableRegion[2] - TableLeftPadding - OuterSpacing) / 2;
        VerticalTableCount = Ceil(Tables.Length / 2.0);
        WidthReduction = UpdateColumnWidths(C);
        TableRegion[0] += WidthReduction;
        TableRegion[2] -= WidthReduction * 2;
    }
    MaxHeight = TableRegion[3] - TableTopPadding;
    if (SpectatingPRIs.Length > 0)
    {
        UpdateSpectatingPlayers(C);
        MaxHeight -= SpectatingRegionHeight;
    }
    UpdateExtraSizes(C);
    MaxHeight -= OuterSpacing * (VerticalTableCount - 1) + HeaderHeight * VerticalTableCount;
    MaxVisibleRows = MaxHeight / (FullRowHeight * VerticalTableCount);
    UpdateVisibleRows(C);
}

simulated function int UpdateColumnWidths(Canvas C)
{
    local int AvailableWidth;
    local int FilledWidth;
    local int RemainingWidth;
    local int AdditionalWidth;
    local int i;

    RowWidth = TableWidth;
    AvailableWidth = RowWidth - ScrollZoneWidth;
    ColumnLefts.Length = Columns.Length;
    ColumnWidths.Length = Columns.Length;
    for (i = 0; i < Columns.Length; ++i)
    {
        ColumnWidths[i] = GetMinimumColumnSize(C, i);
        FilledWidth += ColumnWidths[i];
    }
    if (FilledWidth > AvailableWidth)
    {
        for (i = Columns.Length - 1; i >= 0; --i)
        {
            if (Columns[i].bCanHide)
            {
                FilledWidth -= ColumnWidths[i];
                ColumnWidths[i] = 0;
                if (FilledWidth <= AvailableWidth)
                {
                    break;
                }
            }
        }
    }
    if (FilledWidth <= AvailableWidth)
    {
        RemainingWidth = AvailableWidth - FilledWidth;
        AdditionalWidth = (GetMaximumColumnSize(C, PlayerColumn) - ColumnWidths[PlayerColumn]) & ~1;
        if (AdditionalWidth > 0)
        {
            AdditionalWidth = Min(AdditionalWidth, RemainingWidth);
            ColumnWidths[PlayerColumn] += AdditionalWidth;
            RemainingWidth -= AdditionalWidth;
        }
        for (i = 0; i < Columns.Length && RemainingWidth > 0; ++i)
        {
            if (ColumnWidths[i] > 0 && PlayerColumn != i)
            {
                AdditionalWidth = (GetMaximumColumnSize(C, i) - ColumnWidths[i]) & ~1;
                if (AdditionalWidth > 0)
                {
                    AdditionalWidth = Min(AdditionalWidth, RemainingWidth);
                    ColumnWidths[i] += AdditionalWidth;
                    RemainingWidth -= AdditionalWidth;
                }
            }
        }
        if (RemainingWidth > 0)
        {
            RowWidth -= RemainingWidth;
            TableWidth -= RemainingWidth;
        }
    }
    else
    {
        ColumnWidths[PlayerColumn] -= FilledWidth - AvailableWidth;
    }
    ColumnWidths[PlayerColumn] += ScrollZoneWidth;
    UpdateColumnLefts(C);
    return RemainingWidth;
}

simulated function UpdateColumnLefts(Canvas C)
{
    local int Left;
    local int i;

    for (i = 0; i < Columns.Length; ++i)
    {
        ColumnLefts[i] = Left;
        Left += ColumnWidths[i];
    }
}

simulated function UpdateVisibleRows(Canvas C)
{
    local bool bNewShowScrollbar;

    VisibleRows = Min(MaxVisibleRows, RowCount);
    bNewShowScrollbar = RowCount > VisibleRows;
    if (bShowScrollbar ^^ bNewShowScrollbar)
    {
        if (bNewShowScrollbar)
        {
            RowWidth -= ScrollZoneWidth;
            ColumnWidths[PlayerColumn] -= ScrollZoneWidth;
        }
        else
        {
            RowWidth += ScrollZoneWidth;
            ColumnWidths[PlayerColumn] += ScrollZoneWidth;
        }
        UpdateColumnLefts(C);
        bShowScrollbar = bNewShowScrollbar;
        ScrollZoneHeight = VisibleRows * FullRowHeight - 2 * ScrollPadding - Divider;
        if (Border == 0 && Divider == 0)
        {
            ScrollZoneHeight += ScrollPadding;
        }
    }
    if (TopIndex + VisibleRows > RowCount)
    {
        TopIndex = Max(0, RowCount - VisibleRows);
    }
}

simulated function UpdateSpectatingPlayers(Canvas C)
{
    local bool bSavedCenter;
    local float SavedClipX;
    local float TextWidth;
    local float TextHeight;

    bSavedCenter = C.bCenter;
    SavedClipX = C.ClipX;
    C.bCenter = true;
    C.ClipX = TableRegion[2];
    C.CurX = 0;
    C.CurY = 0;
    C.Font = TinyFont;
    C.StrLen(SpectatingPlayers, TextWidth, TextHeight);
    C.bCenter = bSavedCenter;
    C.ClipX = SavedClipX;
    SpectatingRegionHeight = Ceil(TextHeight + SmallRowPadding);
}

simulated function UpdatePRIs()
{
    local int i;

    SortPRIArray();
    ActivePRIs.Length = 0;
    SpectatingPRIs.length = 0;
    for (i = 0; i < GRI.PRIArray.Length; ++i)
    {
        if (!GRI.PRIArray[i].bOnlySpectator)
        {
            ActivePRIs[ActivePRIs.Length] = GRI.PRIArray[i];

        }
        else if (!IsSystemSpectator(GRI.PRIArray[i]))
        {
            SpectatingPRIs[SpectatingPRIs.Length] = GRI.PRIArray[i];
        }
    }
    if (SpectatingPRIs.Length > 0)
    {
        SpectatingPlayers = Repl(SpectatingLabel, "%", SpectatingPRIs.Length);
        for (i = 0; i < SpectatingPRIs.Length - 1; ++i)
        {
            SpectatingPlayers $= SpectatingPRIs[i].PlayerName$CommaText;
        }
        SpectatingPlayers $= SpectatingPRIs[i].PlayerName;
    }
    else
    {
        SpectatingPlayers = "";
        SpectatingRegionHeight = 0;
    }
    if (GRI.bMatchHasBegun)
    {
        for (i = 0; i < ActivePRIs.Length; ++i)
        {
            if (TeamPlayerReplicationInfo(ActivePRIs[i]) != None)
            {
                PC.ServerUpdateStats(TeamPlayerReplicationInfo(ActivePRIs[i]));
            }
        }
    }
    LastUpdateTime = Level.TimeSeconds;
}

simulated function bool UpdateTables()
{
    local Pawn ViewTarget;
    local bool bUpdateVisible;
    local bool bNewHasWeaponStats;
    local bool bNewHasKillStats;
    local bool bNewHasRank;
    local int PreviousCount;
    local int i;
    local int j;

    RowCount = 0;
    for (i = 0; i < Tables.Length; ++i)
    {
        PreviousCount = Tables[i].PRIs.Length;
        Tables[i].PRIs.Length = 0;
        if (Tables[i].TeamIndex < 0)
        {
            Tables[i].PRIs = ActivePRIs;
        }
        else
        {
            for (j = 0; j < ActivePRIs.Length; ++j)
            {
                if (ActivePRIs[j].Team != None
                    && ActivePRIs[j].Team.TeamIndex == Tables[i].TeamIndex)
                {
                    Tables[i].PRIs[Tables[i].PRIs.Length] = ActivePRIs[j];
                }
            }
        }
        Tables[i].TeamPRIs.Length = Tables[i].PRIs.Length;
        Tables[i].HxPRIs.Length = Tables[i].PRIs.Length;
        for (j = 0; j < Tables[i].PRIs.Length; ++j)
        {
            Tables[i].TeamPRIs[j] = TeamPlayerReplicationInfo(Tables[i].PRIs[j]);
            Tables[i].HxPRIs[j] = class'HxPlayerReplicationInfo'.static.Get(Tables[i].PRIs[j]);
            if (Tables[i].HxPRIs[j] != None)
            {
                if (Tables[i].HxPRIs[j].HasWeaponStats())
                {
                    bNewHasWeaponStats = true;
                }
                if (Tables[i].HxPRIs[j].HasKillStats())
                {
                    bNewHasKillStats = true;
                }
                if (Tables[i].HxPRIs[j].Rank > -1)
                {
                    bNewHasRank = true;
                }
                ClientManager.UpdateStats(Tables[i].HxPRIs[j]);
            }
        }
        if (Tables[i].PRIs.Length > RowCount)
        {
            RowCount = Tables[i].PRIs.Length;
        }
        bUpdateVisible = bUpdateVisible || Tables[i].PRIs.Length != PreviousCount;
    }
    ViewTarget = Pawn(PC.ViewTarget);
    FocusedTable = -1;
    FocusedIndex = -1;
    for (i = 0; i < Tables.Length; ++i)
    {
        Tables[i].Portraits.Length = Tables[i].PRIs.Length;
        Tables[i].PortraitCrops.Length = Tables[i].PRIs.Length;
        Tables[i].CharacterNames.Length = Tables[i].PRIs.Length;
        Tables[i].Pings.Length = Tables[i].PRIs.Length;
        Tables[i].PLs.Length = Tables[i].PRIs.Length;
        for (j = 0; j < Tables[i].PRIs.Length; ++j)
        {
            if (PC.PlayerReplicationInfo.bOnlySpectator)
            {
                if (ViewTarget != None && Tables[i].PRIs[j] == ViewTarget.PlayerReplicationInfo)
                {
                    FocusedTable = i;
                    FocusedIndex = j;
                }
            }
            else if (Tables[i].PRIs[j] == PC.PlayerReplicationInfo)
            {
                FocusedTable = i;
                FocusedIndex = j;
            }
            if (bShowPlayerPortraits)
            {
                UpdatePlayerPortrait(i, j);
            }
            Tables[i].Pings[j] = string(Min(999, 4 * Tables[i].PRIs[j].Ping));
            Tables[i].PLs[j] = string(Tables[i].PRIs[j].PacketLoss);
        }
    }
    if (bNewHasWeaponStats ^^ bHasWeaponStats || bHasKillStats ^^ bNewHasKillStats
        || bHasRank ^^ bNewHasRank)
    {
        bHasWeaponStats = bNewHasWeaponStats;
        bHasKillStats = bNewHasKillStats;
        bHasRank = bNewHasRank;
        Init();
    }
    return bUpdateVisible;
}

simulated function UpdatePlayerPortrait(int Table, int Index)
{
    local xUtil.PlayerRecord Record;

    if (Tables[Table].CharacterNames[Index] != Tables[Table].PRIs[Index].CharacterName)
    {
        Tables[Table].CharacterNames[Index] = Tables[Table].PRIs[Index].CharacterName;
        Record = class'xUtil'.static.FindPlayerRecord(Tables[Table].CharacterNames[Index]);
        if (Record.DefaultName ~= Tables[Table].CharacterNames[Index])
        {
            Tables[Table].Portraits[Index] = Record.Portrait;
            Tables[Table].PortraitCrops[Index] = GetBestPortraitCrop(Record.DefaultName);
        }
        else
        {
            Tables[Table].Portraits[Index] = Texture'PlayerPictures.cDefault';
            Tables[Table].PortraitCrops[Index] = UnknownPortraitCrop;
        }
    }
}

simulated function bool IsSystemSpectator(PlayerReplicationInfo PRI)
{
    return PRI.PlayerName ~= "WebAdmin" || PRI.PlayerName ~= "DemoRecSpectator";
}

simulated function CenterOnFocused()
{
    TopIndex = Max(0, Min(RowCount - MaxVisibleRows, FocusedIndex - (MaxVisibleRows / 2)));
}

simulated function bool ScrollUp()
{
    TopIndex = Max(0, TopIndex - 1);
    return true;
}

simulated function bool PageUp()
{
    TopIndex = Max(0, TopIndex - MaxVisibleRows);
    return true;
}

simulated function bool ScrollDown()
{
    TopIndex = Max(0, Min(RowCount - MaxVisibleRows, TopIndex + 1));
    return true;
}

simulated function bool PageDown()
{
    TopIndex = Max(0, Min(RowCount - MaxVisibleRows, TopIndex + MaxVisibleRows));
    return true;
}

simulated function bool ToggleLayout()
{
    if (Tables.Length > 1)
    {
        default.bVerticalLayout = !default.bVerticalLayout;
        bVerticalLayout = default.bVerticalLayout;
        ScreenWidth = 0;
        ScreenHeight = 0;
        return true;
    }
    return false;
}

simulated function int GetMinimumColumnSize(Canvas C, int Column)
{
    local float TextWidth;
    local float TextHeight;
    local float MaxWidth;

    if (bShowPlayerPortraits && Column < PlayerColumn)
    {
        return (RowHeight * 1.2 + 1) & ~1;
    }
    C.Font = SmallFont;
    if (Columns[Column].Headings[0] != "")
    {
        C.StrLen(Columns[Column].Headings[0], MaxWidth, TextHeight);
    }
    if (Columns[Column].Headings[1] != "")
    {
        C.StrLen(Columns[Column].Headings[1], TextWidth, TextHeight);
        if (TextWidth > MaxWidth)
        {
            MaxWidth = TextWidth;
        }
    }
    else if (!Columns[Column].bSmall)
    {
        C.Font = MediumFont;
    }
    if (Columns[Column].MinWidthValues[0] != "")
    {
        C.StrLen(Columns[Column].MinWidthValues[0], TextWidth, TextHeight);
        if (TextWidth > MaxWidth)
        {
            MaxWidth = TextWidth;
        }
    }
    if (Columns[Column].MinWidthValues[1] != "")
    {
        C.StrLen(Columns[Column].MinWidthValues[1], TextWidth, TextHeight);
        if (TextWidth > MaxWidth)
        {
            MaxWidth = TextWidth;
        }
    }
    return (MaxWidth + MediumFontHeight + 1) & ~1;
}

simulated function int GetMaximumColumnSize(Canvas C, int Column)
{
    local float TextWidth;
    local float TextHeight;
    local float MaxWidth;

    if (Columns[Column].MaxWidthValues[0] == "" && Columns[Column].MaxWidthValues[1] == "")
    {
        return ColumnWidths[Column];
    }
    C.Font = MediumFont;
    if (Columns[Column].MaxWidthValues[0] != "")
    {
        C.StrLen(Columns[Column].MaxWidthValues[0], MaxWidth, TextHeight);
    }
    if (Columns[Column].MaxWidthValues[1] != "")
    {
        C.StrLen(Columns[Column].MaxWidthValues[1], TextWidth, TextHeight);
        if (TextWidth > MaxWidth)
        {
            MaxWidth = TextWidth;
        }
    }
    return FMax((MaxWidth + MediumFontHeight + 1) & ~1, ColumnWidths[Column]);
}

simulated function HxSBColumnDefinition GetColumnDefinition(EHxSBStatType MainStat,
                                                            optional EHxSBStatType SecStat)
{
    local HxSBColumnDefinition Def;
    local int Index;

    Index = MainStat - 1;
    Def.Types[0] = MainStat;
    if (bAbbreviateHeadings && StatData[Index].MainLabel.Length > 1)
    {
        Def.Headings[0] = StatData[Index].MainLabel[1];
    }
    else
    {
        Def.Headings[0] = StatData[Index].MainLabel[0];
    }
    Def.MinWidthValues[0] = StatData[Index].MinWidthValue;
    Def.MaxWidthValues[0] = StatData[Index].MaxWidthValue;
    if (bShowSecondaryStats && IsStatAvailable(SecStat))
    {
        Index = SecStat - 1;
        Def.Types[1] = SecStat;
        if (bAbbreviateHeadings && StatData[Index].MainLabel.Length > 1)
        {
            Def.Headings[1] = StatData[Index].SecLabel[1];
        }
        else
        {
            Def.Headings[1] = StatData[Index].SecLabel[0];
        }
        Def.MinWidthValues[1] = StatData[Index].MinWidthValue;
        Def.MaxWidthValues[1] = StatData[Index].MaxWidthValue;
    }
    Def.bCanHide = true;
    return Def;

}

simulated function HxSBColumnDefinition GetPositionColumnDefinition()
{
    local HxSBColumnDefinition Def;

    Def.Types[0] = HX_SBS_Reserved;
    Def.MinWidthValues[0] = "111";
    Def.MaxWidthValues[0] = "191";
    Def.bSmall = true;
    return Def;
}

simulated function HxSBColumnDefinition GetPortraitColumnDefinition()
{
    local HxSBColumnDefinition Def;

    Def.Types[0] = HX_SBS_Reserved;
    Def.MinWidthValues[0] = "111";
    Def.bCanHide = true;
    return Def;
}

simulated function HxSBColumnDefinition GetPlayerColumnDefinition()
{
    local HxSBColumnDefinition Def;

    Def.Types[0] = HX_SBS_Reserved;
    Def.Headings[0] = PlayerLabel;
    Def.MinWidthValues[0] = MinNameWidthTestText;
    Def.MaxWidthValues[0] = MaxNameWidthTestText;
    return Def;
}

simulated function HxSBColumnDefinition GetPingColumnDefinition()
{
    local HxSBColumnDefinition Def;

    Def.Types[0] = HX_SBS_Reserved;
    Def.Headings[0] = PingLabel;
    if (bShowSecondaryStats)
    {
        Def.Headings[1] = PacketLossLabel;
    }
    Def.MinWidthValues[0] = "999";
    return Def;
}

simulated function string GetField(EHxSBStatType Type, int Table, int Index)
{
    switch (Type)
    {
        case HX_SBS_Score:
            return string(int(Tables[Table].PRIs[Index].Score));
        case HX_SBS_Frags:
            return string(Tables[Table].PRIs[Index].Kills);
        case HX_SBS_Deaths:
            return string(int(Tables[Table].PRIs[Index].Deaths));
        case HX_SBS_Lives:
            if (Tables[Table].PRIs[Index].bOutOfLives)
            {
                return class'ScoreBoardDeathMatch'.default.OutText;
            }
            return string(int(GRI.MaxLives - Tables[Table].PRIs[Index].Deaths));
        case HX_SBS_TeamKills:
            if (Tables[Table].HxPRIs[Index] != None)
            {
                return string(Tables[Table].HxPRIs[Index].TeamKills);
            }
            // [[fallthrough]]
        case HX_SBS_Suicides:
            if (Tables[Table].TeamPRIs[Index] != None)
            {
                return string(Tables[Table].TeamPRIs[Index].Suicides);
            }
            break;
        case HX_SBS_Goals:
            // [[fallthrough]]
        case HX_SBS_Captures:
            return string(Tables[Table].PRIs[Index].GoalsScored);
        case HX_SBS_Touches:
            if (Tables[Table].TeamPRIs[Index] != None)
            {
                return string(Tables[Table].TeamPRIs[Index].FlagTouches);
            }
            break;
        case HX_SBS_MaxSpree:
            if (Tables[Table].HxPRIs[Index] != None)
            {
                return string(Tables[Table].HxPRIs[Index].MaxSpree);
            }
            break;
        case HX_SBS_Accuracy:
            if (Tables[Table].HxPRIs[Index] != None)
            {
                return string(Tables[Table].HxPRIs[Index].Accuracy)$"%";
            }
            return "0%";
        case HX_SBS_Efficiency:
            if (Tables[Table].PRIs[Index].Kills == 0)
            {
                return "0%";
            }
            return string(int(Tables[Table].PRIs[Index].Kills
                / (Tables[Table].PRIs[Index].Kills + Tables[Table].PRIs[Index].Deaths) * 100))$"%";
        case HX_SBS_PPH:
            return string(Clamp(
                3600 * Tables[Table].PRIs[Index].Score
                    / FMax(1, ElapsedTime - Tables[Table].PRIs[Index].StartTime),
                -999,
                9999));
        case HX_SBS_PlayTime:
            if (GRI.bMatchHasBegun)
            {
                return FormatTime(Max(0, ElapsedTime - Tables[Table].PRIs[Index].StartTime));
            }
            return "--:--";
        case HX_SBS_Rank:
            if (Tables[Table].HxPRIs[Index] != None)
            {
                return string(Tables[Table].HxPRIs[Index].Rank);
            }
            return "-";
    }
    return "";
}

simulated function string GetTitleText()
{
    local int SkillLevel;
    local string Text;

    if (Level.NetMode == NM_Standalone)
    {
        if (Level.Game.CurrentGameProfile != None)
        {
            SkillLevel = Clamp(Level.Game.CurrentGameProfile.BaseDifficulty, 0, 7);
        }
        else
        {
            SkillLevel = Clamp(Level.Game.GameDifficulty, 0, 7);
        }
        Text = class'ScoreBoardDeathMatch'.default.SkillLevel[SkillLevel];
    }
    else if (GRI != None && GRI.BotDifficulty >= 0)
    {
        Text = class'ScoreBoardDeathMatch'.default.SkillLevel[Clamp(GRI.BotDifficulty, 0, 7)];
    }
    return Text@GRI.GameName$class'ScoreBoardDeathMatch'.default.MapName$Level.Title;
}

simulated function bool GetStatusText(out string StatusText)
{
    if (PC.PlayerReplicationInfo.bOnlySpectator)
    {
        if (PlayerReplicationInfo(GRI.Winner) != None)
        {
            StatusText = PlayerReplicationInfo(GRI.Winner).PlayerName
                $class'HUDBase'.default.WonMatchPostFix;
            return true;
        }
        if (UnrealTeamInfo(GRI.Winner) != None)
        {
            StatusText = UnrealTeamInfo(GRI.Winner).GetHumanReadableName()
                $class'HUDBase'.default.WonMatchPostFix;
            return true;
        }
    }
    else if (PC.bDisplayLoser)
    {
        StatusText = class'HUDBase'.default.YouveLostTheMatch;
        return true;
    }
    else if (PC.bDisplayWinner)
    {
        StatusText = class'HUDBase'.default.YouveWonTheMatch;
        return true;
    }
    else if (PC.IsDead())
    {
        if (PC.PlayerReplicationInfo.bOutOfLives)
        {
            StatusText = OutFireLabel;
        }
        else if (Level.TimeSeconds - PC.LastKickWarningTime < 2)
        {
            StatusText = class'GameMessage'.Default.KickWarning;
        }
        else
        {
            StatusText = RestartLabel;
        }
        return true;
    }
    return false;
}

simulated function string GetLevelInfoText()
{
    local string Text;

    if (GRI != None)
    {
        if (GRI.MaxLives != 0)
        {
            Text = class'ScoreBoardDeathMatch'.default.MaxLives@GRI.MaxLives;
        }
        else if (GRI.GoalScore != 0)
        {
            Text = ScoreLimitLabel$GRI.GoalScore;
        }
        if (GRI.TimeLimit != 0)
        {
            Text $= SpacerText$RemainingTimeLabel$FormatTime(GRI.RemainingTime);
        }
        else
        {
            Text $= SpacerText$ElapsedTimeLabel$FormatTime(GRI.ElapsedTime);
        }
    }
    return Text;
}

simulated function string GetTimestampText()
{
    local string Month;
    local string Day;

    if (Level.Month < 10)
    {
        Month = "0"$string(Level.Month);
    }
    else
    {
        Month = string(Level.Month);
    }
    if (Level.Day < 10)
    {
        Day = "0"$string(Level.Day);
    }
    else
    {
        Day = string(Level.Day);
    }
    return Level.Year$"-"$Month$"-"$Day@FormatTime(Level.Hour * 60 + Level.Minute);
}

simulated function string GetOrderFor(TeamPlayerReplicationInfo PRI)
{
    if (PRI.Squad.LeaderPRI != None && !PRI.Squad.LeaderPRI.bBot && !PRI.bHolding)
    {
        return PRI.Squad.SupportString@PRI.Squad.LeaderPRI.PlayerName;
    }
    return PRI.Squad.GetOrderStringFor(PRI);
}

simulated function string GetShortOrdersFor(TeamPlayerReplicationInfo PRI)
{
    local Name Orders;

    if (PRI.Squad.LeaderPRI != None && !PRI.Squad.LeaderPRI.bBot)
    {
        if (PRI.bHolding)
        {
            return ShortHoldOrderLabel;
        }
        return ShortSupportOrderLabel;
    }
    if (PRI.Squad.bFreelance || PRI.Squad.SquadObjective == None)
    {
        return ShortFreelanceOrderLabel;
    }
    Orders = PRI.Squad.GetOrders();
    switch (Orders)
    {
        case 'defend':
            return ShortDefendOrderLabel;
        case 'attack':
            return ShortAttackOrderLabel;
    }
    return PRI.Squad.GetShortOrderStringFor(PRI);
}

simulated function UpdateFontSizes(Canvas C)
{
    local float Width;

    C.CurX = 0;
    C.CurY = 0;
    FontIndex = class'HxGUIFontMidGame'.static.GetFontIndex(C, FontSizeModifier);
    TinyFont = class'HxGUIFontMidGame'.static.GetTinyFontFor(FontIndex);
    SmallFont = class'HxGUIFontMidGame'.static.GetSmallFontFor(FontIndex);
    MediumFont = class'HxGUIFontMidGame'.static.GetMediumFontFor(FontIndex);
    BigFont = class'HxGUIFontMidGame'.static.GetBigFontFor(FontIndex);
    ScoreFont = class'HxGUIFontMidGame'.static.GetHugeNumericFontFor(FontIndex);
    C.Font = TinyFont;
    C.StrLen("9", Width, TinyFontHeight);
    C.Font = SmallFont;
    C.StrLen("9", Width, SmallFontHeight);
    C.Font = MediumFont;
    C.StrLen("9", Width, MediumFontHeight);
    C.Font = BigFont;
    C.StrLen("9", Width, BigFontHeight);
    C.Font = ScoreFont;
    C.StrLen("9", Width, ScoreFontHeight);
}

simulated function UpdatePrecacheFonts()
{
    class'HxGUIFontMidGame'.static.PrecacheFonts();
}

simulated function bool IsStatAvailable(EHxSBStatType Type)
{
    if (Type == HX_SBS_None || Type == HX_SBS_Reserved)
    {
        return false;
    }
    switch (Type)
    {
        case HX_SBS_Accuracy:
            return bHasWeaponStats;
        CASE HX_SBS_Rank:
            return bHasRank;
    }
    return true;
}

static function HxTypes.HxImageCrop GetBestPortraitCrop(string ModelName)
{
    local int Compare;
    local int Middle;
    local int Low;
    local int High;

    Low = 0;
    High = default.BestPortraitCrops.Length - 1;
    while (Low <= High)
    {
        Middle = (Low + High) / 2;
        Compare = StrCmp(ModelName, default.BestPortraitCrops[Middle].ModelName);
        if (Compare == 0)
        {
            return default.BestPortraitCrops[Middle].Crop;
        }
        if (Compare > 0)
        {
            Low = Middle + 1;
        }
        else
        {
            High = Middle - 1;
        }
    }
    return default.FallbackPortraitCrop;
}

static final function array<string> ExtractMainStatCaptions()
{
    local array<string> Captions;
    local int i;


    for (i = 0; i < ArrayCount(default.StatData); ++i)
    {
        Captions[Captions.Length] = default.StatData[i].MainLabel[0];
    }
    return Captions;
}

static final function array<string> ExtractSecStatCaptions()
{
    local array<string> Captions;
    local int i;

    Captions[Captions.Length] = "";
    for (i = 0; i < ArrayCount(default.StatData); ++i)
    {
        Captions[Captions.Length] = default.StatData[i].SecLabel[0];
    }
    return Captions;
}

defaultproperties
{
    Tables(0)=(TeamIndex=-1)
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
    bShowPlayerPortraits=false
    bShowBotCallSigns=false
    bShowBotOrders=true
    bShowShortcuts=true
    bShowTimestamp=true
    HeaderColor=(R=0,G=0,B=20,A=196)
    RowColor=(R=130,G=130,B=140,A=142)
    AltRowColor=(R=100,G=100,B=110,A=112)
    BorderColor=(R=220,G=220,B=230,A=220)
    DividerColor=(R=220,G=220,B=230,A=172)
    ScrollThumbColor=(R=220,G=220,B=230,A=172)
    TextColor=(R=255,G=255,B=255,A=255)
    SecondTextColor=(R=200,G=210,B=220,A=255)
    HighlightTextColor=(R=255,G=255,B=0,A=255)
    ReadyColor=(R=64,G=255,B=64,A=255)
    LastUpdateTime=-5
    bApplyPreferredLayout=true
    // Huge thanks to 21 for creating this list of crops!
    BestPortraitCrops(0)=(ModelName="Abaddon",Crop=(Left=18,Top=69,Width=221,Height=221))
    BestPortraitCrops(1)=(ModelName="Ambrosia",Crop=(Left=14,Top=57,Width=227,Height=227))
    BestPortraitCrops(2)=(ModelName="Annika",Crop=(Left=61,Top=43,Width=195,Height=195))
    BestPortraitCrops(3)=(ModelName="Arclite",Crop=(Left=29,Top=7,Width=227,Height=227))
    BestPortraitCrops(4)=(ModelName="Asp",Crop=(Left=35,Top=87,Width=186,Height=186))
    BestPortraitCrops(5)=(ModelName="Axon",Crop=(Left=21,Top=37,Width=170,Height=170))
    BestPortraitCrops(6)=(ModelName="Azure",Crop=(Left=52,Top=56,Width=163,Height=163))
    BestPortraitCrops(7)=(ModelName="Baird",Crop=(Left=14,Top=13,Width=215,Height=215))
    BestPortraitCrops(8)=(ModelName="Barktooth",Crop=(Left=57,Top=24,Width=151,Height=151))
    BestPortraitCrops(9)=(ModelName="BlackJack",Crop=(Left=26,Top=19,Width=204,Height=204))
    BestPortraitCrops(10)=(ModelName="Brock",Crop=(Left=41,Top=40,Width=215,Height=215))
    BestPortraitCrops(11)=(ModelName="Brutalis",Crop=(Left=15,Top=43,Width=227,Height=227))
    BestPortraitCrops(12)=(ModelName="Cannonball",Crop=(Left=28,Top=29,Width=227,Height=227))
    BestPortraitCrops(13)=(ModelName="Cathode",Crop=(Left=73,Top=50,Width=146,Height=146))
    BestPortraitCrops(14)=(ModelName="ClanLord",Crop=(Left=22,Top=29,Width=227,Height=227))
    BestPortraitCrops(15)=(ModelName="Cleopatra",Crop=(Left=45,Top=100,Width=178,Height=178))
    BestPortraitCrops(16)=(ModelName="Cobalt",Crop=(Left=41,Top=94,Width=215,Height=215))
    BestPortraitCrops(17)=(ModelName="Corrosion",Crop=(Left=0,Top=56,Width=256,Height=256))
    BestPortraitCrops(18)=(ModelName="Cyclops",Crop=(Left=0,Top=64,Width=227,Height=227))
    BestPortraitCrops(19)=(ModelName="Damarus",Crop=(Left=38,Top=115,Width=204,Height=204))
    BestPortraitCrops(20)=(ModelName="Diva",Crop=(Left=42,Top=70,Width=170,Height=170))
    BestPortraitCrops(21)=(ModelName="Divisor",Crop=(Left=16,Top=22,Width=240,Height=240))
    BestPortraitCrops(22)=(ModelName="Domina",Crop=(Left=0,Top=80,Width=256,Height=256))
    BestPortraitCrops(23)=(ModelName="Dominator",Crop=(Left=38,Top=45,Width=204,Height=204))
    BestPortraitCrops(24)=(ModelName="Drekorig",Crop=(Left=86,Top=43,Width=170,Height=170))
    BestPortraitCrops(25)=(ModelName="Enigma",Crop=(Left=23,Top=5,Width=186,Height=186))
    BestPortraitCrops(26)=(ModelName="Faraleth",Crop=(Left=36,Top=115,Width=195,Height=195))
    BestPortraitCrops(27)=(ModelName="Fate",Crop=(Left=29,Top=22,Width=227,Height=227))
    BestPortraitCrops(28)=(ModelName="Frostbite",Crop=(Left=27,Top=20,Width=215,Height=215))
    BestPortraitCrops(29)=(ModelName="Gaargod",Crop=(Left=67,Top=11,Width=178,Height=178))
    BestPortraitCrops(30)=(ModelName="Garrett",Crop=(Left=0,Top=37,Width=240,Height=240))
    BestPortraitCrops(31)=(ModelName="Gkublok",Crop=(Left=14,Top=48,Width=215,Height=215))
    BestPortraitCrops(32)=(ModelName="Gorge",Crop=(Left=21,Top=37,Width=199,Height=199))
    BestPortraitCrops(33)=(ModelName="Greith",Crop=(Left=8,Top=0,Width=240,Height=240))
    BestPortraitCrops(34)=(ModelName="Guardian",Crop=(Left=39,Top=32,Width=204,Height=204))
    BestPortraitCrops(35)=(ModelName="Harlequin",Crop=(Left=37,Top=61,Width=195,Height=195))
    BestPortraitCrops(36)=(ModelName="Horus",Crop=(Left=36,Top=55,Width=195,Height=195))
    BestPortraitCrops(37)=(ModelName="Hyena",Crop=(Left=26,Top=71,Width=204,Height=204))
    BestPortraitCrops(38)=(ModelName="Kaela",Crop=(Left=0,Top=0,Width=240,Height=240))
    BestPortraitCrops(39)=(ModelName="Kane",Crop=(Left=0,Top=12,Width=204,Height=204))
    BestPortraitCrops(40)=(ModelName="Karag",Crop=(Left=0,Top=102,Width=215,Height=215))
    BestPortraitCrops(41)=(ModelName="Komek",Crop=(Left=14,Top=67,Width=215,Height=215))
    BestPortraitCrops(42)=(ModelName="Kraagesh",Crop=(Left=52,Top=20,Width=204,Height=204))
    BestPortraitCrops(43)=(ModelName="Kragoth",Crop=(Left=61,Top=81,Width=163,Height=163))
    BestPortraitCrops(44)=(ModelName="Lauren",Crop=(Left=16,Top=22,Width=240,Height=240))
    BestPortraitCrops(45)=(ModelName="Lilith",Crop=(Left=7,Top=29,Width=227,Height=227))
    BestPortraitCrops(46)=(ModelName="Makreth",Crop=(Left=25,Top=83,Width=204,Height=204))
    BestPortraitCrops(47)=(ModelName="Malcolm",Crop=(Left=16,Top=45,Width=240,Height=240))
    BestPortraitCrops(48)=(ModelName="Mandible",Crop=(Left=38,Top=58,Width=204,Height=204))
    BestPortraitCrops(49)=(ModelName="Matrix",Crop=(Left=0,Top=40,Width=256,Height=256))
    BestPortraitCrops(50)=(ModelName="Mekkor",Crop=(Left=0,Top=104,Width=256,Height=256))
    BestPortraitCrops(51)=(ModelName="Memphis",Crop=(Left=35,Top=52,Width=186,Height=186))
    BestPortraitCrops(52)=(ModelName="Mokara",Crop=(Left=26,Top=96,Width=204,Height=204))
    BestPortraitCrops(53)=(ModelName="Motig",Crop=(Left=0,Top=80,Width=256,Height=256))
    BestPortraitCrops(54)=(ModelName="Mr.Crow",Crop=(Left=25,Top=38,Width=204,Height=204))
    BestPortraitCrops(55)=(ModelName="Nebri",Crop=(Left=14,Top=99,Width=227,Height=227))
    BestPortraitCrops(56)=(ModelName="Ophelia",Crop=(Left=4,Top=62,Width=248,Height=248))
    BestPortraitCrops(57)=(ModelName="Outlaw",Crop=(Left=0,Top=16,Width=256,Height=256))
    BestPortraitCrops(58)=(ModelName="Prism",Crop=(Left=15,Top=57,Width=227,Height=227))
    BestPortraitCrops(59)=(ModelName="Rae",Crop=(Left=10,Top=13,Width=221,Height=221))
    BestPortraitCrops(60)=(ModelName="Rapier",Crop=(Left=51,Top=97,Width=163,Height=163))
    BestPortraitCrops(61)=(ModelName="Ravage",Crop=(Left=24,Top=61,Width=195,Height=195))
    BestPortraitCrops(62)=(ModelName="Reinha",Crop=(Left=14,Top=28,Width=227,Height=227))
    BestPortraitCrops(63)=(ModelName="Remus",Crop=(Left=4,Top=16,Width=248,Height=248))
    BestPortraitCrops(64)=(ModelName="Renegade",Crop=(Left=0,Top=37,Width=240,Height=240))
    BestPortraitCrops(65)=(ModelName="Riker",Crop=(Left=0,Top=0,Width=256,Height=256))
    BestPortraitCrops(66)=(ModelName="Roc",Crop=(Left=17,Top=83,Width=221,Height=221))
    BestPortraitCrops(67)=(ModelName="Romulus",Crop=(Left=8,Top=15,Width=240,Height=240))
    BestPortraitCrops(68)=(ModelName="Rylisa",Crop=(Left=16,Top=37,Width=240,Height=240))
    BestPortraitCrops(69)=(ModelName="Sapphire",Crop=(Left=4,Top=16,Width=248,Height=248))
    BestPortraitCrops(70)=(ModelName="Satin",Crop=(Left=0,Top=32,Width=256,Height=256))
    BestPortraitCrops(71)=(ModelName="Scarab",Crop=(Left=11,Top=70,Width=186,Height=186))
    BestPortraitCrops(72)=(ModelName="Selig",Crop=(Left=13,Top=94,Width=215,Height=215))
    BestPortraitCrops(73)=(ModelName="Siren",Crop=(Left=29,Top=40,Width=210,Height=210))
    BestPortraitCrops(74)=(ModelName="Skakruk",Crop=(Left=27,Top=27,Width=215,Height=215))
    BestPortraitCrops(75)=(ModelName="Skrilax",Crop=(Left=11,Top=11,Width=178,Height=178))
    BestPortraitCrops(76)=(ModelName="Subversa",Crop=(Left=16,Top=45,Width=240,Height=240))
    BestPortraitCrops(77)=(ModelName="Syzygy",Crop=(Left=57,Top=59,Width=190,Height=190))
    BestPortraitCrops(78)=(ModelName="Thannis",Crop=(Left=35,Top=58,Width=186,Height=186))
    BestPortraitCrops(79)=(ModelName="Thorax",Crop=(Left=12,Top=54,Width=195,Height=195))
    BestPortraitCrops(80)=(ModelName="Torch",Crop=(Left=13,Top=40,Width=215,Height=215))
    BestPortraitCrops(81)=(ModelName="Virus",Crop=(Left=45,Top=59,Width=146,Height=146))
    BestPortraitCrops(82)=(ModelName="Widowmaker",Crop=(Left=26,Top=64,Width=204,Height=204))
    BestPortraitCrops(83)=(ModelName="Wraith",Crop=(Left=29,Top=14,Width=227,Height=227))
    BestPortraitCrops(84)=(ModelName="Xan",Crop=(Left=0,Top=55,Width=195,Height=195))
    BestPortraitCrops(85)=(ModelName="Zarina",Crop=(Left=52,Top=11,Width=186,Height=186))
    FallbackPortraitCrop=(Left=0,Top=25,Width=256,Height=256)
    UnknownPortraitCrop=(Left=0,Top=56,Width=256,Height=400)
    StatData(0)=(MainLabel=("SCORE"),SecLabel=("score"),MinWidthValue="9999",MaxWidthValue="999999")
    StatData(1)=(MainLabel=("FRAGS"),SecLabel=("frags"),MinWidthValue="999",MaxWidthValue="99999")
    StatData(2)=(MainLabel=("DEATHS"),SecLabel=("deaths"),MinWidthValue="999",MaxWidthValue="99999")
    StatData(3)=(MainLabel=("LIVES"),SecLabel=("lives"),MinWidthValue="999",MaxWidthValue="99999")
    StatData(4)=(MainLabel=("TEAM KILLS","TK"),SecLabel=("team kills","tk"),MinWidthValue="999",MaxWidthValue="99999")
    StatData(5)=(MainLabel=("SUICIDES","SUIC"),SecLabel=("suicides","suic"),MinWidthValue="999",MaxWidthValue="99999")
    StatData(6)=(MainLabel=("GOALS"),SecLabel=("goals"),MinWidthValue="999",MaxWidthValue="9999")
    StatData(7)=(MainLabel=("CAPTURES","CAPS"),SecLabel=("captures","caps"),MinWidthValue="999",MaxWidthValue="9999")
    StatData(8)=(MainLabel=("GRABS"),SecLabel=("grabs"),MinWidthValue="999",MaxWidthValue="9999")
    StatData(9)=(MainLabel=("MAX SPREE","MS"),SecLabel=("max spree","ms"),MinWidthValue="999",MaxWidthValue="99999")
    StatData(10)=(MainLabel=("ACCURACY","ACC"),SecLabel=("accuracy","acc"),MinWidthValue="100%")
    StatData(11)=(MainLabel=("EFFICIENCY","EFF"),SecLabel=("efficiency","eff"),MinWidthValue="100%")
    StatData(12)=(MainLabel=("PPH"),SecLabel=("PPH"),MinWidthValue="9999")
    StatData(13)=(MainLabel=("TIME"),SecLabel=("time"),MinWidthValue="99:99")
    StatData(14)=(MainLabel=("RANK"),SecLabel=("rank"),MinWidthValue="9999",MaxWidthValue="99999")
    ReadyLabel="RDY"
    PlayerLabel="PLAYER (%)"
    LocationLabel="location"
    PingLabel="PING"
    PacketLossLabel="loss"
    SpectatingLabel="SPECTATING (%): "
    ElapsedTimeLabel="ELAPSED TIME: "
    RemainingTimeLabel="REMAINING TIME: "
    ScoreLimitLabel="SCORE LIMIT: "
    MatchIDLabel="ID: "
    BotLabel="BOT"
    OutFireLabel="You are OUT. Fire to view other players."
    RestartLabel="You were killed. Press Fire to respawn!"
    DetailedStatsLabel="%: detailed stats"
    SwitchLayoutLabel="F8: switch layout"
    ShortSupportOrderLabel="SUP"
    ShortFreelanceOrderLabel="SWP"
    ShortDefendOrderLabel="DEF"
    ShortAttackOrderLabel="ATK"
    ShortHoldOrderLabel="HLD"
    TeamNameLabels(0)="RED TEAM (%)"
    TeamNameLabels(1)="BLUE TEAM (%)"
    TeamNameLabels(2)="GREEN TEAM (%)"
    TeamNameLabels(3)="GOLD TEAM (%)"
    SpacerText="   "
    CommaText=", "
    MinNameWidthTestText="WWWWWWWWWWWM"
    MaxNameWidthTestText="WWWWWWWWWWWWWWWWWWWWWM"
}
