class HxFavorites extends Object
    config(User);

enum EHxTag
{
    HX_TAG_Like,
    HX_TAG_None,
    HX_TAG_Dislike,
};

struct HxMapTag
{
    var string Map;
    var EHxTag Tag;
};

var config Color StarColor;
var config Color BlockColor;
var config array<HxMapTag> Maps;

defaultproperties
{
    StarColor=(R=255,G=210,B=0,A=255)
    BlockColor=(R=255,G=210,B=0,A=255)
}
