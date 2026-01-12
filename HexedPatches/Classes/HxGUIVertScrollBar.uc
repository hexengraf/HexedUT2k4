class HxGUIVertScrollBar extends GUIVertScrollBar;

var float WidthScale;
var bool bOutside;

function bool GripPreDraw(GUIComponent Sender)
{
    if (WidthScale != 1.0)
    {
        WinWidth = ActualWidth() * WidthScale;
    }
    else
    {
        WinWidth = ActualWidth();
    }
    if (bOutside)
    {
        WinLeft = ActualLeft() + WinWidth;
    }
    WinTop = ActualTop() - WinWidth;
    WinHeight = ActualHeight() + 2 * WinWidth;
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

    WidthScale=1.0
    bOutside=false
    MyScrollZone=ScrollZone
    MyDecreaseButton=UpBut
    MyIncreaseButton=DownBut
    MyGripButton=Grip
}
