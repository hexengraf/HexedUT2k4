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
        ApplyAllProperties();
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
        ApplyAllProperties();
        SaveConfig();
    }
}

function ApplyAllProperties()
{
    class'HxSkinHighlight'.default.YourTeam = YourTeam;
    class'HxSkinHighlight'.default.EnemyTeam = EnemyTeam;
    class'HxSkinHighlight'.default.SoloPlayer = SoloPlayer;
    class'HxSkinHighlight'.default.ShieldHit = ShieldHit;
    class'HxSkinHighlight'.default.LinkHit = LinkHit;
    class'HxSkinHighlight'.default.ShockHit = ShockHit;
    class'HxSkinHighlight'.default.LightningHit = LightningHit;
    class'HxSkinHighlight'.default.bDisableOnDeadBodies = bDisableOnDeadBodies;
    class'HxSkinHighlight'.default.bForceNormalSkins = bForceNormalSkins;
    class'HxSkinHighlight'.default.SpectatorTeam = SpectatorTeam;
}

function ApplyProperty(int Index)
{
    switch (Index)
    {
        case 0:
            class'HxSkinHighlight'.default.YourTeam = YourTeam;
            break;
        case 1:
            class'HxSkinHighlight'.default.EnemyTeam = EnemyTeam;
            break;
        case 2:
            class'HxSkinHighlight'.default.SoloPlayer = SoloPlayer;
            break;
        case 3:
            class'HxSkinHighlight'.default.ShieldHit = ShieldHit;
            break;
        case 4:
            class'HxSkinHighlight'.default.LinkHit = LinkHit;
            break;
        case 5:
            class'HxSkinHighlight'.default.ShockHit = ShockHit;
            break;
        case 6:
            class'HxSkinHighlight'.default.LightningHit = LightningHit;
            break;
        case 7:
            class'HxSkinHighlight'.default.bDisableOnDeadBodies = bDisableOnDeadBodies;
            break;
        case 8:
            class'HxSkinHighlight'.default.bForceNormalSkins = bForceNormalSkins;
            break;
        case 9:
            class'HxSkinHighlight'.default.SpectatorTeam = SpectatorTeam;
            break;
    }
}

defaultproperties
{
    ObjectName="HexedUT"
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
