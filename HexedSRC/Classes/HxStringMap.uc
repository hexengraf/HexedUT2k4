class HxStringMap extends HxTypes
    config(HexedCache)
    PerObjectConfig;

struct HxStringMapPair
{
    var string Key;
    var string Value;
};

var config bool bSorted;
var config array<HxStringMapPair> Map;

event Created()
{
    if (bSorted)
    {
        Sort();
    }
    Super.Created();
}

function Clear()
{
    Map.Remove(0, Map.Length);
    bSorted = true;
}

function Sort()
{
    local HxStringMapPair Pair;
    local int i;
    local int j;

    for (i = 1; i < Map.Length; i++)
    {
        Pair = Map[i];
        j = i - 1;
        while (j >= 0 && StrCmp(Map[j].Key, Pair.Key) > 0)
        {
            Map[j + 1] = Map[j];
            --j;
        }
        Map[j + 1] = Pair;
    }
}

function Copy(HxStringMap Other)
{
    Map = Other.Map;
    bSorted = Other.bSorted;
}

function int Size()
{
    return Map.Length;
}

function bool IsEmpty()
{
    return Map.Length == 0;
}

function int Insert(string Key, string Value)
{
    local int Index;

    if (Search(Key,, Index))
    {
        Map[Index].Value = Value;
        return Index;
    }
    Index = Map.Length;
    Map.Insert(Index, 1);
    Map[Index].Key = Key;
    Map[Index].Value = Value;
    return Index;
}

function int SortedInsert(string Key, string Value)
{
    local int Compare;
    local int i;

    for (i = 0; i < Map.Length; ++i)
    {
        Compare = StrCmp(Map[i].Key, Key);
        if (Compare == 0)
        {
            Map[i].Value = Value;
            return i;
        }
        if (Compare > 0)
        {
            break;
        }
    }
    Map.Insert(i, 1);
    Map[i].Key = Key;
    Map[i].Value = Value;
    return i;
}

function bool Remove(string Key)
{
    local int Index;

    if (Search(Key,, Index))
    {
        Map.Remove(Index, 1);
        return true;
    }
    return false;
}

function bool SortedRemove(string Key)
{
    local int Index;

    if (BinarySearch(Key,, Index))
    {
        Map.Remove(Index, 1);
        return true;
    }
    return false;
}

function bool RemoveValue(string Value)
{
    local bool bRemoved;
    local int i;

    for (i = Map.Length - 1; i >= 0; ++i)
    {
        if (Map[i].Value ~= Value)
        {
            Map.Remove(i, 1);
            bRemoved = true;
        }
    }
    return bRemoved;
}

function bool ReplaceValue(string OldValue, string NewValue)
{
    local bool bReplaced;
    local int i;

    for (i = Map.Length - 1; i >= 0; ++i)
    {
        if (Map[i].Value ~= OldValue)
        {
            Map[i].Value = NewValue;
            bReplaced = true;
        }
    }
    return bReplaced;
}


function bool Search(string Key, optional out string Value, optional out int Index)
{
    local int i;

    for (i = 0; i < Map.Length; ++i)
    {
        if (Key ~= Map[i].Key)
        {
            Value = Map[i].Value;
            Index = i;
            return true;
        }
    }
    return false;
}

function bool BinarySearch(string Key, optional out string Value, optional out int Index)
{
    local int Compare;
    local int Middle;
    local int Low;
    local int High;

    Low = 0;
    High = Map.Length - 1;
    while (Low <= High)
    {
        Middle = (Low + High) / 2;
        Compare = StrCmp(Key, Map[Middle].Key);
        if (Compare == 0)
        {
            Value = Map[Middle].Value;
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

defaultproperties
{
}
