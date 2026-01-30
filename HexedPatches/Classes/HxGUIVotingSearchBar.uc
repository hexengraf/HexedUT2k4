class HxGUIVotingSearchBar extends HxGUIFramedImage;

var automated GUILabel l_Search;
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
        FilledWidth = l_Search.WinWidth;
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
    GetFontSize(l_Search, C, l_Search.Caption, l_Search.WinWidth);
    l_Search.WinWidth = l_Search.RelativeWidth(l_Search.WinWidth * 1.2);
}

function UpdateHeight(Canvas C)
{
    GetFontSize(l_Search, C,,, WinHeight);
    WinHeight = RelativeHeight(WinHeight * 1.5);
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
    Begin Object class=GUILabel Name=SearchLabel
        Caption="Search:"
        WinLeft=0
        WinTop=0
        WinHeight=1
        WinWidth=1
        TextFont="HxSmallerFont"
        TextAlign=TXTA_Center
        TextColor=(R=255,G=255,B=255,A=255)
        FontScale=FNS_Small
        bNeverFocus=true
        bBoundToParent=true
        bScaleToParent=true
    End Object
    l_Search=SearchLabel

    ImageSources(0)=(Color=(R=28,G=43,B=91,A=255),Style=ISTY_Stretched)
}
