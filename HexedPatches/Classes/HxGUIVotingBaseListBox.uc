class HxGUIVotingBaseListBox extends GUIMultiColumnListBox;

var automated GUIImage i_Background;
var automated HxGUIVotingBaseList MyVoteBaseList;

var float ScrollbarWidth;

delegate NotifySelection(GUIComponent Sender);
delegate NotifyVote();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyVoteBaseList = HxGUIVotingBaseList(List);
    MyVoteBaseList.OnChange = OnChangeList;
    MyVoteBaseList.OnDblClick = OnDbkClickList;
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

event MenuStateChange(eMenuState NewState)
{
    Super.MenuStateChange(NewState);

    if (NewState == MSAT_Focused)
    {
        NotifySelection(Self);
    }
}

function OnChangeList(GUIComponent Sender)
{
    NotifySelection(Self);
}

function bool OnDbkClickList(GUIComponent Sender)
{
    // NotifySelection(Self);
    NotifyVote();
    return true;
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

function SelectRandom()
{
    if (MyVoteBaseList.ItemCount > 0)
    {
        MyVoteBaseList.SetIndex(Rand(MyVoteBaseList.ItemCount));
    }
}

function bool IsEmpty()
{
    return MyVoteBaseList.ItemCount == 0;
}

function Clear()
{
    MyVoteBaseList.Clear();
}

function bool OnBackgroundPreDraw(Canvas C)
{
    i_Background.WinTop = i_Background.RelativeTop(MyList.ActualTop());
    i_Background.WinHeight = 1 - i_Background.WinTop;
    return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte KeyState, float Delta)
{
    if (EInputKey(Key) == IK_Enter && HxGUIVotingPage(PageOwner) != None)
    {
        NotifyVote();
        return true;
    }
    return false;
}

defaultproperties
{
    Begin Object Class=GUIImage Name=Background
        WinLeft=0
        WinTop=0.02
        WinWidth=1
        WinHeight=0.98
        Image=Material'2K4Menus.NewControls.NewFooter'
        Y1=10
        ImageColor=(R=255,G=255,B=255,A=255)
        ImageStyle=ISTY_Stretched
        bScaleToParent=true
        bBoundToParent=true
        RenderWeight=0.2
        OnPreDraw=OnBackgroundPreDraw
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
    OnKeyEvent=InternalOnKeyEvent
}
