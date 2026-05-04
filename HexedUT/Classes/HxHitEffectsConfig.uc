class HxHitEffectsConfig extends HxConfig
    config(User)
    PerObjectConfig;

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

function Created()
{
    local int Changes;

    Super.Created();
    Changes = ValidateHitSounds();
    Changes += ValidateFontNames();
    Changes += ValidateDamagePoints();
    if (Changes > 0)
    {
        SaveConfig();
    }
}

private function int ValidateHitSounds()
{
    local int Changes;
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
                ++Changes;
            }
        }
        else
        {
            ResetConfig("HitSoundName");
            ++Changes;
        }
    }
    for (i = CustomHitSounds.Length - 1; i >= 0; --i)
    {
        if (DynamicLoadObject(CustomHitSounds[i], class'Sound', true) == None)
        {
            CustomHitSounds.Remove(i, 1);
            ++Changes;
        }
    }
    return Changes;
}

private function int ValidateFontNames()
{
    local int Changes;
    local int i;

    if (DynamicLoadObject(DisplayFontName, class'Font', true) != None)
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
            ++Changes;
        }
    }
    else
    {
        ResetConfig("DisplayFontName");
        ++Changes;
    }
    for (i = FontNames.Length - 1; i >= 0; --i)
    {
        if (DynamicLoadObject(FontNames[i], class'Font', true) == None)
        {
            FontNames.Remove(i, 1);
            ++Changes;
        }
    }
    return Changes;
}

private function int ValidateDamagePoints()
{
    local int Changes;
    local float ClampedValue;

    Changes += int(ZeroDamage.Value != 0);
    ZeroDamage.Value = 0;
    Changes += int(ZeroDamage.Color.A != 255);
    ZeroDamage.Color.A = 255;
    ClampedValue = FClamp(ZeroDamage.Pitch, 0.0, 1.0);
    Changes += int(ZeroDamage.Pitch != ClampedValue);
    ZeroDamage.Pitch = ClampedValue;
    ClampedValue = FClamp(ZeroDamage.Scale, 0.0, 1.0);
    Changes += int(ZeroDamage.Scale != ClampedValue);
    ZeroDamage.Scale = ClampedValue;
    Changes += int(LowDamage.Color.A != 255);
    LowDamage.Color.A = 255;
    ClampedValue = FClamp(LowDamage.Pitch, 0.0, 1.0);
    Changes += int(LowDamage.Pitch != ClampedValue);
    LowDamage.Pitch = ClampedValue;
    ClampedValue = FClamp(LowDamage.Scale, 0.0, 1.0);
    Changes += int(LowDamage.Scale != ClampedValue);
    LowDamage.Scale = ClampedValue;
    Changes += int(MediumDamage.Color.A != 255);
    MediumDamage.Color.A = 255;
    ClampedValue = FClamp(MediumDamage.Pitch, 0.0, 1.0);
    Changes += int(MediumDamage.Pitch != ClampedValue);
    MediumDamage.Pitch = ClampedValue;
    ClampedValue = FClamp(MediumDamage.Scale, 0.0, 1.0);
    Changes += int(MediumDamage.Scale != ClampedValue);
    MediumDamage.Scale = ClampedValue;
    Changes += int(HighDamage.Color.A != 255);
    HighDamage.Color.A = 255;
    ClampedValue = FClamp(HighDamage.Pitch, 0.0, 1.0);
    Changes += int(HighDamage.Pitch != ClampedValue);
    HighDamage.Pitch = ClampedValue;
    ClampedValue = FClamp(HighDamage.Scale, 0.0, 1.0);
    Changes += int(HighDamage.Scale != ClampedValue);
    HighDamage.Scale = ClampedValue;
    Changes += int(ExtremeDamage.Color.A != 255);
    ExtremeDamage.Color.A = 255;
    ClampedValue = FClamp(ExtremeDamage.Pitch, 0.0, 1.0);
    Changes += int(ExtremeDamage.Pitch != ClampedValue);
    ExtremeDamage.Pitch = ClampedValue;
    ClampedValue = FClamp(ExtremeDamage.Scale, 0.0, 1.0);
    Changes += int(ExtremeDamage.Scale != ClampedValue);
    ExtremeDamage.Scale = ClampedValue;
    return Changes;
}

function ApplyDefaultConfiguration()
{
    class<HxHitEffects>(TargetClass).default.bHitSounds = bHitSounds;
    class<HxHitEffects>(TargetClass).default.HitSoundName = HitSoundName;
    class<HxHitEffects>(TargetClass).default.HitSoundVolume = HitSoundVolume;
    class<HxHitEffects>(TargetClass).default.PitchMode = PitchMode;
    class<HxHitEffects>(TargetClass).default.bDamageNumbers = bDamageNumbers;
    class<HxHitEffects>(TargetClass).default.DisplayMode = DisplayMode;
    class<HxHitEffects>(TargetClass).default.DisplayFontName = DisplayFontName;
    class<HxHitEffects>(TargetClass).default.DisplayPosX = DisplayPosX;
    class<HxHitEffects>(TargetClass).default.DisplayPosY = DisplayPosY;
    class<HxHitEffects>(TargetClass).default.ZeroDamage = ZeroDamage;
    class<HxHitEffects>(TargetClass).default.LowDamage = LowDamage;
    class<HxHitEffects>(TargetClass).default.MediumDamage = MediumDamage;
    class<HxHitEffects>(TargetClass).default.HighDamage = HighDamage;
    class<HxHitEffects>(TargetClass).default.ExtremeDamage = ExtremeDamage;
    class<HxHitEffects>(TargetClass).default.FontNames = FontNames;
    class<HxHitEffects>(TargetClass).default.CustomHitSounds = CustomHitSounds;
}

defaultproperties
{
    ObjectName="HexedUT"
    TargetClass=class'HxHitEffects'
    Properties(0)=(Name="bHitSounds",Type=HX_PROPERTY_Bool)
    Properties(1)=(Name="HitSoundName",Type=HX_PROPERTY_String)
    Properties(2)=(Name="HitSoundVolume",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0",Step="0.05")
    Properties(3)=(Name="PitchMode",Type=HX_PROPERTY_Enum)
    Properties(4)=(Name="bDamageNumbers",Type=HX_PROPERTY_Bool)
    Properties(5)=(Name="DisplayMode",Type=HX_PROPERTY_Enum)
    Properties(6)=(Name="DisplayFontName",Type=HX_PROPERTY_String)
    Properties(7)=(Name="DisplayPosX",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0",Step="0.05")
    Properties(8)=(Name="DisplayPosY",Type=HX_PROPERTY_Float,LowerLimit="0.0",UpperLimit="1.0",Step="0.05")
    Properties(9)=(Name="ZeroDamage",Type=HX_PROPERTY_Struct)
    Properties(10)=(Name="LowDamage",Type=HX_PROPERTY_Struct)
    Properties(11)=(Name="MediumDamage",Type=HX_PROPERTY_Struct)
    Properties(12)=(Name="HighDamage",Type=HX_PROPERTY_Struct)
    Properties(13)=(Name="ExtremeDamage",Type=HX_PROPERTY_Struct)
    Properties(14)=(Name="FontNames",Type=HX_PROPERTY_Array)
    Properties(15)=(Name="CustomHitSounds",Type=HX_PROPERTY_Array)

    bHitSounds=true
    HitSoundName="HxHitSound1"
    HitSoundVolume=1.0
    PitchMode=HX_PITCH_High2Low
    bDamageNumbers=true
    DisplayMode=HX_DISPLAY_StaticDual
    DisplayFontName="UT2003Fonts.FontEurostile37";
    DisplayPosX=0.5
    DisplayPosY=0.45
    ZeroDamage=(Value=0,Pitch=0,Scale=0,Color=(R=255,G=255,B=255))
    LowDamage=(Value=30,Pitch=0.30,Scale=0.30,Color=(R=255,G=255,B=32))
    MediumDamage=(Value=70,Pitch=0.55,Scale=0.55,Color=(R=255,G=119,B=32))
    HighDamage=(Value=120,Pitch=0.75,Scale=0.75,Color=(R=255,G=32,B=32))
    ExtremeDamage=(Value=180,Pitch=1.00,Scale=1.00,Color=(R=143,G=32,B=245))
    FontNames(0)="UT2003Fonts.FontEurostile29"
    FontNames(1)="UT2003Fonts.FontEurostile37"
    FontNames(2)="UT2003Fonts.FontNeuzeit29"
    FontNames(3)="UT2003Fonts.FontNeuzeit37"
    FontNames(4)="2K4Fonts.Verdana28"
    FontNames(5)="2K4Fonts.Verdana30"
    FontNames(6)="2K4Fonts.Verdana32"
    FontNames(7)="2K4Fonts.Verdana34"
}
