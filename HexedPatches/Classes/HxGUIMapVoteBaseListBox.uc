class HxGUIMapVoteBaseListBox extends GUIMultiColumnListBox;

var automated GUIImage i_Background;

function bool InternalOnPreDraw(Canvas C)
{
    i_Background.WinTop = Header.ActualHeight();
    i_Background.WinWidth = List.WinWidth;
    i_Background.WinHeight = List.WinHeight;
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
    OnPreDraw=InternalOnPreDraw
}
