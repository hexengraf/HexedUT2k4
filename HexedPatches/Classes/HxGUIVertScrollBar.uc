class HxGUIVertScrollBar extends GUIVertScrollBar;

var float ForceRelativeWidth;
var float TopOffset;
var float RightOffset;
var float BottomOffset;

function bool InternalOnPreDraw(Canvas C)
{
    local float MyWidth;
    local float OwnerWidth;
    local float TopPadding;
    local float RightPadding;

    TopPadding = Round(TopOffset * C.ClipY);
    RightPadding = Round(RightOffset * C.ClipY);
    if (ForceRelativeWidth > 0)
    {
        OwnerWidth = MenuOwner.ActualWidth();
        MyWidth = ForceRelativeWidth * OwnerWidth;
        WinWidth = RelativeWidth(MyWidth);
        WinLeft = RelativeLeft(MenuOwner.ActualLeft() + OwnerWidth - MyWidth - RightPadding);
    }
    else
    {
        MyWidth = ActualWidth();
        WinLeft = RelativeLeft(ActualLeft() - RightPadding);
    }
    WinTop = MyList.ActualTop() - MyWidth + TopPadding;
    WinHeight = MyList.ActualHeight() + 2 * MyWidth - TopPadding - Round(BottomOffset * C.ClipY);
    MyDecreaseButton.SetVisibility(false);
    MyIncreaseButton.SetVisibility(false);
    return Super.GripPreDraw(Self);
}

function ZoneClick(float Delta)
{
    GripPos = Delta;
    if (MyList != none)
    {
        MyList.SetTopItem(Round(GripPos * (MyList.ItemCount - MyList.ItemsPerPage)));
        ItemCount = MyList.ItemCount;
    }
    CurPos = Round((ItemCount - ItemsPerPage) * GripPos);
    PositionChanged(CurPos);
}

defaultproperties
{
    Begin Object Class=GUIVertScrollZone Name=NewScrollZone
        StyleName="HxScrollZone"
        OnScrollZoneClick=ZoneClick
    End Object

    Begin Object Class=GUIVertScrollButton Name=NewUpBut
    End Object

    Begin Object Class=GUIVertScrollButton Name=NewDownBut
        bIncreaseButton=true
    End Object

    Begin Object Class=GUIVertGripButton Name=NewGrip
        StyleName="HxScrollGrip"
        OnMousePressed=GripPressed
    End Object

    ForceRelativeWidth=0
    TopOffset=0
    RightOffset=0
    BottomOffset=0
    MyScrollZone=NewScrollZone
    MyDecreaseButton=NewUpBut
    MyIncreaseButton=NewDownBut
    MyGripButton=NewGrip
    OnPreDraw=InternalOnPreDraw
}
