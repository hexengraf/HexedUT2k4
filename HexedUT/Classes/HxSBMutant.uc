class HxSBMutant extends HxScoreBoard;

simulated function LoadDefaults()
{
    Super.LoadDefaults();
    ColumnConfigs = class'HxSBMutant'.default.ColumnConfigs;
}

simulated function bool DrawPlayerMarker(Canvas C, int Table, int Index, int Column, int Top)
{
    local MutantGameReplicationInfo MutantInfo;

    MutantInfo = MutantGameReplicationInfo(GRI);
    if (Tables[Table].PRIs[Index] == MutantInfo.BottomFeederPRI)
    {
        DrawIconCell(C, class'MutantScoreboard'.default.BottomFeederMarker, Column, Top);
        return true;
    }
    if (Tables[Table].PRIs[Index] == MutantInfo.MutantPRI)
    {
        DrawIconCell(C, class'MutantScoreboard'.default.MutantMarker, Column, Top);
        return true;
    }
    return false;
}

defaultproperties
{
    ColumnConfigs(0)=(MainStat=HX_SBS_Score)
    ColumnConfigs(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    ColumnConfigs(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_Suicides)
    ColumnConfigs(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    ColumnConfigs(4)=(MainStat=HX_SBS_Rank)
}
