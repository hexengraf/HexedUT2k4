class HxStringArray extends HxTypes
    config(HexedCache)
    PerObjectConfig;

var config bool bSorted;
var config array<string> Values;

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
    Values.Remove(0, Values.Length);
    bSorted = true;
}

function Sort()
{
    local string Value;
    local int i;
    local int j;

    for (i = 1; i < Values.Length; i++)
    {
        Value = Values[i];
        j = i - 1;
        while (j >= 0 && StrCmp(Values[j], Value) > 0)
        {
            Values[j + 1] = Values[j];
            --j;
        }
        Values[j + 1] = Value;
    }
    bSorted = true;
}

function Copy(HxStringArray Other)
{
    Values = Other.Values;
}

function int Size()
{
    return Values.Length;
}

function bool IsEmpty()
{
    return Values.Length == 0;
}

function int Insert(string Value, optional bool bUnique)
{
    local int i;

    if (bUnique && Search(Value, i))
    {
        return i;
    }
    i = Values.Length;
    Values[Values.Length] = Value;
    bSorted = false;
    return i;
}

function int SortedInsert(string Value, optional bool bUnique)
{
    local int Compare;
    local int i;

    for (i = 0; i < Values.Length; ++i)
    {
        Compare = StrCmp(Values[i], Value);
        if (Compare == 0)
        {
            if (bUnique)
            {
                return i;
            }
        }
        else if (Compare > 0)
        {
            break;
        }
    }
    Values.Insert(i, 1);
    Values[i] = Value;
    return i;
}

function bool Remove(string Value)
{
    local int Index;

    if (Search(Value, Index))
    {
        Values.Remove(Index, 1);
        return true;
    }
    return false;
}

function bool SortedRemove(string Value)
{
    local int Index;

    if (BinarySearch(Value, Index))
    {
        Values.Remove(Index, 1);
        return true;
    }
    return false;
}

function bool Search(string Value, optional out int Index)
{
    local int i;

    for (i = 0; i < Values.Length; ++i)
    {
        if (Value ~= Values[i])
        {
            Index = i;
            return true;
        }
    }
    return false;
}

function bool BinarySearch(string Value, optional out int Index)
{
    local int Compare;
    local int Middle;
    local int Low;
    local int High;

    Low = 0;
    High = Values.Length - 1;
    while (Low <= High)
    {
        Middle = (Low + High) / 2;
        Compare = StrCmp(Value, Values[Middle]);
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

function bool Replace(string OldValue, string NewValue)
{
    local int Index;

    if (Search(OldValue, Index))
    {
        Values[Index] = NewValue;
        return true;
    }
    return false;
}

function bool SortedReplace(string OldValue, string NewValue)
{
    local int Index;

    if (BinarySearch(OldValue, Index))
    {
        Values[Index] = NewValue;
        return true;
    }
    return false;
}

function string PickRandom(optional out int Index)
{
    Index = Rand(Values.Length);
    return Values[Index];
}

function string PopRandom()
{
    local string Value;
    local int Index;

    Value = PickRandom(Index);
    Values.Remove(Index, 1);
    return Value;
}

defaultproperties
{
}
