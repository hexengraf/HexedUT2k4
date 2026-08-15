class HxUTPlayerInteraction extends HxInteraction;

enum EHxViewSmoothing
{
    HX_VS_Default,
    HX_VS_Moderate,
    HX_VS_Weak,
    HX_VS_Disabled,
};

var EHxViewSmoothing ViewSmoothing;

var private PlayerController PC;
var private bool bAllowCustomViewSmoothing;

simulated event Tick(float DeltaTime)
{
    PC = ViewportOwner.Actor;
    if (bAllowCustomViewSmoothing && PC != None && PC.Pawn != None
        && ViewSmoothing != HX_VS_Default)
    {
        ModifyViewSmoothing(PC.Pawn, DeltaTime);
    }
}

simulated function ModifyViewSmoothing(Pawn P, float DeltaTime)
{
    local float MaxDeltaZ;
    local float DeltaZ;

    if (!P.bJustLanded && !P.bLandRecovery
        && (P.Physics == PHYS_Walking || P.Physics == PHYS_Spider))
    {
        MaxDeltaZ = Abs(P.BaseEyeHeight - P.EyeHeight);
        DeltaZ = FClamp(P.Location.Z - P.OldZ, -MaxDeltaZ, MaxDeltaZ);
        switch (ViewSmoothing)
        {
            case HX_VS_Moderate:
                if (P.Floor.Z > P.MINFLOORZ && P.Floor.Z < 0.96)
                {
                    P.EyeHeight += DeltaZ;
                }
                break;
            case HX_VS_Weak:
                if (P.Floor.Z > P.MINFLOORZ && P.Floor.Z < 0.99)
                {
                    P.EyeHeight += DeltaZ;
                }
                break;
            case HX_VS_Disabled:
                P.EyeHeight += DeltaZ;
                break;
        }
    }
}

simulated function ApplyServerConfiguration(HxUTClient Client)
{
    bAllowCustomViewSmoothing = bool(Client.GetServerProperty("bAllowCustomViewSmoothing"));
}

static function HxUTPlayerInteraction Find(Player Owner)
{
    return HxUTPlayerInteraction(FindInteraction(Owner, default.Class));
}

static function HxUTPlayerInteraction Add(Player Owner)
{
    return HxUTPlayerInteraction(AddInteraction(Owner, default.Class));
}

defaultproperties
{
    bActive=true
    bRequiresTick=true
}
