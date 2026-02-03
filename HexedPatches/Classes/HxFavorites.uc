class HxFavorites extends Object
    config(User);

#exec texture Import File=Textures\HxStarIcon.tga Name=HxStarIcon Mips=Off Alpha=1
#exec texture Import File=Textures\HxNoIcon.tga Name=HxNoIcon Mips=Off Alpha=1

enum EHxTag
{
    HX_TAG_Like,
    HX_TAG_None,
    HX_TAG_Hate,
};

struct HxMapTag
{
    var string Map;
    var EHxTag Tag;
};

var config Color StarColor;
var config Color NoColor;
var config array<HxMapTag> Maps;

static function TagMap(string Map, EHxTag Tag)
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

    for (i = 0; i < default.Maps.Length; ++i)
    {
        if (default.Maps[i].Map ~= Map)
        {
            return default.Maps[i].Tag;
        }
    }
    return HX_TAG_None;
}

static function DrawTag(Canvas C, EHxTag Tag, int X, int Y, int Size)
{
    local Color SavedColor;
    local int SavedStyle;
    local float SavedCurX;
    local float SavedCurY;

    if (Tag == HX_TAG_None)
    {
        return;
    }
    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    SavedCurX = C.CurX;
    SavedCurY = C.CurY;
    C.SetPos(X, Y);
    C.Style = 5;
    switch (Tag)
    {
        case HX_TAG_Like:
            C.DrawColor = default.StarColor;
            C.DrawTile(Material'HxStarIcon', Size, Size, 0, 0, 64, 64);
            break;
        case HX_TAG_Hate:
            C.DrawColor = default.NoColor;
            C.DrawTile(Material'HxNoIcon', Size, Size, 0, 0, 64, 64);
            break;
    }
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
    C.CurX = SavedCurX;
    C.CurY = SavedCurY;
}

defaultproperties
{
    // StarColor=(R=255,G=255,B=0,A=255)
    StarColor=(R=255,G=215,B=0,A=255)
    // NoColor=(R=255,G=66,B=66,A=255)
    NoColor=(R=255,G=215,B=0,A=255)
}
