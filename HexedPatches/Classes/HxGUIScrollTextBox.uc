class HxGUIScrollTextBox extends GUIScrollTextBox;

var automated GUIImage i_Background;

var eTextAlign VertAlign;
var float HorizontalPadding;
var float VerticalPadding;
var float ScrollBarWidth;
var Color BackgroundColor;

var bool bHasNewContent;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyScrollBar.WinWidth = ScrollBarWidth;
    if (HorizontalPadding == -1)
    {
        HorizontalPadding = MyScrollBar.WinWidth;
    }
    i_Background.ImageColor = BackgroundColor;
}

function bool InternalOnPreDraw(Canvas C)
{
    AlignText();
    return false;
}

function bool InternalOnDraw(Canvas C)
{
    RestoreStyleOffsets();
    bHasNewContent = false;
    return false;
}

function AlignText()
{
    local float ContentHeight;
    local float MaxWidth;
    local float MaxHeight;
    local float VerticalOffset;
    local float HorizontalOffset;

    MaxWidth = ActualWidth();
    MaxHeight = ActualHeight();
    VerticalOffset = VerticalPadding * MaxHeight;
    HorizontalOffset = HorizontalPadding * MaxWidth;
    Style.BorderOffsets[0] = HorizontalOffset;
    Style.BorderOffsets[1] = VerticalOffset;
    Style.BorderOffsets[2] = HorizontalOffset;
    Style.BorderOffsets[3] = VerticalOffset;

    if (!bHasNewContent)
    {
        ContentHeight = Max(MyScrollText.ItemCount, 1) * MyScrollText.ItemHeight;

        if ((ContentHeight + 2 * VerticalOffset) > MaxHeight)
        {
            Style.BorderOffsets[2] = Max(0, Style.BorderOffsets[2] - MyScrollBar.ActualWidth());
        }
        else if (VertAlign == TXTA_Center)
        {
            Style.BorderOffsets[1] = (MaxHeight - ContentHeight) / 2;
            Style.BorderOffsets[3] = Style.BorderOffsets[1];
        }
    }
}

function RestoreStyleOffsets()
{
    Style.BorderOffsets[0] = Style.default.BorderOffsets[0];
    Style.BorderOffsets[1] = Style.default.BorderOffsets[1];
    Style.BorderOffsets[2] = Style.default.BorderOffsets[2];
    Style.BorderOffsets[3] = Style.default.BorderOffsets[3];
}

function SetContent(string NewContent, optional string sep)
{
    bHasNewContent = true;
    Super.SetContent(NewContent, sep);
}

defaultproperties
{
     Begin Object Class=GUIImage Name=Background
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        Image=Material'2K4Menus.NewControls.NewFooter'
        Y1=2
        ImageStyle=ISTY_Stretched
        bScaleToParent=true
        bBoundToParent=true
        RenderWeight=0.1
    End Object
    i_Background=Background

    Begin Object Class=HxGUIVertScrollBar Name=NewTheScrollbar
        bScaleToParent=true
        bVisible=false
    End Object
    MyScrollBar=NewTheScrollbar

    VertAlign=TXTA_Left
    HorizontalPadding=-1
    VerticalPadding=0.05
    ScrollBarWidth=0.035
    BackgroundColor=(R=255,G=255,B=255,A=192)
    OnPreDraw=InternalOnPreDraw
    OnDraw=InternalOnDraw
}
