class HxGUIVotingBaseListBox extends GUIMultiColumnListBox;

var automated GUIImage i_Background;
var automated HxGUIVotingBaseList MyVoteBaseList;

var float ScrollbarWidth;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyVoteBaseList = HxGUIVotingBaseList(List);
    HxGUIVertScrollBar(MyScrollBar).ForceRelativeWidth = ScrollbarWidth;
}

event ResolutionChanged(int NewX, int NewY)
{
    local int i;

    for (i = 0; i < HeaderColumnPerc.Length; ++i)
    {
        HeaderColumnPerc[i] = default.HeaderColumnPerc[i];
    }
    Super.ResolutionChanged(NewX, NewY);
}

function PopulateList(VotingReplicationInfo MVRI)
{
    MyVoteBaseList.PopulateList(MVRI);
}

function int GetMapIndex()
{
    return MyVoteBaseList.GetMapIndex();
}

function string GetMapName()
{
    return MyVoteBaseList.GetMapName();
}

function Clear()
{
    MyVoteBaseList.Clear();
}

function bool InternalOnPreDraw(Canvas C)
{
    i_Background.WinTop = Header.ActualHeight();
    i_Background.WinHeight = List.WinHeight;
    return false;
}

function bool InternalOnKeyEvent(out byte Key, out byte KeyState, float Delta)
{
    if (EInputKey(Key) == IK_Enter && HxGUIVotingPage(PageOwner) != None)
    {
        HxGUIVotingPage(PageOwner).SendVoteFrom(Self);
        return true;
    }
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
        Y1=10
        ImageColor=(R=255,G=255,B=255,A=255)
        ImageStyle=ISTY_Stretched
        bScaleToParent=true
        bBoundToParent=true
        RenderWeight=0.1
    End Object
    i_Background=Background

    Begin Object Class=HxGUIVertScrollBar Name=NewTheScrollbar
        bScaleToParent=true
    End Object
    MyScrollBar=NewTheScrollbar

    ScrollbarWidth=0.02
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    bVisibleWhenEmpty=true
    OnPreDraw=InternalOnPreDraw
    OnKeyEvent=InternalOnKeyEvent
}
