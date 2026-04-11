class MutHexedCONTROL extends HxMutator;

var config int BonusHealth;
var config int BonusShield;
var config int BonusARGrenades;
var config int BonusAdrenaline;
var config int BonusAdrenalineOnSpawn;
var config bool bNoSpeedCombo;
var config bool bNoBerserkCombo;
var config bool bNoBoosterCombo;
var config bool bNoInvisibleCombo;
var config bool bNoUDamage;
var config float MaxSpeedMultiplier;
var config float AirControlMultiplier;
var config float BaseJumpMultiplier;
var config float MultiJumpMultiplier;
var config int BonusMultiJumps;
var config float DodgeMultiplier;
var config float DodgeSpeedMultiplier;
var config bool bNoWallDodge;
var config bool bNoDodgeJump;
var config float HealthLeechRatio;
var config int HealthLeechLimit;

function Initialized()
{
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
    else if (Other.IsA('UDamagePack'))
    {
        if (bNoUDamage)
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
    Properties(5)=(Name="bNoSpeedCombo",Section="Power-Ups",Caption="Disable speed combo",Hint="Disable speed combo (up, up, up, up). Applied instantly.",Type="Check")
    Properties(6)=(Name="bNoBerserkCombo",Section="Power-Ups",Caption="Disable berserk combo",Hint="Disable berserk combo (up, up, down, down). Applied instantly.",Type="Check")
    Properties(7)=(Name="bNoBoosterCombo",Section="Power-Ups",Caption="Disable booster combo",Hint="Disable booster combo (down, down, down, down). Applied instantly.",Type="Check")
    Properties(8)=(Name="bNoInvisibleCombo",Section="Power-Ups",Caption="Disable invisible combo",Hint="Disable invisible combo (right, right, left, left). Applied instantly.",Type="Check")
    Properties(9)=(Name="bNoUDamage",Section="Pick-Ups",Caption="Disable UDamage",Hint="Disable UDamage packs on the maps. Applied on restart/map change.",Type="Check")
    Properties(10)=(Name="MaxSpeedMultiplier",Section="Movement",Caption="Speed multiplier",Hint="Coefficient to multiply maximum movement speed (between -100.0 and 100.0). Applied on spawn.",Type="Text",Data="8;-100.0:100.0")
    Properties(11)=(Name="AirControlMultiplier",Section="Movement",Caption="Air control multiplier",Hint="Coefficient to multiply air control (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0")
    Properties(12)=(Name="BaseJumpMultiplier",Section="Movement",Caption="Base jump multiplier",Hint="Coefficient to multiply base jump acceleration (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0")
    Properties(13)=(Name="MultiJumpMultiplier",Section="Movement",Caption="Multi-jump multiplier",Hint="Coefficient to multiply multi-jump acceleration boost (between -100.0 and 100.0). Applied on spawn.",Type="Text",Data="8;-100.0:100.0")
    Properties(14)=(Name="BonusMultiJumps",Section="Movement",Caption="Bonus multi-jumps",Hint="Bonus to add to base amount of multi-jumps (between -1 and 99). Applied on spawn.",Type="Text",Data="8;-1:99")
    Properties(15)=(Name="DodgeMultiplier",Section="Movement",Caption="Dodge multiplier",Hint="Coefficient to multiply dodge acceleration (Z-axis, between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0")
    Properties(16)=(Name="DodgeSpeedMultiplier",Section="Movement",Caption="Dodge speed multiplier",Hint="Coefficient to multiply dodge speed factor (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0")
    Properties(17)=(Name="bNoWallDodge",Section="Movement",Caption="Disable wall dodge",Hint="Disable wall dodge (UT Classic). Applied on spawn.",Type="Check")
    Properties(18)=(Name="bNoDodgeJump",Section="Movement",Caption="Disable dodge jump",Hint="Disable dodge jump (UT Classic). Applied on spawn.",Type="Check")
    Properties(19)=(Name="HealthLeechRatio",Section="Health Leech",Caption="Health leech ratio",Hint="Ratio to leech health from damage dealt (between 0.0 and 5.0).",Type="Text",Data="8;0.0:5.0")
    Properties(20)=(Name="HealthLeechLimit",Section="Health Leech",Caption="Health leech limit",Hint="Limit up to how much health can be filled with leech (between 0 and 199).",Type="Text",Data="8;0:199")
    bAllowURLOptions=true
    bDisableTick=true

    BonusHealth=0
    BonusShield=0
    BonusARGrenades=0
    BonusAdrenaline=0
    BonusAdrenalineOnSpawn=0
    bNoSpeedCombo=false
    bNoBerserkCombo=false
    bNoBoosterCombo=false
    bNoInvisibleCombo=false
    bNoUDamage=false
    MaxSpeedMultiplier=1.0
    AirControlMultiplier=1.0
    BaseJumpMultiplier=1.0
    MultiJumpMultiplier=1.0
    BonusMultiJumps=0
    DodgeMultiplier=1.0
    DodgeSpeedMultiplier=1.0
    bNoWallDodge=false
    bNoDodgeJump=false
    HealthLeechRatio=0
    HealthLeechLimit=0
}
