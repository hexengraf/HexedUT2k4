class HxSkinHighlightConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config string Teammates;
var config string Enemies;
var config string ShieldHit;
var config string LinkHit;
var config string ShockHit;
var config string LightningHit;
var config HxSkinHighlight.EHxSkinVariant TeammateSkin;
var config HxSkinHighlight.EHxSkinVariant EnemySkin;
var config bool bRandomize;
var config bool bDisableOnDeadBodies;
var config int SpectatorTeam;
var config string TeammateModel;
var config bool bForceTeammateModel;
var config string EnemyModel;
var config bool bForceEnemyModel;

function ValidateColors(HxColors Colors)
{
    local bool bSave;
    local int i;

    for (i = 0; i < 6; ++i)
    {
        if (!Colors.IsValidName(GetPropertyText(Properties[i].Name)))
        {
            ClearConfig(Properties[i].Name);
            bSave = true;
        }
    }
    if (bSave)
    {
        ApplyAllProperties();
        SaveConfig();
    }
}

function RenameColor(string OldColorName, string NewColorName)
{
    local bool bSave;
    local int i;

    for (i = 0; i < 6; ++i)
    {
        if (GetPropertyText(Properties[i].Name) == OldColorName)
        {
            SetPropertyText(Properties[i].Name, NewColorName);
            bSave = true;
        }
    }
    if (bSave)
    {
        ApplyAllProperties();
        SaveConfig();
    }
}

function ApplyAllProperties()
{
    class'HxSkinHighlight'.default.Teammates = Teammates;
    class'HxSkinHighlight'.default.Enemies = Enemies;
    class'HxSkinHighlight'.default.ShieldHit = ShieldHit;
    class'HxSkinHighlight'.default.LinkHit = LinkHit;
    class'HxSkinHighlight'.default.ShockHit = ShockHit;
    class'HxSkinHighlight'.default.LightningHit = LightningHit;
    class'HxSkinHighlight'.default.TeammateSkin = TeammateSkin;
    class'HxSkinHighlight'.default.EnemySkin = EnemySkin;
    class'HxSkinHighlight'.default.bRandomize = bRandomize;
    class'HxSkinHighlight'.default.bDisableOnDeadBodies = bDisableOnDeadBodies;
    class'HxSkinHighlight'.default.SpectatorTeam = SpectatorTeam;
    class'HxSkinHighlight'.default.TeammateModel = TeammateModel;
    class'HxSkinHighlight'.default.bForceTeammateModel = bForceTeammateModel;
    class'HxSkinHighlight'.default.EnemyModel = EnemyModel;
    class'HxSkinHighlight'.default.bForceEnemyModel = bForceEnemyModel;
}

function ApplyProperty(int Index)
{
    switch (Index)
    {
        case 0:
            class'HxSkinHighlight'.default.Teammates = Teammates;
            break;
        case 1:
            class'HxSkinHighlight'.default.Enemies = Enemies;
            break;
        case 2:
            class'HxSkinHighlight'.default.ShieldHit = ShieldHit;
            break;
        case 3:
            class'HxSkinHighlight'.default.LinkHit = LinkHit;
            break;
        case 4:
            class'HxSkinHighlight'.default.ShockHit = ShockHit;
            break;
        case 5:
            class'HxSkinHighlight'.default.LightningHit = LightningHit;
            break;
        case 6:
            class'HxSkinHighlight'.default.TeammateSkin = TeammateSkin;
            break;
        case 7:
            class'HxSkinHighlight'.default.EnemySkin = EnemySkin;
            break;
        case 8:
            class'HxSkinHighlight'.default.bRandomize = bRandomize;
            break;
        case 9:
            class'HxSkinHighlight'.default.bDisableOnDeadBodies = bDisableOnDeadBodies;
            break;
        case 10:
            class'HxSkinHighlight'.default.SpectatorTeam = SpectatorTeam;
            break;
        case 11:
            class'HxSkinHighlight'.default.TeammateModel = TeammateModel;
            break;
        case 12:
            class'HxSkinHighlight'.default.bForceTeammateModel = bForceTeammateModel;
            break;
        case 13:
            class'HxSkinHighlight'.default.EnemyModel = EnemyModel;
            break;
        case 14:
            class'HxSkinHighlight'.default.bForceEnemyModel = bForceEnemyModel;
            break;
    }
}

static function UpdateDynamicActors(PlayerController PC)
{
    local HxSkinHighlight SkinHighlight;

    if (PC != None)
    {
        ForEach PC.DynamicActors(class'HxSkinHighlight', SkinHighlight)
        {
            SkinHighlight.Restart();
        }
    }
}

defaultproperties
{
    ObjectName="HexedUT"
    Properties(0)=(Name="Teammates",Type=HX_PROPERTY_String)
    Properties(1)=(Name="Enemies",Type=HX_PROPERTY_String)
    Properties(2)=(Name="ShieldHit",Type=HX_PROPERTY_String)
    Properties(3)=(Name="LinkHit",Type=HX_PROPERTY_String)
    Properties(4)=(Name="ShockHit",Type=HX_PROPERTY_String)
    Properties(5)=(Name="LightningHit",Type=HX_PROPERTY_String)
    Properties(6)=(Name="TeammateSkin",Type=HX_PROPERTY_Enum,EnumValues=("HX_SKIN_RedTeam","HX_SKIN_BlueTeam","HX_SKIN_Normal"))
    Properties(7)=(Name="EnemySkin",Type=HX_PROPERTY_Enum,EnumValues=("HX_SKIN_RedTeam","HX_SKIN_BlueTeam","HX_SKIN_Normal"))
    Properties(8)=(Name="bRandomize",Type=HX_PROPERTY_Bool)
    Properties(9)=(Name="bDisableOnDeadBodies",Type=HX_PROPERTY_Bool)
    Properties(10)=(Name="SpectatorTeam",Type=HX_PROPERTY_Int,LowerLimit="0",UpperLimit="1")
    Properties(11)=(Name="TeammateModel",Type=HX_PROPERTY_String)
    Properties(12)=(Name="bForceTeammateModel",Type=HX_PROPERTY_Bool)
    Properties(13)=(Name="EnemyModel",Type=HX_PROPERTY_String)
    Properties(14)=(Name="bForceEnemyModel",Type=HX_PROPERTY_Bool)

    Teammates="DISABLED"
    Enemies="DISABLED"
    ShieldHit="DEFAULT"
    LinkHit="DEFAULT"
    ShockHit="DEFAULT"
    LightningHit="DEFAULT"
    TeammateSkin=HX_SKIN_Normal
    EnemySkin=HX_SKIN_Normal
    bRandomize=false
    bDisableOnDeadBodies=false
    TeammateModel="Jakob"
    bForceTeammateModel=false
    EnemyModel="Jakob"
    bForceEnemyModel=false
}
