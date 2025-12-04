class HxHUDMutant extends HudMutant;

#include Classes\Include\BaseHUD.uci

simulated function DrawHudPassA(Canvas C)
{
    YRad = default.YRad * XYRatio;
    Super.DrawHudPassA(C);
}
