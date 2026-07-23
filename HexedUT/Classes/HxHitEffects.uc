class HxHitEffects extends HudOverlay;

#exec AUDIO IMPORT FILE=Sounds\HxHitSound0.wav
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

const AUTO_FONT = "AUTOSELECT";

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

var bool bHitSounds;
var string HitSoundName;
var float HitSoundVolume;
var EHxPitchMode PitchMode;
var bool bDamageNumbers;
var EHxDisplayMode DisplayMode;
var string DisplayFontName;
var float DisplayPosX;
var float DisplayPosY;
var HxDamagePoint ZeroDamage;
var HxDamagePoint LowDamage;
var HxDamagePoint MediumDamage;
var HxDamagePoint HighDamage;
var HxDamagePoint ExtremeDamage;
var array<string> FontNames;
var array<string> CustomHitSounds;

var private const Sound BuiltInHitSounds[6];
var private PlayerController PC;
var private HxDamagePoint DamagePoints[5];
var private array<HxDisplayWidget> Widgets;
var private Sound LoadedHitSound;
var private Font LoadedFont;
var private float ScreenWidth;
var private float ScreenHeight;
var private float DualOffset;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    if (HUD(Owner) != None)
    {
        PC = HUD(Owner).PlayerOwner;
    }
    InitializeWidgets();
    LoadHitSound();
    LoadDamagePoints();
}

simulated function LoadHitSound()
{
    local int i;

    for (i = 0; i < ArrayCount(BuiltInHitSounds); ++i)
    {
        if (HitSoundName ~= GetItemName(string(BuiltInHitSounds[i])))
        {
            LoadedHitSound = BuiltInHitSounds[i];
            return;
        }
    }
    LoadedHitSound = Sound(DynamicLoadObject(HitSoundName, class'Sound'));
}

simulated function LoadFont(Canvas C)
{
    local float Width;

    if (DisplayFontName == AUTO_FONT)
    {
        LoadedFont = class'HxGUIFontMidGame'.static.GetBigFont(C);
    }
    else
    {
        LoadedFont = class'HXGUIFontMidGame'.static.DynamicLoadFont(DisplayFontName, true);
    }
    C.TextSize("0", Width, DualOffset);
    DualOffset = DualOffset / C.ClipY;
}

simulated function LoadDamagePoints()
{
    DamagePoints[0] = ZeroDamage;
    DamagePoints[1] = LowDamage;
    DamagePoints[2] = MediumDamage;
    DamagePoints[3] = HighDamage;
    DamagePoints[4] = ExtremeDamage;
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

    if (C.ClipX != ScreenWidth || C.ClipY != ScreenHeight)
    {
        LoadFont(C);
        ScreenWidth = C.ClipX;
        ScreenHeight = C.ClipY;
    }
    SavedFontScaleX = C.FontScaleX;
    SavedFontScaleY = C.FontScaleY;
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
    C.FontScaleX = Widgets[i].Scale;
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
    C.FontScaleX = ToAbsoluteScale(DamagePoints[i].Scale);
    C.FontScaleY = C.FontScaleX;
    C.StrLen(DamagePoints[i].Value, XL, YL);
    C.SetPos((C.ClipX - XL) * 0.5, (C.ClipY - YL) * 0.5);
    C.DrawText(DamagePoints[i].Value);
}

simulated function DisplayDamageNumber(int Damage)
{
    if (bDamageNumbers)
    {
        UpdateWidgets(Damage);
    }
}

simulated function PlayHitSound(int Damage)
{
    if (bHitSounds && PC.ViewTarget != None)
    {
        PC.ViewTarget.PlaySound(LoadedHitSound,,HitSoundVolume,,,GetPitch(Damage));
    }
}

simulated function PlayHitSoundPreview(int Index)
{
    PlayHitSound(DamagePoints[Index].Value);
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
            Pitch = Lerp(
                Damage / DamagePoints[i].Value, DamagePoints[i - 1].Pitch, DamagePoints[i].Pitch);
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
                    Widgets[DN_TOTAL_INDEX].DeltaY -= DualOffset;
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
            return ToAbsoluteScale(Lerp(
                Damage / DamagePoints[i].Value, DamagePoints[i - 1].Scale, DamagePoints[i].Scale));
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
            return class'HxTypes'.static.BlendColor(
                float(Damage) / DamagePoints[i].Value,
                DamagePoints[i - 1].Color,
                DamagePoints[i].Color);
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

simulated function SetProperty(string Name, string Value)
{
    SetPropertyText(Name, Value);
    switch (Name)
    {
        case "HitSoundName":
            LoadHitSound();
            break;
        case "DisplayFontName":
            ScreenWidth = 0;
            ScreenHeight = 0;
            break;
        case "ZeroDamage":
            DamagePoints[0] = ZeroDamage;
            break;
        case "LowDamage":
            DamagePoints[1] = LowDamage;
            break;
        case "MediumDamage":
            DamagePoints[2] = MediumDamage;
            break;
        case "HighDamage":
            DamagePoints[3] = HighDamage;
            break;
        case "ExtremeDamage":
            DamagePoints[4] = ExtremeDamage;
            break;
    }
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

static function float ToAbsoluteScale(float NormalizedScale)
{
    return FONT_SCALE_MIN + NormalizedScale * FONT_SCALE_SPECTRUM;
}

static function bool GetHitSoundNames(out array<string> Names)
{
    local int i;

    for (i = 0; i < ArrayCount(default.BuiltInHitSounds); ++i)
    {
        Names[Names.Length] = GetItemName(string(default.BuiltInHitSounds[i]));
    }
    for (i = 0; i < default.CustomHitSounds.Length; ++i)
    {
        Names[Names.Length] = default.CustomHitSounds[i];
    }
    return Names.Length > 0;
}

static function bool IsBuiltInHitSound(string Name)
{
    local int i;

    for (i = 0; i < ArrayCount(default.BuiltInHitSounds); ++i)
    {
        if (Name ~= GetItemName(string(default.BuiltInHitSounds[i])))
        {
            return true;
        }
    }
    return false;
}

defaultproperties
{
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
    BuiltInHitSounds(0)=Sound'HxHitSound0'
    BuiltInHitSounds(1)=Sound'HxHitSound1'
    BuiltInHitSounds(2)=Sound'HxHitSound2'
    BuiltInHitSounds(3)=Sound'HxHitSound3'
    BuiltInHitSounds(4)=Sound'HxHitSound4'
    BuiltInHitSounds(5)=Sound'HxHitSound5'
}
