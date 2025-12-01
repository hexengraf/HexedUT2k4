class HxHitEffects extends HudOverlay
    config(User)
    notplaceable;

enum EHxPitchMode
{
    HX_PITCH_Disabled,
    HX_PITCH_Low2High,
    HX_PITCH_High2Low,
};

enum EHxDMode
{
    HX_DMODE_Static,
    HX_DMODE_StaticTotal,
    HX_DMODE_StaticDual,
    HX_DMODE_Float,
    HX_DMODE_FloatDual,
};

struct HxDamageNumber
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

const DAMAGE_POINT_COUNT = 5;

var config bool bHitSounds;
var config int SelectedHitSound;
var config float HitSoundVolume;
var config EHxPitchMode PitchMode;

var config bool bDamageNumbers;
var config EHxDMode DMode;
var config Font DFont;
var config float PosX;
var config float PosY;
var config HxDamagePoint DamagePoints[DAMAGE_POINT_COUNT];

var PlayerController PC;
var array<HxDamageNumber> DamageNumbers;
var float GlobalScale;

simulated event PreBeginPlay()
{
    super.PreBeginPlay();
    ValidateConfig();
    InitializeDamageNumbers();
}

simulated function ValidateConfig()
{
    local int i;

    for (i = 0; i < DAMAGE_POINT_COUNT; ++i)
    {
        DamagePoints[i].Color.A = 255;
        DamagePoints[i].Pitch = FClamp(DamagePoints[i].Pitch, 0.0, 1.0);
        DamagePoints[i].Scale = FClamp(DamagePoints[i].Scale, 0.0, 1.0);
    }
    SelectedHitSound = Clamp(SelectedHitSound, 0, class'HxSounds'.default.HitSounds.Length - 1);
    DamagePoints[0].Value = 0;
    SaveConfig();
}

simulated function InitializeDamageNumbers()
{
    local int i;

    DamageNumbers.Length = DN_TOTAL_INDEX + 1;
    for (i = 0; i < DamageNumbers.Length; ++i)
    {
        InitializeDamageNumber(i);
    }
}

simulated function InitializeDamageNumber(int i)
{
    DamageNumbers[i].Value = 0;
    DamageNumbers[i].DeltaY = 0;
    DamageNumbers[i].Duration = DN_NORMAL_DURATION;
}

simulated Event Tick(float DeltaTime)
{
    local int i;
    local bool bKeepSize;

    bKeepSize = DamageNumbers.Length == DN_TOTAL_INDEX + 1;

    for (i = 0; i < DamageNumbers.Length; ++i)
    {
        if (DamageNumbers[i].Value > 0)
        {
            DamageNumbers[i].Duration -= DeltaTime;
            if (i > DN_TOTAL_INDEX && TickFloatMode(i, DeltaTime))
            {
                bKeepSize = true;
            }
            if (DamageNumbers[i].Duration <= 0)
            {
                InitializeDamageNumber(i);
            }
            else
            {
                DamageNumbers[i].Color.A = GetFade(i);
            }
        }
    }
    if (!bKeepSize)
    {
        DamageNumbers.Length = DN_TOTAL_INDEX + 1;
    }
}

simulated function bool TickFloatMode(int i, float DeltaTime)
{
    if (DamageNumbers[i].Duration > 0)
    {
        DamageNumbers[i].DeltaY -= DeltaTime * DN_TRAVEL;
        return true;
    }
    if (DMode == HX_DMODE_FloatDual)
    {
        if (DamageNumbers[DN_TOTAL_INDEX].Value == 0)
        {
            DamageNumbers[DN_TOTAL_INDEX].DeltaY = -DN_TRAVEL - DeltaTime * DN_TRAVEL;
        }
        UpdateDamageNumber(DN_TOTAL_INDEX, DamageNumbers[i].Value);
        DamageNumbers[DN_TOTAL_INDEX].Duration = DN_EXTENDED_DURATION;
    }
    return false;
}

simulated function Render(Canvas C)
{
    local int i;
    local float OldFontScaleX;
    local float OldFontScaleY;

    OldFontScaleX = C.FontScaleX;
    OldFontScaleY = C.FontScaleY;
    GlobalScale = C.ClipX / REFERENCE_SCREEN_X;
    for (i = 0; i < DamageNumbers.Length; ++i)
    {
        if (DamageNumbers[i].Value > 0)
        {
            DrawDamageNumber(C, i);
        }
    }
    C.FontScaleX = OldFontScaleX;
    C.FontScaleY = OldFontScaleY;
}

simulated function DrawDamageNumber(Canvas C, int i)
{
    local float XL;
    local float YL;
    local float FinalScale;

    FinalScale = GlobalScale * DamageNumbers[i].Scale;
    C.DrawColor = DamageNumbers[i].Color;
    C.Font = DFont;
    C.FontScaleX = FinalScale;
    C.FontScaleY = FinalScale;
    C.StrLen(DamageNumbers[i].Value, XL, YL);
    C.SetPos((C.ClipX - XL) * PosX, (C.ClipY - YL) * (PosY + DamageNumbers[i].DeltaY));
    C.DrawText(DamageNumbers[i].Value);
}

simulated function DrawDamageNumberPreview(Canvas C, int i)
{
    local float XL;
    local float YL;
    local float OldFontScaleX;
    local float OldFontScaleY;
    local float FinalScale;

    OldFontScaleX = C.FontScaleX;
    OldFontScaleY = C.FontScaleY;
    FinalScale = GlobalScale * ToAbsoluteScale(DamagePoints[i].Scale);
    C.DrawColor = DamagePoints[i].Color;
    C.Font = DFont;
    C.FontScaleX = FinalScale;
    C.FontScaleY = FinalScale;
    C.StrLen(DamagePoints[i].Value, XL, YL);
    C.SetPos((C.ClipX - XL) * 0.5, (C.ClipY - YL) * 0.5);
    C.DrawText(DamagePoints[i].Value);
    C.FontScaleX = OldFontScaleX;
    C.FontScaleY = OldFontScaleY;
}

simulated function Update(int Damage, bool bAllowHitSounds, bool bAllowDamageNumbers)
{
    if (bAllowHitSounds && bHitSounds)
    {
        PlayHitSound(Damage);
    }
    if (bAllowDamageNumbers && bDamageNumbers)
    {
        UpdateDamageNumbers(Damage);
    }
}

simulated function PlayHitSound(int Damage)
{
    if (PC.ViewTarget != None)
    {
        PC.ViewTarget.PlaySound(
            class'HxSounds'.default.HitSounds[SelectedHitSound],,HitSoundVolume,,,GetPitch(Damage));
    }
}

simulated function float GetPitch(int Damage)
{
    local int i;
    local float NormalizedPitch;

    if (PitchMode == HX_PITCH_Disabled)
    {
        return ALAUDIO_PITCH_NEUTRAL;
    }
    for (i = 1; i < DAMAGE_POINT_COUNT; ++i)
    {
        if (Damage < DamagePoints[i].Value)
        {
            NormalizedPitch = FInterpolate(
                Damage, DamagePoints[i].Value, DamagePoints[i - 1].Pitch, DamagePoints[i].Pitch);
            break;
        }
    }
    if (i == DAMAGE_POINT_COUNT)
    {
        NormalizedPitch = DamagePoints[DAMAGE_POINT_COUNT - 1].Pitch;
    }
    if (PitchMode == HX_PITCH_Low2High)
    {
        return ALAUDIO_PITCH_MIN + NormalizedPitch * ALAUDIO_PITCH_SPECTRUM;
    }
    return ALAUDIO_PITCH_MAX - NormalizedPitch * ALAUDIO_PITCH_SPECTRUM;
}

simulated function UpdateDamageNumbers(int Damage)
{
    switch (DMode)
    {
        case HX_DMODE_Static:
            DamageNumbers[DN_STATIC_INDEX].Value = 0;
            UpdateDamageNumber(DN_STATIC_INDEX, Damage);
            break;
        case HX_DMODE_StaticTotal:
            UpdateDamageNumber(DN_TOTAL_INDEX, Damage);
            break;
        case HX_DMODE_StaticDual:
            if (DamageNumbers[DN_STATIC_INDEX].Value > 0)
            {
                if (DamageNumbers[DN_TOTAL_INDEX].Value == 0)
                {
                    DamageNumbers[DN_TOTAL_INDEX].Value = DamageNumbers[DN_STATIC_INDEX].Value;
                    DamageNumbers[DN_TOTAL_INDEX].DeltaY -= DN_DUAL_OFFSET;
                }
                UpdateDamageNumber(DN_TOTAL_INDEX, Damage);
                DamageNumbers[DN_STATIC_INDEX].Value = 0;
            }
            UpdateDamageNumber(DN_STATIC_INDEX, Damage);
            break;
        case HX_DMODE_Float:
        case HX_DMODE_FloatDual:
            UpdateDamageNumber(GetFloatModeIndex(), Damage);
            break;
    }
}

simulated function UpdateDamageNumber(int i, int Damage)
{
    DamageNumbers[i].Value += Damage;
    DamageNumbers[i].Scale = GetScale(DamageNumbers[i].Value);
    DamageNumbers[i].Color = GetColor(DamageNumbers[i].Value);
    DamageNumbers[i].Duration = DN_NORMAL_DURATION;
}

simulated function int GetFloatModeIndex()
{
    local int i;

    for (i = DN_TOTAL_INDEX + 1; i < DamageNumbers.Length; ++i)
    {
        if (DamageNumbers[i].Value == 0)
        {
            break;
        }
    }
    if (i == DamageNumbers.Length)
    {
        DamageNumbers.Insert(DamageNumbers.Length, 1);
        InitializeDamageNumber(i);
    }
    return i;
}

simulated function float GetScale(int Damage)
{
    local int i;

    for (i = 1; i < DAMAGE_POINT_COUNT; ++i)
    {
        if (Damage < DamagePoints[i].Value)
        {
            return ToAbsoluteScale(FInterpolate(
                Damage, DamagePoints[i].Value, DamagePoints[i - 1].Scale, DamagePoints[i].Scale));
            break;
        }
    }
    return ToAbsoluteScale(DamagePoints[DAMAGE_POINT_COUNT - 1].Scale);
}

simulated function Color GetColor(int Damage)
{
    local int i;

    for (i = 1; i < DAMAGE_POINT_COUNT; ++i)
    {
        if (Damage < DamagePoints[i].Value)
        {
            return InterpolateColor(
                Damage, DamagePoints[i].Value, DamagePoints[i - 1].Color, DamagePoints[i].Color);
        }
    }
    return DamagePoints[DAMAGE_POINT_COUNT - 1].Color;
}

simulated function int GetFade(int DNIndex)
{
    if (DamageNumbers[DNIndex].Duration <= 0.33)
    {
        return Clamp(int(3 * DamageNumbers[DNIndex].Duration * 255), 0, 255);
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

static simulated function float FInterpolate(int Value, float MaxValue, float First, float Second)
{
    return First + FClamp(Value / MaxValue, 0.0, 1.0) * (Second - First);
}

static simulated function float ToAbsoluteScale(float NormalizedScale)
{
    return FONT_SCALE_MIN + NormalizedScale * FONT_SCALE_SPECTRUM;
}

defaultproperties
{
    bHitSounds=true
    SelectedHitSound=0
    HitSoundVolume=1.0
    PitchMode=HX_PITCH_High2Low
    bDamageNumbers=true
    DMode=HX_DMODE_StaticDual
    DFont=Font'UT2003Fonts.FontEurostile37';
    PosX=0.5
    PosY=0.45
    DamagePoints(0)=(Value=0,Pitch=0,Scale=0,Color=(R=255,G=255,B=255))
    DamagePoints(1)=(Value=30,Pitch=0.30,Scale=0.30,Color=(R=255,G=255,B=32))
    DamagePoints(2)=(Value=70,Pitch=0.55,Scale=0.55,Color=(R=255,G=119,B=32))
    DamagePoints(3)=(Value=120,Pitch=0.75,Scale=0.75,Color=(R=255,G=32,B=32))
    DamagePoints(4)=(Value=180,Pitch=1.00,Scale=1.00,Color=(R=143,G=32,B=245))
}
