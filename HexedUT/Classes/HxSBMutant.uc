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
    ColumnTypes(4)=HX_SBCOL_Frags
    ColumnTypes(5)=HX_SBCOL_Deaths
    ColumnTypes(6)=HX_SBCOL_Accuracy
    ColumnTypes(7)=HX_SBCOL_Ping
    // TODO: removed because Mutant either doesn't update GRI.ElapsedTime or some other issue
    // with PRI.StartTime
    // ColumnTypes(8)=HX_SBCOL_PPH
}
