class HxScoreBoardInteraction extends HxInteraction;

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

static function HxScoreBoardInteraction Add(Player Owner)
{
    return HxScoreBoardInteraction(AddInteraction(Owner, default.Class));
}

defaultproperties
{
    bActive=true
}
