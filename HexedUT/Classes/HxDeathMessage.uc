class HxDeathMessage extends xDeathMessage;

static function string GetString(optional int Switch,
                                 optional PlayerReplicationInfo RelatedPRI_1,
                                 optional PlayerReplicationInfo RelatedPRI_2,
                                 optional Object OptionalObject)
{
    if (Class<DamageType>(OptionalObject) == None)
    {
        return "";
    }
    if (Switch == 1)
    {
        return class'GameInfo'.static.ParseKillMessage(
            "",
            GetColoredName(RelatedPRI_2, class'HUD'.default.BlueColor),
            Class<DamageType>(OptionalObject).static.SuicideMessage(RelatedPRI_2));
    }
    return class'GameInfo'.static.ParseKillMessage(
        GetColoredName(RelatedPRI_1, class'HUD'.default.BlueColor),
        GetColoredName(RelatedPRI_2, class'HUD'.default.RedColor),
        Class<DamageType>(OptionalObject).static.DeathMessage(RelatedPRI_1, RelatedPRI_2));
}

static function string GetColoredName(PlayerReplicationInfo PRI, Color Fallback)
{
    if (PRI == None)
    {
        return default.SomeoneString;
    }
    return GetColorCode(PRI, Fallback)$PRI.PlayerName$GetConsoleColorCode(PRI);
}

static function string GetColorCode(PlayerReplicationInfo PRI, Color Fallback)
{
    if (!PRI.bNoTeam)
    {
        // PRI.Team.TeamColor is not properly initialized :(
        if (PRI.Team.TeamIndex == 0)
        {
            return class'GameInfo'.static.MakeColorCode(class'HUD'.default.RedColor);

        } else if (PRI.Team.TeamIndex == 1)
        {
            return class'GameInfo'.static.MakeColorCode(class'HUD'.default.BlueColor);
        }
    }
    return class'GameInfo'.static.MakeColorCode(Fallback);
}

static function string GetConsoleColorCode(PlayerReplicationInfo PRI)
{
    return class'GameInfo'.static.MakeColorCode(GetConsoleColor(PRI));
}

defaultproperties
{
}
