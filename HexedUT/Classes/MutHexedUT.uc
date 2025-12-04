class MutHexedUT extends HxMutator;

var config bool bAllowHitSounds;
var config bool bAllowDamageNumbers;
var config bool bColoredDeathMessages;
var config float HealthLeechRatio;
var config int HealthLeechLimit;
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
var config bool bCanBoostDodge;
var config bool bDisableWallDodge;
var config bool bDisableDodgeJump;

var array<string> DisabledCombos;

function Mutate(string Command, PlayerController Sender)
{
    if (Command ~= "HexedUT")
    {
        Sender.ClientOpenMenu(string(MenuClass));
    }
    else
    {
        Super.Mutate(Command, Sender);
    }
}

event PreBeginPlay()
{
    Super.PreBeginPlay();
    ListDisableCombos();
    ModifyDeathMessageClass();
}

event PostBeginPlay()
{
    Super.PostBeginPlay();
    SpawnGameRules();
}

function SpawnGameRules()
{
    local HxGameRules G;

    G = Spawn(class'HxGameRules');
    G.HexedUT = self;
    Level.Game.AddGameModifier(G);
}

function ModifyPlayer(Pawn Other)
{
    ModifyStartingValues(Other);
    ModifyMovement(xPawn(Other));
    Super.ModifyPlayer(Other);
}

function ModifyStartingValues(Pawn Other)
{
    local AssaultRifle AR;

    Other.GiveHealth(BonusStartingHealth, Other.SuperHealthMax);
    Other.AddShieldStrength(BonusStartingShield);
    if (Other.SpawnTime == Level.TimeSeconds)
    {
        AR = AssaultRifle(Other.FindInventoryType(class'AssaultRifle'));
        if (AR != None)
        {
            AR.AmmoClass[1].default.MaxAmmo = Max(
                AR.AmmoClass[1].default.MaxAmmo, BonusStartingGrenades);
            AR.AddAmmo(BonusStartingGrenades, 1);
        }
        Other.Controller.AwardAdrenaline(BonusAdrenalineOnSpawn);
    }
}

function ModifyStartingAdrenaline(Controller Other)
{
    Other.AwardAdrenaline(BonusStartingAdrenaline);
}

function ModifyMovement(xPawn Other)
{
    if (Other != None)
    {
        Other.GroundSpeed *= MaxSpeedMultiplier;
        Other.WaterSpeed *= MaxSpeedMultiplier;
        Other.AirSpeed *= MaxSpeedMultiplier;
        Other.AirControl *= AirControlMultiplier;
        Other.JumpZ *= BaseJumpMultiplier;
        Other.MultiJumpBoost *= MultiJumpMultiplier;
        Other.MaxMultiJump += BonusMultiJumps;
        Other.MultiJumpRemaining += BonusMultiJumps;
        Other.DodgeSpeedZ *= DodgeMultiplier;
        Other.DodgeSpeedFactor *= DodgeSpeedMultiplier;
        Other.bCanBoostDodge = Other.bCanBoostDodge || bCanBoostDodge;
        Other.bCanWallDodge = Other.bCanWallDodge ^^ bDisableWallDodge;
        Other.bCanDodgeDoubleJump = Other.bCanDodgeDoubleJump ^^ bDisableDodgeJump;
    }
}

function ModifyDeathMessageClass()
{
    if (bColoredDeathMessages)
    {
        if (Level.Game.DeathMessageClass == class'xDeathMessage')
        {
            Level.Game.DeathMessageClass = class'HxDeathMessage';
        }
    } else if (Level.Game.DeathMessageClass == class'HxDeathMessage')
    {
        Level.Game.DeathMessageClass = class'xDeathMessage';
    }
}

function SpawnHxAgent(PlayerReplicationInfo PRI)
{
    local HxAgent Agent;

    if (PlayerController(PRI.Owner) != None && MessagingSpectator(PRI.Owner) == None)
    {
        Agent = HxAgent(SpawnLinkedPRI(PRI, class'HxAgent'));
        Agent.PC = PlayerController(PRI.Owner);
        Agent.HexedUT = Self;
        UpdateAgent(Agent);
    }
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
        SpawnHxAgent(PlayerReplicationInfo(Other));
    }
    else if (Other.IsA('Controller'))
    {
        ModifyStartingAdrenaline(Controller(Other));
    }
    return true;
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
    local int i;

    for (i = 0; i < DisabledCombos.Length; ++i)
    {
        if (Name ~= DisabledCombos[i])
        {
            return true;
        }
    }
    return false;
}

function ListDisableCombos()
{
    DisabledCombos.Length = 0;
    if (bDisableSpeedCombo)
    {
        DisabledCombos[DisabledCombos.Length] = "XGame.ComboSpeed";
    }
    if (bDisableBerserkCombo)
    {
        DisabledCombos[DisabledCombos.Length] = "XGame.ComboBerserk";
    }
    if (bDisableBoosterCombo)
    {
        DisabledCombos[DisabledCombos.Length] = "XGame.ComboDefensive";
    }
    if (bDisableInvisibleCombo)
    {
        DisabledCombos[DisabledCombos.Length] = "XGame.ComboInvis";
    }
}

function UpdateAgent(HxAgent Agent)
{
    Agent.bAllowHitSounds = bAllowHitSounds;
    Agent.bAllowDamageNumbers = bAllowDamageNumbers;
    Agent.bColoredDeathMessages = bColoredDeathMessages;
    Agent.HealthLeechRatio = HealthLeechRatio;
    Agent.HealthLeechLimit = HealthLeechLimit;
    Agent.BonusStartingHealth = BonusStartingHealth;
    Agent.BonusStartingShield = BonusStartingShield;
    Agent.BonusStartingGrenades = BonusStartingGrenades;
    Agent.BonusStartingAdrenaline = BonusStartingAdrenaline;
    Agent.BonusAdrenalineOnSpawn = BonusAdrenalineOnSpawn;
    Agent.bDisableSpeedCombo = bDisableSpeedCombo;
    Agent.bDisableBerserkCombo = bDisableBerserkCombo;
    Agent.bDisableBoosterCombo = bDisableBoosterCombo;
    Agent.bDisableInvisibleCombo = bDisableInvisibleCombo;
    Agent.bDisableUDamage = bDisableUDamage;
    Agent.MaxSpeedMultiplier = MaxSpeedMultiplier;
    Agent.AirControlMultiplier = AirControlMultiplier;
    Agent.BaseJumpMultiplier = BaseJumpMultiplier;
    Agent.MultiJumpMultiplier = MultiJumpMultiplier;
    Agent.BonusMultiJumps = BonusMultiJumps;
    Agent.DodgeMultiplier = DodgeMultiplier;
    Agent.DodgeSpeedMultiplier = DodgeSpeedMultiplier;
    Agent.bCanBoostDodge = bCanBoostDodge;
    Agent.bDisableWallDodge = bDisableWallDodge;
    Agent.bDisableDodgeJump = bDisableDodgeJump;
    Agent.NetUpdateTime = Level.TimeSeconds - 1;
}

function UpdateAfterPropertyChange(string PropertyName, String PropertyValue)
{
    local HxAgent Agent;
    local Controller C;

    if (PropertyName == "bColoredDeathMessages")
    {
        ModifyDeathMessageClass();
    }
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        Agent = class'HxAgent'.static.GetAgent(C);
        if (Agent != None)
        {
            UpdateAgent(Agent);
        }
    }
}

defaultproperties
{
    FriendlyName="HexedUT v2dev"
    Description="A mutator for hit sounds, damage numbers, spawn protection timer, and more."
    bAddToServerPackages=true
    MutatorGroup="HexedUT"

    PropertyInfoEntries(0)=(Name="bAllowHitSounds",Caption="Allow hit sound effects",Hint="Allow clients to enable/disable hit sound effects.",PIType="Check")
    PropertyInfoEntries(1)=(Name="bAllowDamageNumbers",Caption="Allow damage number effects",Hint="Allow clients to enable/disable damage number effects.",PIType="Check")
    PropertyInfoEntries(2)=(Name="bColoredDeathMessages",Caption="Colored death messages",Hint="Use team colors in death messages (blue = killer and red = victim if no teams).",PIType="Check")
    PropertyInfoEntries(3)=(Name="HealthLeechRatio",Caption="Health leech ratio",Hint="Ratio to leech health from damage dealt (between 0.0 and 5.0).",PIType="Text",PIExtras="8;0.0:5.0")
    PropertyInfoEntries(4)=(Name="HealthLeechLimit",Caption="Health leech limit",Hint="Limit up to how much health can be filled with leech (between 0 and 199).",PIType="Text",PIExtras="8;0:199")
    PropertyInfoEntries(5)=(Name="BonusStartingHealth",Caption="Bonus health",Hint="Bonus to add to starting health (between -99 and 99). Applied on spawn.",PIType="Text",PIExtras="8;-99:99")
    PropertyInfoEntries(6)=(Name="BonusStartingShield",Caption="Bonus shield",Hint="Bonus to add to Starting shield (between 0 and 150). Applied on spawn.",PIType="Text",PIExtras="8;0:150")
    PropertyInfoEntries(7)=(Name="BonusStartingGrenades",Caption="Bonus AR grenades",Hint="Bonus to add to starting number of AR grenades (between -4 and 99). Applied on spawn.",PIType="Text",PIExtras="8;-4:99")
    PropertyInfoEntries(8)=(Name="BonusStartingAdrenaline",Caption="Bonus adrenaline",Hint="Bonus to add to starting adrenaline (between 0 and 100). Applied on restart/map change.",PIType="Text",PIExtras="8;0:100")
    PropertyInfoEntries(9)=(Name="BonusAdrenalineOnSpawn",Caption="Bonus adrenaline on spawn",Hint="Bonus to add to adrenaline on spawn (between -100 and 100). Applied on spawn.",PIType="Text",PIExtras="8;-100:100")
    PropertyInfoEntries(10)=(Name="bDisableSpeedCombo",Caption="Disable speed combo",Hint="Disable speed adrenaline combo (up, up, up, up). Applied on restart/map change.",PIType="Check")
    PropertyInfoEntries(11)=(Name="bDisableBerserkCombo",Caption="Disable berserk combo",Hint="Disable berserk adrenaline combo (up, up, down, down). Applied on restart/map change.",PIType="Check")
    PropertyInfoEntries(12)=(Name="bDisableBoosterCombo",Caption="Disable booster combo",Hint="Disable booster combo (down, down, down, down). Applied on restart/map change.",PIType="Check")
    PropertyInfoEntries(13)=(Name="bDisableInvisibleCombo",Caption="Disable invisible combo",Hint="Disable invisible combo (right, right, left, left). Applied on restart/map change.",PIType="Check")
    PropertyInfoEntries(14)=(Name="bDisableUDamage",Caption="Disable UDamage",Hint="Disable UDamage packs on the maps. Applied on restart/map change.",PIType="Check")
    PropertyInfoEntries(15)=(Name="MaxSpeedMultiplier",Caption="Maximum speed multiplier",Hint="Coefficient to multiply maximum movement speed (between -100.0 and 100.0). Applied on spawn.",PIType="Text",PIExtras="8;-100.0:100.0")
    PropertyInfoEntries(16)=(Name="AirControlMultiplier",Caption="Air control multiplier",Hint="Coefficient to multiply air control (between -10.0 and 10.0). Applied on spawn.",PIType="Text",PIExtras="8;-10.0:10.0")
    PropertyInfoEntries(17)=(Name="BaseJumpMultiplier",Caption="Base jump multiplier",Hint="Coefficient to multiply base jump acceleration (between -10.0 and 10.0). Applied on spawn.",PIType="Text",PIExtras="8;-10.0:10.0")
    PropertyInfoEntries(18)=(Name="MultiJumpMultiplier",Caption="Multi-jump multiplier",Hint="Coefficient to multiply multi-jump acceleration boost (between -100.0 and 100.0). Applied on spawn.",PIType="Text",PIExtras="8;-100.0:100.0")
    PropertyInfoEntries(19)=(Name="BonusMultiJumps",Caption="Bonus multi-jumps",Hint="Bonus to add to base amount of multi-jumps (between -1 and 99). Applied on spawn.",PIType="Text",PIExtras="8;-1:99")
    PropertyInfoEntries(20)=(Name="DodgeMultiplier",Caption="Dodge multiplier",Hint="Coefficient to multiply dodge acceleration (Z-axis, between -10.0 and 10.0). Applied on spawn.",PIType="Text",PIExtras="8;-10.0:10.0")
    PropertyInfoEntries(21)=(Name="DodgeSpeedMultiplier",Caption="Dodge speed multiplier",Hint="Coefficient to multiply dodge speed factor (between -10.0 and 10.0). Applied on spawn.",PIType="Text",PIExtras="8;-10.0:10.0")
    PropertyInfoEntries(22)=(Name="bCanBoostDodge",Caption="Enable boost dodge",Hint="Enable UT2003's boost dodge. Applied on spawn.",PIType="Check")
    PropertyInfoEntries(23)=(Name="bDisableWallDodge",Caption="Disable wall dodge",Hint="Disable wall dodge (UT Classic). Applied on spawn.",PIType="Check")
    PropertyInfoEntries(24)=(Name="bDisableDodgeJump",Caption="Disable dodge jump",Hint="Disable dodge jump (UT Classic). Applied on spawn.",PIType="Check")

    // Config variables
    bAllowHitSounds=true
    bAllowDamageNumbers=true
    bColoredDeathMessages=true
    HealthLeechLimit=0
    HealthLeechRatio=0
    BonusStartingHealth=0
    BonusStartingShield=0
    BonusStartingGrenades=0
    BonusStartingAdrenaline=0
    BonusAdrenalineOnSpawn=0
    bDisableSpeedCombo=false
    bDisableBerserkCombo=false
    bDisableBoosterCombo=false
    bDisableInvisibleCombo=false
    MaxSpeedMultiplier=1.0
    AirControlMultiplier=1.0
    BaseJumpMultiplier=1.0
    MultiJumpMultiplier=1.0
    BonusMultiJumps=0
    DodgeMultiplier=1.0
    DodgeSpeedMultiplier=1.0
    bCanBoostDodge=false
    bDisableWallDodge=false
    bDisableDodgeJump=false
}
