class MutHexedUT extends HxMutator;

const MIN_VERSION = 3;

var config bool bFirstRun;
var config bool bAllowHitSounds;
var config bool bAllowDamageNumbers;
var config bool bAllowSpawnProtectionTimer;
var config bool bColoredDeathMessages;
var config bool bAllowSkinHighlight;
var config float SkinHighlightIntensity;
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
var config bool bDisableWallDodge;
var config bool bDisableDodgeJump;

var private bool bInitialized;
var private array<string> DisabledCombos;

function Mutate(string Command, PlayerController Sender)
{
    if (Command ~= "HexedUT")
    {
        OpenHexedMenu(Sender);
    }
    else
    {
        Super.Mutate(Command, Sender);
    }
}

event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (bFirstRun)
    {
        RecoverConfigs();
    }
}

event Tick(float DeltaTime)
{
    if (!bInitialized)
    {
        bInitialized = true;
        ListDisableCombos();
        ModifyDeathMessageClass();
        Spawn(class'HxUTGameRules', Self);
    }
    else
    {
        Disable('Tick');
    }
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
        RegisterSpawn(Pawn);
    }
    Super.ModifyPlayer(Pawn);
}

function NotifyLogout(Controller Exiting)
{
    DestroyLinkedPRI(Exiting.PlayerReplicationInfo, class'HxUTPlayerInfo');
    Super.NotifyLogout(Exiting);
}

function ModifyDeathMessageClass()
{
    if (bColoredDeathMessages)
    {
        if (Level.Game.DeathMessageClass == class'xDeathMessage')
        {
            Level.Game.DeathMessageClass = class'HxDeathMessage';
        }
    }
    else if (Level.Game.DeathMessageClass == class'HxDeathMessage')
    {
        Level.Game.DeathMessageClass = class'xDeathMessage';
    }
}

function SpawnSkinHighlight(xPawn Pawn)
{
    local HxSkinHighlight SkinHighlight;

    if (bAllowSkinHighlight && Pawn != None)
    {
        SkinHighlight = Pawn.Spawn(class'HxSkinHighlight', Pawn);
        SkinHighlight.HighlightIntensity = SkinHighlightIntensity;
        Pawn.AttachToBone(SkinHighlight, 'spine');
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
        SpawnLinkedPRI(PlayerReplicationInfo(Other), class'HxUTPlayerInfo');
    }
    else if (Other.IsA('Controller'))
    {
        Controller(Other).AwardAdrenaline(BonusStartingAdrenaline);
    }
    else if (Other.IsA('xPawn'))
    {
        SpawnSkinHighlight(xPawn(Other));
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

function PropertyChanged(int Index, string OldValue)
{
    if (Properties[Index].Name == "bColoredDeathMessages")
    {
        ModifyDeathMessageClass();
    }
}

function RegisterDamage(int Damage, Pawn Injured, Pawn Inflictor, class<DamageType> Type)
{
    local PlayerController PC;
    local int i;

    if (bAllowHitSounds || bAllowDamageNumbers)
    {
        for (i = 0; i < CRIs.Length; ++i)
        {
            PC = PlayerController(CRIs[i].Owner);
            if (PC != None && PC.ViewTarget == Inflictor)
            {
                HxUTClient(CRIs[i]).UpdateDamage(Damage, Injured, Inflictor, Type);
            }
        }
    }
    if (HealthLeechLimit != 0)
    {
        class'HxUTPlayerInfo'.static.RegisterDamage(Damage, Injured, Inflictor, Type);
    }
}

function RegisterSpawn(Pawn Spawned)
{
    local PlayerController PC;
    local int i;

    if (bAllowSpawnProtectionTimer)
    {
        for (i = 0; i < CRIs.Length; ++i)
        {
            PC = PlayerController(CRIs[i].Owner);
            if (PC != None && PC.ViewTarget == Spawned)
            {
                HxUTClient(CRIs[i]).NotifySpawn(Spawned);
            }
        }
    }
}

function RecoverConfigs()
{
    local Actor OldActor;
    local int Version;
    local int i;

    OldActor = class'HxConfig'.static.FindOldVersionActor(Self, Class, MIN_VERSION, Version);
    if (OldActor != None)
    {
        for (i = 0; i < Properties.Length; ++i)
        {
            class'HxConfig'.static.CopyProperty(Self, OldActor, Properties[i].Name);
        }
        CleanUpOldGameRules(OldActor);
        OldActor.Destroy();
    }
    bFirstRun = false;
    SaveConfig();
}

// TODO: remove this in the next version (HxUTGameRules no longer spawned in PostBeginPlay)
function CleanUpOldGameRules(Actor OldActor)
{
    local GameRules Rules;
    local GameRules PrevRules;
    local string PackageName;
    local string ClassName;

    if (Divide(string(OldActor.Class), ".", PackageName, ClassName))
    {
        for (Rules = Level.Game.GameRulesModifiers; Rules != None; Rules = Rules.NextGameRules)
        {
            if (StrCmp(PackageName, string(Rules.Class), Len(PackageName)) == 0)
            {
                if (PrevRules != None)
                {
                    PrevRules.NextGameRules = Rules.NextGameRules;
                }
                else
                {
                    Level.Game.GameRulesModifiers = Rules.NextGameRules;
                }
                Rules.Destroy();
                break;
            }
            PrevRules = Rules;
        }
    }
}

defaultproperties
{
    FriendlyName="HexedUT v6dev"
    Description="A mutator for hit sounds, damage numbers, skin highlights, colored death messages, enhanced map vote menu, and more."
    bAddToServerPackages=true

    MutatorGroup="HexedUT"
    CRIClass=class'HxUTClient'
    Properties(0)=(Name="bAllowHitSounds",Section="Hit Effects",Caption="Allow hit sounds",Hint="Allow clients to enable/disable hit sound effects.",Type="Check")
    Properties(1)=(Name="bAllowDamageNumbers",Section="Hit Effects",Caption="Allow damage numbers",Hint="Allow clients to enable/disable damage number effects.",Type="Check")
    Properties(2)=(Name="bAllowSpawnProtectionTimer",Section="Interface",Caption="Allow spawn protection timer",Hint="Allow clients to enable/disable the spawn protection timer.",Type="Check")
    Properties(3)=(Name="bColoredDeathMessages",Section="Interface",Caption="Colored death messages",Hint="Use team colors in death messages (blue = killer and red = victim if no teams).",Type="Check")
    Properties(4)=(Name="bAllowSkinHighlight",Section="Skin Highlight",Caption="Allow skin highlight",Hint="Allow clients to enable/disable skin highlights.",Type="Check")
    Properties(5)=(Name="SkinHighlightIntensity",Section="Skin Highlight",Caption="Skin highlight intensity",Hint="Factor to multiply RGB values (between 0.0 and 1.0).",Type="Text",Data="8;0.0:1.0",bAdvanced=true)
    Properties(6)=(Name="HealthLeechRatio",Section="Health Leech",Caption="Health leech ratio",Hint="Ratio to leech health from damage dealt (between 0.0 and 5.0).",Type="Text",Data="8;0.0:5.0",bAdvanced=true)
    Properties(7)=(Name="HealthLeechLimit",Section="Health Leech",Caption="Health leech limit",Hint="Limit up to how much health can be filled with leech (between 0 and 199).",Type="Text",Data="8;0:199",bAdvanced=true)
    Properties(8)=(Name="BonusStartingHealth",Section="Starting Values",Caption="Bonus health",Hint="Bonus to add to starting health (between -99 and 99). Applied on spawn.",Type="Text",Data="8;-99:99",bAdvanced=true)
    Properties(9)=(Name="BonusStartingShield",Section="Starting Values",Caption="Bonus shield",Hint="Bonus to add to Starting shield (between 0 and 150). Applied on spawn.",Type="Text",Data="8;0:150",bAdvanced=true)
    Properties(10)=(Name="BonusStartingGrenades",Section="Starting Values",Caption="Bonus AR grenades",Hint="Bonus to add to starting number of AR grenades (between -4 and 99). Applied on spawn.",Type="Text",Data="8;-4:99",bAdvanced=true)
    Properties(11)=(Name="BonusStartingAdrenaline",Section="Starting Values",Caption="Bonus adrenaline",Hint="Bonus to add to starting adrenaline (between 0 and 100). Applied on restart/map change.",Type="Text",Data="8;0:100",bAdvanced=true)
    Properties(12)=(Name="BonusAdrenalineOnSpawn",Section="Starting Values",Caption="Bonus adrenaline on spawn",Hint="Bonus to add to adrenaline on spawn (between -100 and 100). Applied on spawn.",Type="Text",Data="8;-100:100",bAdvanced=true)
    Properties(13)=(Name="bDisableSpeedCombo",Section="Power-Ups",Caption="Disable speed combo",Hint="Disable speed adrenaline combo (up, up, up, up). Applied on restart/map change.",Type="Check",bAdvanced=true)
    Properties(14)=(Name="bDisableBerserkCombo",Section="Power-Ups",Caption="Disable berserk combo",Hint="Disable berserk adrenaline combo (up, up, down, down). Applied on restart/map change.",Type="Check",bAdvanced=true)
    Properties(15)=(Name="bDisableBoosterCombo",Section="Power-Ups",Caption="Disable booster combo",Hint="Disable booster combo (down, down, down, down). Applied on restart/map change.",Type="Check",bAdvanced=true)
    Properties(16)=(Name="bDisableInvisibleCombo",Section="Power-Ups",Caption="Disable invisible combo",Hint="Disable invisible combo (right, right, left, left). Applied on restart/map change.",Type="Check",bAdvanced=true)
    Properties(17)=(Name="bDisableUDamage",Section="Power-Ups",Caption="Disable UDamage",Hint="Disable UDamage packs on the maps. Applied on restart/map change.",Type="Check",bAdvanced=true)
    Properties(18)=(Name="MaxSpeedMultiplier",Section="Movement",Caption="Speed multiplier",Hint="Coefficient to multiply maximum movement speed (between -100.0 and 100.0). Applied on spawn.",Type="Text",Data="8;-100.0:100.0",bAdvanced=true)
    Properties(19)=(Name="AirControlMultiplier",Section="Movement",Caption="Air control multiplier",Hint="Coefficient to multiply air control (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0",bAdvanced=true)
    Properties(20)=(Name="BaseJumpMultiplier",Section="Movement",Caption="Base jump multiplier",Hint="Coefficient to multiply base jump acceleration (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0",bAdvanced=true)
    Properties(21)=(Name="MultiJumpMultiplier",Section="Movement",Caption="Multi-jump multiplier",Hint="Coefficient to multiply multi-jump acceleration boost (between -100.0 and 100.0). Applied on spawn.",Type="Text",Data="8;-100.0:100.0",bAdvanced=true)
    Properties(22)=(Name="BonusMultiJumps",Section="Movement",Caption="Bonus multi-jumps",Hint="Bonus to add to base amount of multi-jumps (between -1 and 99). Applied on spawn.",Type="Text",Data="8;-1:99",bAdvanced=true)
    Properties(23)=(Name="DodgeMultiplier",Section="Movement",Caption="Dodge multiplier",Hint="Coefficient to multiply dodge acceleration (Z-axis, between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0",bAdvanced=true)
    Properties(24)=(Name="DodgeSpeedMultiplier",Section="Movement",Caption="Dodge speed multiplier",Hint="Coefficient to multiply dodge speed factor (between -10.0 and 10.0). Applied on spawn.",Type="Text",Data="8;-10.0:10.0",bAdvanced=true)
    Properties(25)=(Name="bDisableWallDodge",Section="Movement",Caption="Disable wall dodge",Hint="Disable wall dodge (UT Classic). Applied on spawn.",Type="Check",bAdvanced=true)
    Properties(26)=(Name="bDisableDodgeJump",Section="Movement",Caption="Disable dodge jump",Hint="Disable dodge jump (UT Classic). Applied on spawn.",Type="Check",bAdvanced=true)

    bFirstRun=true
    // Config variables
    bAllowHitSounds=true
    bAllowDamageNumbers=true
    bAllowSpawnProtectionTimer=true
    bColoredDeathMessages=true
    bAllowSkinHighlight=true
    SkinHighlightIntensity=0.35
    HealthLeechRatio=0
    HealthLeechLimit=0
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
}
