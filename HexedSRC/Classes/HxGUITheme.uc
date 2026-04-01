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

static function ApplyComboBoxStyle(GUIController Controller, moComboBox CB)
{
    local eFontScale FontScale;

    CB.MyComboBox.Edit.StyleName = "HxComboBox";
    CB.MyComboBox.Edit.Style = Controller.GetStyle("HxComboBox", FontScale);
    CB.MyComboBox.Edit.FontScale = CB.FontScale;
    CB.MyComboBox.MyShowListBtn.StyleName = "HxSquareButton";
    CB.MyComboBox.MyShowListBtn.Style = Controller.GetStyle("HxSquareButton", FontScale);
    CB.MyComboBox.MyShowListBtn.FontScale = CB.FontScale;
}

static function ApplyEditBoxStyle(GUIController Controller, moEditBox EB)
{
    local eFontScale FontScale;

    EB.MyEditBox.StyleName = "HxEditBox";
    EB.MyEditBox.Style = Controller.GetStyle("HxEditBox", FontScale);
    EB.MyEditBox.FontScale = EB.FontScale;
}

defaultproperties
{
}
