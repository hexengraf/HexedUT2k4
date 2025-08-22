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

struct DamagePoint
{
    var int Value;
    var float pitch;
    var Color Color;
};

const ALAUDIO_PITCH_MIN = 0.5;
const ALAUDIO_PITCH_MAX = 2.0;
const ALAUDIO_PITCH_SPECTRUM = 1.5;
const ALAUDIO_PITCH_NEUTRAL = 1.0;
const DAMAGE_POINT_COUNT = 4;

var config bool bHitSounds;
var config int SelectedHitSound;
var config float HitSoundVolume;
var config EHxPitch PitchType;
var config float PitchFactor;

var config bool bDamageNumbers;
var config int FontSizeModifier;
var config float PosX;
var config float PosY;

var config DamagePoint DamagePoints[DAMAGE_POINT_COUNT];

var bool bAllowHitSounds;
var bool bAllowDamageNumbers;
var PlayerController PC;

var array<Sound> HitSounds;
var float HitSoundTimestamp;
var int DrawDamage;
var float DrawTimestamp;
var Color DrawColor;

var localized string EHxPitchNames[3];
var localized string DamagePointNames[DAMAGE_POINT_COUNT];

simulated event PreBeginPlay()
{
    local int i;

    super.PreBeginPlay();

    if (SelectedHitSound >= HitSounds.Length || SelectedHitSound < 0)
    {
        SelectedHitSound = 0;
    }
    for (i = 0; i < DAMAGE_POINT_COUNT; ++i)
    {
        DamagePoints[i].Pitch = FClamp(DamagePoints[i].Pitch, 0.0, 1.0);
    }
    SaveConfig();
}

simulated function Render(Canvas C)
{
    local float XL, YL;
    local string DamageString;

    if (DrawDamage > 0 && Level.TimeSeconds <= DrawTimestamp)
    {
        C.Font = GetFont(C, FontSizeModifier);
        C.DrawColor = DrawColor;
        C.DrawColor.A = GetFade();
        DamageString = string(DrawDamage);
        C.StrLen(DamageString, XL, YL);
        C.SetPos((C.ClipX - XL) * PosX, (C.ClipY - YL) * PosY);
        C.DrawTextClipped(DamageString);
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
    if (HitSoundTimestamp > Level.TimeSeconds || PC.ViewTarget == None)
    {
        return;
    }
    HitSoundTimestamp = Level.TimeSeconds;
    PC.ViewTarget.PlaySound(HitSounds[SelectedHitSound],,HitSoundVolume,,,GetPitch(Damage));
}

simulated function UpdateDamageNumbers(int Damage)
{
    if (Level.TimeSeconds - DrawTimestamp > 0)
    {
        DrawDamage = 0;
    }
    DrawDamage += Damage;
    DrawColor = GetColor();
    DrawTimestamp = Level.TimeSeconds + 1;
}

simulated function Font GetFont(Canvas C, int FontSize)
{
    FontSize += Min(C.ClipX / 256, 8);
	return HUD(Owner).LoadFont(Clamp(8-FontSize, 0, 8));
}

simulated function float GetPitch(int Damage)
{
    local int i;
    local float NormalizedPitch;

    if (PitchType == HX_PITCH_Disabled)
    {
        return ALAUDIO_PITCH_NEUTRAL;
    }
    if (Damage <= DamagePoints[0].Value)
    {
        NormalizedPitch = InterpolatePitch(Damage, DamagePoints[0].Value, 0, DamagePoints[0].Pitch);
    }
    else
    {
        for (i = 1; i < DAMAGE_POINT_COUNT; ++i)
        {
            if (Damage < DamagePoints[i].Value)
            {
                NormalizedPitch = InterpolatePitch(
                    Damage,
                    DamagePoints[i].Value,
                    DamagePoints[i - 1].Pitch,
                    DamagePoints[i].Pitch);
                break;
            }
        }
        if (i == DAMAGE_POINT_COUNT)
        {
            NormalizedPitch = DamagePoints[DAMAGE_POINT_COUNT - 1].Pitch;
        }
    }
    if (PitchType == HX_PITCH_Low2High)
    {
        return ALAUDIO_PITCH_MIN + NormalizedPitch * ALAUDIO_PITCH_SPECTRUM;
    }
    return ALAUDIO_PITCH_MAX - NormalizedPitch * ALAUDIO_PITCH_SPECTRUM;
}

simulated function Color GetColor()
{
    local int i;

    if (DrawDamage <= DamagePoints[0].Value)
    {
        return InterpolateColor(
            DamagePoints[0].Value, class'HUD'.default.WhiteColor, DamagePoints[0].Color);
    }
    for (i = 1; i < DAMAGE_POINT_COUNT; ++i)
    {
        if (DrawDamage < DamagePoints[i].Value)
        {
            return InterpolateColor(
                DamagePoints[i].Value, DamagePoints[i - 1].Color, DamagePoints[i].Color);
        }
    }
    return DamagePoints[DAMAGE_POINT_COUNT - 1].Color;
}

simulated function int GetFade()
{
    return Clamp(int(((DrawTimestamp + 1) - Level.TimeSeconds) * 255), 1, 255);
}

simulated function Color InterpolateColor(float MaxValue, Color First, Color Second)
{
    local Color Result;
    local float Percentage;

    Percentage = FClamp(DrawDamage / MaxValue, 0.0, 1.0);
    Result.R = First.R + Round(Percentage * (Second.R - First.R));
    Result.G = First.G + Round(Percentage * (Second.G - First.G));
    Result.B = First.B + Round(Percentage * (Second.B - First.B));
    Result.A = First.A + Round(Percentage * (Second.A - First.A));
    return Result;
}

static simulated function float InterpolatePitch(int Value,
                                                 float MaxValue,
                                                 float First,
                                                 float Second)
{
    return First + FClamp(Value / MaxValue, 0.0, 1.0) * (Second - First);
}

defaultproperties
{
    bHitSounds=true
    SelectedHitSound=0
    HitSoundVolume=1.0
    PitchType=HX_PITCH_Low2High
    bDamageNumbers=true
    FontSizeModifier=-1
    PosX=0.5
    PosY=0.45
    DamagePoints(0)=(Value=30,Pitch=0.30,Color=(R=255,G=255,B=32,A=255))
    DamagePoints(1)=(Value=70,Pitch=0.55,Color=(R=255,G=119,B=32,A=255))
    DamagePoints(2)=(Value=120,Pitch=0.75,Color=(R=255,G=32,B=32,A=255))
    DamagePoints(3)=(Value=180,Pitch=1.00,Color=(R=143,G=32,B=245,A=255))
    HitSounds(0)=Sound'HitSound1'
    HitSounds(1)=Sound'HitSound2'
    HitSounds(2)=Sound'HitSound3'
    HitSounds(3)=Sound'HitSound4'
    HitSounds(4)=Sound'HitSound5'
    EHxPitchNames(0)="disabled"
    EHxPitchNames(1)="low to high"
    EHxPitchNames(2)="high to low"
    DamagePointNames(0)="low damage"
    DamagePointNames(1)="moderate damage"
    DamagePointNames(2)="high damage"
    DamagePointNames(3)="extreme damage"
}
