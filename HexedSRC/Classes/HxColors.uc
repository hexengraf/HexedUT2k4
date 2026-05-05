class HxColors extends Object
    config(User)
    perObjectConfig;

struct HxColor
{
    var string ColorName;
    var Color Color;
    var bool bRandom;
};

struct HxColorAlias
{
    var string Alias;
    var string ColorName;
};

var config array<HxColor> List;
var config array<HxColorAlias> Aliases;
var config bool bPruneUnusedAliases;
var array<string> ReservedNames;

var private array<HxColorAlias> OldAliases;
var private array<string> RandomPool;

function Created()
{
    local int i;

    ValidateAliases(Aliases);
    PopulateRandomPool();
    if (bPruneUnusedAliases)
    {
        OldAliases = Aliases;
        Aliases.Remove(0, Aliases.Length);
    }
    else
    {
        for (i = 0; i < Aliases.Length; ++i)
        {
            RemoveFromRandomPool(Aliases[i].ColorName);
        }
    }
}

function int Insert(string ColorName, optional Color Color, optional bool bRandom)
{
    local int Index;

    if (Find(ColorName) < 0)
    {
        Index = List.Length;
        List.Length = Index + 1;
        List[Index].ColorName = ColorName;
        List[Index].Color = Color;
        List[Index].bRandom = bRandom;
        SaveConfig();
        return Index;
    }
    return -1;
}

function bool Remove(int Index)
{
    if (IsValidIndex(Index))
    {
        ValidateAliases(Aliases);
        if (bPruneUnusedAliases)
        {
            ValidateAliases(OldAliases);
        }
        RemoveFromRandomPool(List[Index].ColorName);
        List.Remove(Index, 1);
        SaveConfig();
        return true;
    }
    return false;
}

function bool Rename(int Index, string ColorName)
{
    local int i;

    if (!IsValidIndex(Index) || Find(ColorName) > -1)
    {
        return false;
    }
    for (i = 0; i < Aliases.Length; ++i)
    {
        if (Aliases[i].ColorName == List[Index].ColorName)
        {
            Aliases[i].ColorName = ColorName;
        }
    }
    if (bPruneUnusedAliases)
    {
        for (i = 0; i < OldAliases.Length; ++i)
        {
            if (OldAliases[i].ColorName == List[Index].ColorName)
            {
                OldAliases[i].ColorName = ColorName;
            }
        }
    }
    for (i = 0; i < RandomPool.Length; ++i)
    {
        if (RandomPool[i] == List[Index].ColorName)
        {
            RandomPool[i] = ColorName;
        }
    }
    List[Index].ColorName = ColorName;
    SaveConfig();
    return true;
}

function int Find(string ColorName, optional out Color Color)
{
    local int i;

    if (!IsReservedName(ColorName))
    {
        for (i = 0; i < List.Length; ++i)
        {
            if (List[i].ColorName == ColorName)
            {
                Color = List[i].Color;
                return i;
            }
        }
    }
    return -1;
}

function int FindEntry(string ColorName, optional out HxColor ColorEntry)
{
    local int i;

    if (IsReservedName(ColorName))
    {
        return -1;
    }
    for (i = 0; i < List.Length; ++i)
    {
        if (List[i].ColorName == ColorName)
        {
            ColorEntry = List[i];
            return i;
        }
    }
    return -1;
}

function string AliasedRandom(string Alias)
{
    local int i;

    for (i = 0; i < Aliases.Length; ++i)
    {
        if (Aliases[i].Alias == Alias)
        {
            return Aliases[i].ColorName;
        }
    }
    if (bPruneUnusedAliases)
    {
        for (i = 0; i < OldAliases.Length; ++i)
        {
            if  (OldAliases[i].Alias == Alias)
            {
                Aliases[Aliases.Length] = OldAliases[i];
                RemoveFromRandomPool(OldAliases[i].ColorName);
                SaveConfig();
                return OldAliases[i].ColorName;
            }
        }
    }
    i = Aliases.Length;
    Aliases.Length = i + 1;
    Aliases[i].Alias = Alias;
    Aliases[i].ColorName = UniqueRandom();
    SaveConfig();
    return Aliases[i].ColorName;
}

function string UniqueRandom()
{
    local int Index;
    local string ColorName;

    Index = Rand(RandomPool.Length);
    ColorName = RandomPool[Index];
    RandomPool.Remove(Index, 1);
    if (RandomPool.Length == 0)
    {
        PopulateRandomPool();
    }
    return ColorName;
}

function bool SetRandom(int Index, bool bRandom)
{
    local int i;

    if (!IsValidIndex(Index))
    {
        return false;
    }
    if (List[Index].bRandom ^^ bRandom)
    {
        for (i = 0; i < Aliases.Length; ++i)
        {
            if (Aliases[i].ColorName == List[Index].ColorName)
            {
                Aliases.Remove(i, 1);
                --i;
            }
        }
        if (bPruneUnusedAliases)
        {
            for (i = 0; i < OldAliases.Length; ++i)
            {
                if (OldAliases[i].ColorName == List[Index].ColorName)
                {
                    OldAliases.Remove(i, 1);
                    --i;
                }
            }
        }
        for (i = 0; i < RandomPool.Length; ++i)
        {
            if (RandomPool[i] == List[Index].ColorName)
            {
                RandomPool.Remove(i, 1);
                break;
            }
        }
    }
    List[Index].bRandom = bRandom;
    return true;
}

function bool Reserve(string ColorName)
{
    local int i;

    for (i = 0; i < ReservedNames.Length; ++i)
    {
        if (ColorName ~= ReservedNames[i])
        {
            return false;
        }
    }
    ReservedNames[i] = ColorName;
    return true;
}

function bool IsReservedName(string ColorName)
{
    local int i;

    for (i = 0; i < ReservedNames.Length; ++i)
    {
        if (ColorName == ReservedNames[i])
        {
            return true;
        }
    }
    return false;
}

private function ValidateAliases(out array<HxColorAlias> OtherAliases)
{
    local int i;
    local int j;

    for (i = OtherAliases.Length - 1; i >= 0; --i)
    {
        for (j = 0; j < List.Length; ++j)
        {
            if (OtherAliases[i].ColorName == List[j].ColorName)
            {
                break;
            }
        }
        if (j == List.Length)
        {
            OtherAliases.Remove(i, 1);
        }
    }
}

private function PopulateRandomPool()
{
    local int i;

    for (i = 0; i < List.Length; ++i)
    {
        if (List[i].bRandom)
        {
            RandomPool[RandomPool.Length] = List[i].ColorName;
        }
    }
}

private function RemoveFromRandomPool(string ColorName)
{
    local int i;

    for (i = 0; i < RandomPool.Length; ++i)
    {
        if (RandomPool[i] == ColorName)
        {
            RandomPool.Remove(i, 1);
            break;
        }
    }
    if (RandomPool.Length == 0)
    {
        PopulateRandomPool();
    }
}

private function bool IsValidIndex(int Index)
{
    return Index >= 0 && Index < List.Length;
}

static function string RandomName()
{
    return "Color#"$Rand(999999);
}

defaultproperties
{
    ReservedNames(0)=""
    List(0)=(ColorName="Red",Color=(R=255,G=0,B=0,A=255),bRandom=true)
    List(1)=(ColorName="Blue",Color=(R=0,G=0,B=255,A=255),bRandom=true)
    List(2)=(ColorName="Green",Color=(R=0,G=255,B=0,A=255),bRandom=true)
    List(3)=(ColorName="Pink",Color=(R=255,G=0,B=255,A=255),bRandom=true)
    List(4)=(ColorName="Teal",Color=(R=0,G=255,B=255,A=255),bRandom=true)
    List(5)=(ColorName="Yellow",Color=(R=255,G=255,B=0,A=255),bRandom=true)
    List(6)=(ColorName="Purple",Color=(R=64,G=0,B=255,A=255),bRandom=false)
    bPruneUnusedAliases=true
}
