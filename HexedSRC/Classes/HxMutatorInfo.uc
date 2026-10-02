class HxMutatorInfo extends PlayInfo;

struct HxArrayInfo
{
    var array<string> Values;
};

var class<HxMutator> MutatorClass;
var LevelInfo Level;
var PlayerController PlayerOwner;
var private array<HxArrayInfo> Arrays;
var private bool bInitialized;

function NotifyLevelChange();

function Setup(class<HxMutator> MutatorClass, LevelInfo Level, PlayerController PlayerOwner)
{
    Self.MutatorClass = MutatorClass;
    Self.Level = Level;
    self.PlayerOwner = PlayerOwner;
    MutatorClass.static.FillPlayInfo(Self);
    Arrays.Length = Settings.Length;
}

function Initialized()
{
    bInitialized = true;
}

final function bool IsInitialized()
{
    return bInitialized;
}

final function bool IsLast(int Index)
{
    return Index == Settings.Length - 1;
}

final function string GetName(int Index)
{
    return GetItemName(Settings[Index].SettingName);
}

final function string Get(string Name)
{
    local int Index;

    Index = FindIndex(Name);
    if (Index > -1)
    {
        return GetByIndex(Index);
    }
    return "";
}

final function string GetByIndex(int Index)
{
    return Settings[Index].Value;
}

final function bool GetArray(string Name, out array<string> ArrayProperty)
{
    local int Index;

    Index = FindIndex(Name);
    if (Index > -1)
    {
        return GetArrayByIndex(Index, ArrayProperty);
    }
    return false;
}

final function bool GetArrayByIndex(int Index, out array<string> ArrayProperty)
{
    if (Settings[Index].ArrayDim > -1)
    {
        ArrayProperty = Arrays[Index].Values;
        return true;
    }
    return false;
}

final function string GetArrayElement(string Name, int ElementIndex)
{
    local int Index;

    Index = FindIndex(Name);
    if (Index > -1)
    {
        return GetArrayElementByIndex(Index, ElementIndex);
    }
    return "";
}

final function string GetArrayElementByIndex(int Index, int ElementIndex)
{
    if (ElementIndex > -1 && ElementIndex < Arrays[Index].Values.Length)
    {
        return Arrays[Index].Values[ElementIndex];
    }
    return "";
}

final function bool Set(string Name, string Value)
{
    local int Index;

    Index = FindIndex(Name);
    if (Index > -1)
    {
        return SetByIndex(Index, Value);
    }
    return false;
}

final function bool SetByIndex(int Index, string Value)
{
    return StoreSetting(Index, Value);
}

final function bool SetArray(string Name, array<string> ArrayProperty)
{
    local int Index;

    Index = FindIndex(Name);
    if (Index > -1)
    {
        return SetArrayByIndex(Index, ArrayProperty);
    }
    return false;
}

final function bool SetArrayByIndex(int Index, array<string> ArrayProperty)
{
    if (Settings[Index].ArrayDim > -1)
    {
        Arrays[Index].Values = ArrayProperty;
        return true;
    }
    return false;
}

final function bool SetArrayElement(string Name, int ElementIndex, string ElementValue)
{
    local int Index;

    Index = FindIndex(Name);
    if (Index > -1)
    {
        return SetArrayElementByIndex(Index, ElementIndex, ElementValue);
    }
    return false;
}

final function bool SetArrayElementByIndex(int Index, int ElementIndex, string ElementValue)
{
    if (Settings[Index].ArrayDim > -1)
    {
        Arrays[Index].Values.Length = Max(Arrays[Index].Values.Length, ElementIndex + 1);
        Arrays[Index].Values[ElementIndex] = ElementValue;
        return true;
    }
    return false;
}

defaultproperties
{
}
