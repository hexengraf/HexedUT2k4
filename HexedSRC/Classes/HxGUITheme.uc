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

static function ApplyComboBoxStyle(GUIController GC, moComboBox CB)
{
    local eFontScale FontScale;

    CB.MyComboBox.Edit.StyleName = "HxComboBox";
    CB.MyComboBox.Edit.Style = GC.GetStyle("HxComboBox", FontScale);
    CB.MyComboBox.Edit.FontScale = CB.FontScale;
    CB.MyComboBox.MyShowListBtn.StyleName = "HxSquareButton";
    CB.MyComboBox.MyShowListBtn.Style = GC.GetStyle("HxSquareButton", FontScale);
    CB.MyComboBox.MyShowListBtn.FontScale = CB.FontScale;
}

static function ApplyEditBoxStyle(GUIController GC, moEditBox EB)
{
    local eFontScale FontScale;

    EB.MyEditBox.StyleName = "HxEditBox";
    EB.MyEditBox.Style = GC.GetStyle("HxEditBox", FontScale);
    EB.MyEditBox.FontScale = EB.FontScale;
}

static function ApplySquareButtonStyle(GUIController GC, GUIButton B)
{
    local eFontScale FontScale;

    B.StyleName = "HxSquareButton";
    B.Style = GC.GetStyle("HxSquareButton", FontScale);
}

defaultproperties
{
}
