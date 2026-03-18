class HxGUIMultiOptionList extends GUIMultiOptionList;

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    if (EInputAction(State) == IST_Hold)
    {
        if (EInputKey(Key) == IK_Up && Up())
        {
            return true;
        }
        if (EInputKey(Key) == IK_Down && Down())
        {
            return true;
        }
    }
    return Super.InternalOnKeyEvent(Key, State, Delta);
}

defaultproperties
{
    bDrawSelectionBorder=false
    ItemScaling=0.045
    ItemPadding=0.35
}
