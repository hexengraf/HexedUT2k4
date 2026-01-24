class HxGUIScrollText extends GUIScrollText;

var eTextAlign VertAlign;
var bool bAutoSpacing;
var float LineSpacing;
var float LeftPadding;
var float TopPadding;
var float RightPadding;
var float BottomPadding;

var private float NewLeft;
var private float NewTop;
var private float NewWidth;
var private float NewHeight;
var private float MyItemHeight;
var private int MyItemsPerPage;
var private bool bScrollToBottom;

function ResolutionChanged(int ResX, int ResY)
{
    bInit = true;
    Super.ResolutionChanged(ResX, ResY);
}

function float GetSpacedItemHeight(Canvas C)
{
    local float XL;
    local float YL;

    Style.TextSize(C, MenuState, "q|W", XL, YL, FontScale);
    MyItemHeight = YL + Round(LineSpacing * C.ClipY);
    if (bAutoSpacing)
    {
        MyItemsPerPage = int(NewHeight / MyItemHeight);
        MyItemHeight = YL + int((NewHeight - (MyItemsPerPage * YL)) / MyItemsPerPage);
    }
    MyItemsPerPage = int(NewHeight / MyItemHeight);
    return MyItemHeight;
}

function bool InternalOnPreDraw(Canvas C)
{
    if (bInit || bNewContent || NewText != "")
    {
        bInit = false;
        UpdateNewCoordinates(C);
    }
    WinLeft = NewLeft;
    WinTop = NewTop;
    WinWidth = NewWidth;
    WinHeight = NewHeight;
    return true;
}

function bool InternalOnDraw(Canvas C)
{
    if (bScrollToBottom)
    {
        SetTopItem(ItemCount);
        bScrollToBottom = false;
    }
    return false;
}

function UpdateNewCoordinates(Canvas C)
{
    local float ScrollbarOffset;
    local float ActualRightPadding;

    NewWidth = MenuOwner.ActualWidth();
    NewHeight = MenuOwner.ActualHeight();
    NewLeft = LeftPadding * NewWidth;
    ActualRightPadding = RightPadding * NewWidth;
    ScrollbarOffset = FMax(0, MyScrollBar.ActualWidth() - ActualRightPadding);
    NewWidth -= NewLeft + ActualRightPadding + ScrollbarOffset;
    NewLeft += MenuOwner.ActualLeft();
    NewTop = TopPadding * NewHeight;
    NewHeight -= NewTop + (BottomPadding * NewHeight);
    NewTop += MenuOwner.ActualTop();
    GetSpacedItemHeight(C);
    UpdateItemCount(C);
    if (ItemCount > MyItemsPerPage)
    {
        ApplyVerticalAlignment(MyItemsPerPage * MyItemHeight);
    }
    else
    {
        ApplyVerticalAlignment(ItemCount * MyItemHeight);
        NewWidth += ScrollbarOffset;
    }
}

function ApplyVerticalAlignment(float ContentHeight)
{
    local float VerticalOffset;

    switch (VertAlign)
    {
        case TXTA_Left:
            VerticalOffset = 0;
            break;
        case TXTA_Center:
            if (ItemCount > 0)
            {
                VerticalOffset = FMax(0, (NewHeight - ContentHeight) / 2);
            }
            else
            {
                VerticalOffset = 0;
            }
            break;
        case TXTA_Right:
            VerticalOffset = FMax(0, NewHeight - FMax(MyItemHeight, ContentHeight));
            break;
    }
    NewHeight -= VerticalOffset;
    NewTop += VerticalOffset;
}

function UpdateItemCount(Canvas C)
{
    if (bNewContent)
    {
        ItemCount = 0;
        AddToItemCount(C, Content);
    }
    if (NewText != "")
    {
        bScrollToBottom = (ItemCount - 1) < (Top + MyItemsPerPage);
        AddToItemCount(C, NewText);
    }
}

function AddToItemCount(Canvas C, string Text)
{
    local Font SavedFont;
    local array<string> Lines;

    SavedFont = C.Font;
    C.Font = Style.Fonts[MenuState + 5 * FontScale].GetFont(C.ClipX);
    C.WrapStringToArray(
        Text, Lines, NewWidth - Style.BorderOffsets[0] - Style.BorderOffsets[2], Separator);
    C.Font = SavedFont;
    ItemCount += Lines.Length;
    Lines.Remove(0, Lines.Length);
}

defaultproperties
{
    VertAlign=TXTA_Left
    bAutoSpacing=false
    LineSpacing=0.002
    LeftPadding=0
    TopPadding=0
    RightPadding=0
    BottomPadding=0
    StyleName="HxSmallText"
    SelectedStyleName="HxSmallText"
    GetItemHeight=GetSpacedItemHeight
    OnPreDraw=InternalOnPreDraw
    OnDraw=InternalOnDraw
}
