class HxSkinHighlightConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config string Teammates;
var config string Enemies;
var config string ShieldHit;
var config string LinkHit;
var config string ShockHit;
var config string LightningHit;
var config HxSkinHighlight.EHxSkinType TeammateSkin;
var config HxSkinHighlight.EHxSkinType EnemySkin;
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
            ResetProperty(i);
            bSave = true;
        }
    }
    if (bSave)
    {
        InitializeProperties();
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
        InitializeProperties();
        SaveConfig();
    }
}

function InitializeProperties()
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
    UpdateDynamicActors();
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
    UpdateDynamicActors();
}

function bool ResetProperty(int Index)
{
    local bool bReset;

    switch (Index)
    {
        case 0:
            Teammates = default.Teammates;
            bReset = true;
            break;
        case 1:
            Enemies = default.Enemies;
            bReset = true;
            break;
        case 2:
            ShieldHit = default.ShieldHit;
            bReset = true;
            break;
        case 3:
            LinkHit = default.LinkHit;
            bReset = true;
            break;
        case 4:
            ShockHit = default.ShockHit;
            bReset = true;
            break;
        case 5:
            LightningHit = default.LightningHit;
            bReset = true;
            break;
        case 6:
            TeammateSkin = default.TeammateSkin;
            bReset = true;
            break;
        case 7:
            EnemySkin = default.EnemySkin;
            bReset = true;
            break;
        case 8:
            bRandomize = default.bRandomize;
            bReset = true;
            break;
        case 9:
            bDisableOnDeadBodies = default.bDisableOnDeadBodies;
            bReset = true;
            break;
        case 10:
            SpectatorTeam = default.SpectatorTeam;
            bReset = true;
            break;
        case 11:
            TeammateModel = default.TeammateModel;
            bReset = true;
            break;
        case 12:
            bForceTeammateModel = default.bForceTeammateModel;
            bReset = true;
            break;
        case 13:
            EnemyModel = default.EnemyModel;
            bReset = true;
            break;
        case 14:
            bForceEnemyModel = default.bForceEnemyModel;
            bReset = true;
            break;
    }
    if (bReset)
    {
        UpdateDynamicActors();
    }
    return bReset;
}

function UpdateDynamicActors()
{
    local HxSkinHighlight SkinHighlight;

    if (Level != None)
    {
        ForEach Level.DynamicActors(class'HxSkinHighlight', SkinHighlight)
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
    Properties(6)=(Name="TeammateSkin",Type=HX_PROPERTY_Enum,UpperLimit="3",EnumType=enum'EHxSkinType')
    Properties(7)=(Name="EnemySkin",Type=HX_PROPERTY_Enum,UpperLimit="3",EnumType=enum'EHxSkinType')
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
