class HxGUIVotingBaseListBox extends GUIMultiColumnListBox
    abstract;

var automated HxGUIFramedImage fi_Background;
var automated HxGUIVotingBaseList MyVoteBaseList;

var float ScrollbarWidth;
var float FrameThickness;

delegate NotifySelection(GUIComponent Sender);
delegate NotifyVote();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyVoteBaseList = HxGUIVotingBaseList(List);
    MyVoteBaseList.FrameThickness = FrameThickness;
    MyVoteBaseList.OnChange = OnChangeList;
    MyVoteBaseList.OnDblClick = OnDbkClickList;
    HxGUIVertScrollBar(MyScrollBar).ForceRelativeWidth = ScrollbarWidth;
    HxGUIVertScrollBar(MyScrollBar).FrameThickness = FrameThickness;
    fi_Background.FrameThickness = FrameThickness;
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

function bool InternalOnKeyEvent(out byte Key, out byte KeyState, float Delta)
{
    if (EInputKey(Key) == IK_Enter && HxGUIVotingPage(PageOwner) != None)
    {
        NotifyVote();
        return true;
    }
    return false;
}

function bool OnHeaderPreDraw(Canvas C)
{
    Header.WinHeight *= 1.2;
    return true;
}

function OnHeaderRendered(Canvas C)
{
    local float Thickness;
    local float Width;
    local float Height;
    local int i;

    C.Style = 5;
    C.DrawColor = fi_Background.FrameColor;
    Thickness = Round(FrameThickness * C.ClipY);
    Width = Header.ActualWidth();
    Height = Header.ActualHeight() - Thickness;
    C.SetPos(Header.ActualLeft(), Header.ActualTop() + Height);
    C.DrawTileStretched(fi_Background.FrameMaterial, Width, Thickness);
    C.SetPos(C.CurX, C.CurY - Height);
    C.DrawTileStretched(fi_Background.FrameMaterial, Width, Thickness);
    C.DrawTileStretched(fi_Background.FrameMaterial, Thickness, Height);
    for (i = 0; i < MyVoteBaseList.ColumnHeadings.Length - 1; ++i)
    {
        C.SetPos(C.CurX + MyVoteBaseList.ColumnWidths[i], C.CurY);
        C.DrawTileStretched(fi_Background.FrameMaterial, Thickness, Height);
    }
    C.SetPos(C.CurX + MyVoteBaseList.ColumnWidths[i] - Thickness, C.CurY);
    C.DrawTileStretched(fi_Background.FrameMaterial, Thickness, Height);
}

defaultproperties
{
    Begin Object Class=GUIMultiColumnListHeader Name=MyNewHeader
        StyleName="HxListHeader"
        BarStyleName="HxListHeader"
        OnPreDraw=OnHeaderPreDraw
        OnRendered=OnHeaderRendered
    End Object
    Header=MyNewHeader

    Begin Object Class=HxGUIFramedImage Name=Background
        WinLeft=0
        WinTop=0.02
        WinWidth=1
        WinHeight=0.98
        RenderWeight=0.1
        ImageColor=(R=38,G=59,B=126,A=255)
        bScaleToParent=true
        bBoundToParent=true
    End Object
    fi_Background=Background

    Begin Object Class=HxGUIVertScrollBar Name=NewTheScrollbar
        bScaleToParent=true
    End Object
    MyScrollBar=NewTheScrollbar

    ScrollbarWidth=0.02
    FrameThickness=0.001
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    bVisibleWhenEmpty=true
    OnKeyEvent=InternalOnKeyEvent
}
