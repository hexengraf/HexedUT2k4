class HxHitEffects extends HudOverlay
    config(User);

#exec AUDIO IMPORT FILE=Sounds\HxHitSound1.wav
#exec AUDIO IMPORT FILE=Sounds\HxHitSound2.wav
#exec AUDIO IMPORT FILE=Sounds\HxHitSound3.wav
#exec AUDIO IMPORT FILE=Sounds\HxHitSound4.wav
#exec AUDIO IMPORT FILE=Sounds\HxHitSound5.wav

enum EHxPitchMode
{
    HX_PITCH_Disabled,
    HX_PITCH_Low2High,
    HX_PITCH_High2Low,
};

enum EHxDisplayMode
{
    HX_DISPLAY_Static,
    HX_DISPLAY_StaticTotal,
    HX_DISPLAY_StaticDual,
    HX_DISPLAY_Float,
    HX_DISPLAY_FloatDual,
};

struct HxDisplayWidget
{
    var int Value;
    var float Scale;
    var Color Color;
    var float DeltaY;
    var float Duration;
};

struct HxDamagePoint
{
    var int Value;
    var float Pitch;
    var float Scale;
    var Color Color;
};

const ALAUDIO_PITCH_MIN = 0.5;
const ALAUDIO_PITCH_MAX = 2.0;
const ALAUDIO_PITCH_SPECTRUM = 1.5; // ALAUDIO_PITCH_MAX - ALAUDIO_PITCH_MIN
const ALAUDIO_PITCH_NEUTRAL = 1.0;

const FONT_SCALE_MIN = 0.70;
const FONT_SCALE_SPECTRUM = 0.30; // 1 - FONT_SCALE_MIN
const REFERENCE_SCREEN_X = 3840;

const DN_STATIC_INDEX = 0;
const DN_TOTAL_INDEX = 1;
const DN_NORMAL_DURATION = 1.0;
const DN_EXTENDED_DURATION = 1.5;
const DN_TRAVEL = 0.15;
const DN_DUAL_OFFSET = 0.025;

var config bool bHitSounds;
var config string HitSoundName;
var config float HitSoundVolume;
var config EHxPitchMode PitchMode;
var config bool bDamageNumbers;
var config EHxDisplayMode DisplayMode;
var config string DisplayFontName;
var config float DisplayPosX;
var config float DisplayPosY;
var config HxDamagePoint DamagePoints[5];
var config array<string> FontNames;
var config array<string> CustomHitSounds;

var private PlayerController PC;
var private array<Sound> BuiltInHitSounds;
var private array<HxDisplayWidget> Widgets;
var private Sound LoadedHitSound;
var private Font LoadedFont;
var private float GlobalScale;

simulated event PreBeginPlay()
{
    super.PreBeginPlay();
    PC = HUD(Owner).PlayerOwner;
    InitializeWidgets();
    LoadHitSound();
    LoadFont();
    ValidatePositions();
    ValidateCustomHitSounds();
    ValidateDamagePoints();
    ValidateFontNames();
    SaveConfig();
}

simulated function ValidatePositions()
{
    DisplayPosX = FClamp(DisplayPosX, 0.0, 1.0);
    DisplayPosY = FClamp(DisplayPosY, 0.0, 1.0);
}

simulated function ValidateCustomHitSounds()
{
    local int i;

    for (i = 0; i < BuiltInHitSounds.Length; ++i)
    {
        if (HitSoundName ~= GetItemName(string(BuiltInHitSounds[i])))
        {
            return;
        }
    }
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

simulated function ValidateFontNames()
{
    local int i;

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

simulated function ValidateDamagePoints()
{
    local int i;

    for (i = 0; i < ArrayCount(DamagePoints); ++i)
    {
        DamagePoints[i].Color.A = 255;
        DamagePoints[i].Pitch = FClamp(DamagePoints[i].Pitch, 0.0, 1.0);
        DamagePoints[i].Scale = FClamp(DamagePoints[i].Scale, 0.0, 1.0);
    }
    DamagePoints[0].Value = 0;
}

simulated function bool LoadHitSound()
{
    if (IsHitSoundChanged())
    {
        if (LoadHitSoundFromBuiltIn())
        {
            return true;
        }
        LoadedHitSound = Sound(DynamicLoadObject(HitSoundName, class'Sound', true));
        if (LoadedHitSound == None)
        {
            ResetConfig("HitSoundName");
            LoadHitSoundFromBuiltIn();
            return false;
        }
    }
    return true;
}

simulated function bool LoadHitSoundFromBuiltIn()
{
    local int i;

    for (i = 0; i < BuiltInHitSounds.Length; ++i)
    {
        if (HitSoundName ~= GetItemName(string(BuiltInHitSounds[i])))
        {
            LoadedHitSound = BuiltInHitSounds[i];
            return true;
        }
    }
    return false;
}

simulated function bool LoadFont()
{
    if (IsFontChanged())
    {
        LoadedFont = Font(DynamicLoadObject(DisplayFontName, class'Font', true));
        if (LoadedFont == None)
        {
            ResetConfig("DisplayFontName");
            LoadedFont = Font(DynamicLoadObject(DisplayFontName, class'Font'));
            return false;
        }
    }
    return true;
}

simulated function InitializeWidgets()
{
    local int i;

    Widgets.Length = DN_TOTAL_INDEX + 1;
    for (i = 0; i < Widgets.Length; ++i)
    {
        InitializeWidget(i);
    }
}

simulated function InitializeWidget(int i)
{
    Widgets[i].Value = 0;
    Widgets[i].DeltaY = 0;
    Widgets[i].Duration = DN_NORMAL_DURATION;
}

simulated Event Tick(float DeltaTime)
{
    local bool bKeepSize;
    local int i;

    bKeepSize = Widgets.Length == DN_TOTAL_INDEX + 1;

    for (i = 0; i < Widgets.Length; ++i)
    {
        if (Widgets[i].Value > 0)
        {
            Widgets[i].Duration -= DeltaTime;
            if (i > DN_TOTAL_INDEX && TickFloatWidgets(i, DeltaTime))
            {
                bKeepSize = true;
            }
            if (Widgets[i].Duration <= 0)
            {
                InitializeWidget(i);
            }
            else
            {
                Widgets[i].Color.A = GetFade(i);
            }
        }
    }
    if (!bKeepSize)
    {
        Widgets.Length = DN_TOTAL_INDEX + 1;
    }
}

simulated function bool TickFloatWidgets(int i, float DeltaTime)
{
    if (Widgets[i].Duration > 0)
    {
        Widgets[i].DeltaY -= DeltaTime * DN_TRAVEL;
        return true;
    }
    if (DisplayMode == HX_DISPLAY_FloatDual)
    {
        if (Widgets[DN_TOTAL_INDEX].Value == 0)
        {
            Widgets[DN_TOTAL_INDEX].DeltaY = -DN_TRAVEL - DeltaTime * DN_TRAVEL;
        }
        UpdateWidget(DN_TOTAL_INDEX, Widgets[i].Value);
        Widgets[DN_TOTAL_INDEX].Duration = DN_EXTENDED_DURATION;
    }
    return false;
}

simulated function Render(Canvas C)
{
    local float SavedFontScaleX;
    local float SavedFontScaleY;
    local int i;

    SavedFontScaleX = C.FontScaleX;
    SavedFontScaleY = C.FontScaleY;
    GlobalScale = C.ClipX / REFERENCE_SCREEN_X;
    for (i = 0; i < Widgets.Length; ++i)
    {
        if (Widgets[i].Value > 0)
        {
            DrawWidget(C, i);
        }
    }
    C.FontScaleX = SavedFontScaleX;
    C.FontScaleY = SavedFontScaleY;
}

simulated function DrawWidget(Canvas C, int i)
{
    local float XL;
    local float YL;

    C.DrawColor = Widgets[i].Color;
    C.Font = LoadedFont;
    C.FontScaleX = GlobalScale * Widgets[i].Scale;
    C.FontScaleY = C.FontScaleX;
    C.StrLen(Widgets[i].Value, XL, YL);
    C.SetPos((C.ClipX - XL) * DisplayPosX, (C.ClipY - YL) * (DisplayPosY + Widgets[i].DeltaY));
    C.DrawText(Widgets[i].Value);
}

simulated function DrawPreview(Canvas C, int i)
{
    local float XL;
    local float YL;

    C.DrawColor = DamagePoints[i].Color;
    C.Font = LoadedFont;
    C.FontScaleX = GlobalScale * ToAbsoluteScale(DamagePoints[i].Scale);
    C.FontScaleY = C.FontScaleX;
    C.StrLen(DamagePoints[i].Value, XL, YL);
    C.SetPos((C.ClipX - XL) * 0.5, (C.ClipY - YL) * 0.5);
    C.DrawText(DamagePoints[i].Value);
}

simulated function Update(int Damage, bool bAllowHitSounds, bool bAllowDamageNumbers)
{
    if (bAllowHitSounds && bHitSounds)
    {
        PlayHitSound(Damage);
    }
    if (bAllowDamageNumbers && bDamageNumbers)
    {
        UpdateWidgets(Damage);
    }
}

simulated function PlayHitSound(int Damage)
{
    if (PC.ViewTarget != None)
    {
        PC.ViewTarget.PlaySound(LoadedHitSound,,HitSoundVolume,,,GetPitch(Damage));
    }
}

simulated function float GetPitch(int Damage)
{
    local float Pitch;
    local int i;

    if (PitchMode == HX_PITCH_Disabled)
    {
        return ALAUDIO_PITCH_NEUTRAL;
    }
    for (i = 1; i < ArrayCount(DamagePoints); ++i)
    {
        if (Damage < DamagePoints[i].Value)
        {
            Pitch = FInterpolate(
                Damage, DamagePoints[i].Value, DamagePoints[i - 1].Pitch, DamagePoints[i].Pitch);
            break;
        }
    }
    if (i == ArrayCount(DamagePoints))
    {
        Pitch = DamagePoints[ArrayCount(DamagePoints) - 1].Pitch;
    }
    if (PitchMode == HX_PITCH_Low2High)
    {
        return ALAUDIO_PITCH_MIN + Pitch * ALAUDIO_PITCH_SPECTRUM;
    }
    return ALAUDIO_PITCH_MAX - Pitch * ALAUDIO_PITCH_SPECTRUM;
}

simulated function UpdateWidgets(int Damage)
{
    switch (DisplayMode)
    {
        case HX_DISPLAY_Static:
            Widgets[DN_STATIC_INDEX].Value = 0;
            UpdateWidget(DN_STATIC_INDEX, Damage);
            break;
        case HX_DISPLAY_StaticTotal:
            UpdateWidget(DN_TOTAL_INDEX, Damage);
            break;
        case HX_DISPLAY_StaticDual:
            if (Widgets[DN_STATIC_INDEX].Value > 0)
            {
                if (Widgets[DN_TOTAL_INDEX].Value == 0)
                {
                    Widgets[DN_TOTAL_INDEX].Value = Widgets[DN_STATIC_INDEX].Value;
                    Widgets[DN_TOTAL_INDEX].DeltaY -= DN_DUAL_OFFSET;
                }
                UpdateWidget(DN_TOTAL_INDEX, Damage);
                Widgets[DN_STATIC_INDEX].Value = 0;
            }
            UpdateWidget(DN_STATIC_INDEX, Damage);
            break;
        case HX_DISPLAY_Float:
        case HX_DISPLAY_FloatDual:
            UpdateWidget(GetFloatWidgetIndex(), Damage);
            break;
    }
}

simulated function UpdateWidget(int i, int Damage)
{
    Widgets[i].Value += Damage;
    Widgets[i].Scale = GetScale(Widgets[i].Value);
    Widgets[i].Color = GetColor(Widgets[i].Value);
    Widgets[i].Duration = DN_NORMAL_DURATION;
}

simulated function int GetFloatWidgetIndex()
{
    local int i;

    for (i = DN_TOTAL_INDEX + 1; i < Widgets.Length; ++i)
    {
        if (Widgets[i].Value == 0)
        {
            break;
        }
    }
    if (i == Widgets.Length)
    {
        Widgets.Insert(Widgets.Length, 1);
        InitializeWidget(i);
    }
    return i;
}

simulated function float GetScale(int Damage)
{
    local int i;

    for (i = 1; i < ArrayCount(DamagePoints); ++i)
    {
        if (Damage < DamagePoints[i].Value)
        {
            return ToAbsoluteScale(FInterpolate(
                Damage, DamagePoints[i].Value, DamagePoints[i - 1].Scale, DamagePoints[i].Scale));
            break;
        }
    }
    return ToAbsoluteScale(DamagePoints[ArrayCount(DamagePoints) - 1].Scale);
}

simulated function Color GetColor(int Damage)
{
    local int i;

    for (i = 1; i < ArrayCount(DamagePoints); ++i)
    {
        if (Damage < DamagePoints[i].Value)
        {
            return InterpolateColor(
                Damage, DamagePoints[i].Value, DamagePoints[i - 1].Color, DamagePoints[i].Color);
        }
    }
    return DamagePoints[ArrayCount(DamagePoints) - 1].Color;
}

simulated function int GetFade(int DNIndex)
{
    if (Widgets[DNIndex].Duration <= 0.33)
    {
        return Clamp(int(3 * Widgets[DNIndex].Duration * 255), 0, 255);
    }
    return 255;
}

simulated function Color InterpolateColor(int Damage, float MaxValue, Color First, Color Second)
{
    local Color Result;
    local float Percentage;

    Percentage = FClamp(Damage / MaxValue, 0.0, 1.0);
    Result.R = First.R + Round(Percentage * (Second.R - First.R));
    Result.G = First.G + Round(Percentage * (Second.G - First.G));
    Result.B = First.B + Round(Percentage * (Second.B - First.B));
    Result.A = 255;
    return Result;
}

simulated function bool IsHitSoundChanged()
{
    return LoadedHitSound == None
        || !(string(LoadedHitSound) ~= HitSoundName
            || GetItemName(string(LoadedHitSound)) ~= HitSoundName);
}

simulated function bool IsFontChanged()
{
    return LoadedFont == None || !(string(LoadedFont) ~= DisplayFontName);
}

static function float FInterpolate(int Value, float MaxValue, float First, float Second)
{
    return First + FClamp(Value / MaxValue, 0.0, 1.0) * (Second - First);
}

static function float ToAbsoluteScale(float NormalizedScale)
{
    return FONT_SCALE_MIN + NormalizedScale * FONT_SCALE_SPECTRUM;
}

static function bool GetHitSoundNames(out array<string> Names)
{
    local int i;

    for (i = 0; i < default.BuiltInHitSounds.Length; ++i)
    {
        Names[Names.Length] = GetItemName(string(default.BuiltInHitSounds[i]));
    }
    for (i = 0; i < default.CustomHitSounds.Length; ++i)
    {
        Names[Names.Length] = default.CustomHitSounds[i];
    }
    return Names.Length > 0;
}

defaultproperties
{
    bHitSounds=true
    HitSoundName="HxHitSound1"
    HitSoundVolume=1.0
    PitchMode=HX_PITCH_High2Low
    bDamageNumbers=true
    DisplayMode=HX_DISPLAY_StaticDual
    DisplayFontName="UT2003Fonts.FontEurostile37";
    DisplayPosX=0.5
    DisplayPosY=0.45
    DamagePoints(0)=(Value=0,Pitch=0,Scale=0,Color=(R=255,G=255,B=255))
    DamagePoints(1)=(Value=30,Pitch=0.30,Scale=0.30,Color=(R=255,G=255,B=32))
    DamagePoints(2)=(Value=70,Pitch=0.55,Scale=0.55,Color=(R=255,G=119,B=32))
    DamagePoints(3)=(Value=120,Pitch=0.75,Scale=0.75,Color=(R=255,G=32,B=32))
    DamagePoints(4)=(Value=180,Pitch=1.00,Scale=1.00,Color=(R=143,G=32,B=245))
    FontNames(0)="UT2003Fonts.FontEurostile29"
    FontNames(1)="UT2003Fonts.FontEurostile37"
    FontNames(2)="UT2003Fonts.FontNeuzeit29"
    FontNames(3)="UT2003Fonts.FontNeuzeit37"
    FontNames(4)="2K4Fonts.Verdana28"
    FontNames(5)="2K4Fonts.Verdana30"
    FontNames(6)="2K4Fonts.Verdana32"
    FontNames(7)="2K4Fonts.Verdana34"
    BuiltInHitSounds(0)=Sound'HxHitSound1'
    BuiltInHitSounds(1)=Sound'HxHitSound2'
    BuiltInHitSounds(2)=Sound'HxHitSound3'
    BuiltInHitSounds(3)=Sound'HxHitSound4'
    BuiltInHitSounds(4)=Sound'HxHitSound5'
}
