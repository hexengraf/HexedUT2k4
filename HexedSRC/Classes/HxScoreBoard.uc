class HxScoreBoard extends ScoreBoard
    abstract;

enum EHxSBColumnType
{
    HX_SBCOL_Position,
    HX_SBCOL_Portrait,
    HX_SBCOL_Player,
    HX_SBCOL_Score,
    HX_SBCOL_Lives,
    HX_SBCOL_FragsAndEfficiency,
    HX_SBCOL_DeathsAndSuicides,
    HX_SBCOL_CapsAndGrabs,
    HX_SBCOL_PingAndLoss,
    HX_SBCOL_PPHAndTime,
    HX_SBCOL_Custom,
};

enum EHxSBTeamScoreStyle
{
    HX_SB_TSCORE_FullSize,
    HX_SB_TSCORE_Compact,
};

struct HxSBColumnConfig
{
    var EHxSBColumnType Type;
    var string Heading;
    var string SubHeading;
    var string MinWidthValue;
    var string MaxWidthValue;
    var bool bCanHide;
    var bool bSmall;
};

struct HxSBTable
{
    var int TeamIndex;
    var array<PlayerReplicationInfo> PRIs;
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

var localized string ReadyLabel;
var localized string PlayerLabel;
var localized string LocationLabel;
var localized string ScoreLabel;
var localized string FragsLabel;
var localized string EfficiencyLabel;
var localized string LivesLabel;
var localized string DeathsLabel;
var localized string SuicidesLabel;
var localized string CapturesLabel;
var localized string GoalsLabel;
var localized string GrabsLabel;
var localized string ReturnsLabel;
var localized string PingLabel;
var localized string PacketLossLabel;
var localized string PPHLabel;
var localized string TimeLabel;
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
var EHxSBTeamScoreStyle TeamScoreStyle;
var float BorderSize;
var float DividerSize;
var int FontSizeModifier;
var bool bAlternateRowColors;
var bool bShowPlayerPortraits;
var bool bShowPPHAndTime;
var bool bShowBotCallSigns;
var bool bShowBotOrders;
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

var protected const array<HxSBTable> Tables;
var protected const array<EHxSBColumnType> ColumnTypes;
var protected array<HxSBColumnConfig> Columns;
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
var protected array<PlayerReplicationInfo> ActivePRIs;
var protected array<PlayerReplicationInfo> SpectatingPRIs;

var private float ElapsedTime;
var private float LastUpdateTime;
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

simulated function InitializeCustomColumn(int Index);
simulated function UpdateTablePaddings(Canvas C);
simulated function UpdateExtraSizes(Canvas C);
simulated function SetTableColors(int Table);

simulated function Init()
{
    local int i;

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
    for (i = 0; i < ColumnTypes.Length; ++i)
    {
        InitializeColumn(ColumnTypes[i], i);
    }
}

simulated function LoadDefaults()
{
    BoardAlignment = class'HxScoreBoard'.default.BoardAlignment;
    HeadingAlignment = class'HxScoreBoard'.default.HeadingAlignment;
    TeamScoreStyle = class'HxScoreBoard'.default.TeamScoreStyle;
    BorderSize = class'HxScoreBoard'.default.BorderSize;
    DividerSize = class'HxScoreBoard'.default.DividerSize;
    FontSizeModifier = class'HxScoreBoard'.default.FontSizeModifier;
    bAlternateRowColors = class'HxScoreBoard'.default.bAlternateRowColors;
    bShowPlayerPortraits = class'HxScoreBoard'.default.bShowPlayerPortraits;
    bShowPPHAndTime = class'HxScoreBoard'.default.bShowPPHAndTime;
    bShowBotCallSigns = class'HxScoreBoard'.default.bShowBotCallSigns;
    bShowBotOrders = class'HxScoreBoard'.default.bShowBotOrders;
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
}

simulated function InitializeColumn(EHxSBColumnType Type, int Index)
{
    switch (Type)
    {
        case HX_SBCOL_Position:
            Columns[Columns.Length] = GetPositionColumnConfig();
            Alignments[Alignments.Length] = TXTA_Center;
            break;
        case HX_SBCOL_Portrait:
            if (bShowPlayerPortraits)
            {
                Columns[Columns.Length] = GetPortraitColumnConfig();
                Alignments[Alignments.Length] = TXTA_Center;
            }
            break;
        case HX_SBCOL_Player:
            PlayerColumn = Columns.Length;
            Columns[Columns.Length] = GetPlayerColumnConfig();
            Alignments[Alignments.Length] = TXTA_Left;
            break;
        case HX_SBCOL_Score:
            Columns[Columns.Length] = GetScoreColumnConfig();
            Alignments[Alignments.Length] = TXTA_Center;
            break;
        case HX_SBCOL_Lives:
            Columns[Columns.Length] = GetLivesColumnConfig();
            Alignments[Alignments.Length] = TXTA_Center;
            break;
        case HX_SBCOL_PingAndLoss:
            Columns[Columns.Length] = GetPingColumnConfig();
            Alignments[Alignments.Length] = TXTA_Center;
            break;
        case HX_SBCOL_FragsAndEfficiency:
            Columns[Columns.Length] = GetFragsColumnConfig();
            Alignments[Alignments.Length] = TXTA_Center;
            break;
        case HX_SBCOL_DeathsAndSuicides:
            Columns[Columns.Length] = GetDeathsColumnConfig();
            Alignments[Alignments.Length] = TXTA_Center;
            break;
        case HX_SBCOL_CapsAndGrabs:
            Columns[Columns.Length] = GetCapturesColumnConfig();
            Alignments[Alignments.Length] = TXTA_Center;
            break;
        case HX_SBCOL_PPHAndTime:
            if (bShowPPHAndTime)
            {
                Columns[Columns.Length] = GetPPHColumnConfig();
                Alignments[Alignments.Length] = TXTA_Center;
            }
            break;
        case HX_SBCOL_Custom:
            InitializeCustomColumn(Index);
            break;
    }
}

simulated function bool Initialized()
{
    PC = UnrealPlayer(Owner);
    if (PC == None || PC.PlayerReplicationInfo == None)
    {
        return false;
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
    C.DrawTextJustified(GetTimestampText(), 2, 0, Top, Right, Bottom);
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
    if (GetStatusText(StatusText))
    {
        C.Font = MediumFont;
        C.DrawTextJustified(StatusText, 1, 0, Top - MediumFontHeight * 1.25, ScreenWidth, Top);
    }
    if (GRI.MatchID != 0)
    {
        C.DrawTextJustified(MatchIDLabel$GRI.MatchID, 2, 0, Top - SmallFontHeight, Right, Top);
    }
}

simulated function DrawHeadings(Canvas C, int Table)
{
    local float UpperTop;
    local float MiddleTop;
    local int i;

    if (Columns[PlayerColumn].Heading != "")
    {
        Columns[PlayerColumn].Heading = Repl(PlayerLabel, "%", Tables[Table].PRIs.Length);
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
        if (ColumnWidths[i] > 0 && Columns[i].Heading != "")
        {
            if (Columns[i].SubHeading != "")
            {
                C.CurY = UpperTop;
                DrawTextClipped(
                    C, Columns[i].Heading, Alignments[i], ColumnLefts[i], ColumnWidths[i]);
                C.DrawColor = SecondTextColor;
                DrawTextClipped(
                    C, Columns[i].SubHeading, Alignments[i], ColumnLefts[i], ColumnWidths[i]);
                C.DrawColor = TextColor;
            }
            else
            {
                C.CurY = MiddleTop;
                DrawTextClipped(
                    C, Columns[i].Heading, Alignments[i], ColumnLefts[i], ColumnWidths[i]);
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

    for (i = 0; i < Columns.Length; ++i)
    {
        if (ColumnWidths[i] > 0)
        {
            switch (Columns[i].Type)
            {
                case HX_SBCOL_Position:
                    DrawPlayerPosition(C, Table, Index, i, Top);
                    break;
                case HX_SBCOL_Portrait:
                    DrawPlayerPortrait(C, Table, Index, i, Top);
                    break;
                case HX_SBCOL_Player:
                    DrawPlayerName(C, Table, Index, i, Top);
                    break;
                case HX_SBCOL_Score:
                    C.Font = MediumFont;
                    DrawTextCell(C, int(Tables[Table].PRIs[Index].Score), i, Top);
                    break;
                case HX_SBCOL_Lives:
                    DrawPlayerLives(C, Table, Index, i, Top);
                    break;
                case HX_SBCOL_FragsAndEfficiency:
                    DrawPlayerFrags(C, Table, Index, i, Top);
                    break;
                case HX_SBCOL_DeathsAndSuicides:
                    DrawPlayerDeaths(C, Table, Index, i, Top);
                    break;
                case HX_SBCOL_CapsAndGrabs:
                    DrawPlayerCaptures(C, Table, Index, i, Top);
                    break;
                case HX_SBCOL_PingAndLoss:
                    DrawPlayerPing(C, Table, Index, i, Top);
                    break;
                case HX_SBCOL_PPHAndTime:
                    DrawPlayerPPH(C, Table, Index, i, Top);
                    break;
            }
        }
    }
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

simulated function DrawPlayerLives(Canvas C, int Table, int Index, int Column, int Top)
{
    C.Font = MediumFont;
    if (Tables[Table].PRIs[Index].bOutOfLives)
    {
        DrawTextCell(C, class'ScoreBoardDeathMatch'.default.OutText, Column, Top);
    }
    else
    {
        DrawTextCell(C, int(GRI.MaxLives - Tables[Table].PRIs[Index].Deaths), Column, Top);
    }
}

simulated function DrawPlayerFrags(Canvas C, int Table, int Index, int Column, int Top)
{
    local float Kills;
    local float Deaths;
    local int Efficiency;

    Kills = Tables[Table].PRIs[Index].Kills;
    Deaths = Tables[Table].PRIs[Index].Deaths;
    if (Kills > 0)
    {
        Efficiency = int((Kills / (Kills + Deaths)) * 100);
    }
    DrawTextCellDual(C, Tables[Table].PRIs[Index].Kills, string(Efficiency)$"%", Column, Top);
}

simulated function DrawPlayerDeaths(Canvas C, int Table, int Index, int Column, int Top)
{
    local TeamPlayerReplicationInfo TeamPRI;

    TeamPRI = TeamPlayerReplicationInfo(Tables[Table].PRIs[Index]);
    if (TeamPRI != None)
    {
        DrawTextCellDual(C, int(Tables[Table].PRIs[Index].Deaths), TeamPRI.Suicides, Column, Top);
    }
    else
    {
        C.Font = MediumFont;
        DrawTextCell(C, int(Tables[Table].PRIs[Index].Deaths), Column, Top);
    }
}

simulated function DrawPlayerCaptures(Canvas C, int Table, int Index, int Column, int Top)
{
    local TeamPlayerReplicationInfo TeamPRI;

    TeamPRI = TeamPlayerReplicationInfo(Tables[Table].PRIs[Index]);
    if (TeamPRI != None)
    {
        DrawTextCellDual(C, TeamPRI.GoalsScored, TeamPRI.FlagTouches, Column, Top);
    }
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
    else
    {
        DrawTextCellDual(C, Tables[Table].Pings[Index], Tables[Table].PLs[Index], Column, Top);
    }
}

simulated function DrawPlayerPPH(Canvas C, int Table, int Index, int Column, float Top)
{
    local PlayerReplicationInfo PRI;
    local string FormattedTime;
    local float Time;
    local int PPH;

    PRI = Tables[Table].PRIs[Index];
    Time = Max(0, ElapsedTime - Tables[Table].PRIs[Index].StartTime);
    PPH = Clamp(3600 * Tables[Table].PRIs[Index].Score / FMax(1, Time), -999, 9999);
    if (GRI.bMatchHasBegun)
    {
        FormattedTime = FormatTime(Time);
    }
    else
    {
        FormattedTime = "--:--";
    }
    DrawTextCellDual(C, PPH, FormattedTime, Column, Top);
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
    local float TextWidth[3];
    local float TextHeight[3];

    if ((bShowPlayerPortraits && Columns[Column].Type == HX_SBCOL_Position)
        || Columns[Column].Type == HX_SBCOL_Portrait)
    {
        return (RowHeight * 1.2 + 1) & ~1;
    }
    C.Font = SmallFont;
    if (Columns[Column].Heading != "")
    {
        C.StrLen(Columns[Column].Heading, TextWidth[0], TextHeight[0]);
    }
    if (Columns[Column].SubHeading != "")
    {
        C.StrLen(Columns[Column].SubHeading, TextWidth[1], TextHeight[1]);
    }
    else if (!Columns[Column].bSmall)
    {
        C.Font = MediumFont;
    }
    if (Columns[Column].MinWidthValue != "")
    {
        C.StrLen(Columns[Column].MinWidthValue, TextWidth[2], TextHeight[2]);
    }
    return (FMax(TextWidth[0], FMax(TextWidth[1], TextWidth[2])) + MediumFontHeight + 1) & ~1;
}

simulated function int GetMaximumColumnSize(Canvas C, int Column)
{
    local float TextWidth;
    local float TextHeight;

    if (Columns[Column].MaxWidthValue == "")
    {
        return ColumnWidths[Column];
    }
    C.Font = MediumFont;
    C.StrLen(Columns[Column].MaxWidthValue, TextWidth, TextHeight);
    return Ceil(FMax(TextWidth + MediumFontHeight, ColumnWidths[Column]));
}

simulated function HxSBColumnConfig GetPositionColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_Position;
    Config.MinWidthValue = "111";
    Config.MaxWidthValue = "191";
    Config.bSmall = true;
    return Config;
}

simulated function HxSBColumnConfig GetPortraitColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_Portrait;
    Config.MinWidthValue = "111";
    Config.bCanHide = true;
    return Config;
}

simulated function HxSBColumnConfig GetPlayerColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_Player;
    Config.Heading = PlayerLabel;
    Config.MinWidthValue = MinNameWidthTestText;
    Config.MaxWidthValue = MaxNameWidthTestText;
    return Config;
}

simulated function HxSBColumnConfig GetScoreColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_Score;
    Config.Heading = ScoreLabel;
    Config.MinWidthValue = "9999";
    Config.MaxWidthValue = "999999";
    return Config;
}

simulated function HxSBColumnConfig GetLivesColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_Lives;
    Config.Heading = LivesLabel;
    Config.MinWidthValue = "9999";
    Config.MaxWidthValue = "999999";
    return Config;
}

simulated function HxSBColumnConfig GetPingColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_PingAndLoss;
    Config.Heading = PingLabel;
    Config.SubHeading = PacketLossLabel;
    Config.MinWidthValue = "999";
    return Config;
}

simulated function HxSBColumnConfig GetFragsColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_FragsAndEfficiency;
    Config.Heading = FragsLabel;
    Config.SubHeading = EfficiencyLabel;
    Config.MinWidthValue = "9999";
    Config.MaxWidthValue = "999999";
    Config.bCanHide = true;
    return Config;
}

simulated function HxSBColumnConfig GetDeathsColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_DeathsAndSuicides;
    Config.Heading = DeathsLabel;
    Config.SubHeading = SuicidesLabel;
    Config.MinWidthValue = "9999";
    Config.MaxWidthValue = "999999";
    Config.bCanHide = true;
    return Config;
}

simulated function HxSBColumnConfig GetCapturesColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_CapsAndGrabs;
    Config.Heading = CapturesLabel;
    Config.SubHeading = GrabsLabel;
    Config.MinWidthValue = "9999";
    Config.MaxWidthValue = "999999";
    Config.bCanHide = true;
    return Config;
}

simulated function HxSBColumnConfig GetPPHColumnConfig()
{
    local HxSBColumnConfig Config;

    Config.Type = HX_SBCOL_PPHAndTime;
    Config.Heading = PPHLabel;
    Config.SubHeading = TimeLabel;
    Config.MinWidthValue = FormatTime(0);
    Config.bCanHide = true;
    return Config;
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

defaultproperties
{
    Tables(0)=(TeamIndex=-1)
    ColumnTypes(0)=HX_SBCOL_Position
    ColumnTypes(1)=HX_SBCOL_Portrait
    ColumnTypes(2)=HX_SBCOL_Player
    ColumnTypes(3)=HX_SBCOL_Score
    BoardAlignment=HX_VALIGN_Top
    HeadingAlignment=HX_VALIGN_Center
    TeamScoreStyle=HX_SB_TSCORE_FullSize
    BorderSize=0.25
    DividerSize=0.2
    FontSizeModifier=0
    bAlternateRowColors=false
    bShowPlayerPortraits=false
    bShowPPHAndTime=false
    bShowBotCallSigns=false
    bShowBotOrders=true
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
    FallbackPortraitCrop=(Left=0,Top=20,Width=256,Height=256)
    UnknownPortraitCrop=(Left=0,Top=56,Width=256,Height=400)
    ReadyLabel="RDY"
    PlayerLabel="PLAYER (%)"
    LocationLabel="location"
    ScoreLabel="SCORE"
    FragsLabel="FRAGS"
    EfficiencyLabel="efficiency"
    LivesLabel="LIVES"
    DeathsLabel="DEATHS"
    SuicidesLabel="suicides"
    CapturesLabel="CAPS"
    GoalsLabel="GOALS"
    GrabsLabel="grabs"
    ReturnsLabel="returns"
    PingLabel="PING"
    PacketLossLabel="loss"
    PPHLabel="PPH"
    TimeLabel="time"
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
