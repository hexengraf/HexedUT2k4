class HxScoreBoardInteraction extends Interaction;

event Initialized()
{
}

function bool KeyEvent(out EInputKey Key, out EInputAction Action, FLOAT Delta)
{
    if (!ViewportOwner.Actor.myHUD.bShowScoreboard
        || HxScoreBoard(ViewportOwner.Actor.myHUD.ScoreBoard) == None
        || Action != IST_Press)
    {
        return false;
    }
    switch (Key)
    {
        case IK_Up:
        case IK_MouseWheelUp:
            return HxScoreBoard(ViewportOwner.Actor.myHUD.ScoreBoard).ScrollUp();
        case IK_PageUp:
            return HxScoreBoard(ViewportOwner.Actor.myHUD.ScoreBoard).PageUp();
        case IK_Down:
        case IK_MouseWheelDown:
            return HxScoreBoard(ViewportOwner.Actor.myHUD.ScoreBoard).ScrollDown();
        case IK_PageDown:
            return HxScoreBoard(ViewportOwner.Actor.myHUD.ScoreBoard).PageDown();
        case IK_F8:
            return HxScoreBoard(ViewportOwner.Actor.myHUD.ScoreBoard).ToggleLayout();
    }
    return false;
}

static function HxScoreBoardInteraction AddInteraction(Player Owner)
{
    local int i;

    for (i = 0; i < Owner.LocalInteractions.Length; ++i)
    {
        if (Owner.LocalInteractions[i].Class == default.Class)
        {
            return HxScoreBoardInteraction(Owner.LocalInteractions[i]);
        }
    }
    return HxScoreBoardInteraction(
        Owner.InteractionMaster.AddInteraction(string(class'HxScoreBoardInteraction'), Owner));
}

defaultproperties
{
    bActive=true
}
