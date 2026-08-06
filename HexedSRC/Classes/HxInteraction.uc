class HxInteraction extends Interaction;

static function HxInteraction FindInteraction(Player Owner, class<HxInteraction> InteractionClass)
{
    local int i;

    for (i = 0; i < Owner.LocalInteractions.Length; ++i)
    {
        if (Owner.LocalInteractions[i].Class == InteractionClass)
        {
            return HxInteraction(Owner.LocalInteractions[i]);
        }
    }
    return None;
}

static function HxInteraction AddInteraction(Player Owner, class<HxInteraction> InteractionClass)
{
    local int i;

    for (i = 0; i < Owner.LocalInteractions.Length; ++i)
    {
        if (Owner.LocalInteractions[i].Class == InteractionClass)
        {
            return HxInteraction(Owner.LocalInteractions[i]);
        }
    }
    return HxInteraction(Owner.InteractionMaster.AddInteraction(string(InteractionClass), Owner));
}

defaultproperties
{
}
