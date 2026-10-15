class HxSBCaptureTheFlag extends HxTeamScoreBoard;

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
    ColumnTypes(4)=HX_SBCOL_Captures
    ColumnTypes(5)=HX_SBCOL_Frags
    ColumnTypes(6)=HX_SBCOL_Deaths
    ColumnTypes(7)=HX_SBCOL_Accuracy
    ColumnTypes(8)=HX_SBCOL_Ping
    ColumnTypes(9)=HX_SBCOL_PPH
}
