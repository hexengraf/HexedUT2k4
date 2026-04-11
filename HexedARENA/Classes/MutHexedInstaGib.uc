class MutHexedInstaGib extends HxMutator;

var config bool bAllowTranslocator;
var config bool bAllowBoost;
var config bool bZoomInstagib;
var config float FireRate;

var private name WeaponName;
var private name AmmoName;
var private bool bConfigurationApplied;
var private bool bTranslocatorEnabled;
var private bool bBoostEnabled;
var private bool bZoomEnabled;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if (bZoomInstagib)
    {
        DefaultWeaponName = string(class'HxZoomSuperShockRifle');
    }
    else
    {
        DefaultWeaponName = string(class'HxSuperShockRifle');
    }
}

function ApplyConfiguration()
{
    local class<Weapon> WeaponClass;

    if (bAllowBoost && TeamGame(Level.Game) != None)
    {
        TeamGame(Level.Game).TeammateBoost = 1.0;
    }
    if (bAllowTranslocator)
    {
        DeathMatch(Level.Game).bOverrideTranslocator = true;
    }
    WeaponClass = class<Weapon>(DynamicLoadObject(DefaultWeaponName, class'Class', true));
    if (WeaponClass != None)
    {
        WeaponName = WeaponClass.Name;
        AmmoName = WeaponClass.default.FireModeClass[0].default.AmmoClass.Name;
    }
    DisablePickupBases(Self);
    bConfigurationApplied = true;
}

function Tick(float DeltaTime)
{
    if (!bConfigurationApplied)
    {
        ApplyConfiguration();
    }
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
    if (Other.IsA(WeaponName) || Other.IsA(AmmoName))
    {
        if (NextMutator != None)
        {
            NextMutator.AlwaysKeep(Other);
        }
        return true;
    }
    return Super.AlwaysKeep(Other);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (Other.IsA('Weapon'))
    {
        if (Weapon(Other).bNoInstagibReplace)
        {
            bSuperRelevant = 0;
            return true;
        }
        if (Other.IsA('TransLauncher') && DeathMatch(Level.Game).bOverrideTranslocator)
        {
            bSuperRelevant = 0;
            return true;
        }
        if (!Other.IsA(WeaponName))
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
    return Super.CheckReplacement(Other, bSuperRelevant);
}

function ModifyFireRate(Pawn Pawn)
{
    local inventory Inv;

    if (FireRate > 0)
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

static function DisablePickupBases(Actor Requester)
{
    local xPickupBase P;
    local Pickup L;

    foreach Requester.AllActors(class'xPickupBase', P)
    {
        P.bHidden = true;
        if (P.myEmitter != None)
        {
            P.myEmitter.Destroy();
        }
    }
    foreach Requester.AllActors(class'Pickup', L)
    {
        if (L.IsA('WeaponLocker'))
        {
            L.GotoState('Disabled');
        }
    }
}

defaultproperties
{
    FriendlyName="HexedInstaGib v7T1"
    Description="Instant-kill combat with modified Shock Rifles with options to enable zoom and change fire rate."
    GroupName="Arena"
    bAddToServerPackages=true

    AmmoName='ShockAmmo'
    DefaultWeaponName=""

    MutatorGroup="HexedInstaGib"
    CRIClass=class'HxIGClient'
    Properties(0)=(Name="bAllowTranslocator",Caption="Allow Translocator",Hint="Players get a Translocator in their inventory. Applied on restart/map change.",Type="Check")
    Properties(1)=(Name="bAllowBoost",Caption="Allow Teammate boosting",Hint="Teammates get a big boost when shot by the instagib rifle. Applied on restart/map change.",Type="Check")
    Properties(2)=(Name="bZoomInstagib",Caption="Allow Zoom",Hint="Instagib rifles have sniper scopes. Applied on restart/map change.",Type="Check")
    Properties(3)=(Name="FireRate",Caption="Fire rate",Hint="Change the default fire rate of shock rifles (0 = default). Applied on respawn.",Type="Text",Data="8;0.0:2.0",bAdvanced=true)
}
