class HxGUIVertScrollBar extends GUIVertScrollBar;

var string GripStyleName;
var string ZoneStyleName;
var float StandardWidth;

function bool InternalOnPreDraw(Canvas C)
{
    local float ButtonOffset;

    if (StandardWidth > 0)
    {
        WinWidth = (StandardWidth * C.ClipY);
        WinLeft = MenuOwner.ActualLeft() + MenuOwner.ActualWidth() - WinWidth;
    }
    ButtonOffset = MyDecreaseButton.ActualHeight();
    WinTop = MyList.ActualTop() - ButtonOffset;
    ButtonOffset += MyIncreaseButton.ActualHeight();
    WinHeight = MyList.ActualHeight() + ButtonOffset;
    MyDecreaseButton.SetVisibility(false);
    MyIncreaseButton.SetVisibility(false);
    Super.GripPreDraw(Self);
    return true;
}

function bool OnPreDrawGripButton(Canvas C)
{
    local HxGUIStyles ZoneStyle;
    local float LeftOffset;
    local float TopOffset;

    ZoneStyle = HxGUIStyles(MyScrollZone.Style);
    if (ZoneStyle != None)
    {
        LeftOffset = ZoneStyle.ActualLeftFrameThickness();
        TopOffset = ZoneStyle.ActualTopFrameThickness();
        MyGripButton.WinLeft = MyGripButton.ActualLeft() - LeftOffset;
        MyGripButton.WinTop = MyGripButton.ActualTop() + TopOffset;
        MyGripButton.WinWidth = MyGripButton.ActualWidth() - LeftOffset
            - ZoneStyle.ActualRightFrameThickness();
        MyGripButton.WinHeight = MyGripButton.ActualHeight() - TopOffset
            - ZoneStyle.ActualBottomFrameThickness();
    }
    return true;
}

function ZoneClick(float Delta)
{
    GripPos = Delta;
    if (MyList != none)
    {
        MyList.SetTopItem(GripPos * (MyList.ItemCount - MyList.ItemsPerPage));
        ItemCount = MyList.ItemCount;
    }
    CurPos = (ItemCount - ItemsPerPage) * GripPos;
    PositionChanged(CurPos);
}

function InternalOnCreateComponent(GUIComponent NewComponent, GUIComponent Sender)
{
    if (NewComponent.IsA('GUIVertGripButton'))
    {
        NewComponent.StyleName = GripStyleName;
    }
    else if (NewComponent.IsA('GUIVertScrollZone'))
    {
        NewComponent.StyleName = ZoneStyleName;
    }
}

defaultproperties
{
    Begin Object class=GUIVertScrollZone Name=NewScrollZone
        OnScrollZoneClick=ZoneClick
    End Object

    Begin Object class=GUIVertScrollButton Name=NewUpBut
    End Object

    Begin Object class=GUIVertScrollButton Name=NewDownBut
    End Object

    Begin Object class=GUIVertGripButton Name=NewGrip
        OnPreDraw=OnPreDrawGripButton
        OnMousePressed=GripPressed
    End Object

    GripStyleName="HxScrollGrip"
    ZoneStyleName="HxList"
    StandardWidth=0
    MyScrollZone=NewScrollZone
    MyDecreaseButton=NewUpBut
    MyIncreaseButton=NewDownBut
    MyGripButton=NewGrip
    OnPreDraw=InternalOnPreDraw
    OnCreateComponent=InternalOnCreateComponent
}
