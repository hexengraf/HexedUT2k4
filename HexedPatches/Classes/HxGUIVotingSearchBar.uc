class HxGUIVotingSearchBar extends HxGUIFramedImage;

var automated GUILabel l_Search;
var automated array<HxGUIFramedEditBox> ed_Columns;

var int FirstColumn;

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

function ResolutionChanged(int ResX, int ResY)
{
    bInit = true;
    Super.ResolutionChanged(ResX, ResY);
}

function bool InternalOnPreDraw(Canvas C)
{
    bInit = bInit || GUIMultiColumnListBox(MenuOwner).Header.MenuState == MSAT_Pressed;
    if (bInit)
    {
        UpdateHeight(C);
        ResizeSearchLabel(C);
    }
    ResizeEditBoxes(C);
    return Super.InternalOnPreDraw(C);
}

function UpdateHeight(Canvas C)
{
    GetFontSize(l_Search, C,,, WinHeight);
    WinHeight = RelativeHeight(WinHeight * 1.5);
}

function ResizeSearchLabel(Canvas C)
{
    GetFontSize(l_Search, C, l_Search.Caption, l_Search.WinWidth);
    l_Search.WinWidth = FMax(0.1, l_Search.RelativeWidth(l_Search.WinWidth * 1.2));
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
        Thickness = Round(C.ClipY * FrameThickness) / Width;
        for (i = 0; i < ed_Columns.Length; ++i)
        {
            if (i == 0)
            {
                ed_Columns[i].WinLeft = FirstLeft(List, Width) - Thickness;
            }
            else
            {
                ed_Columns[i].WinLeft =
                    ed_Columns[i - 1].WinLeft + ed_Columns[i - 1].WinWidth - Thickness;
            }
            ed_Columns[i].WinTop = 0;
            ed_Columns[i].WinWidth = List.ColumnWidths[FirstColumn + i] / Width + Thickness;
            ed_Columns[i].WinHeight = 1;
            ed_Columns[i].bInit = bInit;
        }
        ed_Columns[i - 1].WinWidth = 1.0 - ed_Columns[i - 1].WinLeft;
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
    return Left / TotalWidth;
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

    ImageSources(0)=(Color=(R=28,G=47,B=96,A=255),Style=ISTY_Stretched)
    FirstColumn=0
}
