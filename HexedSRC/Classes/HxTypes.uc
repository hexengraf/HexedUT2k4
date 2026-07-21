class HxTypes extends Object
    abstract;

enum HxPropertyType
{
    HX_PROPERTY_Bool,
    HX_PROPERTY_Int,
    HX_PROPERTY_Float,
    HX_PROPERTY_String,
    HX_PROPERTY_Enum,
    HX_PROPERTY_Color,
    HX_PROPERTY_Array,
    HX_PROPERTY_Struct,
};

enum EHxDataType
{
    HX_DATA_String,
    HX_DATA_Number,
    HX_DATA_Range,
};

enum EHxOperation
{
    HX_OPERATION_DontCare,
    HX_OPERATION_LessThan,
    HX_OPERATION_GreaterThan,
    HX_OPERATION_EqualTo,
    HX_OPERATION_EqualTo_Implicit,
};

struct HxProperty
{
    var const string Name;
    var const HxPropertyType Type;
    var const string LowerLimit;
    var const string UpperLimit;
    var const Object EnumType;
};

struct HxDisplayProperty
{
    var const localized string Section;
    var const localized string Caption;
    var const localized string Hint;
    var const localized array<string> EnumLabels;
    var const string Step;
    var const string Dependency;
    var const string ConfigPage;
    var const string Privileges;
    var const int SecLevel;
    var const bool bMPOnly;
    var const bool bAdvanced;
    var const bool bHidden;
};

enum EHxVertAlignment
{
    HX_VALIGN_Top,
    HX_VALIGN_Center,
    HX_VALIGN_Bottom,
};

static function string GetDataCharset(EHxDataType Type)
{
    switch (Type)
    {
        case HX_DATA_String:
            return "";
        case HX_DATA_Number:
            return "0123456789<=>*";
        case HX_DATA_Range:
            return "0123456789<=>*-";
    }
    return "";
}

static function bool ExtractVersion(coerce string FullName,
                                    out string Version,
                                    optional out string PackageName,
                                    optional out string ClassName)
{
    return Divide(FullName, ".", PackageName, ClassName)
        && Divide(PackageName, "v", PackageName, Version);
}

static final function Color BlendColor(float Alpha, Color From, Color To)
{
    local Color Result;
    local float Complement;

    Alpha = FClamp(Alpha, 0.0, 1.0);
    Alpha = Alpha * Alpha * (3.0 - (2.0 * Alpha));
    Complement = 1.0 - Alpha;
    Result.R = Clamp(Sqrt((To.R * To.R) * Alpha + (From.R * From.R) * Complement), 0, 255);
    Result.G = Clamp(Sqrt((To.G * To.G) * Alpha + (From.G * From.G) * Complement), 0, 255);
    Result.B = Clamp(Sqrt((To.B * To.B) * Alpha + (From.B * From.B) * Complement), 0, 255);
    Result.A = From.A;
    return Result;
}
