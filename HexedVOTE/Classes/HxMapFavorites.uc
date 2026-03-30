
class HxMapFavorites extends HxFavorites
    config(User);

const MIN_VERSION = 6;
const COMPAT_MIN_VERSION = 4;

struct HxMapTag
{
    var string Map;
    var EHxTag Tag;
};

var config bool bFirstRun;
var config array<HxMapTag> Maps;

static function TagMap(string Map, EHxTag Tag)
{
    local bool bSave;
    local int i;

    if (default.bFirstRun)
    {
        StaticRecoverConfigs();
    }
    for (i = 0; i < default.Maps.Length; ++i)
    {
        if (default.Maps[i].Map ~= Map)
        {
            break;
        }
    }
    if (Tag != HX_TAG_None)
    {
        default.Maps.Length = Max(i + 1, default.Maps.Length);
        default.Maps[i].Map = Map;
        default.Maps[i].Tag = Tag;
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

static function EHxTag GetMapTag(string Map)
{
    local int i;

    if (default.bFirstRun)
    {
        StaticRecoverConfigs();
    }
    for (i = 0; i < default.Maps.Length; ++i)
    {
        if (default.Maps[i].Map ~= Map)
        {
            return default.Maps[i].Tag;
        }
    }
    return HX_TAG_None;
}

static function StaticRecoverConfigs()
{
    local HxMapFavorites NewObject;
    local Object OldObject;

    NewObject = new() default.Class;
    OldObject = FindOldVersionObject(default.Class, MIN_VERSION);
    if (OldObject == None)
    {
        OldObject = FindOldVersionObject("HexedUTv6.HxMapFavorites", COMPAT_MIN_VERSION);
    }
    if (OldObject != None)
    {
        NewObject.CopyPropertyFrom(OldObject, "Maps");
        NewObject.CopyPropertyFrom(OldObject, "StarColor");
        NewObject.CopyPropertyFrom(OldObject, "BlockColor", "NoColor");
    }
    NewObject.bFirstRun = false;
    NewObject.SaveConfig();
    NewObject = None;
    OldObject = None;
}

defaultproperties
{
    bFirstRun=true
}
