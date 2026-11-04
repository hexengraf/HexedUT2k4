class HxGUITheme extends GUI
    abstract;

var const protected array<class<GUIStyles> > StyleClasses;

static function RegisterStyles(GUIController GC)
{
    local int i;

    for (i = 0; i < default.StyleClasses.Length; ++i)
    {
        GC.RegisterStyle(default.StyleClasses[i]);
    }
}

static function ApplySquareButtonStyle(GUIController GC, GUIButton B)
{
    local eFontScale FontScale;

    B.StyleName = "HxButton";
    B.Style = GC.GetStyle("HxButton", FontScale);
}

defaultproperties
{
}
