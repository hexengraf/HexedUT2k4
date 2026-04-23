class MutHexedINSTAGIB extends HxMutator;

var config bool bAllowTranslocator;
var config bool bAllowBoost;
var config bool bZoomInstagib;
var config float FireRate;

function PreBeginPlay()
{
    Super.PreBeginPlay();
    if (bZoomInstagib)
    {
        DefaultWeaponName = string(class'HxZoomSuperShockRifle');
    }
    else
    {
        DefaultWeaponName = string(class'HxSuperShockRifle');
    }
    DefaultWeapon = class<Weapon>(DynamicLoadObject(DefaultWeaponName, class'Class'));
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if (bAllowBoost && TeamGame(Level.Game) != None)
    {
        TeamGame(Level.Game).TeammateBoost = 1.0;
    }
    if (bAllowTranslocator)
    {
        DeathMatch(Level.Game).bOverrideTranslocator = true;
    }
    HidePickupBases(Self);
}

function ModifyPlayer(Pawn Pawn)
{
    ModifyFireRate(Pawn);
    Super.ModifyPlayer(Pawn);
}

function string RecommendCombo(string ComboName)
{
    if (ComboName != "xGame.ComboSpeed" && ComboName != "xGame.ComboInvis")
    {
        return Super.RecommendCombo(Eval(FRand() < 0.65, "xGame.ComboInvis", "xGame.ComboSpeed"));
    }
    return Super.RecommendCombo(ComboName);
}

function bool AlwaysKeep(Actor Other)
{
    if (Other.Class == DefaultWeapon || Other.IsA('SuperShockAmmo'))
    {
        Super.AlwaysKeep(Other);
        return true;
    }
    return Super.AlwaysKeep(Other);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (Other.IsA('Weapon'))
    {
        if (Weapon(Other).bNoInstagibReplace
            || (DeathMatch(Level.Game).bOverrideTranslocator && Other.IsA('TransLauncher')))
        {
            bSuperRelevant = 0;
            return true;
        }
        if (Other.Class != DefaultWeapon)
        {
            Level.Game.bWeaponStay = false;
            return false;
        }
    }
    else if (Other.IsA('Pickup'))
    {
        if (Other.bStatic || Other.bNoDelete)
        {
            Other.GotoState('Disabled');
        }
        return false;
    }
    else if (Other.IsA('xPickupBase'))
    {
        Other.bHidden = true;
    }
    return Super.CheckReplacement(Other, bSuperRelevant);
}

function PropertyChanged(int Index, string OldValue)
{
    local int i;

    if (Properties[Index].Name == "FireRate")
    {
        for (i = 0; i < CRIs.Length; ++i)
        {
            if (PlayerController(CRIs[i].Owner).Pawn != None)
            {
                ModifyFireRate(PlayerController(CRIs[i].Owner).Pawn, true);
            }
        }
    }
}

function ModifyFireRate(Pawn Pawn, optional bool bForce)
{
    local Inventory Inv;

    if (FireRate > 0 || bForce)
    {
        for (Inv = Pawn.Inventory; Inv != None; Inv = Inv.inventory)
        {
            if (HxZoomSuperShockRifle(Inv) != None)
            {
                HxZoomSuperShockRifle(Inv).SetFireRate(FireRate);
                break;
            }
            if (HxSuperShockRifle(Inv) != None)
            {
                HxSuperShockRifle(Inv).SetFireRate(FireRate);
                break;
            }
        }
    }
}

static function HidePickupBases(Actor Requester)
{
    local xPickupBase P;
    local WeaponLocker L;

    foreach Requester.AllActors(class'xPickupBase', P)
    {
        P.bHidden = true;
        if (P.myEmitter != None)
        {
            P.myEmitter.Destroy();
        }
    }
    foreach Requester.AllActors(class'WeaponLocker', L)
    {
        L.GotoState('Disabled');
    }
}

defaultproperties
{
    FriendlyName="HexedINSTAGIB v7preview1"
    Description="Instant-kill combat with modified Shock Rifles with options to enable zoom and change fire rate."
    GroupName="Arena"
    bAddToServerPackages=true
    CRIClass=class'HxIGClient'
    Properties(0)=(Name="bAllowTranslocator",Caption="Allow Translocator",Hint="Players get a Translocator in their inventory. Applied on restart/map change.",Type="Check")
    Properties(1)=(Name="bAllowBoost",Caption="Allow Teammate boosting",Hint="Teammates get a big boost when shot by the instagib rifle. Applied on restart/map change.",Type="Check")
    Properties(2)=(Name="bZoomInstagib",Caption="Allow Zoom",Hint="Instagib rifles have sniper scopes. Applied on restart/map change.",Type="Check")
    Properties(3)=(Name="FireRate",Caption="Fire rate",Hint="Change the default fire rate of shock rifles (0 = default). Applied instantly.",Type="Text",Data="8;0.0:2.0",bAdvanced=true)
    bDisableTick=true
}
