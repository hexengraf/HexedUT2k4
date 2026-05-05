class HxColors extends Object
    config(User)
    perObjectConfig;

struct HxColor
{
    var string Name;
    var Color Color;
    var bool bRandom;
};

struct HxColorChoice
{
    var string Key;
    var string Value;
};

var config array<HxColor> ColorList;
var config array<HxColorChoice> RandomChoices;
var config bool bPruneUnusedChoices;

var private array<string> ReservedNames;
var private array<string> RandomPool;
var private array<HxColorChoice> OldRandomChoices;

function Created()
{
    local int i;

    if (ValidateMap(RandomChoices))
    {
        SaveConfig();
    }
    PopulateRandomPool();
    if (bPruneUnusedChoices)
    {
        OldRandomChoices = RandomChoices;
        RandomChoices.Remove(0, RandomChoices.Length);
    }
    else
    {
        for (i = 0; i < RandomChoices.Length; ++i)
        {
            RemoveFromRandomPool(RandomChoices[i].Value);
        }
    }
}

function int Insert(string Name, optional Color Color, optional bool bRandom)
{
    local int Index;

    if (Find(Name) < 0)
    {
        Index = ColorList.Length;
        ColorList.Length = Index + 1;
        ColorList[Index].Name = Name;
        ColorList[Index].Color = Color;
        ColorList[Index].bRandom = bRandom;
        SaveConfig();
        return Index;
    }
    return -1;
}

function bool Remove(int Index)
{
    if (IsValidIndex(Index))
    {
        ValidateMap(RandomChoices);
        if (bPruneUnusedChoices)
        {
            ValidateMap(OldRandomChoices);
        }
        RemoveFromRandomPool(ColorList[Index].Name);
        ColorList.Remove(Index, 1);
        SaveConfig();
        return true;
    }
    return false;
}

function bool Rename(int Index, string Name)
{
    local int i;

    if (!IsValidIndex(Index) || Find(Name) > -1)
    {
        return false;
    }
    for (i = 0; i < RandomChoices.Length; ++i)
    {
        if (RandomChoices[i].Value == ColorList[Index].Name)
        {
            RandomChoices[i].Value = Name;
        }
    }
    if (bPruneUnusedChoices)
    {
        for (i = 0; i < OldRandomChoices.Length; ++i)
        {
            if (OldRandomChoices[i].Value == ColorList[Index].Name)
            {
                OldRandomChoices[i].Value = Name;
            }
        }
    }
    for (i = 0; i < RandomPool.Length; ++i)
    {
        if (RandomPool[i] == ColorList[Index].Name)
        {
            RandomPool[i] = Name;
        }
    }
    ColorList[Index].Name = Name;
    SaveConfig();
    return true;
}

function int Find(string Name, optional out Color Color)
{
    local int i;

    if (Name != "" && !IsReservedName(Name))
    {
        for (i = 0; i < ColorList.Length; ++i)
        {
            if (ColorList[i].Name == Name)
            {
                Color = ColorList[i].Color;
                return i;
            }
        }
    }
    return -1;
}

function int FindEntry(string Name, optional out HxColor ColorEntry)
{
    local int i;

    if (Name == "" || IsReservedName(Name))
    {
        return -1;
    }
    for (i = 0; i < ColorList.Length; ++i)
    {
        if (ColorList[i].Name == Name)
        {
            ColorEntry = ColorList[i];
            return i;
        }
    }
    return -1;
}

function string SavedRandom(string Key)
{
    local int i;

    for (i = 0; i < RandomChoices.Length; ++i)
    {
        if (RandomChoices[i].Key == Key)
        {
            return RandomChoices[i].Value;
        }
    }
    if (bPruneUnusedChoices)
    {
        for (i = 0; i < OldRandomChoices.Length; ++i)
        {
            if  (OldRandomChoices[i].Key == Key)
            {
                RandomChoices[RandomChoices.Length] = OldRandomChoices[i];
                RemoveFromRandomPool(OldRandomChoices[i].Value);
                SaveConfig();
                return OldRandomChoices[i].Value;
            }
        }
    }
    i = RandomChoices.Length;
    RandomChoices.Length = i + 1;
    RandomChoices[i].Key = Key;
    RandomChoices[i].Value = UniqueRandom();
    SaveConfig();
    return RandomChoices[i].Value;
}

function string UniqueRandom()
{
    local int Index;
    local string Name;

    Index = Rand(RandomPool.Length);
    Name = RandomPool[Index];
    RandomPool.Remove(Index, 1);
    if (RandomPool.Length == 0)
    {
        PopulateRandomPool();
    }
    return Name;
}

function bool SetRandom(int Index, bool bRandom)
{
    local int i;

    if (!IsValidIndex(Index))
    {
        return false;
    }
    if (ColorList[Index].bRandom ^^ bRandom)
    {
        for (i = 0; i < RandomChoices.Length; ++i)
        {
            if (RandomChoices[i].Value == ColorList[Index].Name)
            {
                RandomChoices.Remove(i, 1);
                --i;
            }
        }
        if (bPruneUnusedChoices)
        {
            for (i = 0; i < OldRandomChoices.Length; ++i)
            {
                if (OldRandomChoices[i].Value == ColorList[Index].Name)
                {
                    OldRandomChoices.Remove(i, 1);
                    --i;
                }
            }
        }
        for (i = 0; i < RandomPool.Length; ++i)
        {
            if (RandomPool[i] == ColorList[Index].Name)
            {
                RandomPool.Remove(i, 1);
                break;
            }
        }
    }
    ColorList[Index].bRandom = bRandom;
    return true;
}

function bool Reserve(string Name)
{
    local int i;

    for (i = 0; i < ReservedNames.Length; ++i)
    {
        if (Name ~= ReservedNames[i])
        {
            return false;
        }
    }
    ReservedNames[i] = Name;
    return true;
}

function bool IsValidName(string Name)
{
    return IsReservedName(Name) || Find(Name) > -1;
}

function bool IsReservedName(string Name)
{
    local int i;

    for (i = 0; i < ReservedNames.Length; ++i)
    {
        if (Name == ReservedNames[i])
        {
            return true;
        }
    }
    return false;
}

private function bool ValidateMap(out array<HxColorChoice> Map)
{
    local bool bChanged;
    local int i;
    local int j;

    for (i = Map.Length - 1; i >= 0; --i)
    {
        for (j = 0; j < ColorList.Length; ++j)
        {
            if (Map[i].Value == ColorList[j].Name)
            {
                if (!ColorList[j].bRandom)
                {
                    j = ColorList.Length;
                }
                break;
            }
        }
        if (j == ColorList.Length)
        {
            Map.Remove(i, 1);
            bChanged = true;
        }
    }
    return bChanged;
}

private function PopulateRandomPool()
{
    local int i;

    for (i = 0; i < ColorList.Length; ++i)
    {
        if (ColorList[i].bRandom)
        {
            RandomPool[RandomPool.Length] = ColorList[i].Name;
        }
    }
}

private function RemoveFromRandomPool(string Name)
{
    local int i;

    for (i = 0; i < RandomPool.Length; ++i)
    {
        if (RandomPool[i] == Name)
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
    return Index >= 0 && Index < ColorList.Length;
}

static function string RandomName()
{
    return "Color#"$Rand(999999);
}

defaultproperties
{
    ColorList(0)=(Name="Red",Color=(R=255,G=0,B=0,A=255),bRandom=true)
    ColorList(1)=(Name="Blue",Color=(R=0,G=0,B=255,A=255),bRandom=false)
    ColorList(2)=(Name="Green",Color=(R=0,G=255,B=0,A=255),bRandom=true)
    ColorList(3)=(Name="Pink",Color=(R=255,G=0,B=255,A=255),bRandom=true)
    ColorList(4)=(Name="Teal",Color=(R=0,G=255,B=255,A=255),bRandom=true)
    ColorList(5)=(Name="Yellow",Color=(R=255,G=255,B=0,A=255),bRandom=true)
    ColorList(6)=(Name="Purple",Color=(R=64,G=0,B=255,A=255),bRandom=false)
    bPruneUnusedChoices=true
}
