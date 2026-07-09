class HxSBDoubleDomination extends HxTeamScoreBoard;

simulated function ConfigureColumns()
{
    Columns[Columns.Length] = GetPositionColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetPlayerColumnConfig();
    Alignments[Alignments.Length] = TXTA_Left;
    Columns[Columns.Length] = GetScoreColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetFragsColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetDeathsColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetPingColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetPPHColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
}

simulated function DrawRow(Canvas C, int Table, int Index, int Row, int Top)
{
    DrawPlayerPosition(C, Table, Index, 0, Top);
    DrawPlayerName(C, Table, Index, 1, Top);
    C.Font = MediumFont;
    DrawTextCell(C, int(Tables[Table].PRIs[Index].Score), 2, Top);
    DrawPlayerFrags(C, Table, Index, 3, Top);
    DrawPlayerDeaths(C, Table, Index, 4, Top);
    DrawPlayerPing(C, Table, Index, 5, Top);
    DrawPlayerPPH(C, Table, Index, 6, Top);
}

defaultproperties
{
}
