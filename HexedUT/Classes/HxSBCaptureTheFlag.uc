class HxSBCaptureTheFlag extends HxTeamScoreBoard;

simulated function LoadDefaults()
{
    Super.LoadDefaults();
    ColumnConfigs = class'HxSBCaptureTheFlag'.default.ColumnConfigs;
}

simulated function bool DrawPlayerMarker(Canvas C, int Table, int Index, int Column, int Top)
{
    if (Tables[Table].PRIs[Index].HasFlag != None
        || Tables[Table].PRIs[Index] == GRI.FlagHolder[Table])
    {
        DrawIconCell(C, class'ScoreBoardTeamDeathMatch'.default.FlagIcon, Column, Top);
        return true;
    }
    return false;
}

defaultproperties
{
    ColumnConfigs(0)=(MainStat=HX_SBS_Score)
    ColumnConfigs(1)=(MainStat=HX_SBS_Captures,SecStat=HX_SBS_Touches)
    ColumnConfigs(2)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    ColumnConfigs(3)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_TeamKills)
    ColumnConfigs(4)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    ColumnConfigs(5)=(MainStat=HX_SBS_Rank)
}
