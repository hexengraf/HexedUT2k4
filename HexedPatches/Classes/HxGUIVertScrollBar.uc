class HxGUIVertScrollBar extends GUIVertScrollBar;

var float ForceRelativeWidth;
var float FrameThickness;

function bool InternalOnPreDraw(Canvas C)
{
    local float MyWidth;
    local float OwnerWidth;
    local float FrameOffset;

    FrameOffset = Round(FrameThickness * C.ClipY);
    if (ForceRelativeWidth > 0)
    {
        OwnerWidth = MenuOwner.ActualWidth();
        MyWidth = ForceRelativeWidth * OwnerWidth;
        WinWidth = RelativeWidth(MyWidth);
        WinLeft = RelativeLeft(MenuOwner.ActualLeft() + OwnerWidth - MyWidth - FrameOffset);
    }
    else
    {
        MyWidth = ActualWidth();
        WinLeft = RelativeLeft(ActualLeft() - FrameOffset);
    }
    WinTop = MyList.ActualTop() - MyWidth + FrameOffset;
    WinHeight = MyList.ActualHeight() + 2 * MyWidth - (2 * FrameOffset);
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
    Begin Object Class=GUIVertScrollZone Name=ScrollZone
        StyleName="HxScrollZone"
        OnScrollZoneClick=ZoneClick
    End Object

    Begin Object Class=GUIVertScrollButton Name=UpBut
    End Object

    Begin Object Class=GUIVertScrollButton Name=DownBut
        bIncreaseButton=true
    End Object

    Begin Object Class=GUIVertGripButton Name=Grip
        StyleName="HxScrollGrip"
        OnMousePressed=GripPressed
    End Object

    ForceRelativeWidth=0
    FrameThickness=0
    MyScrollZone=ScrollZone
    MyDecreaseButton=UpBut
    MyIncreaseButton=DownBut
    MyGripButton=Grip
    OnPreDraw=InternalOnPreDraw
}
