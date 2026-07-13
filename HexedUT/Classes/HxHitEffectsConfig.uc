class HxHitEffectsConfig extends HxConfig
    config(User)
    PerObjectConfig;

const AUTO_FONT = "AUTOSELECT";

var config bool bHitSounds;
var config string HitSoundName;
var config float HitSoundVolume;
var config HxHitEffects.EHxPitchMode PitchMode;
var config bool bDamageNumbers;
var config HxHitEffects.EHxDisplayMode DisplayMode;
var config string DisplayFontName;
var config float DisplayPosX;
var config float DisplayPosY;
var config HxHitEffects.HxDamagePoint ZeroDamage;
var config HxHitEffects.HxDamagePoint LowDamage;
var config HxHitEffects.HxDamagePoint MediumDamage;
var config HxHitEffects.HxDamagePoint HighDamage;
var config HxHitEffects.HxDamagePoint ExtremeDamage;
var config array<string> FontNames;
var config array<string> CustomHitSounds;

var HxHitEffects.HxDamagePoint ValidationPoint;

function Created()
{
    ValidateHitSounds();
    ValidateFontNames();
    Super.Created();
}

private function ValidateHitSounds()
{
    local int i;

    if (!class'HxHitEffects'.static.IsBuiltInHitSound(HitSoundName))
    {
        if (DynamicLoadObject(HitSoundName, class'Sound', true) != None)
        {
            for (i = 0; i < CustomHitSounds.Length; ++i)
            {
                if (HitSoundName ~= CustomHitSounds[i])
                {
                    break;
                }
            }
            if (i == CustomHitSounds.Length)
            {
                CustomHitSounds[CustomHitSounds.Length] = HitSoundName;
            }
        }
        else
        {
            ResetProperty(1);
        }
    }
    for (i = CustomHitSounds.Length - 1; i >= 0; --i)
    {
        if (DynamicLoadObject(CustomHitSounds[i], class'Sound', true) == None)
        {
            CustomHitSounds.Remove(i, 1);
        }
    }
}

private function ValidateFontNames()
{
    local int i;

    if (DisplayFontName != AUTO_FONT)
    {
        if (class'HXGUIFontMidGame'.static.DynamicLoadFont(DisplayFontName, true) != None)
        {
            for (i = 0; i < FontNames.Length; ++i)
            {
                if (DisplayFontName ~= FontNames[i])
                {
                    break;
                }
            }
            if (i == FontNames.Length)
            {
                FontNames[FontNames.Length] = DisplayFontName;
            }
        }
        else
        {
            ResetProperty(6);
        }
    }
    for (i = FontNames.Length - 1; i >= 0; --i)
    {
        if (class'HXGUIFontMidGame'.static.DynamicLoadFont(FontNames[i], true) == None)
        {
            FontNames.Remove(i, 1);
        }
    }
}

function string ValidateStruct(int Index, string Value)
{
    SetPropertyText("ValidationPoint", Value);
    if (Properties[Index].Name == "ZeroDamage")
    {
        ValidationPoint.Value = 0;
    }
    ValidationPoint.Color.A = 255;
    ValidationPoint.Pitch = FClamp(ValidationPoint.Pitch, 0.0, 1.0);
    ValidationPoint.Scale = FClamp(ValidationPoint.Scale, 0.0, 1.0);
    return GetPropertyText("ValidationPoint");
}

function InitializeProperties()
{
    class'HxHitEffects'.default.bHitSounds = bHitSounds;
    class'HxHitEffects'.default.HitSoundName = HitSoundName;
    class'HxHitEffects'.default.HitSoundVolume = HitSoundVolume;
    class'HxHitEffects'.default.PitchMode = PitchMode;
    class'HxHitEffects'.default.bDamageNumbers = bDamageNumbers;
    class'HxHitEffects'.default.DisplayMode = DisplayMode;
    class'HxHitEffects'.default.DisplayFontName = DisplayFontName;
    class'HxHitEffects'.default.DisplayPosX = DisplayPosX;
    class'HxHitEffects'.default.DisplayPosY = DisplayPosY;
    class'HxHitEffects'.default.ZeroDamage = ZeroDamage;
    class'HxHitEffects'.default.LowDamage = LowDamage;
    class'HxHitEffects'.default.MediumDamage = MediumDamage;
    class'HxHitEffects'.default.HighDamage = HighDamage;
    class'HxHitEffects'.default.ExtremeDamage = ExtremeDamage;
    class'HxHitEffects'.default.FontNames = FontNames;
    class'HxHitEffects'.default.CustomHitSounds = CustomHitSounds;
    UpdateDynamicActors(-1);
}

function ApplyProperty(int Index)
{
    switch (Index)
    {
        case 0:
            class'HxHitEffects'.default.bHitSounds = bHitSounds;
            break;
        case 1:
            class'HxHitEffects'.default.HitSoundName = HitSoundName;
            break;
        case 2:
            class'HxHitEffects'.default.HitSoundVolume = HitSoundVolume;
            break;
        case 3:
            class'HxHitEffects'.default.PitchMode = PitchMode;
            break;
        case 4:
            class'HxHitEffects'.default.bDamageNumbers = bDamageNumbers;
            break;
        case 5:
            class'HxHitEffects'.default.DisplayMode = DisplayMode;
            break;
        case 6:
            class'HxHitEffects'.default.DisplayFontName = DisplayFontName;
            break;
        case 7:
            class'HxHitEffects'.default.DisplayPosX = DisplayPosX;
            break;
        case 8:
            class'HxHitEffects'.default.DisplayPosY = DisplayPosY;
            break;
        case 9:
            class'HxHitEffects'.default.ZeroDamage = ZeroDamage;
            break;
        case 10:
            class'HxHitEffects'.default.LowDamage = LowDamage;
            break;
        case 11:
            class'HxHitEffects'.default.MediumDamage = MediumDamage;
            break;
        case 12:
            class'HxHitEffects'.default.HighDamage = HighDamage;
            break;
        case 13:
            class'HxHitEffects'.default.ExtremeDamage = ExtremeDamage;
            break;
        case 14:
            class'HxHitEffects'.default.FontNames = FontNames;
            break;
        case 15:
            class'HxHitEffects'.default.CustomHitSounds = CustomHitSounds;
            break;
    }
    UpdateDynamicActors(Index);
}

function bool ResetProperty(int Index)
{
    local bool bReset;

    switch (Index)
    {
        case 0:
            bHitSounds = default.bHitSounds;
            bReset = true;
            break;
        case 1:
            HitSoundName = default.HitSoundName;
            bReset = true;
            break;
        case 2:
            HitSoundVolume = default.HitSoundVolume;
            bReset = true;
            break;
        case 3:
            PitchMode = default.PitchMode;
            bReset = true;
            break;
        case 4:
            bDamageNumbers = default.bDamageNumbers;
            bReset = true;
            break;
        case 5:
            DisplayMode = default.DisplayMode;
            bReset = true;
            break;
        case 6:
            DisplayFontName = default.DisplayFontName;
            bReset = true;
            break;
        case 7:
            DisplayPosX = default.DisplayPosX;
            bReset = true;
            break;
        case 8:
            DisplayPosY = default.DisplayPosY;
            bReset = true;
            break;
        case 9:
            ZeroDamage = default.ZeroDamage;
            bReset = true;
            break;
        case 10:
            LowDamage = default.LowDamage;
            bReset = true;
            break;
        case 11:
            MediumDamage = default.MediumDamage;
            bReset = true;
            break;
        case 12:
            HighDamage = default.HighDamage;
            bReset = true;
            break;
        case 13:
            ExtremeDamage = default.ExtremeDamage;
            bReset = true;
            break;
        case 14:
            FontNames = default.FontNames;
            bReset = true;
            break;
        case 15:
            CustomHitSounds = default.CustomHitSounds;
            bReset = true;
            break;
    }
    if (bReset)
    {
        UpdateDynamicActors(Index);
    }
    return bReset;
}

function UpdateDynamicActors(int Index)
{
    local HxHitEffects HitEffects;

    HitEffects = HxHitEffects(FindHudOverlay(class'HxHitEffects'));
    if (HitEffects != None)
    {
        if (Index < 0)
        {
            for (Index = 0; Index < Properties.Length; ++Index)
            {
                HitEffects.SetProperty(
                    Properties[Index].Name, GetPropertyText(Properties[Index].Name));
            }
        }
        else
        {
            HitEffects.SetProperty(Properties[Index].Name, GetPropertyText(Properties[Index].Name));
        }
    }
}

function TemporaryFirstRunFix()
{
    local array<string> NewFontNames;
    local int i;
    local int j;

    ResetProperty(6);
    NewFontNames = default.FontNames;
    for (i = 0; i < FontNames.Length; ++i)
    {
        for (j = 0; j < NewFontNames.Length; ++j)
        {
            if (FontNames[i] ~= NewFontNames[j])
            {
                break;
            }
        }
        if (j == NewFontNames.Length)
        {
            NewFontNames[NewFontNames.Length] = FontNames[i];
        }
    }
    FontNames = NewFontNames;
    SaveConfig();
    InitializeProperties();
}

defaultproperties
{
    ObjectName="HexedUT"
    Properties(0)=(Name="bHitSounds",Type=HX_PROPERTY_Bool)
    Properties(1)=(Name="HitSoundName",Type=HX_PROPERTY_String)
    Properties(2)=(Name="HitSoundVolume",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0")
    Properties(3)=(Name="PitchMode",Type=HX_PROPERTY_Enum)
    Properties(4)=(Name="bDamageNumbers",Type=HX_PROPERTY_Bool)
    Properties(5)=(Name="DisplayMode",Type=HX_PROPERTY_Enum)
    Properties(6)=(Name="DisplayFontName",Type=HX_PROPERTY_String)
    Properties(7)=(Name="DisplayPosX",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0")
    Properties(8)=(Name="DisplayPosY",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0")
    Properties(9)=(Name="ZeroDamage",Type=HX_PROPERTY_Struct)
    Properties(10)=(Name="LowDamage",Type=HX_PROPERTY_Struct)
    Properties(11)=(Name="MediumDamage",Type=HX_PROPERTY_Struct)
    Properties(12)=(Name="HighDamage",Type=HX_PROPERTY_Struct)
    Properties(13)=(Name="ExtremeDamage",Type=HX_PROPERTY_Struct)
    Properties(14)=(Name="FontNames",Type=HX_PROPERTY_Array)
    Properties(15)=(Name="CustomHitSounds",Type=HX_PROPERTY_Array)

    bHitSounds=true
    HitSoundName="HxHitSound0"
    HitSoundVolume=1.0
    PitchMode=HX_PITCH_High2Low
    bDamageNumbers=true
    DisplayMode=HX_DISPLAY_StaticDual
    DisplayFontName="AUTOSELECT";
    DisplayPosX=0.5
    DisplayPosY=0.45
    ZeroDamage=(Value=0,Pitch=0.00,Scale=0.00,Color=(R=255,G=255,B=255))
    LowDamage=(Value=20,Pitch=0.40,Scale=0.25,Color=(R=255,G=255,B=32))
    MediumDamage=(Value=45,Pitch=0.60,Scale=0.50,Color=(R=255,G=119,B=32))
    HighDamage=(Value=75,Pitch=0.82,Scale=0.75,Color=(R=255,G=32,B=32))
    ExtremeDamage=(Value=110,Pitch=1.00,Scale=1.00,Color=(R=143,G=32,B=245))
    FontNames(0)="UT2003Fonts.FontEurostile9"
    FontNames(1)="UT2003Fonts.FontEurostile12"
    FontNames(2)="UT2003Fonts.FontEurostile14"
    FontNames(3)="UT2003Fonts.FontEurostile17"
    FontNames(4)="HxFontEurostile18"
    FontNames(5)="UT2003Fonts.FontEurostile21"
    FontNames(6)="HxFontEurostile22"
    FontNames(7)="UT2003Fonts.FontEurostile24"
    FontNames(8)="HxFontEurostile27"
    FontNames(9)="HxFontEurostile28"
    FontNames(10)="UT2003Fonts.FontEurostile29"
    FontNames(11)="HxFontEurostile32"
    FontNames(12)="HxFontEurostile35"
    FontNames(13)="UT2003Fonts.FontEurostile37"
    FontNames(14)="HxFontEurostile42"
}
