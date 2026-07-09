class HxSBLastManStanding extends HxScoreBoard;

simulated function ConfigureColumns()
{
    Columns[Columns.Length] = GetPositionColumnConfig();
    Alignments[Alignments.Length] = TXTA_Center;
    Columns[Columns.Length] = GetPlayerColumnConfig();
    Alignments[Alignments.Length] = TXTA_Left;
    Columns[Columns.Length] = GetLivesColumnConfig();
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
    local plane SavedColorModulated;

    SavedColorModulated = C.ColorModulate;
    C.Font = MediumFont;
    if (Tables[Table].PRIs[Index].bOutOfLives)
    {
        C.ColorModulate = class'ScoreBoardLMS'.default.GrayedOut;
        DrawTextCell(C, class'ScoreBoardLMS'.default.OutText, 2, Top);
    }
    else
    {
        C.ColorModulate = class'ScoreBoardLMS'.default.FullOn;
        DrawTextCell(C, int(GRI.MaxLives - Tables[Table].PRIs[Index].Deaths), 2, Top);
    }
    DrawPlayerPosition(C, Table, Index, 0, Top);
    DrawPlayerName(C, Table, Index, 1, Top);
    DrawPlayerFrags(C, Table, Index, 3, Top);
    DrawPlayerDeaths(C, Table, Index, 4, Top);
    DrawPlayerPing(C, Table, Index, 5, Top);
    DrawPlayerPPH(C, Table, Index, 6, Top);
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
}
