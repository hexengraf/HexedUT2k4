class HxHUDAssault extends HUD_Assault;

#include Classes\Include\BaseHUD.uci

simulated event PostBeginPlay()
{
    local int i;

    Super.PostBeginPlay();

    for (i = 0; i < 2; ++i)
    {
        RoundTimeBackground.Tints[i] = HudColorBlack;
        RoundTimeBackground.Tints[i].A = 150;
        ReinforceBackground.Tints[i] = HudColorBlack;
        ReinforceBackground.Tints[i].A = 150;
        VSBackground.Tints[i] = HudColorBlack;
        VSBackground.Tints[i].A = 150;
        TeleportBackground.Tints[i] = HudColorBlack;
        TeleportBackground.Tints[i].A = 150;
        ReinforcePulse.Tints[i] = HudColorHighLight;
        TeleportPulse.Tints[i] = HudColorHighLight;
    }
}

simulated function DrawRoundTimeLimit(Canvas C, float PosY)
{
    DrawSpriteWidget(C, RoundTimeBackground);
    DrawSpriteWidget(C, RoundTimeBackgroundDisc);
    DrawSpriteWidget(C, RoundTimeSeparator);
    DrawSpriteWidget(C, RoundTimeIcon);
    DrawNumericWidget(C, RoundTimeMinutes, DigitsBig);
    DrawNumericWidget(C, RoundTimeSeconds, DigitsBig);
}

simulated function DrawReinforcementsCountdown(Canvas C, float PosY)
{
    ReinforceBackground.PosY = PosY;
    DrawSpriteWidget(C, ReinforceBackground);
    ReinforceBackgroundDisc.PosY = PosY;
    DrawSpriteWidget(C, ReinforceBackgroundDisc);
    if (ASGRI.ReinforcementCountDown < 1)
    {
        ReinforcePulse.PosY = PosY;
        DrawSpriteWidget(C, ReinforcePulse);
    }
    ReinforceIcon.PosY = PosY;
    DrawSpriteWidget(C, ReinforceIcon);
    ReinforceSprNum.PosY = PosY;
    DrawNumericWidget(C, ReinforceSprNum, DigitsBig);
}

simulated function DrawWaveComparison(Canvas C, float PosY)
{
    VSBackground.PosY = PosY;
    DrawSpriteWidget(C, VSBackground);
    VSBackgroundDisc.PosY = PosY;
    DrawSpriteWidget(C, VSBackgroundDisc);
    VSIcon.PosY = PosY;
    DrawSpriteWidget(C, VSIcon);
    DrawTeamVS(C);
}

simulated function DrawTeleport(Canvas C, float PosY)
{
    TeleportBackground.PosY = PosY;
    DrawSpriteWidget(C, TeleportBackground);
    TeleportBackgroundDisc.PosY = PosY;
    DrawSpriteWidget(C, TeleportBackgroundDisc);
    TeleportPulse.PosY = PosY;
    DrawSpriteWidget(C, TeleportPulse);
    TeleportIcon.PosY = PosY;
    DrawSpriteWidget(C, TeleportIcon);
    TeleportSprNum.PosY = PosY;
    DrawNumericWidget(C, TeleportSprNum, DigitsBig);
}

simulated function ShowTeamScorePassA(Canvas C)
{
    local float PosY;
    local float DeltaY;

    if (ASGRI != None)
    {
        DeltaY = 0.06 * XYRatio * HUDScale;
        if (ASGRI.RoundTimeLimit > 0)
        {
            DrawRoundTimeLimit(C, PosY);
            PosY += DeltaY;
        }
        if (Level.Game == None || !ASGameInfo(Level.Game).bDisableReinforcements)
        {
            DrawReinforcementsCountdown(C, PosY);
            PosY += DeltaY;
        }
        if (ASGRI.CurrentRound % 2 == 0 && !ASGRI.IsPracticeRound() && IsVSRelevant())
        {
            DrawWaveComparison(C, PosY);
            PosY += DeltaY;
        }
        if (ASPRI != None && ASPRI.bTeleportToSpawnArea && TeleportSprNum.Value >= 0)
        {
            DrawTeleport(C, PosY);
        }
    }
}
