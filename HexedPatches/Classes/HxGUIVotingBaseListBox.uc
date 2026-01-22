class HxGUIVotingBaseListBox extends GUIMultiColumnListBox
    abstract;

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
    local float Height;
    local int i;

    C.SetDrawColor(255, 255, 255, 78);
    C.Style = 5;
    Thickness = Round(0.0015 * C.ClipY);
    Height = Header.ActualHeight() - Thickness;
    C.SetPos(Header.ActualLeft(), Header.ActualTop() + Height);
    C.DrawTileStretched(Material'engine.WhiteSquareTexture', Header.ActualWidth(), Thickness);
    C.SetPos(C.CurX - (Thickness / 2), C.CurY - Height);

    for (i = 0; i < MyVoteBaseList.ColumnHeadings.Length - 1; ++i)
    {
        C.SetPos(C.CurX + MyVoteBaseList.ColumnWidths[i], C.CurY);
        C.DrawTileStretched(Material'engine.WhiteSquareTexture', Thickness, Height);
    }
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

    Begin Object Class=GUIImage Name=Background
        WinLeft=0
        WinTop=0.02
        WinWidth=1
        WinHeight=0.98
        Image=Material'2K4Menus.NewControls.NewFooter'
        Y1=10
        ImageColor=(R=255,G=255,B=255,A=255)
        // Image=Material'engine.WhiteSquareTexture'
        // ImageColor=(R=36,G=70,B=136,A=255)
        // ImageColor=(R=37,G=71,B=139,A=255)
        ImageStyle=ISTY_Stretched
        bScaleToParent=true
        bBoundToParent=true
        RenderWeight=0.2
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
