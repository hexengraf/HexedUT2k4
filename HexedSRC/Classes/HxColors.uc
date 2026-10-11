class HxColors extends HxManagedObject
    config(User)
    perObjectConfig;

struct HxColorEntry
{
    var string Name;
    var Color Color;
    var bool bRandom;
};

var config array<HxColorEntry> ColorList;

var private HxStringMap Cache;
var private HxStringMap OldCache;
var private HxStringArray ReservedNames;
var private HxStringArray ReferencePool;
var private HxStringArray PriorityPool;
var private HxStringArray RandomPool;
var private array<int> Counts;

event Created()
{
    local HxColorEntry Entry;
    local int i;
    local int j;

    Super.Created();
    for (i = 1; i < ColorList.Length; i++)
    {
        Entry = ColorList[i];
        j = i - 1;
        while (j >= 0 && ColorList[j].Name > Entry.Name)
        {
            ColorList[j + 1] = ColorList[j];
            --j;
        }
        ColorList[j + 1] = Entry;
    }
    SaveConfig();
}

function Setup(LevelInfo Level, HxClientManager Manager)
{
    local int i;

    Super.Setup(Level, Manager);
    Cache = new (None, Name$"Cache") class'HxStringMap';
    OldCache = new (None, Name$"OldCache") class'HxStringMap';
    ReservedNames = new (None, Name$"ReservedNames") class'HxStringArray';
    ReferencePool = new (None, Name$"ReferencePool") class'HxStringArray';
    PriorityPool = new (None, Name$"PriorityPool") class'HxStringArray';
    RandomPool = new (None, Name$"RandomPool") class'HxStringArray';
    for (i = Cache.Map.Length - 1; i >= 0; --i)
    {
        if (FindIndex(Cache.Map[i].Value))
        {
            PriorityPool.SortedRemove(Cache.Map[i].Value);
        }
        else
        {
            Cache.Map.Remove(i, 1);
        }
    }
    OldCache.Copy(Cache);
    if (!OldCache.bSorted)
    {
        OldCache.Sort();
    }
    Cache.Clear();
    Counts.Length = ColorList.Length;
    for (i = 0; i < ColorList.Length; ++i)
    {
        if (ColorList[i].bRandom)
        {
            ReferencePool.SortedInsert(ColorList[i].Name);
        }
    }
    PriorityPool.Copy(ReferencePool);
    RandomPool.Copy(ReferencePool);
}

function Destroy()
{
    Cache.SaveConfig();
    Cache = None;
    OldCache = None;
    ReservedNames = None;
    ReferencePool = None;
    PriorityPool = None;
    RandomPool = None;
    Super.Destroy();
}

function string CachedRandomColorName(string Key)
{
    local string ColorName;
    local int Index;

    if (Cache.BinarySearch(Key, ColorName))
    {
        return ColorName;
    }
    if (!OldCache.BinarySearch(Key, ColorName)
        || (OldCache.Size() < ReferencePool.Size() && Cache.Size() < ReferencePool.Size()
            && (!FindIndex(ColorName, Index) || Counts[Index] > 0)))
    {
        ColorName = RandomColorName();
        FindIndex(ColorName, Index);
    }
    ++Counts[Index];
    Cache.SortedInsert(Key, ColorName);
    Cache.SaveConfig();
    return ColorName;
}

function string RandomColorName()
{
    local string ColorName;

    if (!PriorityPool.IsEmpty())
    {
        return PriorityPool.PopRandom();
    }
    ColorName = RandomPool.PopRandom();
    if (RandomPool.IsEmpty())
    {
        RandomPool.Copy(ReferencePool);
    }
    return ColorName;
}

function int Insert(string ColorName, optional Color Color, optional bool bRandom)
{
    local int i;

    if (ColorName != "" && !IsReservedName(ColorName) && !FindIndex(ColorName))
    {
        for (i = 0; i < ColorList.Length; ++i)
        {
            if (ColorList[i].Name > ColorName)
            {
                ColorList.Insert(i, 1);
                ColorList[i].Name = ColorName;
                ColorList[i].Color = Color;
                ColorList[i].bRandom = bRandom;
                Counts.Insert(i, 1);
                ReferencePool.Insert(ColorName);
                RandomPool.Insert(ColorName);
                SaveConfig();
                return i;
            }
        }
    }
    return -1;
}

function bool Remove(int Index)
{
    if (IsValidIndex(Index))
    {
        RemoveFromChoices(ColorList[Index].Name);
        ColorList.Remove(Index, 1);
        Counts.Remove(Index, 1);
        SaveConfig();
        return true;
    }
    return false;
}

function bool Rename(int Index, string NewName)
{
    if (NewName != "" && IsValidIndex(Index) && !IsReservedName(NewName) && !FindIndex(NewName))
    {
        ReferencePool.SortedReplace(ColorList[Index].Name, NewName);
        PriorityPool.SortedReplace(ColorList[Index].Name, NewName);
        RandomPool.SortedReplace(ColorList[Index].Name, NewName);
        OldCache.ReplaceValue(ColorList[Index].Name, NewName);
        if (Cache.ReplaceValue(ColorList[Index].Name, NewName))
        {
            Cache.SaveConfig();
        }
        ColorList[Index].Name = NewName;
        SaveConfig();
        return true;
    }
    return false;
}

function bool SetRandom(int Index, bool bRandom)
{
    if (IsValidIndex(Index))
    {
        if (ColorList[Index].bRandom)
        {
            if (!bRandom)
            {
                RemoveFromChoices(ColorList[Index].Name);
            }
        }
        else if (bRandom)
        {
            ReferencePool.SortedInsert(ColorList[Index].Name);
            PriorityPool.SortedInsert(ColorList[Index].Name);
            RandomPool.SortedInsert(ColorList[Index].Name);
        }
        ColorList[Index].bRandom = bRandom;
        SaveConfig();
        return true;
    }
    return false;
}

function int Find(string ColorName, optional out Color Color)
{
    local int Index;

    if (FindIndex(ColorName, Index))
    {
        Color = ColorList[Index].Color;
        return Index;
    }
    return -1;
}

function bool FindEntry(string ColorName, optional out HxColorEntry Entry)
{
    local int Index;

    if (FindIndex(ColorName, Index))
    {
        Entry = ColorList[Index];
        return true;
    }
    return false;
}

function bool FindIndex(string ColorName, optional out int Index)
{
    local int Compare;
    local int Middle;
    local int Low;
    local int High;

    Low = 0;
    High = ColorList.Length - 1;
    while (Low <= High)
    {
        Middle = (Low + High) / 2;
        Compare = StrCmp(ColorName, ColorList[Middle].Name,, true);
        if (Compare == 0)
        {
            Index = Middle;
            return true;
        }
        if (Compare > 0)
        {
            Low = Middle + 1;
        }
        else
        {
            High = Middle - 1;
        }
    }
    return false;
}

function bool IsValidIndex(int Index)
{
    return Index >= 0 && Index < ColorList.Length;
}

function bool IsValidName(string ColorName)
{
    return IsReservedName(ColorName) || FindIndex(ColorName);
}

function int ReserveName(string ColorName)
{
    return ReservedNames.Insert(ColorName, true);
}

function bool IsReservedName(string ColorName)
{
    return ReservedNames.Search(ColorName);
}

private function RemoveFromChoices(string ColorName)
{
    ReferencePool.SortedRemove(ColorName);
    PriorityPool.SortedRemove(ColorName);
    if (RandomPool.SortedRemove(ColorName) && RandomPool.IsEmpty())
    {
        RandomPool.Copy(ReferencePool);
    }
    OldCache.RemoveValue(ColorName);
    if (Cache.RemoveValue(ColorName))
    {
        Cache.SaveConfig();
    }
}

static function string RandomName()
{
    return "Color#"$Rand(999999);
}

defaultproperties
{
    ColorList(0)=(Name="Blue",Color=(R=0,G=0,B=255,A=255),bRandom=true)
    ColorList(1)=(Name="Green",Color=(R=0,G=255,B=0,A=255),bRandom=true)
    ColorList(2)=(Name="Orange",Color=(R=255,G=100,B=0,A=255),bRandom=true)
    ColorList(3)=(Name="Pink",Color=(R=255,G=0,B=255,A=255),bRandom=true)
    ColorList(4)=(Name="Red",Color=(R=255,G=0,B=0,A=255),bRandom=true)
    ColorList(5)=(Name="Teal",Color=(R=0,G=255,B=255,A=255),bRandom=true)
    ColorList(6)=(Name="Yellow",Color=(R=255,G=255,B=0,A=255),bRandom=true)
}
