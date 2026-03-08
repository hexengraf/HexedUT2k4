class HxGUIMenuBasePanel extends HxGUIBasePanel;

var localized string PanelHint;
var bool bInsertFront;

var private bool bPanelAdded;

static function bool AddToMenu()
{
    if (!default.bPanelAdded)
    {
        default.bPanelAdded = true;
        class'HxGUIMenu'.static.AddPanel(
            default.Class, default.PanelCaption, default.PanelHint, default.bInsertFront);
        return true;
    }
    return false;
}
