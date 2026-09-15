class HxRandomGenerator extends Object;

var private int S0;
var private int S1;
var private int S2;
var private int S3;

event Created()
{
    Initialize();
}

final function Initialize()
{
    S0 = NonZeroRand();
    S1 = NonZeroRand();
    S2 = NonZeroRand();
    S3 = NonZeroRand();
}

final function SetSeed(int Part1, int Part2, int Part3, int Part4)
{
    S0 = Part1;
    S1 = Part2;
    S2 = Part3;
    S3 = Part4;
}

final function GetSeed(out int Part1, out int Part2, out int Part3, out int Part4)
{
    Part1 = S0;
    Part2 = S1;
    Part3 = S2;
    Part4 = S3;
}

// Implementation from https://prng.di.unimi.it/xoshiro128plus.c
final function int RandInt()
{
    local int Result;
    local int Temp;

    Result = S0 + S3;
    Temp = S1 << 9;
    S2 = S2 ^ S0;
    S3 = S3 ^ S1;
    S1 = S1 ^ S2;
    S0 = S0 ^ S3;
    S2 = S2 ^ Temp;
    S3 = (S3 << 11) | (S3 >>> 21);
    return Result;
}

// Implementation from https://prng.di.unimi.it/xoshiro128plusplus.c
// This one is slower, something like 20% slower? Could still be fast enough, dunno.
// private final function int Next()
// {
//     local int Result;
//     local int Temp;

//     Result = S0 + S3;
//     Result = (Result << 7) | (Result >>> 25) + S0;
//     Temp = S1 << 9;
//     S2 = S2 ^ S0;
//     S3 = S3 ^ S1;
//     S1 = S1 ^ S2;
//     S0 = S0 ^ S3;
//     S2 = S2 ^ Temp;
//     S3 = (S3 << 11) | (S3 >>> 21);
//     return Result;
// }

final function float RandFloat()
{
    return (RandInt() >>> 9) / 8388608.0;
}

final function bool RandBool()
{
    return bool(RandInt() >>> 31);
}

final function Rotator RandRot(optional bool bRoll)
{
    local Rotator Result;

    Result.Yaw = RandInt() >>> 16;
    Result.Pitch = RandInt() >>> 16;
    if (bRoll)
    {
        Result.Roll = RandInt() >>> 16;
    }
    return Result;
}

final function Vector RandVect()
{
    local Vector Result;

    do
    {
        Result.X = RandFloat() * 2 - 1;
        Result.Y = RandFloat() * 2 - 1;
        Result.Z = RandFloat() * 2 - 1;
    } until ((Result dot Result) <= 1.0);
    return Normal(Result);
}

static private final function int NonZeroRand()
{
    local int Candidate;

    while (Candidate == 0)
    {
        Candidate = Rand(MaxInt);
    }
    return Candidate;
}

defaultproperties
{
}
