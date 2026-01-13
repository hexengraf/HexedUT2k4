class HxGUIVertScrollBar extends GUIVertScrollBar;

var float ForceRelativeWidth;

function bool GripPreDraw(GUIComponent Sender)
{
    local float MyWidth;
    local float OwnerWidth;

    if (ForceRelativeWidth > 0)
    {
        OwnerWidth = MenuOwner.ActualWidth();
        MyWidth = ForceRelativeWidth * OwnerWidth;
        WinWidth = RelativeWidth(MyWidth);
        WinLeft = RelativeLeft(MenuOwner.ActualLeft() + OwnerWidth - MyWidth);
    }
    else
    {
        MyWidth = ActualWidth();
    }
    WinTop = MyList.ActualTop() - MyWidth;
    WinHeight = MyList.ActualHeight() + 2 * MyWidth;
    MyDecreaseButton.SetVisibility(false);
    MyIncreaseButton.SetVisibility(false);
    Super.GripPreDraw(Sender);
    return true;
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
    MyScrollZone=ScrollZone
    MyDecreaseButton=UpBut
    MyIncreaseButton=DownBut
    MyGripButton=Grip
}
