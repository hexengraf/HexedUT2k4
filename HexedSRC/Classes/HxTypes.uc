class HxTypes extends Object
    abstract;

struct HxMutatorProperty
{
    var const string Name;
    var const localized string Section;
    var const localized string Caption;
    var const localized string Hint;
    var const string Type;
    var const string Data;
    var const bool bMPOnly;
    var const bool bAdvanced;
};

struct HxClientProperty
{
    var const string Name;
    var const localized string Section;
    var const localized string Caption;
    var const localized string Hint;
    var const PlayInfo.EPlayInfoType Type;
    var const string Data;
    var const float Step;
    var const string Dependency;
    var const bool bAdvanced;
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
