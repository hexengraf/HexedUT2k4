class HxGUIMapVoteBaseListBox extends GUIMultiColumnListBox;

var automated GUIImage i_Background;
var automated HxGUIMapVoteBaseList MyVoteBaseList;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyVoteBaseList = HxGUIMapVoteBaseList(List);
}

function PopulateList(VotingReplicationInfo MVRI)
{
    MyVoteBaseList.PopulateList(MVRI);
}

function int GetSelectedMapIndex()
{
    return MyVoteBaseList.GetSelectedMapIndex();
}

function string GetSelectedMapName()
{
    return MyVoteBaseList.GetSelectedMapName();
}

function Clear()
{
    MyVoteBaseList.Clear();
}

function LevelChanged()
{
    Clear();
}

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

    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    bVisibleWhenEmpty=true
    OnPreDraw=InternalOnPreDraw
}
