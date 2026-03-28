class HxFavorites extends HxConfig
    abstract
    config(User);

enum EHxTag
{
    HX_TAG_Any,
    HX_TAG_Like,
    HX_TAG_None,
    HX_TAG_Dislike,
};

var config Color StarColor;
var config Color BlockColor;

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
