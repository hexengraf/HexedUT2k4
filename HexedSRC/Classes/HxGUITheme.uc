class HxGUITheme extends Object
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

defaultproperties
{
}
