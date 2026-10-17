class HxSBDoubleDomination extends HxTeamScoreBoard;

simulated function LoadDefaults()
{
    Super.LoadDefaults();
    ColumnConfigs = class'HxSBDoubleDomination'.default.ColumnConfigs;
}

defaultproperties
{
    ColumnConfigs(0)=(MainStat=HX_SBS_Score)
    ColumnConfigs(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    ColumnConfigs(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_TeamKills)
    ColumnConfigs(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    ColumnConfigs(4)=(MainStat=HX_SBS_Rank)
}
