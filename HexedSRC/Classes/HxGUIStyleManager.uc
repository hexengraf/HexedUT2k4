class HxGUIStyleManager extends Object
    abstract;

struct HxGUIStyleEntry
{
    var string StyleName;
    var class<GUIStyles> StyleClass;
};

var private array<HxGUIStyleEntry> Entries;
var private bool bRegistered;

static function RegisterStyles(GUIController Controller, optional bool bTemporary)
{
    local int i;

    if (!default.bRegistered)
    {
        for (i = 0; i < default.Entries.Length; ++i)
        {
            Controller.RegisterStyle(default.Entries[i].StyleClass, bTemporary);
        }
        default.bRegistered = true;
    }
}

static function NotifyLevelChange()
{
    // GUIController calls PurgeObjectReferences() on level change,
    // completely nuking custom styles, so we need to re-register every level.
    default.bRegistered = false;
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
    Entries(7)=(StyleName="HxSquareButton",StyleClass=class'HxSTYSquareButton')
    Entries(8)=(StyleName="HxCloseButton",StyleClass=class'HxSTYCloseButton')
    Entries(9)=(StyleName="HxMenuHeader",StyleClass=class'HxSTYMenuHeader')
    Entries(10)=(StyleName="HxMenuBackground",StyleClass=class'HxSTYMenuBackground')
}
