class HxGUIVertScrollBar extends GUIVertScrollBar;

var bool bOutside;

function bool GripPreDraw(GUIComponent Sender)
{
    local float Width;

    Width = ActualWidth();
    if (bOutside)
    {
        WinLeft = ActualLeft() + Width;
    }
    WinTop = ActualTop() - Width;
    WinHeight = ActualHeight() + 2 * Width;
    MyDecreaseButton.SetVisibility(false);
    MyIncreaseButton.SetVisibility(false);
    return Super.GripPreDraw(Sender);
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

    MyScrollZone=ScrollZone
    MyDecreaseButton=UpBut
    MyIncreaseButton=DownBut
    MyGripButton=Grip
}
