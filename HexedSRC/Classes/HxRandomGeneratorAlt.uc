class HxRandomGeneratorAlt extends Object;

var private int S;

event Created()
{
    Initialize();
}

final function Initialize()
{
    S = Rand(MaxInt);
}

final function SetSeed(int Seed)
{
    S = Seed;
}

final function int GetSeed()
{
    return S;
}

// splitmix32
// see first comment in https://gist.github.com/tommyettinger/46a874533244883189143505d203312c
final function int RandInt()
{
    local int Result;

    S -= 1640531527; // 0x9e3779b9 becomes negative due to int representation
    Result = S ^ (S >>> 16);
    Result = Result * 569420461;
    Result = Result ^ (Result >>> 15);
    Result = Result * 1935289751;
    Result = Result ^ (Result >>> 15);
    return Result;
}

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

defaultproperties
{
}
