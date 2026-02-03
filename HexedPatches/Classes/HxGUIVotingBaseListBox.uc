class HxGUIVotingBaseListBox extends GUIMultiColumnListBox
    abstract
    DependsOn(HxFavorites);

var automated HxGUIFramedImage fi_Background;
var automated HxGUIVotingBaseList MyBaseList;
var automated HxGUIVotingSearchBar SearchBar;

var float ScrollbarWidth;
var float FrameThickness;

delegate OnTagUpdated(int MapIndex, HxFavorites.EHxTag NewTag);
delegate NotifySelection(GUIComponent Sender);
delegate NotifyVote();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    MyBaseList = HxGUIVotingBaseList(List);
    MyBaseList.FrameThickness = FrameThickness;
    MyBaseList.OnTagUpdated = InternalOnTagUpdated;
    MyBaseList.OnChange = OnChangeList;
    MyBaseList.OnDblClick = OnDbkClickList;
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
    MyBaseList.SetVRI(V);
}

function bool Refresh()
{
    return MyBaseList.Refresh();
}

function int GetMapIndex()
{
    return MyBaseList.GetMapIndex();
}

function string GetMapName()
{
    return MyBaseList.GetMapName();
}

function SelectRandom()
{
    if (MyBaseList.ItemCount > 0)
    {
        MyBaseList.SetIndex(Rand(MyBaseList.ItemCount));
    }
}

function bool IsEmpty()
{
    return MyBaseList.ItemCount == 0;
}

function int SilentSetIndex(int NewIndex)
{
    return MyBaseList.SilentSetIndex(NewIndex);
}

function UpdateMapTag(int MapIndex, HxFavorites.EHxTag NewTag)
{
    MyBaseList.UpdateMapTag(MapIndex, NewTag);
}

function Clear()
{
    if (SearchBar != None)
    {
        SearchBar.Clear();
    }
    MyBaseList.Clear();
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

function InternalOnTagUpdated(int MapIndex, HxFavorites.EHxTag NewTag)
{
    OnTagUpdated(MapIndex, NewTag);
}

function bool OnHoverHeader(GUIComponent Sender)
{
    local float Left;
    local float Right;
    local bool bOnResizing;
    local int i;

    Left = Header.ActualLeft() + 5;
    for (i = 0; i < Header.MyList.ColumnHeadingHints.Length; ++i)
    {
        Right = Left + Header.MyList.ColumnWidths[i] - 10;
        if (Controller.MouseX > Left && Controller.MouseX < Right)
        {
            if (Header.Hint != Header.MyList.ColumnHeadingHints[i])
            {
                Header.SetHint(Header.MyList.ColumnHeadingHints[i]);
            }
            break;
        }
        if (Controller.MouseX <= Right + 10 && Controller.MouseX >= Right)
        {
            bOnResizing = true;
            break;
        }
        Left += Header.MyList.ColumnWidths[i];
    }
    if (bOnResizing && i > 0 && i < Header.MyList.ColumnHeadingHints.Length - 1)
    {
        Header.MouseCursorIndex = 5;
    }
    else
    {
        Header.MouseCursorIndex = 0;
    }
    return true;
}

function bool OnPreDrawHeader(Canvas C)
{
    Header.WinHeight *= 1.2;
    return true;
}

function OnRenderedHeder(Canvas C)
{
    local float Thickness;
    local float Left;
    local float Top;
    local float Width;
    local float Height;
    local int i;

    C.Style = 5;
    C.DrawColor = fi_Background.FrameColor;
    Thickness = Round(FrameThickness * C.ClipY);
    Left = Header.ActualLeft();
    Top = Header.ActualTop();
    Width = Header.ActualWidth();
    Height = Header.ActualHeight() - Thickness;
    C.SetPos(Left, Top + Height);
    C.DrawTileStretched(fi_Background.FrameMaterial, Width, Thickness);
    C.SetPos(C.CurX, C.CurY - Height);
    C.DrawTileStretched(fi_Background.FrameMaterial, Width, Thickness);
    C.DrawTileStretched(fi_Background.FrameMaterial, Thickness, Height);
    for (i = 0; i < List.ColumnHeadings.Length - 1; ++i)
    {
        C.SetPos(C.CurX + List.ColumnWidths[i], C.CurY);
        C.DrawTileStretched(fi_Background.FrameMaterial, Thickness, Height);
    }
    C.SetPos(C.CurX + List.ColumnWidths[i] - Thickness, C.CurY);
    C.DrawTileStretched(fi_Background.FrameMaterial, Thickness, Height);
    Height += Thickness;
    Top += Height * 0.15;
    Height = Round(Height * 0.75);
    Left += (List.ColumnWidths[0] - Height) / 2 + (Thickness / 2);
    class'HxFavorites'.static.DrawTag(C, HX_TAG_Like, Left, Top, Height);
}

function bool OnCapturedMouseMoveHeader(float deltaX, float deltaY)
{
    if (Header.SizingCol == 0)
    {
        Header.MenuState = Header.LastMenuState;
    }
    return false;
}

defaultproperties
{
    Begin Object Class=GUIToolTip Name=HeaderToolTip
    End Object

    Begin Object Class=GUIMultiColumnListHeader Name=MyNewHeader
        StyleName="HxListHeader"
        BarStyleName="HxListHeader"
        ToolTip=HeaderToolTip
        OnCapturedMouseMove=OnCapturedMouseMoveHeader
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

    HeaderColumnPerc(0)=0.05
    ScrollbarWidth=0.017
    FrameThickness=0.001
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    bVisibleWhenEmpty=true
    OnPreDraw=InternalOnPreDraw
    OnKeyEvent=InternalOnKeyEvent
}
