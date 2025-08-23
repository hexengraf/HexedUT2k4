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
    HX_DN_Static,
    HX_DN_Rising,
};

struct HxDamageNumber
{
    var int Damage;
    var int FontModifier;
    var Color Color;
    var float PosX;
    var float PosY;
    var float Offset;
    var float Duration;
};

struct HxDamagePoint
{
    var int Value;
    var float pitch;
    var int FontModifier;
    var Color Color;
};

const ALAUDIO_PITCH_MIN = 0.5;
const ALAUDIO_PITCH_MAX = 2.0;
const ALAUDIO_PITCH_SPECTRUM = 1.5;
const ALAUDIO_PITCH_NEUTRAL = 1.0;
const FLOAT_TIME = 0.2;
const DAMAGE_POINT_COUNT = 4;

var config bool bHitSounds;
var config int SelectedHitSound;
var config float HitSoundVolume;
var config EHxPitch PitchType;
var config float PitchFactor;
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
        DamagePoints[Index].Pitch = FClamp(DamagePoints[Index].Pitch, 0.0, 1.0);
        DamagePoints[Index].FontModifier = Clamp(DamagePoints[Index].FontModifier, -8, 8);
    }
    SaveConfig();
}

simulated Event Tick(float DeltaTime)
{
    local int Index;

    super.Tick(DeltaTime);
    for (Index = 0; Index < DamageNumbers.Length; ++Index)
    {
        DamageNumbers[Index].Duration -= DeltaTime;
        if (DamageNumbers[Index].Duration <= 0)
        {
            DamageNumbers[Index].Damage = 0;
        }
        else if (DamageNumberStyle == HX_DN_Rising)
        {
            DamageNumbers[Index].PosY -= (DeltaTime / FLOAT_TIME) * DamageNumbers[Index].Offset;
        }
    }
}

simulated function Render(Canvas C)
{
    local int Index;
    local string DamageString;
    local float XL;
    local float YL;

    for (Index = 0; Index < DamageNumbers.Length; ++Index)
    {
        if (DamageNumbers[Index].Damage > 0)
        {
            DamageString = string(DamageNumbers[Index].Damage);
            C.DrawColor = DamageNumbers[Index].Color;
            C.DrawColor.A = Clamp(int(DamageNumbers[Index].Duration * 255), 0, 255);
            C.Font = GetFont(C, DamageNumbers[Index].FontModifier);
            C.StrLen(DamageString, XL, YL);
            C.SetPos(
                (C.ClipX - XL) * DamageNumbers[Index].PosX,
                (C.ClipY - YL) * DamageNumbers[Index].PosY);
            C.DrawTextClipped(DamageString);
            DamageNumbers[Index].Offset = YL / C.ClipY;
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
        DamageNumbers[Index].Offset = 0.0005;
    }
    if (DamageNumberStyle == HX_DN_Static)
    {
        DamageNumbers[Index].Damage += Damage;
    }
    else
    {
        DamageNumbers[Index].Damage = Damage;
    }
    DamageNumbers[Index].FontModifier = GetFontModifier(DamageNumbers[Index].Damage);
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

simulated function int GetDamageNumberIndex()
{
    local int Index;

    Index = 0;
    if (DamageNumbers.Length == 0)
    {
        DamageNumbers.Insert(DamageNumbers.Length, 1);
        return Index;
    }
    if (DamageNumberStyle == HX_DN_Rising)
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

simulated function Font GetFont(Canvas C, int FontSize)
{
    FontSize += Min(C.ClipX / 256, 8);
	return HUD(Owner).LoadFont(Clamp(8 - FontSize, 0, 8));
}

simulated function int GetFontModifier(int Damage)
{
    local int i;

    for (i = DAMAGE_POINT_COUNT - 1; i >= 0; --i)
    {
        if (Damage >= DamagePoints[i].Value)
        {
            return DamagePoints[i].FontModifier;
        }
    }
    return DamagePoints[0].FontModifier;
}

simulated function Color GetColor(int Damage)
{
    local int i;

    if (Damage <= DamagePoints[0].Value)
    {
        return InterpolateColor(
            Damage, DamagePoints[0].Value, class'HUD'.default.WhiteColor, DamagePoints[0].Color);
    }
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

static simulated function float InterpolatePitch(int Value,
                                                 float MaxValue,
                                                 float First,
                                                 float Second)
{
    return First + FClamp(Value / MaxValue, 0.0, 1.0) * (Second - First);
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
    DamageNumberStyle=HX_DN_Rising
    PosX=0.5
    PosY=0.45
    DamagePoints(0)=(Value=30,Pitch=0.30,FontModifier=-2,Color=(R=255,G=255,B=32,A=255))
    DamagePoints(1)=(Value=70,Pitch=0.55,FontModifier=-1,Color=(R=255,G=119,B=32,A=255))
    DamagePoints(2)=(Value=120,Pitch=0.75,FontModifier=-1,Color=(R=255,G=32,B=32,A=255))
    DamagePoints(3)=(Value=180,Pitch=1.00,FontModifier=0,Color=(R=143,G=32,B=245,A=255))
    HitSounds(0)=Sound'HitSound1'
    HitSounds(1)=Sound'HitSound2'
    HitSounds(2)=Sound'HitSound3'
    HitSounds(3)=Sound'HitSound4'
    HitSounds(4)=Sound'HitSound5'
    EHxPitchNames(0)="disabled"
    EHxPitchNames(1)="low to high"
    EHxPitchNames(2)="high to low"
    EHxDNStyleNames(0)="static"
    EHxDNStyleNames(1)="rising"
    DamagePointNames(0)="low damage"
    DamagePointNames(1)="moderate damage"
    DamagePointNames(2)="high damage"
    DamagePointNames(3)="extreme damage"
}
