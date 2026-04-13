class HxGUIMultiColumnListSearchBar extends HxGUIBackground;

var automated GUILabel l_Search;

var int FirstColumn;
var array<HxPatternMatch.EHxPatternType> Types;
var localized array<string> Hints;

var private array<GUIEditBox> ed_Columns;

delegate OnSearch(int Index, string Term);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.InitComponent(MyController, MyOwner);
    Types.Length = Max(Types.Length, Hints.Length);
    Hints.Length = Types.Length;
    for (i = 0; i < Types.Length; ++i)
    {
        CreateSearchBox(i);
    }
}

function AddSearchBox(HxPatternMatch.EHxPatternType Type, optional string Hint)
{
    Types[Types.Length] = Type;
    Hints[Hints.Length] = Hint;
    CreateSearchBox(Types.Length - 1);
    bInit = true;
}

private function CreateSearchBox(int i)
{
    ed_Columns[i] = GUIEditBox(AddComponent("XInterface.GUIEditBox", true));
    ed_Columns[i].TabOrder = i;
    ed_Columns[i].AllowedCharSet = class'HxPatternMatch'.static.GetPatternCharset(Types[i]);
    ed_Columns[i].SetHint(Hints[i]@class'HxPatternMatch'.static.GetPatternHint(Types[i]));
    ed_Columns[i].ToolTip.ExpirationSeconds = 0.085 * Len(ed_Columns[i].Hint);
}

function ResolutionChanged(int ResX, int ResY)
{
    bInit = true;
    Super.ResolutionChanged(ResX, ResY);
}

function bool InternalOnPreDraw(Canvas C)
{
    if (bInit || GUIMultiColumnListBox(MenuOwner).Header.MenuState == MSAT_Pressed)
    {
        ResizeSearchLabel(C);
        ResizeEditBoxes(C);
    }
    return Super.InternalOnPreDraw(C);
}

function ResizeSearchLabel(Canvas C)
{
    GetFontSize(l_Search, C, l_Search.Caption, l_Search.WinWidth);
    l_Search.WinWidth = FMax(0.09, l_Search.RelativeWidth(l_Search.WinWidth * 1.2));
}

function ResizeEditBoxes(Canvas C)
{
    local GUIMultiColumnList List;
    local float Thickness;
    local float Width;
    local int i;

    List = GUIMultiColumnListBox(MenuOwner).List;
    if (List != None && (ed_Columns.Length + FirstColumn) <= List.ColumnWidths.Length)
    {
        Width = ActualWidth();
        Thickness = class'HxGUIStyles'.static.GetActualFrameThickness(Self) / Width;
        for (i = 0; i < ed_Columns.Length; ++i)
        {
            ed_Columns[i].WinWidth = List.ColumnWidths[FirstColumn + i] / Width + Thickness;
            if (i == 0)
            {
                ed_Columns[i].WinLeft = FirstLeft(List, Width) - Thickness;
            }
            else
            {
                ed_Columns[i].WinLeft =
                    ed_Columns[i - 1].WinLeft + ed_Columns[i - 1].WinWidth - Thickness;
            }
            ed_Columns[i].bInit = bInit;
        }
    }
}

function float FirstLeft(GUIMultiColumnList List, float TotalWidth)
{
    local float Left;
    local int i;

    if (FirstColumn == 0)
    {
        return l_Search.WinWidth;
    }

    for (i = 0; i < FirstColumn; ++i)
    {
        Left += List.ColumnWidths[i];
    }
    Left = Left / TotalWidth;
    if (l_Search.WinWidth > Left)
    {
        ed_Columns[0].WinWidth -= l_Search.WinWidth - Left;
        return l_Search.WinWidth;
    }
    return Left;
}

function Clear()
{
    local int i;

    for (i = 0; i < ed_Columns.Length; ++i)
    {
        ed_Columns[i].SetText("");
    }
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIEditBox(NewComp) != None)
    {
        NewComp.StyleName = "HxEditBox";
        NewComp.FontScale = FNS_Small;
        NewComp.WinTop = 0;
        NewComp.WinHeight = 1;
        NewComp.bBoundToParent = true;
        NewComp.bScaleToParent = true;
        NewComp.OnChange = EditBoxOnChange;
    }
}

function EditBoxOnChange(GUIComponent Sender)
{
    OnSearch(Sender.TabOrder, GUIEditBox(Sender).GetText());
}

defaultproperties
{
    Begin Object class=GUILabel Name=SearchLabel
        Caption="Find"
        WinLeft=0
        WinTop=0
        WinHeight=1
        WinWidth=1
        StyleName="HxTextLabel"
        TextAlign=TXTA_Center
        FontScale=FNS_Small
        bNeverFocus=true
        bBoundToParent=true
        bScaleToParent=true
    End Object
    l_Search=SearchLabel

    StyleName="HxBackgroundDarker"
    FirstColumn=0
    OnCreateComponent=InternalOnCreateComponent
}
