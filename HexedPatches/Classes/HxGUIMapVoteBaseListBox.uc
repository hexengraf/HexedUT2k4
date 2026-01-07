class HxGUIMapVoteBaseListBox extends GUIMultiColumnListBox;

var automated GUIImage i_Background;

var float LeftPadding;
var float VerticalPadding;

function bool InternalOnPreDraw(Canvas C)
{
    Style.BorderOffsets[0] = LeftPadding * ActualWidth();
    Style.BorderOffsets[1] = VerticalPadding * ActualHeight();
    Style.BorderOffsets[3] = Style.BorderOffsets[1];
    i_Background.WinTop = Header.ActualHeight();
    i_Background.WinWidth = List.WinWidth;
    i_Background.WinHeight = List.WinHeight;
    return false;
}

function bool InternalOnDraw(Canvas C)
{
    Style.BorderOffsets[0] = Style.default.BorderOffsets[0];
    Style.BorderOffsets[1] = Style.default.BorderOffsets[1];
    Style.BorderOffsets[3] = Style.default.BorderOffsets[3];
    return false;
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
        ImageColor=(R=255,G=255,B=255,A=192)
        ImageStyle=ISTY_Stretched
        bScaleToParent=true
        bBoundToParent=true
        RenderWeight=0.1
    End Object
    i_Background=Background

    StyleName="HxSimpleList"
    SelectedStyleName="ListSelection"
    bVisibleWhenEmpty=true
    LeftPadding=0.007
    VerticalPadding=0.007
    OnPreDraw=InternalOnPreDraw
    OnDraw=InternalOnDraw
}
