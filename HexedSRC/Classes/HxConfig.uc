class HxConfig extends HxTypes
    abstract;

var const string ObjectName;
var const array<HxProperty> Properties;
var const array<HxDisplayProperty> DisplayInfo;

var protected LevelInfo Level;
var protected HxClientReplicationInfo ClientOwner;

function InitializeProperties();
function ApplyProperty(int Index);
function string ValidateStruct(int Index, string Value);

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
    SaveConfig();
}

function Setup(HxClientReplicationInfo Owner)
{
    Level = Owner.Level;
    ClientOwner = Owner;
    InitializeProperties();
}

function bool SetProperty(int Index, coerce string Value)
{
    local string OldValue;

    if (IsValidPropertyIndex(Index))
    {
        OldValue = GetPropertyText(Properties[Index].Name);
        if (SetPropertyText(Properties[Index].Name, ValidateProperty(Index, Value)))
        {
            ApplyProperty(Index);
            if (ClientOwner != None)
            {
                ClientOwner.NotifyUserPropertyChanged(Self, Index, OldValue);
            }
            SaveConfig();
            return true;
        }
    }
    return false;
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
        case HX_PROPERTY_Enum:
            return ValidateEnum(Index, Value);
        case HX_PROPERTY_Struct:
            return ValidateStruct(Index, Value);
    }
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

final function bool IsValidPropertyIndex(int Index)
{
    return Index > -1 && Index < Properties.Length;
}

function UpdateConfiguration(Object TargetObject)
{
    local int i;

    for (i = 0; i < Properties.Length; ++i)
    {
        TargetObject.SetPropertyText(Properties[i].Name, GetProperty(i));
    }
}

function HudOverlay FindHudOverlay(class<HudOverlay> OverlayClass)
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


static function HxConfig Load()
{
    return new(None, default.ObjectName) default.Class;
}

defaultproperties
{
}
