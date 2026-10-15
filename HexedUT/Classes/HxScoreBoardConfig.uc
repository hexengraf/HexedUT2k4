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
var config bool bShowSecondaryInfo;
var config bool bShowPlayerPortraits;
var config bool bShowPPHAndTime;
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
    class'HxScoreBoard'.default.bShowSecondaryInfo = bShowSecondaryInfo;
    class'HxScoreBoard'.default.bShowPlayerPortraits = bShowPlayerPortraits;
    class'HxScoreBoard'.default.bShowPPHAndTime = bShowPPHAndTime;
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
    UpdateScoreBoard();
}

function ApplyProperty(int Index)
{
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
            class'HxScoreBoard'.default.bShowSecondaryInfo = bShowSecondaryInfo;
            break;
        case 9:
            class'HxScoreBoard'.default.bShowPlayerPortraits = bShowPlayerPortraits;
            break;
        case 10:
            class'HxScoreBoard'.default.bShowPPHAndTime = bShowPPHAndTime;
            break;
        case 11:
            class'HxScoreBoard'.default.bShowBotCallSigns = bShowBotCallSigns;
            break;
        case 12:
            class'HxScoreBoard'.default.bShowBotOrders = bShowBotOrders;
            break;
        case 13:
            class'HxScoreBoard'.default.bShowShortcuts = bShowShortcuts;
            break;
        case 14:
            class'HxScoreBoard'.default.bShowTimestamp = bShowTimestamp;
            break;
        case 15:
            class'HxScoreBoard'.default.HeaderColor = HeaderColor;
            break;
        case 16:
            class'HxTeamScoreBoard'.default.TeamHeaderColors[0] = RedTeamHeaderColor;
            break;
        case 17:
            class'HxTeamScoreBoard'.default.TeamHeaderColors[1] = BlueTeamHeaderColor;
            break;
        case 18:
            class'HxScoreBoard'.default.RowColor = RowColor;
            break;
        case 19:
            class'HxTeamScoreBoard'.default.TeamRowColors[0] = RedTeamRowColor;
            break;
        case 20:
            class'HxTeamScoreBoard'.default.TeamRowColors[1] = BlueTeamRowColor;
            break;
        case 21:
            class'HxScoreBoard'.default.AltRowColor = AltRowColor;
            break;
        case 22:
            class'HxTeamScoreBoard'.default.TeamAltRowColors[0] = RedTeamAltRowColor;
            break;
        case 23:
            class'HxTeamScoreBoard'.default.TeamAltRowColors[1] = BlueTeamAltRowColor;
            break;
        case 24:
            class'HxScoreBoard'.default.BorderColor = BorderColor;
            break;
        case 25:
            class'HxTeamScoreBoard'.default.TeamBorderColors[0] = RedTeamBorderColor;
            break;
        case 26:
            class'HxTeamScoreBoard'.default.TeamBorderColors[1] = BlueTeamBorderColor;
            break;
        case 27:
            class'HxScoreBoard'.default.DividerColor = DividerColor;
            break;
        case 28:
            class'HxTeamScoreBoard'.default.TeamDividerColors[0] = RedTeamDividerColor;
            break;
        case 29:
            class'HxTeamScoreBoard'.default.TeamDividerColors[1] = BlueTeamDividerColor;
            break;
        case 30:
            class'HxScoreBoard'.default.ScrollThumbColor = ScrollThumbColor;
            break;
        case 31:
            class'HxTeamScoreBoard'.default.TeamScrollThumbColors[0] = RedTeamScrollThumbColor;
            break;
        case 32:
            class'HxTeamScoreBoard'.default.TeamScrollThumbColors[1] = BlueTeamScrollThumbColor;
            break;
        case 33:
            class'HxTeamScoreBoard'.default.TeamColors[0] = RedTeamColor;
            break;
        case 34:
            class'HxTeamScoreBoard'.default.TeamColors[1] = BlueTeamColor;
            break;
        case 35:
            class'HxScoreBoard'.default.TextColor = TextColor;
            break;
        case 36:
            class'HxScoreBoard'.default.SecondTextColor = SecondTextColor;
            break;
        case 37:
            class'HxScoreBoard'.default.HighlightTextColor = HighlightTextColor;
            break;
        case 38:
            class'HxScoreBoard'.default.ReadyColor = ReadyColor;
            break;
    }
    UpdateScoreBoard();
}

function bool ResetProperty(int Index)
{
    local bool bReset;

    switch (Index)
    {
        case 0:
            bEnabled = default.bEnabled;
            bReset = true;
            break;
        case 1:
            BoardAlignment = default.BoardAlignment;
            bReset = true;
            break;
        case 2:
            HeadingAlignment = default.HeadingAlignment;
            bReset = true;
            break;
        case 3:
            BorderSize = default.BorderSize;
            bReset = true;
            break;
        case 4:
            DividerSize = default.DividerSize;
            bReset = true;
            break;
        case 5:
            FontSizeModifier = default.FontSizeModifier;
            bReset = true;
            break;
        case 6:
            bAlternateRowColors = default.bAlternateRowColors;
            bReset = true;
            break;
        case 7:
            bCompactTeamScores = default.bCompactTeamScores;
            bReset = true;
            break;
        case 8:
            bShowSecondaryInfo = default.bShowSecondaryInfo;
            bReset = true;
            break;
        case 9:
            bShowPlayerPortraits = default.bShowPlayerPortraits;
            bReset = true;
            break;
        case 10:
            bShowPPHAndTime = default.bShowPPHAndTime;
            bReset = true;
            break;
        case 11:
            bShowBotCallSigns = default.bShowBotCallSigns;
            bReset = true;
            break;
        case 12:
            bShowBotOrders = default.bShowBotOrders;
            bReset = true;
            break;
        case 13:
            bShowShortcuts = default.bShowShortcuts;
            bReset = true;
            break;
        case 14:
            bShowTimestamp = default.bShowTimestamp;
            bReset = true;
            break;
        case 15:
            HeaderColor = default.HeaderColor;
            bReset = true;
            break;
        case 16:
            RedTeamHeaderColor = default.RedTeamHeaderColor;
            bReset = true;
            break;
        case 17:
            BlueTeamHeaderColor = default.BlueTeamHeaderColor;
            bReset = true;
            break;
        case 18:
            RowColor = default.RowColor;
            bReset = true;
            break;
        case 19:
            RedTeamRowColor = default.RedTeamRowColor;
            bReset = true;
            break;
        case 20:
            BlueTeamRowColor = default.BlueTeamRowColor;
            bReset = true;
            break;
        case 21:
            AltRowColor = default.AltRowColor;
            bReset = true;
            break;
        case 22:
            RedTeamAltRowColor = default.RedTeamAltRowColor;
            bReset = true;
            break;
        case 23:
            BlueTeamAltRowColor = default.BlueTeamAltRowColor;
            bReset = true;
            break;
        case 24:
            BorderColor = default.BorderColor;
            bReset = true;
            break;
        case 25:
            RedTeamBorderColor = default.RedTeamBorderColor;
            bReset = true;
            break;
        case 26:
            BlueTeamBorderColor = default.BlueTeamBorderColor;
            bReset = true;
            break;
        case 27:
            DividerColor = default.DividerColor;
            bReset = true;
            break;
        case 28:
            RedTeamDividerColor = default.RedTeamDividerColor;
            bReset = true;
            break;
        case 29:
            BlueTeamDividerColor = default.BlueTeamDividerColor;
            bReset = true;
            break;
        case 30:
            ScrollThumbColor = default.ScrollThumbColor;
            bReset = true;
            break;
        case 31:
            RedTeamScrollThumbColor = default.RedTeamScrollThumbColor;
            bReset = true;
            break;
        case 32:
            BlueTeamScrollThumbColor = default.BlueTeamScrollThumbColor;
            bReset = true;
            break;
        case 33:
            RedTeamColor = default.RedTeamColor;
            bReset = true;
            break;
        case 34:
            BlueTeamColor = default.BlueTeamColor;
            bReset = true;
            break;
        case 35:
            TextColor = default.TextColor;
            bReset = true;
            break;
        case 36:
            SecondTextColor = default.SecondTextColor;
            bReset = true;
            break;
        case 37:
            HighlightTextColor = default.HighlightTextColor;
            bReset = true;
            break;
        case 38:
            ReadyColor = default.ReadyColor;
            bReset = true;
            break;
    }
    if (bReset)
    {
        UpdateScoreBoard();
    }
    return bReset;
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

function UpdateScoreBoard()
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
    Properties(8)=(Name="bShowSecondaryInfo",Type=HX_PROPERTY_Bool)
    Properties(9)=(Name="bShowPlayerPortraits",Type=HX_PROPERTY_Bool)
    Properties(10)=(Name="bShowPPHAndTime",Type=HX_PROPERTY_Bool)
    Properties(11)=(Name="bShowBotCallSigns",Type=HX_PROPERTY_Bool)
    Properties(12)=(Name="bShowBotOrders",Type=HX_PROPERTY_Bool)
    Properties(13)=(Name="bShowShortcuts",Type=HX_PROPERTY_Bool)
    Properties(14)=(Name="bShowTimestamp",Type=HX_PROPERTY_Bool)
    Properties(15)=(Name="HeaderColor",Type=HX_PROPERTY_Color)
    Properties(16)=(Name="RedTeamHeaderColor",Type=HX_PROPERTY_Color)
    Properties(17)=(Name="BlueTeamHeaderColor",Type=HX_PROPERTY_Color)
    Properties(18)=(Name="RowColor",Type=HX_PROPERTY_Color)
    Properties(19)=(Name="RedTeamRowColor",Type=HX_PROPERTY_Color)
    Properties(20)=(Name="BlueTeamRowColor",Type=HX_PROPERTY_Color)
    Properties(21)=(Name="AltRowColor",Type=HX_PROPERTY_Color)
    Properties(22)=(Name="RedTeamAltRowColor",Type=HX_PROPERTY_Color)
    Properties(23)=(Name="BlueTeamAltRowColor",Type=HX_PROPERTY_Color)
    Properties(24)=(Name="BorderColor",Type=HX_PROPERTY_Color)
    Properties(25)=(Name="RedTeamBorderColor",Type=HX_PROPERTY_Color)
    Properties(26)=(Name="BlueTeamBorderColor",Type=HX_PROPERTY_Color)
    Properties(27)=(Name="DividerColor",Type=HX_PROPERTY_Color)
    Properties(28)=(Name="RedTeamDividerColor",Type=HX_PROPERTY_Color)
    Properties(29)=(Name="BlueTeamDividerColor",Type=HX_PROPERTY_Color)
    Properties(30)=(Name="ScrollThumbColor",Type=HX_PROPERTY_Color)
    Properties(31)=(Name="RedTeamScrollThumbColor",Type=HX_PROPERTY_Color)
    Properties(32)=(Name="BlueTeamScrollThumbColor",Type=HX_PROPERTY_Color)
    Properties(33)=(Name="RedTeamColor",Type=HX_PROPERTY_Color)
    Properties(34)=(Name="BlueTeamColor",Type=HX_PROPERTY_Color)
    Properties(35)=(Name="TextColor",Type=HX_PROPERTY_Color)
    Properties(36)=(Name="SecondTextColor",Type=HX_PROPERTY_Color)
    Properties(37)=(Name="HighlightTextColor",Type=HX_PROPERTY_Color)
    Properties(38)=(Name="ReadyColor",Type=HX_PROPERTY_Color)

    bEnabled=true
    BoardAlignment=HX_VALIGN_Top
    HeadingAlignment=HX_VALIGN_Center
    BorderSize=0.25
    DividerSize=0.2
    FontSizeModifier=0
    bAlternateRowColors=false
    bCompactTeamScores=false
    bShowSecondaryInfo=true
    bShowPlayerPortraits=true
    bShowPPHAndTime=false
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
}
