class HxGUIScrollText extends GUIScrollText;

var eTextAlign VertAlign;
var float LineSpacing;
var float LeftPadding;
var float TopPadding;
var float RightPadding;
var float BottomPadding;

var bool bLayoutFixed;

function float GetSpacedItemHeight(Canvas C)
{
    local float XL;
    local float YL;

    Style.TextSize(C, MenuState, "A", XL, YL, FontScale);
    return Round(YL + LineSpacing * C.ClipY);
}

function bool InternalOnPreDraw(Canvas C)
{
    local float OwnerHeight;
    local float ContentHeight;
    local float ActualLeftPadding;
    local float ActualTopPadding;
    local float ActualRightPadding;

    WinWidth = MenuOwner.ActualWidth();
    OwnerHeight = MenuOwner.ActualHeight();
    ActualLeftPadding = LeftPadding * WinWidth;
    ActualTopPadding = TopPadding * OwnerHeight;
    ActualRightPadding = RightPadding * WinWidth;
    WinHeight = OwnerHeight - ActualTopPadding - (BottomPadding * OwnerHeight);
    ContentHeight = ItemCount * GetSpacedItemHeight(C);

    if (ContentHeight > WinHeight)
    {
        ActualRightPadding = FMax(ActualRightPadding, MyScrollBar.ActualWidth());
    }
    else if (VertAlign != TXTA_Left)
    {
        switch (VertAlign)
        {
            case TXTA_Center:
                ActualTopPadding = (OwnerHeight - ContentHeight) / 2;
                break;
            case TXTA_Right:
                ActualTopPadding = OwnerHeight - ContentHeight;
                break;
        }
        WinHeight = ContentHeight;
    }
    WinTop = MenuOwner.ActualTop() + ActualTopPadding;
    WinLeft = MenuOwner.ActualLeft() + ActualLeftPadding;
    WinWidth -= (ActualLeftPadding + ActualRightPadding);
    return true;
}

defaultproperties
{
    VertAlign=TXTA_Left
    LineSpacing=0.002
    LeftPadding=0
    TopPadding=0
    RightPadding=0
    BottomPadding=0
    StyleName="HxSmallText"
    SelectedStyleName="HxSmallText"
    GetItemHeight=GetSpacedItemHeight
    OnPreDraw=InternalOnPreDraw
}
