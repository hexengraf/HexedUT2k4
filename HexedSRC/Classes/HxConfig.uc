class HxConfig extends Object
    abstract;

enum HxPropertyType
{
    HX_PROPERTY_Bool,
    HX_PROPERTY_Int,
    HX_PROPERTY_Float,
    HX_PROPERTY_Enum,
    HX_PROPERTY_String,
    HX_PROPERTY_Color,
    HX_PROPERTY_Array,
    HX_PROPERTY_Struct,
};

struct HxProperty
{
    var const string Name;
    var const HxPropertyType Type;
    var const string LowerLimit;
    var const string UpperLimit;
    var const string Step;
};

struct HxDisplayProperty
{
    var const bool bShow;
    var const localized string Section;
    var const localized string Caption;
    var const localized string Hint;
    var const bool bAdvanced;
};

var const string ObjectName;
var const array<HxProperty> Properties;
var const array<HxDisplayProperty> DisplayProperties;
var const Class TargetClass;
var int Index;

function ApplyDefaultConfiguration();

function Created()
{
    local int i;

    Super.Created();
    for (i = 0; i < Properties.Length; ++i)
    {
        SetPropertyText(
            Properties[i].Name,
            ClampProperty(
                Properties[i].Type,
                GetPropertyText(Properties[i].Name),
                Properties[i].LowerLimit,
                Properties[i].UpperLimit));
    }
    ApplyDefaultConfiguration();
}

function bool SetProperty(int Index, coerce string Value)
{
    if (IsValidPropertyIndex(Index))
    {
        return SetPropertyText(
            Properties[Index].Name,
            ClampProperty(
                Properties[Index].Type,
                Value,
                Properties[Index].LowerLimit,
                Properties[Index].UpperLimit));
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

function string ClampProperty(HxPropertyType Type,
                              string Value,
                              string LowerLimit,
                              string UpperLimit)
{
    switch (Type)
    {
        case HX_PROPERTY_Int:
            return string(Clamp(int(Value), int(LowerLimit), int(UpperLimit)));
        case HX_PROPERTY_Float:
            return string(FClamp(float(Value), float(LowerLimit), float(UpperLimit)));
    }
    return Value;
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

static function HxConfig Load()
{
    return new(None, default.ObjectName) default.Class;
}

static function PlayInfo.EPlayInfoType ToPlayInfoType(HxPropertyType Type)
{
    switch (Type)
    {
        case HX_PROPERTY_Bool:
            return PIT_Check;
        case HX_PROPERTY_Enum:
            return PIT_Select;
    }
    return PIT_Text;
}

function bool CopyPropertyFrom(Object OldObject,
                               string PropertyName,
                               optional string OldPropertyName)
{
    return CopyProperty(Self, OldObject, PropertyName, OldPropertyName);
}

static function Object FindOldVersionObject(coerce string FullName,
                                            optional int MinVersion,
                                            optional out int Version)
{
    local class<Object> OldClass;
    local Object OldObject;
    local string PackageName;
    local string ClassName;
    local string VersionName;

    if (ExtractVersion(FullName, VersionName, PackageName, ClassName))
    {
        Version = int(VersionName);
        while (Version > MinVersion)
        {
            --Version;
            OldClass = class<Object>(DynamicLoadObject(
                PackageName$"v"$string(Version)$"."$ClassName, class'Class', true));
            if (OldClass != None)
            {
                OldObject = new() OldClass;
                if (OldObject != None)
                {
                    return OldObject;
                }
            }
        }
    }
    return None;
}

static function Actor FindOldVersionActor(Actor Owner,
                                          coerce string FullName,
                                          optional int MinVersion,
                                          optional out int Version)
{
    local class<Actor> OldClass;
    local Actor OldActor;
    local string PackageName;
    local string ClassName;
    local string VersionName;

    if (ExtractVersion(FullName, VersionName, PackageName, ClassName))
    {
        Version = int(VersionName);
        while (Version > MinVersion)
        {
            --Version;
            OldClass = class<Actor>(DynamicLoadObject(
                PackageName$"v"$string(Version)$"."$ClassName, class'Class', true));
            if (OldClass != None)
            {
                OldActor = Owner.Spawn(OldClass, Owner);
                if (OldActor != None)
                {
                    OldActor.Disable('Tick');
                    return OldActor;
                }
            }
        }
    }
    return None;
}

static function bool CopyProperty(Object NewObject,
                                  Object OldObject,
                                  string PropertyName,
                                  optional string OldPropertyName)
{
    local string Value;

    Value = OldObject.GetPropertyText(PropertyName);
    if (Value != "")
    {
        return NewObject.SetPropertyText(PropertyName, Value);
    }
    else if (OldPropertyName != "")
    {
        Value = OldObject.GetPropertyText(OldPropertyName);
        if (Value != "")
        {
            return NewObject.SetPropertyText(PropertyName, Value);
        }
    }
    return false;
}

static function bool ExtractVersion(coerce string FullName,
                                    out string Version,
                                    optional out string PackageName,
                                    optional out string ClassName)
{
    return Divide(FullName, ".", PackageName, ClassName)
        && Divide(PackageName, "v", PackageName, Version);
}

defaultproperties
{
    Index=-1
}
