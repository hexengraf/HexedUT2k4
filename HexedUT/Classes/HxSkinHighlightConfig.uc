class HxSkinHighlightConfig extends HxConfig
    config(User)
    PerObjectConfig;

var config string Teammates;
var config string Enemies;
var config string ShieldHit;
var config string LinkHit;
var config string ShockHit;
var config string LightningHit;
var config string TeammateProtected;
var config string EnemyProtected;
var config HxSkinHighlight.EHxSkinType TeammateSkin;
var config HxSkinHighlight.EHxSkinType EnemySkin;
var config bool bRandomize;
var config bool bDisableOnDeadBodies;
var config HxSkinHighlight.EHxHighlightMode HighlightMode;
var config int SpectatorTeam;
var config string PreferredTeammateModel;
var config string CurrentTeammateModel;
var config bool bForceTeammateModel;
var config string PreferredEnemyModel;
var config string CurrentEnemyModel;
var config bool bForceEnemyModel;

var MutHexedUT.EHxForcedModel AllowForcedModels;
var private array<string> ModelList;
var private const array<string> OfficialModelList;

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
    class'HxSkinHighlight'.default.TeammateProtected = TeammateProtected;
    class'HxSkinHighlight'.default.EnemyProtected = EnemyProtected;
    class'HxSkinHighlight'.default.TeammateSkin = TeammateSkin;
    class'HxSkinHighlight'.default.EnemySkin = EnemySkin;
    class'HxSkinHighlight'.default.bRandomize = bRandomize;
    class'HxSkinHighlight'.default.bDisableOnDeadBodies = bDisableOnDeadBodies;
    class'HxSkinHighlight'.default.HighlightMode = HighlightMode;
    class'HxSkinHighlight'.default.SpectatorTeam = SpectatorTeam;
    class'HxSkinHighlight'.default.TeammateModel = CurrentTeammateModel;
    class'HxSkinHighlight'.default.bForceTeammateModel = bForceTeammateModel;
    class'HxSkinHighlight'.default.EnemyModel = CurrentEnemyModel;
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
            class'HxSkinHighlight'.default.TeammateProtected = TeammateProtected;
            break;
        case 7:
            class'HxSkinHighlight'.default.EnemyProtected = EnemyProtected;
            break;
        case 8:
            class'HxSkinHighlight'.default.TeammateSkin = TeammateSkin;
            break;
        case 9:
            class'HxSkinHighlight'.default.EnemySkin = EnemySkin;
            break;
        case 10:
            class'HxSkinHighlight'.default.bRandomize = bRandomize;
            break;
        case 11:
            class'HxSkinHighlight'.default.bDisableOnDeadBodies = bDisableOnDeadBodies;
            break;
        case 12:
            class'HxSkinHighlight'.default.HighlightMode = HighlightMode;
            break;
        case 13:
            class'HxSkinHighlight'.default.SpectatorTeam = SpectatorTeam;
            break;
        case 14:
            class'HxSkinHighlight'.default.TeammateModel = CurrentTeammateModel;
            break;
        case 15:
            class'HxSkinHighlight'.default.bForceTeammateModel = bForceTeammateModel;
            break;
        case 16:
            class'HxSkinHighlight'.default.EnemyModel = CurrentEnemyModel;
            break;
        case 17:
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
            TeammateProtected = default.TeammateProtected;
            bReset = true;
            break;
        case 7:
            EnemyProtected = default.EnemyProtected;
            bReset = true;
            break;
        case 8:
            TeammateSkin = default.TeammateSkin;
            bReset = true;
            break;
        case 9:
            EnemySkin = default.EnemySkin;
            bReset = true;
            break;
        case 10:
            bRandomize = default.bRandomize;
            bReset = true;
            break;
        case 11:
            bDisableOnDeadBodies = default.bDisableOnDeadBodies;
            bReset = true;
            break;
        case 12:
            HighlightMode = default.HighlightMode;
            bReset = true;
            break;
        case 13:
            SpectatorTeam = default.SpectatorTeam;
            bReset = true;
            break;
        case 14:
            PreferredTeammateModel = default.PreferredTeammateModel;
            CurrentTeammateModel = default.CurrentTeammateModel;
            bReset = true;
            break;
        case 15:
            bForceTeammateModel = default.bForceTeammateModel;
            bReset = true;
            break;
        case 16:
            PreferredEnemyModel = default.PreferredEnemyModel;
            CurrentEnemyModel = default.CurrentEnemyModel;
            bReset = true;
            break;
        case 17:
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

function string ValidateString(int Index, string Value)
{
    switch (Properties[Index].Name)
    {
        case "CurrentTeammateModel":
            if (AllowForcedModels == HX_FM_Any || PreferredTeammateModel ~= CurrentTeammateModel)
            {
                PreferredTeammateModel = Value;
            }
            break;
        case "CurrentEnemyModel":
            if (AllowForcedModels == HX_FM_Any || PreferredEnemyModel ~= CurrentEnemyModel)
            {
                PreferredEnemyModel = Value;
            }
            break;
    }
    return Value;
}

function ApplyServerConfiguration(HxUTClient Client)
{
    SetPropertyText("AllowForcedModels", Client.GetServerProperty("AllowForcedModels"));
    ModelList = Client.ModelList;
    switch (AllowForcedModels)
    {
        case HX_FM_OfficialOnly:
            ValidateOfficialModel(PreferredTeammateModel, CurrentTeammateModel);
            ValidateOfficialModel(PreferredEnemyModel, CurrentEnemyModel);
            break;
        case HX_FM_FromList:
            ValidateFromModelList(PreferredTeammateModel, CurrentTeammateModel);
            ValidateFromModelList(PreferredEnemyModel, CurrentEnemyModel);
            break;
        default:
            CurrentTeammateModel = PreferredTeammateModel;
            CurrentEnemyModel = PreferredEnemyModel;
            break;
    }
    InitializeProperties();
    SaveConfig();
}

function ValidateOfficialModel(out string PreferredModel, out string CurrentModel)
{
    if (PreferredModel ~= CurrentModel)
    {
        if (!IsOfficialModel(CurrentModel))
        {
            CurrentModel = OfficialModelList[27];
        }
    }
    else if (IsOfficialModel(PreferredModel))
    {
        CurrentModel = PreferredModel;
    }
    else if (!IsOfficialModel(CurrentModel))
    {
        CurrentModel = OfficialModelList[27];
    }
}

function ValidateFromModelList(out string PreferredModel, out string CurrentModel)
{
    if (PreferredModel ~= CurrentModel)
    {
        if (!IsModelFromList(CurrentModel) && ModelList.Length > 0)
        {
            CurrentModel = ModelList[0];
        }
    }
    else if (IsModelFromList(PreferredModel))
    {
        CurrentModel = PreferredModel;
    }
    else if (!IsModelFromList(CurrentModel) && ModelList.Length > 0)
    {
        CurrentModel = ModelList[0];
    }
}

function bool IsModelFromList(string ModelName)
{
    local int i;

    for (i = 0; i < ModelList.Length; ++i)
    {
        if (ModelName ~= ModelList[i])
        {
            return true;
        }
    }
    return false;
}

function bool IsOfficialModel(string ModelName)
{
    local int i;

    for (i = 0; i < OfficialModelList.Length; ++i)
    {
        if (ModelName ~= OfficialModelList[i])
        {
            return true;
        }
    }
    return false;
}

function bool CanForceModels()
{
    switch (AllowForcedModels)
    {
        case HX_FM_None:
            return false;
        case HX_FM_FromList:
            return ModelList.Length > 0;
    }
    return true;
}

function bool GetAllowedModelList(out array<string> List)
{
    switch (AllowForcedModels)
    {
        case HX_FM_OfficialOnly:
            List = OfficialModelList;
            return true;
        case HX_FM_FromList:
            list = ModelList;
            return true;
    }
    return false;
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
    Properties(6)=(Name="TeammateProtected",Type=HX_PROPERTY_String)
    Properties(7)=(Name="EnemyProtected",Type=HX_PROPERTY_String)
    Properties(8)=(Name="TeammateSkin",Type=HX_PROPERTY_Enum,UpperLimit="3",EnumType=enum'EHxSkinType')
    Properties(9)=(Name="EnemySkin",Type=HX_PROPERTY_Enum,UpperLimit="3",EnumType=enum'EHxSkinType')
    Properties(10)=(Name="bRandomize",Type=HX_PROPERTY_Bool)
    Properties(11)=(Name="bDisableOnDeadBodies",Type=HX_PROPERTY_Bool)
    Properties(12)=(Name="HighlightMode",Type=HX_PROPERTY_Enum,UpperLimit="2",EnumType=enum'EHxHighlightMode')
    Properties(13)=(Name="SpectatorTeam",Type=HX_PROPERTY_Int,LowerLimit="0",UpperLimit="1")
    Properties(14)=(Name="CurrentTeammateModel",Type=HX_PROPERTY_String)
    Properties(15)=(Name="bForceTeammateModel",Type=HX_PROPERTY_Bool)
    Properties(16)=(Name="CurrentEnemyModel",Type=HX_PROPERTY_String)
    Properties(17)=(Name="bForceEnemyModel",Type=HX_PROPERTY_Bool)

    Teammates="DISABLED"
    Enemies="DISABLED"
    ShieldHit="DEFAULT"
    LinkHit="DEFAULT"
    ShockHit="DEFAULT"
    LightningHit="DEFAULT"
    TeammateProtected="DEFAULT"
    EnemyProtected="DEFAULT"
    TeammateSkin=HX_SKIN_Normal
    EnemySkin=HX_SKIN_Normal
    bRandomize=false
    bDisableOnDeadBodies=false
    HighlightMode=HX_SHM_RoleBased
    SpectatorTeam=0
    PreferredTeammateModel="Jakob"
    CurrentTeammateModel="Jakob"
    bForceTeammateModel=false
    PreferredEnemyModel="Jakob"
    CurrentEnemyModel="Jakob"
    bForceEnemyModel=false

    AllowForcedModels=HX_FM_None
    OfficialModelList(0)="Mekkor"
    OfficialModelList(1)="Skrilax"
    OfficialModelList(2)="Barktooth"
    OfficialModelList(3)="Karag"
    OfficialModelList(4)="Kragoth"
    OfficialModelList(5)="Thannis"
    OfficialModelList(6)="Karaash"
    OfficialModelList(7)="Bale"
    OfficialModelList(8)="Tyler"
    OfficialModelList(9)="GothGirl"
    OfficialModelList(10)="glumpf"
    OfficialModelList(11)="Dominator"
    OfficialModelList(12)="Drekorig"
    OfficialModelList(13)="Skakruk"
    OfficialModelList(14)="Guardian"
    OfficialModelList(15)="ClanLord"
    OfficialModelList(16)="Kraagesh"
    OfficialModelList(17)="Gaargod"
    OfficialModelList(18)="Gkublok"
    OfficialModelList(19)="Virus"
    OfficialModelList(20)="Enigma"
    OfficialModelList(21)="Xan"
    OfficialModelList(22)="Cyclops"
    OfficialModelList(23)="Cathode"
    OfficialModelList(24)="Axon"
    OfficialModelList(25)="Divisor"
    OfficialModelList(26)="Matrix"
    OfficialModelList(27)="Jakob"
    OfficialModelList(28)="Aryss"
    OfficialModelList(29)="Tamika"
    OfficialModelList(30)="Othello"
    OfficialModelList(31)="Azure"
    OfficialModelList(32)="Annika"
    OfficialModelList(33)="Riker"
    OfficialModelList(34)="Garrett"
    OfficialModelList(35)="Baird"
    OfficialModelList(36)="Greith"
    OfficialModelList(37)="Zarina"
    OfficialModelList(38)="Ophelia"
    OfficialModelList(39)="Kaela"
    OfficialModelList(40)="Rae"
    OfficialModelList(41)="Kane"
    OfficialModelList(42)="Outlaw"
    OfficialModelList(43)="Abaddon"
    OfficialModelList(44)="Enki"
    OfficialModelList(45)="Neil"
    OfficialModelList(46)="Malcolm"
    OfficialModelList(47)="Brock"
    OfficialModelList(48)="Lauren"
    OfficialModelList(49)="Diva"
    OfficialModelList(50)="Scarab"
    OfficialModelList(51)="Asp"
    OfficialModelList(52)="Roc"
    OfficialModelList(53)="Memphis"
    OfficialModelList(54)="Horus"
    OfficialModelList(55)="Cleopatra"
    OfficialModelList(56)="Hyena"
    OfficialModelList(57)="Gorge"
    OfficialModelList(58)="Rylisa"
    OfficialModelList(59)="Cannonball"
    OfficialModelList(60)="Ambrosia"
    OfficialModelList(61)="Frostbite"
    OfficialModelList(62)="Reinha"
    OfficialModelList(63)="Arclite"
    OfficialModelList(64)="Siren"
    OfficialModelList(65)="Prism"
    OfficialModelList(66)="Wraith"
    OfficialModelList(67)="Sapphire"
    OfficialModelList(68)="Romulus"
    OfficialModelList(69)="BlackJack"
    OfficialModelList(70)="Torch"
    OfficialModelList(71)="Satin"
    OfficialModelList(72)="Remus"
    OfficialModelList(73)="Damarus"
    OfficialModelList(74)="Mokara"
    OfficialModelList(75)="Motig"
    OfficialModelList(76)="Faraleth"
    OfficialModelList(77)="Komek"
    OfficialModelList(78)="Makreth"
    OfficialModelList(79)="Selig"
    OfficialModelList(80)="Nebri"
    OfficialModelList(81)="Thorax"
    OfficialModelList(82)="Widowmaker"
    OfficialModelList(83)="Cobalt"
    OfficialModelList(84)="Corrosion"
    OfficialModelList(85)="Mandible"
    OfficialModelList(86)="Syzygy"
    OfficialModelList(87)="Rapier"
    OfficialModelList(88)="Renegade"
    OfficialModelList(89)="Brutalis"
    OfficialModelList(90)="Lilith"
    OfficialModelList(91)="Mr.Crow"
    OfficialModelList(92)="Domina"
    OfficialModelList(93)="Ravage"
    OfficialModelList(94)="Fate"
    OfficialModelList(95)="Harlequin"
    OfficialModelList(96)="Subversa"
    OfficialModelList(97)="Aurora"
}
