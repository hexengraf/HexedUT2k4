class MutHexedCONTROL extends HxMutator;

var config int BonusHealth;
var config int BonusShield;
var config int BonusARGrenades;
var config int BonusAdrenaline;
var config int BonusAdrenalineOnSpawn;
var config float SelfDamageScale;
var config float HealthLeechRatio;
var config int HealthLeechLimit;
var config bool bNoSpeedCombo;
var config bool bNoBerserkCombo;
var config bool bNoBoosterCombo;
var config bool bNoInvisibleCombo;
var config bool bNoAdrenalinePills;
var config bool bNoHealthVials;
var config bool bNoHealthPacks;
var config bool bNoSuperHealthPacks;
var config bool bNoShieldPacks;
var config bool bNoSuperShieldPacks;
var config bool bNoUDamagePacks;
var config bool bNoAmmoPacks;
var config float MaxSpeedMultiplier;
var config float AirControlMultiplier;
var config float BaseJumpMultiplier;
var config float MultiJumpMultiplier;
var config int BonusMultiJumps;
var config float DodgeMultiplier;
var config float DodgeSpeedMultiplier;
var config bool bNoWallDodge;
var config bool bNoDodgeJump;

function Initialized()
{
    local xPickUpBase PickupBase;
    local Pickup Pickup;

    foreach AllActors(class'xPickUpBase', PickupBase)
    {
        if (ClassIsChildOf(PickupBase.Class, class'WildcardBase'))
        {
            ModifyWildcardBase(WildcardBase(PickupBase));
        }
        else if (IsDisabledPickup(PickupBase.PowerUp))
        {
            ModifyPickupBase(PickupBase, true);
        }
    }
    foreach AllActors(class'Pickup', Pickup)
    {
        if (IsDisabledPickup(Pickup.Class))
        {
            ModifyPickup(Pickup, true);
        }
    }
    Spawn(class'HxCTGameRules', Self);
}

function ModifyPlayer(Pawn Pawn)
{
    local AssaultRifle AR;

    if (!(MaxSpeedMultiplier ~= 1.0))
    {
        Pawn.GroundSpeed *= MaxSpeedMultiplier;
        Pawn.WaterSpeed *= MaxSpeedMultiplier;
        Pawn.AirSpeed *= MaxSpeedMultiplier;
    }
    if (!(AirControlMultiplier ~= 1.0))
    {
        Pawn.AirControl *= AirControlMultiplier;
    }
    if (!(BaseJumpMultiplier ~= 1.0))
    {
        Pawn.JumpZ *= BaseJumpMultiplier;
    }
    if (Pawn.SpawnTime == Level.TimeSeconds)
    {
        if (xPawn(Pawn) != None)
        {
            if (!(MultiJumpMultiplier ~= 1.0))
            {
                xPawn(Pawn).MultiJumpBoost *= MultiJumpMultiplier;
            }
            xPawn(Pawn).MaxMultiJump += BonusMultiJumps;
            xPawn(Pawn).MultiJumpRemaining = xPawn(Pawn).MaxMultiJump;
            if (!(DodgeMultiplier ~= 1.0))
            {
                xPawn(Pawn).DodgeSpeedZ *= DodgeMultiplier;
            }
            if (!(DodgeSpeedMultiplier ~= 1.0))
            {
                xPawn(Pawn).DodgeSpeedFactor *= DodgeSpeedMultiplier;
            }
            xPawn(Pawn).bCanDodgeDoubleJump = xPawn(Pawn).bCanDodgeDoubleJump && !bNoDodgeJump;
        }
        Pawn.bCanWallDodge = Pawn.bCanWallDodge && !bNoWallDodge;
        Pawn.GiveHealth(BonusHealth, Pawn.SuperHealthMax);
        Pawn.AddShieldStrength(BonusShield);
        AR = AssaultRifle(Pawn.FindInventoryType(class'AssaultRifle'));
        if (AR != None)
        {
            AR.AmmoClass[1].default.MaxAmmo = Max(
                AR.AmmoClass[1].default.MaxAmmo,
                AR.AmmoClass[1].default.InitialAmount + BonusARGrenades);
            AR.AddAmmo(BonusARGrenades, 1);
        }
        Pawn.Controller.AwardAdrenaline(BonusAdrenalineOnSpawn);
    }
    Super.ModifyPlayer(Pawn);
}

function ServerTraveling(string URL, bool bItems)
{
    Super.ServerTraveling(URL, bItems);
    class'GrenadeAmmo'.default.MaxAmmo = 8;
}

function NotifyLogout(Controller Exiting)
{
    DestroyLinkedPRI(Exiting.PlayerReplicationInfo, class'HxCTPlayerInfo');
    Super.NotifyLogout(Exiting);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (Other.IsA('Combo'))
    {
        if (IsDisabledCombo(Other.Class))
        {
            bSuperRelevant = 0;
            return false;
        }
    }
    else if (Other.IsA('Pickup'))
    {
        if (IsDisabledPickup(Other.Class))
        {
            Other.GotoState('Disabled');
        }
    }
    else if (Other.IsA('WildcardBase'))
    {
        ModifyWildcardBase(WildcardBase(Other));
    }
    else if (Other.IsA('xPickUpBase'))
    {
        if (IsDisabledPickup(xPickUpBase(Other).PowerUp))
        {
            ModifyPickupBase(xPickUpBase(Other), true);
        }
    }
    else if (Other.IsA('PlayerReplicationInfo'))
    {
        SpawnLinkedPRI(PlayerReplicationInfo(Other), class'HxCTPlayerInfo');
    }
    else if (Other.IsA('Controller'))
    {
        Controller(Other).AwardAdrenaline(BonusAdrenaline);
    }
    return Super.CheckReplacement(Other, bSuperRelevant);
}

function string RecommendCombo(string ComboName)
{
    ComboName = Super.RecommendCombo(ComboName);
    if (IsDisabledCombo(ComboName))
    {
        return string(class'HxComboNull');

    }
    return ComboName;
}

function PropertyChanged(int Index, string OldValue)
{
    switch (Properties[Index].Name)
    {
        case "bNoAdrenalinePills":
            ModifyPickups(class'AdrenalinePickup', bNoAdrenalinePills);
            break;
        case "bNoHealthVials":
            ModifyPickups(class'MiniHealthPack', bNoHealthVials);
            break;
        case "bNoHealthPacks":
            ModifyPickupBases(class'HealthPack', bNoHealthPacks);
            ModifyPickups(class'HealthPack', bNoHealthPacks);
            break;
        case "bNoSuperHealthPacks":
            ModifyPickupBases(class'SuperHealthPack', bNoSuperHealthPacks);
            ModifyPickups(class'SuperHealthPack', bNoSuperHealthPacks);
            break;
        case "bNoShieldPacks":
            ModifyPickupBases(class'ShieldPack', bNoShieldPacks);
            ModifyPickups(class'ShieldPack', bNoShieldPacks);
            break;
        case "bNoSuperShieldPacks":
            ModifyPickupBases(class'SuperShieldPack', bNoSuperShieldPacks);
            ModifyPickups(class'SuperShieldPack', bNoSuperShieldPacks);
            break;
        case "bNoUDamagePacks":
            ModifyPickupBases(class'UDamagePack', bNoUDamagePacks);
            ModifyPickups(class'UDamagePack', bNoUDamagePacks);
            break;
        case "bNoAmmoPacks":
            ModifyPickups(class'Ammo', bNoAmmoPacks);
            break;
    }
}

function bool IsDisabledCombo(coerce string Name)
{
    if (Name ~= "XGame.ComboSpeed")
    {
        return bNoSpeedCombo;
    }
    if (Name ~= "XGame.ComboBerserk")
    {
        return bNoBerserkCombo;
    }
    if (Name ~= "XGame.ComboDefensive")
    {
        return bNoBoosterCombo;
    }
    if (Name ~= "XGame.ComboInvis")
    {
        return bNoInvisibleCombo;
    }
    return false;
}

function bool IsDisabledPickup(class PickupClass)
{
    if (ClassIsChildOf(PickupClass, class'AdrenalinePickup'))
    {
        return bNoAdrenalinePills;
    }
    if (ClassIsChildOf(PickupClass, class'MiniHealthPack'))
    {
        return bNoHealthVials;
    }
    if (ClassIsChildOf(PickupClass, class'HealthPack'))
    {
        return bNoHealthPacks;
    }
    if (ClassIsChildOf(PickupClass, class'SuperHealthPack'))
    {
        return bNoSuperHealthPacks;
    }
    if (ClassIsChildOf(PickupClass, class'ShieldPack'))
    {
        return bNoShieldPacks;
    }
    if (ClassIsChildOf(PickupClass, class'SuperShieldPack'))
    {
        return bNoSuperShieldPacks;
    }
    if (ClassIsChildOf(PickupClass, class'UDamagePack'))
    {
        return bNoUDamagePacks;
    }
    if (ClassIsChildOf(PickupClass, class'Ammo'))
    {
        return bNoAmmoPacks;
    }
    return false;
}

function ModifyPickups(class<Pickup> PickupClass, bool bDisabled)
{
    local Pickup Pickup;

    foreach AllActors(class'Pickup', Pickup)
    {
        if (ClassIsChildOf(Pickup.Class, PickupClass))
        {
            ModifyPickup(Pickup, bDisabled);
        }
    }
}

function ModifyPickupBases(class<Pickup> PickupClass, bool bDisabled)
{
    local xPickUpBase PickupBase;

    foreach AllActors(class'xPickUpBase', PickupBase)
    {
        if (PickupBase.IsA('WildcardBase'))
        {
            ModifyWildcardBase(WildcardBase(PickupBase));
        }
        else if (ClassIsChildOf(PickupBase.PowerUp, PickupClass))
        {
            ModifyPickupBase(PickupBase, bDisabled);
        }
    }
}

function ModifyWildcardBase(WildcardBase PickupBase)
{
    local bool bDelayed;
    local int NumClasses;
    local int i;
    local int j;

    for (i = 0; i < ArrayCount(PickupBase.default.PickupClasses); ++i)
    {
        if (PickupBase.default.PickupClasses[i] == None)
        {
            break;
        }
        if (IsDisabledPickup(PickupBase.default.PickupClasses[i]))
        {
            continue;
        }
        PickupBase.PickupClasses[j] = PickupBase.default.PickupClasses[i];
        ++j;
    }
    if (PickupBase.NumClasses != j)
    {
        NumClasses = PickupBase.NumClasses;
        PickupBase.NumClasses = j;
        if (NumClasses == 0)
        {
            ModifyPickupBase(PickupBase, false);
            PickupBase.TurnOn();
        }
        else if (j == 0)
        {
            ModifyPickupBase(PickupBase, true);
            if (PickupBase.myPickUp != None)
            {
                ModifyPickup(PickupBase.myPickUp, true);
            }
        }
        else if (PickupBase.myPickUp != None && IsDisabledPickup(PickupBase.PowerUp))
        {
            bDelayed = PickupBase.bDelayedSpawn && PickupBase.myPickup.IsInState('WaitingForMatch');
            PickupBase.TurnOn();
            if (bDelayed)
            {
                PickupBase.myPickUp.GoToState('WaitingForMatch');
            }
        }
    }
}

static function ModifyPickup(Pickup Pickup, coerce bool bDisabled)
{
    if (bDisabled)
    {
        Pickup.GoToState('Disabled');
    }
    else if (Pickup.IsInState('Disabled'))
    {
	    Pickup.SetCollision(
            Pickup.default.bCollideActors,
            Pickup.default.bBlockActors,
            Pickup.default.bBlockPlayers);
        Pickup.GotoState('Pickup');
        Pickup.SetRespawn();
    }
}

static function ModifyPickupBase(xPickUpBase PickupBase, coerce bool bDisabled)
{
    PickupBase.bHidden = bDisabled;
    if (PickupBase.bStatic)
    {
        PickupBase.ResetStaticFilterState();
    }
    if (PickupBase.myEmitter != None)
    {
        PickupBase.myEmitter.bHidden = bDisabled;
    }
}

defaultproperties
{
    FriendlyName="HexedCONTROL v7T1"
    Description="Enhanced control over game mechanics: modify starting values, disable specific combos, disable specific pick-ups, modify movement parameters, and more."
    bAddToServerPackages=true
    CRIClass=class'HxCTClient'
    Properties(0)=(Name="BonusHealth",Section="Starting Values",Caption="Bonus health",Hint="Bonus to starting health (between -99 and 99). Applied on spawn.",Type="Text",Data="8;-99:99")
    Properties(1)=(Name="BonusShield",Section="Starting Values",Caption="Bonus shield",Hint="Bonus to starting shield (between 0 and 150). Applied on spawn.",Type="Text",Data="8;0:150")
    Properties(2)=(Name="BonusARGrenades",Section="Starting Values",Caption="Bonus AR grenades",Hint="Bonus to starting number of AR grenades (between -4 and 99). Applied on spawn.",Type="Text",Data="8;-4:99")
    Properties(3)=(Name="BonusAdrenaline",Section="Starting Values",Caption="Bonus adrenaline",Hint="Bonus to starting adrenaline (between 0 and 100). Applied on restart/map change.",Type="Text",Data="8;0:100")
    Properties(4)=(Name="BonusAdrenalineOnSpawn",Section="Starting Values",Caption="Bonus adrenaline on spawn",Hint="Bonus to adrenaline on spawn (between -100 and 100). Applied on spawn.",Type="Text",Data="8;-100:100")
    Properties(5)=(Name="SelfDamageScale",Section="Damage",Caption="Self-damage scale",Hint="How much damage you do to yourself. Applied instantly.",Type="Text",Data="8;0.0:1.0")
    Properties(6)=(Name="HealthLeechRatio",Section="Health Leech",Caption="Health leech ratio",Hint="Ratio to leech health from damage dealt (between 0.0 and 5.0).",Type="Text",Data="8;0.0:5.0")
    Properties(7)=(Name="HealthLeechLimit",Section="Health Leech",Caption="Health leech limit",Hint="Limit up to how much health can be filled with leech (between 0 and 199).",Type="Text",Data="8;0:199")
    Properties(8)=(Name="bNoSpeedCombo",Section="Power-Ups",Caption="No speed combo",Hint="Disable speed combo (up, up, up, up). Applied instantly.",Type="Check")
    Properties(9)=(Name="bNoBerserkCombo",Section="Power-Ups",Caption="No berserk combo",Hint="Disable berserk combo (up, up, down, down). Applied instantly.",Type="Check")
    Properties(10)=(Name="bNoBoosterCombo",Section="Power-Ups",Caption="No booster combo",Hint="Disable booster combo (down, down, down, down). Applied instantly.",Type="Check")
    Properties(11)=(Name="bNoInvisibleCombo",Section="Power-Ups",Caption="No invisible combo",Hint="Disable invisible combo (right, right, left, left). Applied instantly.",Type="Check")
    Properties(12)=(Name="bNoAdrenalinePills",Section="Pick-Ups",Caption="No adrenaline pills",Hint="Disable adrenaline pills. Applied instantly.",Type="Check")
    Properties(13)=(Name="bNoHealthVials",Section="Pick-Ups",Caption="No health vials",Hint="Disable health vials. Applied instantly.",Type="Check")
    Properties(14)=(Name="bNoHealthPacks",Section="Pick-Ups",Caption="No health packs",Hint="Disable health packs. Applied instantly.",Type="Check")
    Properties(15)=(Name="bNoSuperHealthPacks",Section="Pick-Ups",Caption="No super health packs",Hint="Disable super health packs. Applied instantly.",Type="Check")
    Properties(16)=(Name="bNoShieldPacks",Section="Pick-Ups",Caption="No shield packs",Hint="Disable shield packs. Applied instantly.",Type="Check")
    Properties(17)=(Name="bNoSuperShieldPacks",Section="Pick-Ups",Caption="No super shield packs",Hint="Disable super shield packs. Applied instantly.",Type="Check")
    Properties(18)=(Name="bNoUDamagePacks",Section="Pick-Ups",Caption="No UDamage packs",Hint="Disable UDamage packs. Applied instantly.",Type="Check")
    Properties(19)=(Name="bNoAmmoPacks",Section="Pick-Ups",Caption="No ammo packs",Hint="Disable ammo packs. Applied instantly.",Type="Check")
    Properties(20)=(Name="MaxSpeedMultiplier",Section="Movement",Caption="Speed multiplier",Hint="Coefficient to multiply maximum movement speed (between -100.0 and 100.0). Applied on spawn.",Type="Text",Data="8;-100.0:100.0")
    Properties(21)=(Name="AirControlMultiplier",Section="Movement",Caption="Air control multiplier",Hint="Coefficient to multiply air control (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0")
    Properties(22)=(Name="BaseJumpMultiplier",Section="Movement",Caption="Base jump multiplier",Hint="Coefficient to multiply base jump acceleration (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0")
    Properties(23)=(Name="MultiJumpMultiplier",Section="Movement",Caption="Multi-jump multiplier",Hint="Coefficient to multiply multi-jump acceleration boost (between -100.0 and 100.0). Applied on spawn.",Type="Text",Data="8;-100.0:100.0")
    Properties(24)=(Name="BonusMultiJumps",Section="Movement",Caption="Bonus multi-jumps",Hint="Bonus to add to base amount of multi-jumps (between -1 and 99). Applied on spawn.",Type="Text",Data="8;-1:99")
    Properties(25)=(Name="DodgeMultiplier",Section="Movement",Caption="Dodge multiplier",Hint="Coefficient to multiply dodge acceleration (Z-axis, between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0")
    Properties(26)=(Name="DodgeSpeedMultiplier",Section="Movement",Caption="Dodge speed multiplier",Hint="Coefficient to multiply dodge speed factor (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0")
    Properties(27)=(Name="bNoWallDodge",Section="Movement",Caption="Disable wall dodge",Hint="Disable wall dodge (UT Classic). Applied on spawn.",Type="Check")
    Properties(28)=(Name="bNoDodgeJump",Section="Movement",Caption="Disable dodge jump",Hint="Disable dodge jump (UT Classic). Applied on spawn.",Type="Check")
    bAllowURLOptions=true
    bDisableTick=true

    BonusHealth=0
    BonusShield=0
    BonusARGrenades=0
    BonusAdrenaline=0
    BonusAdrenalineOnSpawn=0
    SelfDamageScale=1
    HealthLeechRatio=0
    HealthLeechLimit=0
    bNoSpeedCombo=false
    bNoBerserkCombo=false
    bNoBoosterCombo=false
    bNoInvisibleCombo=false
    bNoAdrenalinePills=false
    bNoHealthVials=false
    bNoHealthPacks=false
    bNoSuperHealthPacks=false
    bNoShieldPacks=false
    bNoSuperShieldPacks=false
    bNoUDamagePacks=false
    bNoAmmoPacks=false
    MaxSpeedMultiplier=1.0
    AirControlMultiplier=1.0
    BaseJumpMultiplier=1.0
    MultiJumpMultiplier=1.0
    BonusMultiJumps=0
    DodgeMultiplier=1.0
    DodgeSpeedMultiplier=1.0
    bNoWallDodge=false
    bNoDodgeJump=false
}
