class HxGUIVotingSearchBar extends HxGUIFramedImage;

var automated HxGUIFramedLabel fl_Search;
var automated array<GUIEditBox> ed_Columns;

var GUIMultiColumnList List;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.InitComponent(MyController, MyOwner);
    for (i = 0; i < ed_Columns.Length; ++i)
    {
        ed_Columns[i].bBoundToParent = true;
        ed_Columns[i].bScaleToParent = true;
    }
}

function bool InternalOnPreDraw(Canvas C)
{
    local float Width;
    local float FilledWidth;
    local int i;

    if (bInit)
    {
        List = GUIMultiColumnListBox(MenuOwner).List;
        UpdateHeight(C);
        ResizeSearchLabel(C);
    }
    if (List != None && ed_Columns.Length <= List.ColumnWidths.Length)
    {
        Width = ActualWidth();
        FilledWidth = fl_Search.WinWidth;
        for (i = 0; i < ed_Columns.Length; ++i)
        {
            ed_Columns[i].WinTop = 0;
            ed_Columns[i].WinHeight = 1;
            ed_Columns[i].WinWidth = List.ColumnWidths[i] / Width;
            if (i == 0)
            {
                ed_Columns[i].WinWidth -= FilledWidth;
            }
            FilledWidth = FMin(1, FilledWidth + ed_Columns[i].WinWidth);
            ed_Columns[i].WinLeft = FilledWidth - ed_Columns[i].WinWidth;
        }
    }
    return Super.InternalOnPreDraw(C);
}

function ResizeSearchLabel(Canvas C)
{
    local float XL;
    local float YL;

    fl_Search.Style.TextSize(
        C, fl_Search.MenuState, fl_Search.Caption, XL, YL, fl_Search.FontScale);
    fl_Search.WinWidth = fl_Search.RelativeWidth(XL * 1.2);
}

function UpdateHeight(Canvas C)
{
    WinHeight = RelativeHeight(fl_Search.GetFontHeight(C) * 1.5);
}

function Clear()
{
    local int i;

    for (i = 0; i < ed_Columns.Length; ++i)
    {
        ed_Columns[i].SetText("");
    }
}

defaultproperties
{
    Begin Object class=HxGUIFramedLabel Name=SearchLabel
        Caption="Search:"
        WinLeft=0
        WinTop=0
        WinHeight=1
        WinWidth=1
        StyleName="HxSmallLabel"
        bTransparent=true
        FontScale=FNS_Small
        bBoundToParent=true
        bScaleToParent=true
    End Object
    fl_Search=SearchLabel

    ImageColor=(R=28,G=43,B=91,A=255)
}
