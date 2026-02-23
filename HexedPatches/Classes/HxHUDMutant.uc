class HxHUDMutant extends HudMutant;

#include Classes\Include\BaseHUD.uci

simulated function DrawHudPassA(Canvas C)
{
    if (!bOldUnrealPatch)
    {
        YRad = default.YRad * XYRatio;
    }
    Super.DrawHudPassA(C);
}
