class HxGUIList extends GUIList;

var bool bAutoSpacing;
var float LineSpacing;
var float LeftPadding;

function float GetSpacedItemHeight(Canvas C)
{
    local float XL;
    local float YL;
    local float Height;
    local float NewItemHeight;
    local float NewItemsPerPage;

    Style.TextSize(C, MenuState, "q|W", XL, YL, FontScale);
    NewItemHeight = YL + Round(LineSpacing * C.ClipY);
    if (bAutoSpacing)
    {
        Height = ActualHeight();
        NewItemsPerPage = int(Height / NewItemHeight);
        NewItemHeight = YL + int((Height - (NewItemsPerPage * YL)) / NewItemsPerPage);
    }
    return NewItemHeight;
}

function DrawItem(Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float Offset;

    X = ActualLeft();
    Offset = Round(LeftPadding * C.ClipY);
    if (bSelected)
    {
        SelectedStyle.Draw(C, MenuState, X, Y, W, H);
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

defaultproperties
{
    bAutoSpacing=true
    LineSpacing=0.003
    LeftPadding=0.015
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    OutlineStyleName=""
    bDrawSelectionBorder=false
    bMultiSelect=false
    OnDrawItem=DrawItem
    GetItemHeight=GetSpacedItemHeight
}
