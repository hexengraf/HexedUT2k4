class HxHitEffects extends HudOverlay
    config(User)
    notplaceable;

#exec AUDIO IMPORT FILE=Sounds\HitSound1.wav
#exec AUDIO IMPORT FILE=Sounds\HitSound2.wav
#exec AUDIO IMPORT FILE=Sounds\HitSound3.wav
#exec AUDIO IMPORT FILE=Sounds\HitSound4.wav
#exec AUDIO IMPORT FILE=Sounds\HitSound5.wav

enum EHxPitch
{
    HX_PITCH_Disabled,
    HX_PITCH_Low2High,
    HX_PITCH_High2Low,
};

enum EHxDNStyle
{
    HX_DN_Cumulative,
    HX_DN_Individual,
};

struct HxDamageNumber
{
    var int Damage;
    var float Scale;
    var Color Color;
    var float PosX;
    var float PosY;
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
const ALAUDIO_PITCH_SPECTRUM = 1.5;
const ALAUDIO_PITCH_NEUTRAL = 1.0;
const DAMAGE_POINT_COUNT = 5;
const DAMAGE_POINT_TRAVEL = 0.15;
const DAMAGE_POINT_SCALE_MIN = 0.65;
const DAMAGE_POINT_SCALE_SPECTRUM = 0.35;

var config bool bHitSounds;
var config int SelectedHitSound;
var config float HitSoundVolume;
var config EHxPitch PitchType;
var config bool bDamageNumbers;
var config EHxDNStyle DamageNumberStyle;
var config float PosX;
var config float PosY;
var config HxDamagePoint DamagePoints[DAMAGE_POINT_COUNT];

var bool bAllowHitSounds;
var bool bAllowDamageNumbers;
var PlayerController PC;
var array<Sound> HitSounds;
var array<HxDamageNumber> DamageNumbers;
var localized string EHxPitchNames[3];
var localized string EHxDNStyleNames[2];
var localized string DamagePointNames[DAMAGE_POINT_COUNT];

simulated event PreBeginPlay()
{
    local int Index;

    super.PreBeginPlay();
    if (SelectedHitSound >= HitSounds.Length || SelectedHitSound < 0)
    {
        SelectedHitSound = 0;
    }
    for (Index = 0; Index < DAMAGE_POINT_COUNT; ++Index)
    {
        DamagePoints[Index].Color.A = 255;
        DamagePoints[Index].Pitch = FClamp(DamagePoints[Index].Pitch, 0.0, 1.0);
        DamagePoints[Index].Scale = FClamp(DamagePoints[Index].Scale, 0.0, 1.0);
    }
    DamagePoints[0].Value = 0;
    SaveConfig();
}

simulated Event Tick(float DeltaTime)
{
    local int Index;

    super.Tick(DeltaTime);
    for (Index = 0; Index < DamageNumbers.Length; ++Index)
    {
        DamageNumbers[Index].Duration -= DeltaTime;
        DamageNumbers[Index].Color.A = Clamp(int(DamageNumbers[Index].Duration * 255), 0, 255);
        if (DamageNumbers[Index].Duration <= 0)
        {
            DamageNumbers[Index].Damage = 0;
        }
        else if (DamageNumberStyle == HX_DN_Individual)
        {
            DamageNumbers[Index].PosY -= DeltaTime * DAMAGE_POINT_TRAVEL;
        }
    }
}

simulated function Render(Canvas C)
{
    local string DamageString;
    local float XL;
    local float YL;
    local int Index;

    for (Index = 0; Index < DamageNumbers.Length; ++Index)
    {
        if (DamageNumbers[Index].Damage > 0)
        {
            DamageString = string(DamageNumbers[Index].Damage);
            C.DrawColor = DamageNumbers[Index].Color;
            C.Font = class'HxHitEffectsFont'.static.GetFont(C.ClipX);
            C.FontScaleX = DamageNumbers[Index].Scale;
            C.FontScaleY = DamageNumbers[Index].Scale;
            C.StrLen(DamageString, XL, YL);
            C.SetPos(
                (C.ClipX - XL) * DamageNumbers[Index].PosX,
                (C.ClipY - YL) * DamageNumbers[Index].PosY);
            C.DrawTextClipped(DamageString);
        }
    }
}

simulated function Update(int Damage)
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
        PC.ViewTarget.PlaySound(HitSounds[SelectedHitSound],,HitSoundVolume,,,GetPitch(Damage));
    }
}

simulated function UpdateDamageNumbers(int Damage)
{
    local int Index;

    Index = GetDamageNumberIndex();

    if (DamageNumbers[Index].Damage == 0)
    {
        DamageNumbers[Index].PosX = PosX;
        DamageNumbers[Index].PosY = PosY;
    }
    if (DamageNumberStyle == HX_DN_Cumulative)
    {
        DamageNumbers[Index].Damage += Damage;
    }
    else
    {
        DamageNumbers[Index].Damage = Damage;
    }
    DamageNumbers[Index].Scale = GetScale(DamageNumbers[Index].Damage);
    DamageNumbers[Index].Color = GetColor(DamageNumbers[Index].Damage);
    DamageNumbers[Index].Duration = 1;
}

simulated function float GetPitch(int Damage)
{
    local int i;
    local float NormalizedPitch;

    if (PitchType == HX_PITCH_Disabled)
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
    if (PitchType == HX_PITCH_Low2High)
    {
        return ALAUDIO_PITCH_MIN + NormalizedPitch * ALAUDIO_PITCH_SPECTRUM;
    }
    return ALAUDIO_PITCH_MAX - NormalizedPitch * ALAUDIO_PITCH_SPECTRUM;
}

simulated function int GetDamageNumberIndex()
{
    local int Index;

    Index = 0;
    if (DamageNumbers.Length == 0)
    {
        DamageNumbers.Insert(DamageNumbers.Length, 1);
        return Index;
    }
    if (DamageNumberStyle == HX_DN_Individual)
    {
        for (Index = 0; Index < DamageNumbers.Length; ++Index)
        {
            if (DamageNumbers[Index].Color.A == 0)
            {
                break;
            }
        }
        if (Index == DamageNumbers.Length)
        {
            DamageNumbers.Insert(DamageNumbers.Length, 1);
        }
    }
    return Index;
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

simulated function Color InterpolateColor(int Damage, float MaxValue, Color First, Color Second)
{
    local Color Result;
    local float Percentage;

    Percentage = FClamp(Damage / MaxValue, 0.0, 1.0);
    Result.R = First.R + Round(Percentage * (Second.R - First.R));
    Result.G = First.G + Round(Percentage * (Second.G - First.G));
    Result.B = First.B + Round(Percentage * (Second.B - First.B));
    Result.A = First.A + Round(Percentage * (Second.A - First.A));
    return Result;
}

static simulated function float FInterpolate(int Value, float MaxValue, float First, float Second)
{
    return First + FClamp(Value / MaxValue, 0.0, 1.0) * (Second - First);
}

static simulated function float ToAbsoluteScale(float NormalizedScale)
{
    return DAMAGE_POINT_SCALE_MIN + NormalizedScale * DAMAGE_POINT_SCALE_SPECTRUM;
}

static simulated function AddHitSound(Sound HitSound)
{
    default.HitSounds[default.HitSounds.Length] = HitSound;
}

defaultproperties
{
    bHitSounds=true
    SelectedHitSound=0
    HitSoundVolume=1.0
    PitchType=HX_PITCH_Low2High
    bDamageNumbers=true
    DamageNumberStyle=HX_DN_Individual
    PosX=0.5
    PosY=0.45
    DamagePoints(0)=(Value=0,Pitch=0,Scale=0,Color=(R=255,G=255,B=255,A=255))
    DamagePoints(1)=(Value=30,Pitch=0.30,Scale=0.30,Color=(R=255,G=255,B=32,A=255))
    DamagePoints(2)=(Value=70,Pitch=0.55,Scale=0.55,Color=(R=255,G=119,B=32,A=255))
    DamagePoints(3)=(Value=120,Pitch=0.75,Scale=0.75,Color=(R=255,G=32,B=32,A=255))
    DamagePoints(4)=(Value=180,Pitch=1.00,Scale=1.00,Color=(R=143,G=32,B=245,A=255))
    HitSounds(0)=Sound'HitSound1'
    HitSounds(1)=Sound'HitSound2'
    HitSounds(2)=Sound'HitSound3'
    HitSounds(3)=Sound'HitSound4'
    HitSounds(4)=Sound'HitSound5'
    EHxPitchNames(0)="disabled"
    EHxPitchNames(1)="low to high"
    EHxPitchNames(2)="high to low"
    EHxDNStyleNames(0)="Cumulative"
    EHxDNStyleNames(1)="Individual"
    DamagePointNames(0)="zero damage"
    DamagePointNames(1)="low damage"
    DamagePointNames(2)="moderate damage"
    DamagePointNames(3)="high damage"
    DamagePointNames(4)="extreme damage"
}
