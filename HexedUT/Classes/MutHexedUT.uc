class MutHexedUT extends HxMutator;

enum EHxForcedModel
{
    HX_FM_None,
    HX_FM_OfficialOnly,
    HX_FM_FromList,
    HX_FM_Any,
};

var config bool bAllowHitSounds;
var config bool bAllowDamageNumbers;
var config bool bRequireLOS;
var config bool bAllowSkinHighlight;
var config float SkinHighlightIntensity;
var config EHxForcedModel AllowForcedModels;
var config array<string> ModelList;
var config bool bAllowCustomViewSmoothing;
var config bool bAllowEnhancedScoreBoards;
var config bool bAllowSpawnProtectionTimer;
var config bool bColoredDeathMessages;

function Mutate(string Command, PlayerController Sender)
{
    if (Command ~= "HexedUT")
    {
        OpenConfigurationMenu(Sender);
    }
    else
    {
        Super.Mutate(Command, Sender);
    }
}

function Initialized()
{
    ModifyDeathMessageClass();
    Spawn(class'HxUTGameRules', Self);
}

function ModifyPlayer(Pawn Pawn)
{
    if (Pawn.SpawnTime == Level.TimeSeconds)
    {
        RegisterSpawn(Pawn);
        SpawnSkinHighlight(xPawn(Pawn));
    }
    Super.ModifyPlayer(Pawn);
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
        SkinHighlight.TeamNumber = SkinHighlight.GetTeamNum(Pawn);
        SkinHighlight.bCanForceModels = AllowForcedModels != HX_FM_None;
        SkinHighlight.HighlightIntensity = SkinHighlightIntensity;
        Pawn.AttachToBone(SkinHighlight, 'spine');
    }
}

function PropertyChanged(int Index, string OldValue)
{
    switch (Properties[Index].Name)
    {
        case "bColoredDeathMessages":
            ModifyDeathMessageClass();
            break;
    }
}

function array<string> GetArrayProperty(int Index)
{
    if (Properties[Index].Name == "ModelList")
    {
        return ModelList;
    }
    return Super.GetArrayProperty(Index);
}

function RegisterDamage(int Damage, Pawn Injured, Pawn Inflictor, class<DamageType> Type)
{
    local PlayerController PC;
    local int i;

    if (bAllowHitSounds || bAllowDamageNumbers)
    {
        if (!bRequireLOS
            || FastTrace(Injured.Location, Inflictor.Location + Inflictor.EyePosition()))
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

static function string GetEnumLabel(int Index, string Value)
{
    if (Index == 5)
    {
        switch (Value)
        {
            case "HX_FM_None":
                return default.DisplayInfo[Index].EnumLabels[0];
            case "HX_FM_OfficialOnly":
                return default.DisplayInfo[Index].EnumLabels[1];
            case "HX_FM_FromList":
                return default.DisplayInfo[Index].EnumLabels[2];
            case "HX_FM_Any":
                return default.DisplayInfo[Index].EnumLabels[3];
        }
    }
    return Super.GetEnumLabel(Index, Value);
}

defaultproperties
{
    FriendlyName="HexedUT v9rc1"
    Description="Provides hit sounds, damage numbers, skin highlights, enhanced scoreboards, and more."
    bAddToServerPackages=true
    CRIClass=class'HxUTClient'
    Properties(0)=(Name="bAllowHitSounds",Type=HX_PROPERTY_Bool)
    Properties(1)=(Name="bAllowDamageNumbers",Type=HX_PROPERTY_Bool)
    Properties(2)=(Name="bRequireLOS",Type=HX_PROPERTY_Bool)
    Properties(3)=(Name="bAllowSkinHighlight",Type=HX_PROPERTY_Bool)
    Properties(4)=(Name="SkinHighlightIntensity",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0")
    Properties(5)=(Name="AllowForcedModels",Type=HX_PROPERTY_Enum,UpperLimit="4",EnumType=enum'EHxForcedModel')
    Properties(6)=(Name="ModelList",Type=HX_PROPERTY_Array)
    Properties(7)=(Name="bAllowCustomViewSmoothing",Type=HX_PROPERTY_Bool)
    Properties(8)=(Name="bAllowEnhancedScoreBoards",Type=HX_PROPERTY_Bool)
    Properties(9)=(Name="bAllowSpawnProtectionTimer",Type=HX_PROPERTY_Bool)
    Properties(10)=(Name="bColoredDeathMessages",Type=HX_PROPERTY_Bool)
    DisplayInfo(0)=(Section="Hit Effects",Caption="Allow hit sounds",Hint="Allow clients to enable/disable hit sound effects.")
    DisplayInfo(1)=(Section="Hit Effects",Caption="Allow damage numbers",Hint="Allow clients to enable/disable damage number effects.")
    DisplayInfo(2)=(Section="Hit Effects",Caption="Require line of sight",Hint="Require line of sight between player and target to trigger hit effects.")
    DisplayInfo(3)=(Section="Skin Highlight",Caption="Allow skin highlight",Hint="Allow clients to enable/disable skin highlights.")
    DisplayInfo(4)=(Section="Skin Highlight",Caption="Skin highlight intensity",Hint="Factor to multiply RGB values (between 0.0 and 1.0).",bAdvanced=true)
    DisplayInfo(5)=(Section="Skin Highlight",Caption="Allow forced models",Hint="Allow client-side forced character models (requires skin highlight allowed).",EnumLabels=("None","Official only","From list","Any"),bAdvanced=true)
    DisplayInfo(6)=(Section="Skin Highlight",Caption="Forced model list",Hint="List of character models to allow when using the 'from list' option.",bAdvanced=true)
    DisplayInfo(7)=(Section="Player",Caption="Allow custom view smoothing",Hint="Allow clients to select different types of view smoothing.")
    DisplayInfo(8)=(Section="HUD",Caption="Allow enhanced scoreboards",Hint="Allow clients to enable/disable the enhanced scoreboards.")
    DisplayInfo(9)=(Section="HUD",Caption="Allow spawn protection timer",Hint="Allow clients to enable/disable the spawn protection timer.")
    DisplayInfo(10)=(Section="HUD",Caption="Colored death messages",Hint="Use team colors in death messages (blue = killer and red = victim if no teams).")
    bDisableTick=true

    bAllowHitSounds=true
    bAllowDamageNumbers=true
    bAllowSkinHighlight=true
    bRequireLOS=false
    SkinHighlightIntensity=0.42
    AllowForcedModels=HX_FM_OfficialOnly
    ModelList(0)="Jakob"
    ModelList(1)="Gorge"
    ModelList(2)="Malcolm"
    ModelList(3)="Xan"
    ModelList(4)="Brock"
    ModelList(5)="Gaargod"
    ModelList(6)="Axon"
    ModelList(7)="Tamika"
    ModelList(8)="Sapphire"
    ModelList(9)="Enigma"
    ModelList(10)="Cathode"
    ModelList(11)="Rylisa"
    ModelList(12)="Ophelia"
    ModelList(13)="Zarina"
    bAllowCustomViewSmoothing=true
    bAllowEnhancedScoreBoards=true
    bAllowSpawnProtectionTimer=true
    bColoredDeathMessages=true
}
