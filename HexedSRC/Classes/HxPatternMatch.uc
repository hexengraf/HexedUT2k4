class HxPatternMatch extends Object
    abstract;

enum EHxOperation
{
    HX_OPERATION_DontCare,
    HX_OPERATION_LessThan,
    HX_OPERATION_GreaterThan,
    HX_OPERATION_EqualTo,
    HX_OPERATION_EqualTo_Implicit,
};

struct HxStringPattern
{
    var bool bEnabled;
    var bool bCaseSensitive;
    var string Prefix;
    var string Suffix;
    var array<string> Parts;
};

struct HxValuePattern
{
    var EHxOperation Operation;
    var int Value;
};

struct HxRangePattern
{
    var HxValuePattern Min;
    var HxValuePattern Max;
};

enum EHxFilterMode
{
    HX_FILTER_MODE_Include,
    HX_FILTER_MODE_Exclude,
};

static function HxStringPattern ParseStringPattern(string SearchTerm, optional bool bCaseSensitive)
{
    local HxStringPattern Pattern;
    local int Length;
    local int i;

    Pattern.bCaseSensitive = bCaseSensitive;
    if (SearchTerm == "")
    {
        return Pattern;
    }
    if (!bCaseSensitive)
    {
        SearchTerm = Caps(SearchTerm);
    }
    Split(SearchTerm, "*", Pattern.Parts);
    if (StrCmp(Pattern.Parts[0], "^", 1) == 0)
    {
        if (Len(Pattern.Parts[0]) > 1)
        {
            Pattern.Prefix = Mid(Pattern.Parts[0], 1);
        }
        Pattern.Parts.Remove(0, 1);
    }
    if (Pattern.Parts.Length > 0)
    {
        i = Pattern.Parts.Length - 1;
        if (Right(Pattern.Parts[i], 1) == "$")
        {
            Length = Len(Pattern.Parts[i]);
            if (Length > 1)
            {
                Pattern.Suffix = Left(Pattern.Parts[i], Length - 1);
            }
            Pattern.Parts.Remove(i, 1);
        }
    }
    i = 0;
    while (i < Pattern.Parts.Length)
    {
        if (Pattern.Parts[i] == "")
        {
            Pattern.Parts.Remove(i, 1);
        }
        else
        {
            ++i;
        }
    }
    Pattern.bEnabled = Pattern.Parts.Length > 0 || Pattern.Prefix != "" || Pattern.Suffix != "";
    return Pattern;
}

static function HxRangePattern ParseRangePattern(string SearchTerm)
{
    local HxRangePattern Pattern;
    local string Min;
    local string Max;

    ReplaceText(SearchTerm, " ", "");
    if (SearchTerm == "")
    {
        return Pattern;
    }
    if (Divide(SearchTerm, "-", Min, Max))
    {
        Pattern.Min = ParseValuePattern(Min);
        Pattern.Max = ParseValuePattern(Max);
    }
    else
    {
        Pattern.Min = ParseValuePattern(SearchTerm);
        if (Pattern.Min.Operation == HX_OPERATION_EqualTo_Implicit)
        {
            Pattern.Max.Operation = HX_OPERATION_GreaterThan;
            Pattern.Max.Value = Pattern.Min.Value - 1;
            Pattern.Min.Operation = HX_OPERATION_LessThan;
            Pattern.Min.Value = Pattern.Min.Value + 1;
        }
        else
        {
            Pattern.Max = Pattern.Min;
        }
    }
    return Pattern;
}

static function HxValuePattern ParseValuePattern(string SearchTerm)
{
    local HxValuePattern Pattern;

    Pattern.Operation = ParseOperation(SearchTerm);
    if (SearchTerm != "")
    {
        Pattern.Value = int(SearchTerm);
    }
    return Pattern;
}

static function EHxOperation ParseOperation(out string SearchTerm)
{
    local string Operation;

    ReplaceText(SearchTerm, " ", "");
    if (SearchTerm == "" || InStr(SearchTerm, "*") > -1)
    {
        return HX_OPERATION_DontCare;
    }
    Operation = Left(SearchTerm, 1);
    if (Operation == "<")
    {
        SearchTerm = Right(SearchTerm, Len(SearchTerm) - 1);
        return HX_OPERATION_LessThan;
    }
    if (Operation == ">")
    {
        SearchTerm = Right(SearchTerm, Len(SearchTerm) - 1);
        return HX_OPERATION_GreaterThan;
    }
    if (Operation == "=")
    {
        SearchTerm = Right(SearchTerm, Len(SearchTerm) - 1);
        return HX_OPERATION_EqualTo;
    }
    return HX_OPERATION_EqualTo_Implicit;
}

static function bool StringPatternMatch(string Text, HxStringPattern Pattern)
{
    local int Position;
    local int Size;
    local int i;

    if (!Pattern.bEnabled)
    {
        return true;
    }
    if (!Pattern.bCaseSensitive)
    {
        Text = Caps(Text);
    }
    if (Pattern.Prefix != "")
    {
        Size = Len(Pattern.Prefix);
        if (StrCmp(Text, Pattern.Prefix, Size, Pattern.bCaseSensitive) != 0)
        {
            return false;
        }
        Text = Mid(Text, Size);
    }
    for (i = 0; i < Pattern.Parts.Length; ++i)
    {
        Position = InStr(Text, Pattern.Parts[i]);
        if (Position < 0)
        {
            return false;
        }
        Text = Mid(Text, Position + Len(Pattern.Parts[i]));
    }
    if (Pattern.Suffix != "")
    {
        Size = Len(Pattern.Suffix);
        if (StrCmp(Right(Text, Size), Pattern.Suffix, Size, Pattern.bCaseSensitive) != 0)
        {
            return false;
        }
    }
    return true;
}

function bool RangePatternMatch(int Min, int Max, HxRangePattern Pattern)
{
    return ValuePatternMatch(Min, Pattern.Min) && ValuePatternMatch(Max, Pattern.Max);
}

function bool ValuePatternMatch(int Value, HxValuePattern Pattern)
{
    switch (Pattern.Operation)
    {
        case HX_OPERATION_DontCare:
            return true;
        case HX_OPERATION_LessThan:
            return Value < Pattern.Value;
        case HX_OPERATION_GreaterThan:
            return Value > Pattern.Value;
        case HX_OPERATION_EqualTo:
        case HX_OPERATION_EqualTo_Implicit:
            return Value == Pattern.Value;
        default:
            break;
    }
    return true;
}

defaultproperties
{
}
