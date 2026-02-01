class HxGUIVotingBaseListBox extends GUIMultiColumnListBox
    abstract;

var automated HxGUIFramedImage fi_Background;
var automated HxGUIVotingBaseList MyVotingBaseList;
var automated HxGUIVotingSearchBar SearchBar;

var float ScrollbarWidth;
var float FrameThickness;

delegate NotifySelection(GUIComponent Sender);
delegate NotifyVote();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyVotingBaseList = HxGUIVotingBaseList(List);
    MyVotingBaseList.FrameThickness = FrameThickness;
    MyVotingBaseList.OnChange = OnChangeList;
    MyVotingBaseList.OnDblClick = OnDbkClickList;
    HxGUIVertScrollBar(MyScrollBar).ForceRelativeWidth = ScrollbarWidth;
    HxGUIVertScrollBar(MyScrollBar).RightOffset = FrameThickness;
    fi_Background.FrameThickness = FrameThickness;
}

event ResolutionChanged(int NewX, int NewY)
{
    local int i;

    for (i = 0; i < HeaderColumnPerc.Length; ++i)
    {
        HeaderColumnPerc[i] = default.HeaderColumnPerc[i];
    }
    bInit = true;
    Super.ResolutionChanged(NewX, NewY);
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

function SetVRI(VotingReplicationInfo V)
{
    MyVotingBaseList.SetVRI(V);
}

function bool Refresh()
{
    return MyVotingBaseList.Refresh();
}

function int GetMapIndex()
{
    return MyVotingBaseList.GetMapIndex();
}

function string GetMapName()
{
    return MyVotingBaseList.GetMapName();
}

function SelectRandom()
{
    if (MyVotingBaseList.ItemCount > 0)
    {
        MyVotingBaseList.SetIndex(Rand(MyVotingBaseList.ItemCount));
    }
}

function bool IsEmpty()
{
    return MyVotingBaseList.ItemCount == 0;
}

function int SilentSetIndex(int NewIndex)
{
    return MyVotingBaseList.SilentSetIndex(NewIndex);
}

function Clear()
{
    if (SearchBar != None)
    {
        SearchBar.Clear();
    }
    MyVotingBaseList.Clear();
}

function bool InternalOnPreDraw(Canvas C)
{
    if (bInit)
    {
        if (SearchBar != None)
        {
            SearchBar.UpdateHeight(C);
            SearchBar.WinTop = SearchBar.RelativeHeight(ActualHeight() - SearchBar.ActualHeight());
            HxGUIVertScrollBar(MyScrollBar).BottomOffset = SearchBar.ActualHeight() / C.ClipY;
        }
        bInit = false;
        return true;
    }
    return false;
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

function bool OnHoverHeader(GUIComponent Sender)
{
    local int i;
    local float Left;
    local float Right;

    Left = Header.ActualLeft() + 5;
    for (i = 0; i < MyVotingBaseList.ColumnHeadingHints.Length; ++i)
    {
        Right = Left + MyVotingBaseList.ColumnWidths[i] - 10;
        if (Controller.MouseX > Left && Controller.MouseX < Right)
        {
            if (Header.Hint != MyVotingBaseList.ColumnHeadingHints[i])
            {
                Header.SetHint(MyVotingBaseList.ColumnHeadingHints[i]);
            }
            break;
        }
        left += MyVotingBaseList.ColumnWidths[i];
    }
    return false;
}

function bool OnPreDrawHeader(Canvas C)
{
    Header.WinHeight *= 1.2;
    return true;
}

function OnRenderedHeder(Canvas C)
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
    for (i = 0; i < MyVotingBaseList.ColumnHeadings.Length - 1; ++i)
    {
        C.SetPos(C.CurX + MyVotingBaseList.ColumnWidths[i], C.CurY);
        C.DrawTileStretched(fi_Background.FrameMaterial, Thickness, Height);
    }
    C.SetPos(C.CurX + MyVotingBaseList.ColumnWidths[i] - Thickness, C.CurY);
    C.DrawTileStretched(fi_Background.FrameMaterial, Thickness, Height);
}

defaultproperties
{
    Begin Object Class=GUIToolTip Name=HeaderToolTip
    End Object

    Begin Object Class=GUIMultiColumnListHeader Name=MyNewHeader
        StyleName="HxListHeader"
        BarStyleName="HxListHeader"
        ToolTip=HeaderToolTip
        OnHover=OnHoverHeader
        OnPreDraw=OnPreDrawHeader
        OnRendered=OnRenderedHeder
    End Object
    Header=MyNewHeader

    Begin Object Class=HxGUIFramedImage Name=BackgroundImage
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        RenderWeight=0.1
        ImageSources(0)=(Color=(R=28,G=64,B=130,A=255),Style=ISTY_Stretched)
        bScaleToParent=true
        bBoundToParent=true
    End Object
    fi_Background=BackgroundImage

    Begin Object Class=HxGUIVertScrollBar Name=NewTheScrollbar
        bScaleToParent=true
    End Object
    MyScrollBar=NewTheScrollbar

    ScrollbarWidth=0.017
    FrameThickness=0.001
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    bVisibleWhenEmpty=true
    OnPreDraw=InternalOnPreDraw
    OnKeyEvent=InternalOnKeyEvent
}
