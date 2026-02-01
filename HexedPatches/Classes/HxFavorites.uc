class HxFavorites extends Object
    config(User);

enum EHxMark
{
    HX_MARK_Positive,
    HX_MARK_Unmarked,
    HX_MARK_Negative,
};

struct HxMapMark
{
    var string Map;
    var EHxMark Mark;
};

var config array<HxMapMark> Maps;

static function MarkMap(string Map, EHxMark Mark)
{
    local bool bSave;
    local int i;

    for (i = 0; i < default.Maps.Length; ++i)
    {
        if (default.Maps[i].Map ~= Map)
        {
            break;
        }
    }
    if (Mark != HX_MARK_Unmarked)
    {
        default.Maps.Length = Max(i + 1, default.Maps.Length);
        default.Maps[i].Map = Map;
        default.Maps[i].Mark = Mark;
        bSave = true;
    }
    else if (i < default.Maps.Length)
    {
        default.Maps.Remove(i, 1);
        bSave = true;
    }
    if (bSave)
    {
        StaticSaveConfig();
    }
}

static function EHxMark GetMapMark(string Map)
{
    local int i;

    for (i = 0; i < default.Maps.Length; ++i)
    {
        if (default.Maps[i].Map ~= Map)
        {
            return default.Maps[i].Mark;
        }
    }
    return HX_MARK_Unmarked;
}

static function bool ClearMapMarks()
{
    local bool bChanged;

    bChanged = default.Maps.Length > 0;
    default.Maps.Remove(0, default.Maps.Length);
    if (bChanged)
    {
        StaticSaveConfig();
    }
    return bChanged;
}

static function EHxMark NameToMark(string MarkName)
{
    switch (MarkName)
    {
        case "+":
            return HX_MARK_Positive;
        case "-":
            return HX_MARK_Negative;
    }
    return HX_MARK_Unmarked;
}

static function string MarkToName(EHxMark Mark)
{
    switch (Mark)
    {
        case HX_MARK_Positive:
            return "+";
        case HX_MARK_Negative:
            return "-";
    }
    return "";
}

defaultproperties
{
}
