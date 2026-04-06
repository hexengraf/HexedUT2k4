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
var private byte DisabledCombos[4];
var private class<Combo> NullComboClass;
var private string NullComboName;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    PC = PlayerController(Owner);
    NullComboName = string(NullComboClass);
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

simulated event WeakViewSmoothing(Pawn P, float DeltaZ, float DeltaTime)
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

simulated function bool ShouldDisableCombo(coerce string Name)
{
    if (Name ~= "XGame.ComboSpeed")
    {
        return DisabledCombos[0] == 1;
    }
    if (Name ~= "XGame.ComboBerserk")
    {
        return DisabledCombos[1] == 1;
    }
    if (Name ~= "XGame.ComboDefensive")
    {
        return DisabledCombos[2] == 1;
    }
    if (Name ~= "XGame.ComboInvis")
    {
        return DisabledCombos[3] == 1;
    }
    return false;
}

simulated function ModifyPlayerCombos(xPlayer Player)
{
    local int i;

    if (Player != None)
    {
        for (i = 0; i < ArrayCount(Player.ComboNameList); ++i)
        {
            if (Player.ComboNameList[i] == "")
            {
                break;
            }
            if (Player.ComboNameList[i] == NullComboName)
            {
                if (!ShouldDisableCombo(Player.default.ComboNameList[i]))
                {
                    Player.ComboNameList[i] = Player.default.ComboNameList[i];
                    Player.ComboList[i] = class<Combo>(
                        DynamicLoadObject(Player.ComboNameList[i], class'Class', true));
                }
            }
            else if (ShouldDisableCombo(Player.ComboNameList[i]))
            {
                Player.ComboNameList[i] = NullComboName;
                Player.ComboList[i] = NullComboClass;
            }
        }
    }
}

simulated function ApplyServerConfiguration(HxUTClient Client)
{
    bAllowCustomViewSmoothing = bool(Client.GetServerProperty("bAllowCustomViewSmoothing"));
    SetDisabledCombos(Client);
}

simulated function SetDisabledCombos(HxUTClient Client)
{
    DisabledCombos[0] = byte(bool(Client.GetServerProperty("bDisableSpeedCombo")));
    DisabledCombos[1] = byte(bool(Client.GetServerProperty("bDisableBerserkCombo")));
    DisabledCombos[2] = byte(bool(Client.GetServerProperty("bDisableBoosterCombo")));
    DisabledCombos[3] = byte(bool(Client.GetServerProperty("bDisableInvisibleCombo")));
    ModifyPlayerCombos(xPlayer(PC));
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
    NullComboClass=class'HxComboNull'
}
