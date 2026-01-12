class HxGUIVotingBaseListBox extends GUIMultiColumnListBox;

var automated GUIImage i_Background;
var automated HxGUIVotingBaseList MyVoteBaseList;

var bool bScrollBarVisible;
var float SizeShiftScale;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyVoteBaseList = HxGUIVotingBaseList(List);
    MyVoteBaseList.OnDblClick = InternalOnDblClick;
    SizeShiftScale = 1.0 - HxGUIVertScrollBar(MyScrollBar).WidthScale;
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
    if (List.ItemCount > List.ItemsPerPage)
    {
        if (!bScrollBarVisible)
        {
            i_Background.WinWidth = ActualWidth();
            WinWidth = i_Background.WinWidth + (Header.ActualHeight() * SizeShiftScale);
            bScrollBarVisible = true;
            return true;
        }
    }
    else if (bScrollBarVisible)
    {
        WinWidth = i_Background.WinWidth;
        bScrollBarVisible = false;
        return true;
    }
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

    Begin Object Class=HxGUIVertScrollBar Name=NewTheScrollbar
        WidthScale=0.6
        bScaleToParent=true
    End Object
    MyScrollBar=NewTheScrollbar

    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    bVisibleWhenEmpty=true
    OnPreDraw=InternalOnPreDraw
    OnKeyEvent=InternalOnKeyEvent
}
