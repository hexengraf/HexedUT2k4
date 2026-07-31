class HxSBMutant extends HxScoreBoard;

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
    // TODO: removed for now because Mutant doesn't update Frags count
    // ColumnTypes(4)=HX_SBCOL_FragsAndEfficiency
    ColumnTypes(4)=HX_SBCOL_DeathsAndSuicides
    ColumnTypes(5)=HX_SBCOL_PingAndLoss
    // TODO: removed because Mutant either doesn't update GRI.ElapsedTime or some other issue
    // with PRI.StartTime
    // ColumnTypes(7)=HX_SBCOL_PPHAndTime
}
