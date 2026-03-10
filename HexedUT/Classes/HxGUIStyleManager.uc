class HxGUIStyleManager extends Object;

struct HxGUIStyleEntry
{
    var string StyleName;
    var class<GUIStyles> StyleClass;
};

var private array<HxGUIStyleEntry> Entries;

static function RegisterAll(GUIController Controller, optional bool bTemporary)
{
    local int i;

    for (i = 0; i < default.Entries.Length; ++i)
    {
        Controller.RegisterStyle(default.Entries[i].StyleClass, bTemporary);
    }
}

defaultproperties
{
    Entries(0)=(StyleName="HxSmallList",StyleClass=class'HxSTYSmallList')
    Entries(1)=(StyleName="HxSmallListSelection",StyleClass=class'HxSTYSmallListSelection')
    Entries(2)=(StyleName="HxSmallText",StyleClass=class'HxSTYSmallText')
    Entries(3)=(StyleName="HxScrollGrip",StyleClass=class'HxSTYScrollGrip')
    Entries(4)=(StyleName="HxScrollZone",StyleClass=class'HxSTYScrollZone')
    Entries(5)=(StyleName="HxEditBox",StyleClass=class'HxSTYEditBox')
    Entries(6)=(StyleName="HxListHeader",StyleClass=class'HxSTYListHeader')
    Entries(7)=(StyleName="HxFlatButton",StyleClass=class'HxSTYFlatButton')
}
