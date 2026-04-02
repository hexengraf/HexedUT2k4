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

// static function ApplyComboBoxStyle(GUIController GC, moComboBox CB)
// {
//     local eFontScale FontScale;

//     CB.MyComboBox.Edit.StyleName = "HxEditBox";
//     CB.MyComboBox.Edit.Style = GC.GetStyle("HxEditBox", FontScale);
//     CB.MyComboBox.Edit.FontScale = CB.FontScale;
//     CB.MyComboBox.MyListBox.List.StyleName = "HxComboList";
//     CB.MyComboBox.MyListBox.List.Style = GC.GetStyle("HxComboList", FontScale);
// }

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
