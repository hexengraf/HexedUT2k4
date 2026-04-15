class HxDataHandler extends Object
    abstract;

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
