class HxGUIList extends GUIList;

var string OverflowStyleName;
var bool bAutoSpacing;
var float LineSpacing;
var float LeftPadding;
var private GUIStyles NormalStyle;
var private GUIStyles OverflowStyle;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    OverflowStyle = MyController.GetStyle(OverflowStyleName, FontScale);
    Super.InitComponent(MyController, MyOwner);
    NormalStyle = Style;
}

function float GetSpacedItemHeight(Canvas C)
{
    local float NewItemHeight;
    local float NewItemsPerPage;
    local float Height;
    local float XL;
    local float YL;

    Style.TextSize(C, MenuState, "q|W", XL, YL, FontScale);
    NewItemHeight = Ceil(YL + (LineSpacing * C.ClipY));
    if (bAutoSpacing)
    {
        Height = ClientBounds[3] - ClientBounds[1] - 1;
        NewItemsPerPage = int(Height / NewItemHeight);
        NewItemHeight = YL + FMax(0, (Height - (NewItemsPerPage * YL)) / NewItemsPerPage);
    }
    return NewItemHeight;
}


function DrawItem(Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float Offset;
    local float SelectionOffset;

    X = ActualLeft();
    Offset = C.ClipY * LeftPadding;
    if (bSelected)
    {
        if (HxGUIStyles(Style) != None)
        {
            SelectionOffset = HxGUIStyles(Style).ActualFrameThickness();
        }
        SelectedStyle.Draw(C, MenuState, X + SelectionOffset, Y, W, H);
        SelectedStyle.DrawText(
            C, MenuState, X + Offset, Y, W - Offset, H, TextAlign, Elements[i].Item, FontScale);
    }
    else
    {
        Style.DrawText(
            C, MenuState, X + Offset, Y, W - Offset, H, TextAlign, Elements[i].Item, FontScale);
    }
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    if (EInputAction(State) == IST_Hold)
    {
        if (EInputKey(Key) == IK_Up && Up())
        {
            return true;
        }
        if (EInputKey(Key) == IK_Down && Down())
        {
            return true;
        }
    }
    return Super.InternalOnKeyEvent(Key, State, Delta);
}

function bool InternalOnPreDraw(Canvas C)
{
    local float Offset;
    local float OwnerWidth;
    local float CurrentWidth;

    OwnerWidth = MenuOwner.ActualWidth();
    CurrentWidth = ActualWidth();
    Offset = FMax(0, (WinHeight - (ItemsPerPage * ItemHeight)) / 2);

    if (CurrentWidth < OwnerWidth)
    {
        if (HxGUIVertScrollBar(MyScrollBar) != None
            && HxGUIVertScrollBar(MyScrollBar).StandardWidth > 0)
        {
            WinWidth = OwnerWidth - (HxGUIVertScrollBar(MyScrollBar).StandardWidth * C.ClipY);
        }
        else
        {
            WinWidth = OwnerWidth - MyScrollBar.ActualWidth();
        }
        Style = OverflowStyle;
    }
    else
    {
        Style = NormalStyle;
    }
    return true;
}

event Free()
{
    NormalStyle = None;
    OverflowStyle = None;
    Super.Free();
}

defaultproperties
{
    bAutoSpacing=true
    LineSpacing=0.0033
    LeftPadding=0.015
    StyleName="HxList"
    SelectedStyleName="HxListSelection"
    OverflowStyleName="HxList"
    OutlineStyleName=""
    bDrawSelectionBorder=false
    bMultiSelect=false
    OnPreDraw=InternalOnPreDraw
    OnDrawItem=DrawItem
}
