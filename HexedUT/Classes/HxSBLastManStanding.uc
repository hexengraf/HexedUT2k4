class HxSBLastManStanding extends HxScoreBoard;

simulated function LoadDefaults()
{
    Super.LoadDefaults();
    ColumnConfigs = class'HxSBLastManStanding'.default.ColumnConfigs;
}

simulated function DrawRow(Canvas C, int Table, int Index, int Row, int Top)
{
    local plane SavedColorModulated;

    SavedColorModulated = C.ColorModulate;
    if (Tables[Table].PRIs[Index].bOutOfLives)
    {
        C.ColorModulate = class'ScoreBoardLMS'.default.GrayedOut;
    }
    else
    {
        C.ColorModulate = class'ScoreBoardLMS'.default.FullOn;
    }
    Super.DrawRow(C, Table, Index, Row, Top);
    C.ColorModulate = SavedColorModulated;
}

simulated function bool InOrder(PlayerReplicationInfo P1, PlayerReplicationInfo P2)
{
    if (P1.bOnlySpectator)
    {
        if (P2.bOnlySpectator)
        {
            return true;
        }
        return false;
    }
    else if (P2.bOnlySpectator)
    {
        return true;
    }
    if (P1.Deaths > P2.Deaths)
    {
        return false;
    }
    if (P1.Deaths == P2.Deaths)
    {
        if (P1.Score < P2.Score)
        {
            return false;
        }
        if (P1.Score == P2.Score && PlayerController(P2.Owner) != None
            && Viewport(PlayerController(P2.Owner).Player) != None)
        {
            return false;
        }
    }
    return true;
}

defaultproperties
{
    ColumnConfigs(0)=(MainStat=HX_SBS_Lives)
    ColumnConfigs(1)=(MainStat=HX_SBS_Frags,SecStat=HX_SBS_MaxSpree)
    ColumnConfigs(2)=(MainStat=HX_SBS_Deaths,SecStat=HX_SBS_Suicides)
    ColumnConfigs(3)=(MainStat=HX_SBS_Accuracy,SecStat=HX_SBS_Efficiency)
    ColumnConfigs(4)=(MainStat=HX_SBS_Rank)
}
