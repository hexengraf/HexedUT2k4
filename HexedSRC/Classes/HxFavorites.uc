class HxFavorites extends HxConfig
    config(HexedFavorites)
    PerObjectConfig;

enum EHxTag
{
    HX_TAG_Any,
    HX_TAG_Like,
    HX_TAG_None,
    HX_TAG_Dislike,
};

struct HxFavoriteEntry
{
    var string Name;
    var EHxTag Tag;
};
var config array<HxFavoriteEntry> List;

var private const Color StarColor;
var private const Color BlockColor;

function Save(string Name, EHxTag Tag, optional bool bSkipSaveConfig)
{
    local bool bSaveConfig;
    local int i;

    for (i = 0; i < List.Length; ++i)
    {
        if (List[i].Name ~= Name)
        {
            break;
        }
    }
    if (Tag != HX_TAG_None)
    {
        List.Length = Max(i + 1, List.Length);
        List[i].Name = Name;
        List[i].Tag = Tag;
        bSaveConfig = !bSkipSaveConfig;
    }
    else if (i < List.Length)
    {
        List.Remove(i, 1);
        bSaveConfig = !bSkipSaveConfig;
    }
    if (bSaveConfig)
    {
        SaveConfig();
    }
}

function EHxTag Get(string Name)
{
    local int i;

    for (i = 0; i < List.Length; ++i)
    {
        if (List[i].Name ~= Name)
        {
            return List[i].Tag;
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
    C.Style = 5; // STY_Alpha
    switch (Tag)
    {
        case HX_TAG_Like:
            C.DrawColor = default.StarColor;
            C.DrawTile(Material'HxStarIcon', Size, Size, 0, 0, 64, 64);
            break;
        case HX_TAG_Dislike:
            C.DrawColor = default.BlockColor;
            C.DrawTile(Material'HxBlockIcon', Size, Size, 0, 0, 64, 64);
            break;
    }
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
    C.CurX = SavedCurX;
    C.CurY = SavedCurY;
}

defaultproperties
{
    StarColor=(R=255,G=210,B=0,A=255)
    BlockColor=(R=255,G=210,B=0,A=255)
}
