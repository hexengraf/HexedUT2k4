class MutHexedCONTROL extends HxMutator;

var config int BonusStartingHealth;
var config int BonusStartingShield;
var config int BonusStartingGrenades;
var config int BonusStartingAdrenaline;
var config int BonusAdrenalineOnSpawn;
var config bool bDisableSpeedCombo;
var config bool bDisableBerserkCombo;
var config bool bDisableBoosterCombo;
var config bool bDisableInvisibleCombo;
var config bool bDisableUDamage;
var config float MaxSpeedMultiplier;
var config float AirControlMultiplier;
var config float BaseJumpMultiplier;
var config float MultiJumpMultiplier;
var config int BonusMultiJumps;
var config float DodgeMultiplier;
var config float DodgeSpeedMultiplier;
var config bool bDisableWallDodge;
var config bool bDisableDodgeJump;
var config float HealthLeechRatio;
var config int HealthLeechLimit;

function Initialized()
{
    Spawn(class'HxCTGameRules', Self);
}

function ModifyPlayer(Pawn Pawn)
{
    local AssaultRifle AR;

    Pawn.GroundSpeed *= MaxSpeedMultiplier;
    Pawn.WaterSpeed *= MaxSpeedMultiplier;
    Pawn.AirSpeed *= MaxSpeedMultiplier;
    Pawn.AirControl *= AirControlMultiplier;
    Pawn.JumpZ *= BaseJumpMultiplier;
    if (Pawn.SpawnTime == Level.TimeSeconds)
    {
        if (xPawn(Pawn) != None)
        {
            xPawn(Pawn).MultiJumpBoost *= MultiJumpMultiplier;
            xPawn(Pawn).MaxMultiJump += BonusMultiJumps;
            xPawn(Pawn).MultiJumpRemaining = xPawn(Pawn).MaxMultiJump;
            xPawn(Pawn).DodgeSpeedZ *= DodgeMultiplier;
            xPawn(Pawn).DodgeSpeedFactor *= DodgeSpeedMultiplier;
            xPawn(Pawn).bCanDodgeDoubleJump = xPawn(Pawn).bCanDodgeDoubleJump && !bDisableDodgeJump;
        }
        Pawn.bCanWallDodge = Pawn.bCanWallDodge && !bDisableWallDodge;
        Pawn.GiveHealth(BonusStartingHealth, Pawn.SuperHealthMax);
        Pawn.AddShieldStrength(BonusStartingShield);
        AR = AssaultRifle(Pawn.FindInventoryType(class'AssaultRifle'));
        if (AR != None)
        {
            AR.AmmoClass[1].default.MaxAmmo = Max(
                AR.AmmoClass[1].default.MaxAmmo,
                AR.AmmoClass[1].default.InitialAmount + BonusStartingGrenades);
            AR.AddAmmo(BonusStartingGrenades, 1);
        }
        Pawn.Controller.AwardAdrenaline(BonusAdrenalineOnSpawn);
    }
    Super.ModifyPlayer(Pawn);
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
    else if (Other.IsA('UDamagePack'))
    {
        if (bDisableUDamage)
        {
            bSuperRelevant = 0;
            return false;
        }
    }
    else if (Other.IsA('PlayerReplicationInfo'))
    {
        SpawnLinkedPRI(PlayerReplicationInfo(Other), class'HxCTPlayerInfo');
    }
    else if (Other.IsA('Controller'))
    {
        Controller(Other).AwardAdrenaline(BonusStartingAdrenaline);
    }
    return Super.CheckReplacement(Other, bSuperRelevant);
}

function string RecommendCombo(string ComboName)
{
    if (IsDisabledCombo(ComboName))
    {
        return string(class'HxComboNull');

    }
    return Super.RecommendCombo(ComboName);
}

function bool IsDisabledCombo(coerce string Name)
{
    if (Name ~= "XGame.ComboSpeed")
    {
        return bDisableSpeedCombo;
    }
    if (Name ~= "XGame.ComboBerserk")
    {
        return bDisableBerserkCombo;
    }
    if (Name ~= "XGame.ComboDefensive")
    {
        return bDisableBoosterCombo;
    }
    if (Name ~= "XGame.ComboInvis")
    {
        return bDisableInvisibleCombo;
    }
    return false;
}

defaultproperties
{
    FriendlyName="HexedControl v7T1"
    Description="Enhanced control over game mechanics: modify starting values, disable specific combos, disable specific pick-ups, modify movement parameters, and more."
    bAddToServerPackages=true
    MutatorGroup="HexedControl"
    CRIClass=class'HxCTClient'
    Properties(0)=(Name="BonusStartingHealth",Section="Starting Values",Caption="Bonus health",Hint="Bonus to add to starting health (between -99 and 99). Applied on spawn.",Type="Text",Data="8;-99:99",bAdvanced=true)
    Properties(1)=(Name="BonusStartingShield",Section="Starting Values",Caption="Bonus shield",Hint="Bonus to add to starting shield (between 0 and 150). Applied on spawn.",Type="Text",Data="8;0:150",bAdvanced=true)
    Properties(2)=(Name="BonusStartingGrenades",Section="Starting Values",Caption="Bonus AR grenades",Hint="Bonus to add to starting number of AR grenades (between -4 and 99). Applied on spawn.",Type="Text",Data="8;-4:99",bAdvanced=true)
    Properties(3)=(Name="BonusStartingAdrenaline",Section="Starting Values",Caption="Bonus adrenaline",Hint="Bonus to add to starting adrenaline (between 0 and 100). Applied on restart/map change.",Type="Text",Data="8;0:100",bAdvanced=true)
    Properties(4)=(Name="BonusAdrenalineOnSpawn",Section="Starting Values",Caption="Bonus adrenaline on spawn",Hint="Bonus to add to adrenaline on spawn (between -100 and 100). Applied on spawn.",Type="Text",Data="8;-100:100",bAdvanced=true)
    Properties(5)=(Name="bDisableSpeedCombo",Section="Power-Ups",Caption="Disable speed combo",Hint="Disable speed adrenaline combo (up, up, up, up). Applied instantly.",Type="Check",bAdvanced=true)
    Properties(6)=(Name="bDisableBerserkCombo",Section="Power-Ups",Caption="Disable berserk combo",Hint="Disable berserk adrenaline combo (up, up, down, down). Applied instantly.",Type="Check",bAdvanced=true)
    Properties(7)=(Name="bDisableBoosterCombo",Section="Power-Ups",Caption="Disable booster combo",Hint="Disable booster combo (down, down, down, down). Applied instantly.",Type="Check",bAdvanced=true)
    Properties(8)=(Name="bDisableInvisibleCombo",Section="Power-Ups",Caption="Disable invisible combo",Hint="Disable invisible combo (right, right, left, left). Applied instantly.",Type="Check",bAdvanced=true)
    Properties(9)=(Name="bDisableUDamage",Section="Power-Ups",Caption="Disable UDamage",Hint="Disable UDamage packs on the maps. Applied on restart/map change.",Type="Check",bAdvanced=true)
    Properties(10)=(Name="MaxSpeedMultiplier",Section="Movement",Caption="Speed multiplier",Hint="Coefficient to multiply maximum movement speed (between -100.0 and 100.0). Applied on spawn.",Type="Text",Data="8;-100.0:100.0",bAdvanced=true)
    Properties(11)=(Name="AirControlMultiplier",Section="Movement",Caption="Air control multiplier",Hint="Coefficient to multiply air control (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0",bAdvanced=true)
    Properties(12)=(Name="BaseJumpMultiplier",Section="Movement",Caption="Base jump multiplier",Hint="Coefficient to multiply base jump acceleration (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0",bAdvanced=true)
    Properties(13)=(Name="MultiJumpMultiplier",Section="Movement",Caption="Multi-jump multiplier",Hint="Coefficient to multiply multi-jump acceleration boost (between -100.0 and 100.0). Applied on spawn.",Type="Text",Data="8;-100.0:100.0",bAdvanced=true)
    Properties(14)=(Name="BonusMultiJumps",Section="Movement",Caption="Bonus multi-jumps",Hint="Bonus to add to base amount of multi-jumps (between -1 and 99). Applied on spawn.",Type="Text",Data="8;-1:99",bAdvanced=true)
    Properties(15)=(Name="DodgeMultiplier",Section="Movement",Caption="Dodge multiplier",Hint="Coefficient to multiply dodge acceleration (Z-axis, between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0",bAdvanced=true)
    Properties(16)=(Name="DodgeSpeedMultiplier",Section="Movement",Caption="Dodge speed multiplier",Hint="Coefficient to multiply dodge speed factor (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0",bAdvanced=true)
    Properties(17)=(Name="bDisableWallDodge",Section="Movement",Caption="Disable wall dodge",Hint="Disable wall dodge (UT Classic). Applied on spawn.",Type="Check",bAdvanced=true)
    Properties(18)=(Name="bDisableDodgeJump",Section="Movement",Caption="Disable dodge jump",Hint="Disable dodge jump (UT Classic). Applied on spawn.",Type="Check",bAdvanced=true)
    Properties(19)=(Name="HealthLeechRatio",Section="Health Leech",Caption="Health leech ratio",Hint="Ratio to leech health from damage dealt (between 0.0 and 5.0).",Type="Text",Data="8;0.0:5.0",bAdvanced=true)
    Properties(20)=(Name="HealthLeechLimit",Section="Health Leech",Caption="Health leech limit",Hint="Limit up to how much health can be filled with leech (between 0 and 199).",Type="Text",Data="8;0:199",bAdvanced=true)
    bAllowURLOptions=true
    bDisableTick=true

    BonusStartingHealth=0
    BonusStartingShield=0
    BonusStartingGrenades=0
    BonusStartingAdrenaline=0
    BonusAdrenalineOnSpawn=0
    bDisableSpeedCombo=false
    bDisableBerserkCombo=false
    bDisableBoosterCombo=false
    bDisableInvisibleCombo=false
    bDisableUDamage=false
    MaxSpeedMultiplier=1.0
    AirControlMultiplier=1.0
    BaseJumpMultiplier=1.0
    MultiJumpMultiplier=1.0
    BonusMultiJumps=0
    DodgeMultiplier=1.0
    DodgeSpeedMultiplier=1.0
    bDisableWallDodge=false
    bDisableDodgeJump=false
    HealthLeechRatio=0
    HealthLeechLimit=0
}
