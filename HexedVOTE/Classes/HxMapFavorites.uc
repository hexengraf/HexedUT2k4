// Compatibility stub to retrieve map list from old format
// TODO: delete this class in v8
class HxMapFavorites extends HxConfig;

struct HxMapTag
{
    var string Map;
    var HxFavorites.EHxTag Tag;
};

var config array<HxMapTag> Maps;

defaultproperties
{
}
