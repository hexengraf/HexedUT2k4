class HxPlayerModifiers extends Info
    config(User);

enum EHxViewSmoothing
{
    HX_VS_Default,
    HX_VS_Weak,
    HX_VS_Disabled,
};

var config EHxViewSmoothing ViewSmoothing;

var private PlayerController PC;
var private bool bAllowCustomViewSmoothing;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    PC = PlayerController(Owner);
}

simulated event Tick(float DeltaTime)
{
    if (PC.Pawn != None && bAllowCustomViewSmoothing && ViewSmoothing != HX_VS_Default)
    {
        ModifyViewSmoothing(PC.Pawn, DeltaTime);
    }
}

simulated function ModifyViewSmoothing(Pawn P, float DeltaTime)
{
    local float DeltaZ;

    if (!P.bJustLanded && !P.bLandRecovery
        && (P.Physics == PHYS_Walking || P.Physics == PHYS_Spider))
    {
        DeltaZ = P.Location.Z - P.OldZ;
        DeltaTime /= Level.TimeDilation;
        switch (ViewSmoothing)
        {
            case HX_VS_Weak:
                WeakViewSmoothing(P, DeltaZ, DeltaTime);
                break;
            case HX_VS_Disabled:
                DisableViewSmoothing(P, DeltaZ, DeltaTime);
                break;
        }
    }
}

simulated function WeakViewSmoothing(Pawn P, float DeltaZ, float DeltaTime)
{
    if (Abs(DeltaZ) <= DeltaTime * P.GroundSpeed)
    {
        P.EyeHeight += DeltaZ;
    }
}

simulated function DisableViewSmoothing(Pawn P, float DeltaZ, float DeltaTime)
{
    P.EyeHeight += FClamp(DeltaZ, -MAXSTEPHEIGHT, MAXSTEPHEIGHT);
}

simulated function ApplyServerConfiguration(HxUTClient Client)
{
    bAllowCustomViewSmoothing = bool(Client.GetServerProperty("bAllowCustomViewSmoothing"));
}

static function SetViewSmoothing(string Value)
{
    switch (Value)
    {
        case "HX_VS_Default":
            class'HxPlayerModifiers'.default.ViewSmoothing = HX_VS_Default;
            break;
        case "HX_VS_Weak":
            class'HxPlayerModifiers'.default.ViewSmoothing = HX_VS_Weak;
            break;
        case "HX_VS_Disabled":
            class'HxPlayerModifiers'.default.ViewSmoothing = HX_VS_Disabled;
            break;
    }
}

defaultproperties
{
}
