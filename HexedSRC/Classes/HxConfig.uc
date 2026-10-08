class HxConfig extends HxTypes
    abstract;

struct HxDelayedUpdate
{
    var int Index;
    var string Value;
};

var const array<HxProperty> Properties;
var const array<HxDisplayProperty> DisplayInfo;
var const array<HxDisplayProperty> StatusInfo;

var protected LevelInfo Level;
var protected HxClientManager ClientManager;
var protected HxMutatorInfo MutatorInfo;
var private array<int> DelayedIndices;
var private array<HxDelayedUpdate> DelayedUpdates;

function InitializeProperties();
function ApplyProperty(int Index);
function NotifyMutatorInfoReady();
function NotifyMutatorPropertyChanged(int Index);

function Created()
{
    local int i;

    Super.Created();
    for (i = 0; i < Properties.Length; ++i)
    {
        if (Properties[i].Type != HX_PROPERTY_Array)
        {
            SetPropertyText(
                Properties[i].Name, ValidateProperty(i, GetPropertyText(Properties[i].Name)));
        }
    }
    DelayedIndices.Length = Properties.Length;
    for (i = 0; i < DelayedIndices.Length; ++i)
    {
        DelayedIndices[i] = -1;
    }
    SaveConfig();
}

function Setup(LevelInfo Level, HxClientManager Manager)
{
    Self.Level = Level;
    ClientManager = Manager;
    InitializeProperties();
}

simulated function SetMutatorInfo(HxMutatorInfo Info)
{
    MutatorInfo = Info;
    NotifyMutatorInfoReady();
}

function Destroy()
{
    Level = None;
    ClientManager = None;
    MutatorInfo = None;
}

function bool SetProperty(int Index, coerce string Value)
{
    if (IsValidPropertyIndex(Index))
    {
        if (SetPropertyText(Properties[Index].Name, ValidateProperty(Index, Value)))
        {
            ApplyProperty(Index);
            SaveConfig();
            return true;
        }
    }
    return false;
}

function bool SetPropertyDelayed(int Index, coerce string Value)
{
    if (IsValidPropertyIndex(Index))
    {
        if (DelayedIndices[Index] == -1)
        {
            DelayedIndices[Index] = DelayedUpdates.Length;
            DelayedUpdates.Insert(DelayedIndices[Index], 1);
        }
        DelayedUpdates[DelayedIndices[Index]].Index = Index;
        DelayedUpdates[DelayedIndices[Index]].Value = Value;
        return true;
    }
    return false;
}

function ApplyDelayedUpdates()
{
    local int i;

    for (i = 0; i < DelayedUpdates.Length; ++i)
    {
        DelayedIndices[DelayedUpdates[i].Index] = -1;
        SetProperty(DelayedUpdates[i].Index, DelayedUpdates[i].Value);
    }
    DelayedUpdates.Remove(0, DelayedUpdates.Length);
}

function string GetProperty(int Index)
{
    if (IsValidPropertyIndex(Index))
    {
        return GetPropertyText(Properties[Index].Name);
    }
    return "";
}

function int GetPropertyIndex(string Name)
{
    local int i;

    for (i = 0; i < Properties.Length; ++i)
    {
        if (Name ~= Properties[i].Name)
        {
            return i;
        }
    }
    return -1;
}

function bool ShouldShowStatus(int Index)
{
    return false;
}

function string GetStatus(int Index)
{
    return "";
}

function bool ResetProperty(int Index)
{
    return false;
}

function string ValidateProperty(int Index, string Value)
{
    switch (Properties[Index].Type)
    {
        case HX_PROPERTY_Int:
            return string(Clamp(
                int(Value),
                int(Properties[Index].LowerLimit),
                int(Properties[Index].UpperLimit)));
        case HX_PROPERTY_Float:
            return string(FClamp(
                float(Value),
                float(Properties[Index].LowerLimit),
                float(Properties[Index].UpperLimit)));
        case HX_PROPERTY_String:
            return ValidateString(Index, Value);
        case HX_PROPERTY_Enum:
            return ValidateEnum(Index, Value);
        case HX_PROPERTY_Struct:
            return ValidateStruct(Index, Value);
    }
    return Value;
}

function string ValidateString(int Index, string Value)
{
    return Value;
}

function string ValidateEnum(int Index, string Value)
{
    local string EnumValue;
    local int Limit;
    local int i;

    if (Properties[Index].EnumType == None)
    {
        return Value;
    }
    Limit = int(Properties[Index].UpperLimit);
    for (i = int(Properties[Index].LowerLimit); i < Limit; ++i)
    {
        EnumValue = string(GetEnum(Properties[Index].EnumType, i));
        if (Value ~= EnumValue)
        {
            return EnumValue;
        }
    }
    return string(GetEnum(Properties[Index].EnumType, int(Properties[Index].LowerLimit)));
}

function string ValidateStruct(int Index, string Value)
{
    return Value;
}

final function bool IsValidPropertyIndex(int Index)
{
    return Index > -1 && Index < Properties.Length;
}

final function bool IsMissingDependency(int Index)
{
    return DisplayInfo[Index].Dependency != ""
        && !bool(MutatorInfo.Get(DisplayInfo[Index].Dependency));
}

final function HudOverlay FindHudOverlay(class<HudOverlay> OverlayClass)
{
    local PlayerController PC;
    local int i;

    if (Level != None)
    {
        PC = Level.GetLocalPlayerController();
        if (PC != None && PC.MyHUD != None)
        {
            for (i = 0; i < PC.MyHUD.Overlays.Length; ++i)
            {
                if (PC.MyHUD.Overlays[i].Class == OverlayClass)
                {
                    return PC.MyHUD.Overlays[i];
                }
            }
        }
    }
    return None;
}

defaultproperties
{
}
