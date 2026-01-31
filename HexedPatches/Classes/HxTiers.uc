class HxTiers extends Object
    config(User);

enum EHxTier
{
    HX_TIER_U,
    HX_TIER_F,
    HX_TIER_E,
    HX_TIER_D,
    HX_TIER_C,
    HX_TIER_B,
    HX_TIER_A,
};

struct HxMapGrade
{
    var string Map;
    var EHxTier Tier;
};

var config array<HxMapGrade> MapTiers;

static function SetTier(string Map, EHxTier Tier)
{
    local int i;

    for (i = 0; i < default.MapTiers.Length; ++i)
    {
        if (default.MapTiers[i].Map ~= Map)
        {
            break;
        }
    }
    if (Tier != HX_TIER_U)
    {
        default.MapTiers.Length = Max(i + 1, default.MapTiers.Length);
        default.MapTiers[i].Map = Map;
        default.MapTiers[i].Tier = Tier;
    }
    else if (i < default.MapTiers.Length)
    {
        default.MapTiers.Remove(i, 1);
    }
    StaticSaveConfig();
}

static function EHxTier GetTier(string Map)
{
    local int i;

    for (i = 0; i < default.MapTiers.Length; ++i)
    {
        if (default.MapTiers[i].Map ~= Map)
        {
            return default.MapTiers[i].Tier;
        }
    }
    return HX_TIER_U;
}

static function EHxTier NameToTier(string TierName)
{
    if (TierName == "")
    {
        return HX_TIER_U;
    }
    TierName = Caps(TierName);
    return EHxTier(6 - Clamp((Asc(Left(TierName, 1)) - Asc("A")), 0, 5));
}

static function string TierToName(EHxTier Tier)
{
    if (Tier == HX_TIER_U)
    {
        return "";
    }
    return Right(GetEnum(enum'EHxTier', Tier), 1);
}

defaultproperties
{
}
