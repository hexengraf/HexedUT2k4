class HxGUIVotingBaseListBox extends GUIMultiColumnListBox;

var automated GUIImage i_Background;
var automated HxGUIVotingBaseList MyVoteBaseList;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyVoteBaseList = HxGUIVotingBaseList(List);
    MyVoteBaseList.OnDblClick = InternalOnDblClick;
}

function PopulateList(VotingReplicationInfo MVRI)
{
    MyVoteBaseList.PopulateList(MVRI);
}

function int GetMapIndex()
{
    return MyVoteBaseList.GetMapIndex();
}

function string GetSelectedMapName()
{
    return MyVoteBaseList.GetSelectedMapName();
}

function Clear()
{
    MyVoteBaseList.Clear();
}

function bool InternalOnPreDraw(Canvas C)
{
    i_Background.WinTop = Header.ActualHeight();
    i_Background.WinWidth = List.WinWidth;
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

function bool InternalOnDblClick(GUIComponent Sender)
{
    if (HxGUIVotingPage(PageOwner) != None)
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

    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    bVisibleWhenEmpty=true
    OnPreDraw=InternalOnPreDraw
    OnKeyEvent=InternalOnKeyEvent
}
