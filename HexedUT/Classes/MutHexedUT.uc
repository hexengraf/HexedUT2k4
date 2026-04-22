class MutHexedUT extends HxMutator;

var config bool bAllowHitSounds;
var config bool bAllowDamageNumbers;
var config bool bAllowSpawnProtectionTimer;
var config bool bColoredDeathMessages;
var config bool bAllowSkinHighlight;
var config float SkinHighlightIntensity;
var config bool bAllowCustomViewSmoothing;

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
        SkinHighlight.HighlightIntensity = SkinHighlightIntensity;
        Pawn.AttachToBone(SkinHighlight, 'spine');
    }
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (Other.IsA('xPawn'))
    {
        SpawnSkinHighlight(xPawn(Other));
    }
    return Super.CheckReplacement(Other, bSuperRelevant);
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

defaultproperties
{
    FriendlyName="HexedUT v7T1"
    Description="Provides hit sounds, damage numbers, skin highlights, colored death messages, and more."
    bAddToServerPackages=true
    CRIClass=class'HxUTClient'
    Properties(0)=(Name="bAllowHitSounds",Section="Hit Effects",Caption="Allow hit sounds",Hint="Allow clients to enable/disable hit sound effects.",Type="Check")
    Properties(1)=(Name="bAllowDamageNumbers",Section="Hit Effects",Caption="Allow damage numbers",Hint="Allow clients to enable/disable damage number effects.",Type="Check")
    Properties(2)=(Name="bAllowSpawnProtectionTimer",Section="Interface",Caption="Allow spawn protection timer",Hint="Allow clients to enable/disable the spawn protection timer.",Type="Check")
    Properties(3)=(Name="bColoredDeathMessages",Section="Interface",Caption="Colored death messages",Hint="Use team colors in death messages (blue = killer and red = victim if no teams).",Type="Check")
    Properties(4)=(Name="bAllowSkinHighlight",Section="Skin Highlight",Caption="Allow skin highlight",Hint="Allow clients to enable/disable skin highlights.",Type="Check")
    Properties(5)=(Name="SkinHighlightIntensity",Section="Skin Highlight",Caption="Skin highlight intensity",Hint="Factor to multiply RGB values (between 0.0 and 1.0).",Type="Text",Data="8;0.0:1.0",bAdvanced=true)
    Properties(6)=(Name="bAllowCustomViewSmoothing",Section="Camera",Caption="Allow custom view smoothing",Hint="Allow clients to select different types of view smoothing.",Type="Check")
    bAllowURLOptions=true
    bDisableTick=true

    bAllowHitSounds=true
    bAllowDamageNumbers=true
    bAllowSpawnProtectionTimer=true
    bColoredDeathMessages=true
    bAllowSkinHighlight=true
    SkinHighlightIntensity=0.35
    bAllowCustomViewSmoothing=true
}
