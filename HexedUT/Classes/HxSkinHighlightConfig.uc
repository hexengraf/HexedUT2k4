class HxSkinHighlightConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config string YourTeam;
var config string EnemyTeam;
var config string SoloPlayer;
var config string ShieldHit;
var config string LinkHit;
var config string ShockHit;
var config string LightningHit;
var config bool bDisableOnDeadBodies;
var config bool bForceNormalSkins;
var config int SpectatorTeam;

function ApplyDefaultConfiguration()
{
    class<HxSkinHighlight>(TargetClass).default.YourTeam = YourTeam;
    class<HxSkinHighlight>(TargetClass).default.EnemyTeam = EnemyTeam;
    class<HxSkinHighlight>(TargetClass).default.SoloPlayer = SoloPlayer;
    class<HxSkinHighlight>(TargetClass).default.ShieldHit = ShieldHit;
    class<HxSkinHighlight>(TargetClass).default.LinkHit = LinkHit;
    class<HxSkinHighlight>(TargetClass).default.ShockHit = ShockHit;
    class<HxSkinHighlight>(TargetClass).default.LightningHit = LightningHit;
    class<HxSkinHighlight>(TargetClass).default.bDisableOnDeadBodies = bDisableOnDeadBodies;
    class<HxSkinHighlight>(TargetClass).default.bForceNormalSkins = bForceNormalSkins;
    class<HxSkinHighlight>(TargetClass).default.SpectatorTeam = SpectatorTeam;
}

function ValidateColors(HxColors Colors)
{
    local bool bSave;
    local int i;

    for (i = 0; i < 7; ++i)
    {
        if (!Colors.IsValidName(GetPropertyText(Properties[i].Name)))
        {
            ResetConfig(Properties[i].Name);
        }
    }
    if (bSave)
    {
        ApplyDefaultConfiguration();
        SaveConfig();
    }
}

function RenameColor(string OldColorName, string NewColorName)
{
    local bool bSave;
    local int i;

    for (i = 0; i < 7; ++i)
    {
        if (GetPropertyText(Properties[i].Name) == OldColorName)
        {
            SetPropertyText(Properties[i].Name, NewColorName);
            bSave = true;
        }
    }
    if (bSave)
    {
        ApplyDefaultConfiguration();
        SaveConfig();
    }
}

defaultproperties
{
    ObjectName="HexedUT"
    TargetClass=class'HxSkinHighlight'
    Properties(0)=(Name="YourTeam",Type=HX_PROPERTY_String)
    Properties(1)=(Name="EnemyTeam",Type=HX_PROPERTY_String)
    Properties(2)=(Name="SoloPlayer",Type=HX_PROPERTY_String)
    Properties(3)=(Name="ShieldHit",Type=HX_PROPERTY_String)
    Properties(4)=(Name="LinkHit",Type=HX_PROPERTY_String)
    Properties(5)=(Name="ShockHit",Type=HX_PROPERTY_String)
    Properties(6)=(Name="LightningHit",Type=HX_PROPERTY_String)
    Properties(7)=(Name="bDisableOnDeadBodies",Type=HX_PROPERTY_Bool)
    Properties(8)=(Name="bForceNormalSkins",Type=HX_PROPERTY_Bool)
    Properties(9)=(Name="SpectatorTeam",Type=HX_PROPERTY_Int,LowerLimit="0",UpperLimit="1")

    EnemyTeam="DISABLED"
    YourTeam="DISABLED"
    SoloPlayer="DISABLED"
    ShieldHit="DEFAULT"
    LinkHit="DEFAULT"
    ShockHit="DEFAULT"
    LightningHit="DEFAULT"
    bDisableOnDeadBodies=false
    bForceNormalSkins=true
}
