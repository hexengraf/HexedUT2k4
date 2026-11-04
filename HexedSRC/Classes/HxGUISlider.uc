class HxGUISlider extends GUIComponent;

var float MinValue;
var float MaxValue;
var float Value;
var float MarkerWidth;
var bool bIntSlider;
var bool bShowMarker;
var bool bReadOnly;
var bool bShowValueTooltip;
var string BarStyleName;
var string FillStyleName;

var private GUIStyles FillStyle;
var private GUIStyles BarStyle;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    FillStyle = Controller.GetStyle(FillStyleName, FontScale);
    BarStyle = Controller.GetStyle(BarStyleName, FontScale);
    if (!bShowMarker)
    {
    }
}

function bool InternalOnDraw(Canvas C)
{
    local float Left;
    local float Top;
    local float Width;
    local float Height;
    local float FillWidth;
    local float MarkTop;
    local float MarkWidth;
    local float MarkHeight;
    local float Perc;

    Perc = (Value - MinValue) / (MaxValue - MinValue);
    MarkWidth = MarkerWidth * C.SizeY;
    Height = ActualHeight();
    Left = ActualLeft();
    Top = ActualTop();
    MarkTop = Top + Height * 0.2;
    Top += Height * 0.35;
    Width = ActualWidth();
    FillWidth = (Width - MarkWidth) * Perc;
    MarkHeight = Height * 0.6;
    Height = Height * 0.3;
    BarStyle.Draw(C, MenuState, Left, Top, Width, Height);
    FillStyle.Draw(C, MenuState, Left, Top, FillWidth, Height);
    Style.Draw(C, MenuState, Left + FillWidth, MarkTop, MarkWidth, MarkHeight);
    return false;
}

function bool InternalCapturedMouseMove(float deltaX, float deltaY)
{
    local float Perc;

    if (bReadOnly)
    {
        return true;
    }
    if (Controller.MouseX >= Bounds[0] && Controller.MouseX<=Bounds[2])
    {
        if (bShowMarker)
        {
            Perc = FClamp(
                (Controller.MouseX - ActualLeft() + (MarkerWidth / 2))
                    / (ActualWidth() - MarkerWidth),
                0.0,
                1.0);
        }
        else
        {
            Perc = FClamp((Controller.MouseX - ActualLeft()) / (ActualWidth()), 0.0, 1.0);
        }
        Value = ((MaxValue - MinValue) * Perc) + MinValue;
        if (bIntSlider)
        {
            Value = round(Value);
        }
    }
    else if (Controller.MouseX < Bounds[0])
    {
        Value = MinValue;
    }
    else if (Controller.MouseX > Bounds[2])
    {
        Value = MaxValue;
    }
    Value = FClamp(Value, MinValue, MaxValue);
    if (bShowValueTooltip)
    {
        ToolTip.SetTip(GetValueString());
    }
    return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    if (!bReadOnly)
    {
        if (State == 1)
        {
            if (Key == 0x25)
            {
                if (bIntSlider)
                {
                    Adjust(-1);
                }
                else
                {
                    Adjust(-0.01);
                }
                return true;
            }
            if (Key == 0x27)
            {
                if (bIntSlider)
                {
                    Adjust(1);
                }
                else
                {
                    Adjust(0.01);
                }
                return true;
            }
        }
    }
    return false;
}

function float SetValue(float NewValue)
{
    Value = FClamp(NewValue, MinValue, MaxValue);
    if (bIntSlider)
    {
        Value = Round(Value);
    }
    return Value;
}

function Adjust(float Amount)
{
    local float Perc;

    Perc = (Value - MinValue) / (MaxValue - MinValue);
    Perc += Amount;
    Perc = FClamp(Perc, 0.0, 1.0);
    Value = FClamp(((MaxValue - MinValue) * Perc) + MinValue, MinValue, MaxValue);
    OnChange(Self);
}

function bool InternalOnClick(GUIComponent Sender)
{
    if (bShowValueToolTip)
    {
        RevertTooltipToNormal();
    }
    OnChange(self);
    return true;
}

function InternalOnMousePressed(GUIComponent Sender,bool RepeatClick)
{
    if (bShowValueTooltip)
    {
        ModifyTooltipForDragging();
    }
    InternalCapturedMouseMove(0, 0);
}

function InternalOnMouseRelease(GUIComponent Sender)
{
    InternalCapturedMouseMove(0, 0);
}

function SetReadOnly(bool b)
{
    bReadOnly = b;
}

event float GetMarkerPosition()
{
    local float Perc;

    Perc = (Value - MinValue) / (MaxValue - MinValue);
    if (bShowMarker)
    {
        return ActualLeft() + (ActualWidth() - MarkerWidth) * Perc;
    }
    return ActualLeft() + ActualWidth() * Perc;
}

function CenterMouse()
{
    local PlayerController PC;

    PC = PlayerOwner();
    if (PC != None)
    {
    PC.ConsoleCommand("SETMOUSE"@GetMarkerPosition()@((ActualTop() + ActualHeight()) / 2));
    }
}

function string GetValueString()
{
    if (bIntSlider)
    {
        return string(int(Value));
    }
    return string(Value);
}

function ModifyTooltipForDragging()
{
    ToolTip.bTrackMouse = true;
    ToolTip.bTrackInput = false;
    ToolTip.bMultiLine = false;
    ToolTip.HideToolTip = HideToolTip;
    ToolTip.LeaveArea = ToolTipLeaveArea;
    SetTooltipText(GetValueString());
    ShowToolTip();
}

function RevertTooltipToNormal()
{
    ToolTip.bTrackMouse = ToolTip.default.bTrackMouse;
    ToolTip.bTrackInput = ToolTip.default.bTrackInput;
    ToolTip.bMultiLine = ToolTip.default.bMultiLine;
    ToolTip.HideToolTip = None;
    ToolTip.LeaveArea = None;
    ToolTip.LeaveArea();
    SetTooltipText(Hint);
}

function ShowToolTip()
{
    Controller.MouseOver = ToolTip.InternalEnterArea();
    ToolTip.SetVisibility(true);
}

function HideToolTip()
{
    if (MenuState != MSAT_Pressed)
    {
        ToolTip.SetVisibility(false);
    }
}

function bool ToolTipLeaveArea()
{
    return false;
}

defaultproperties
{
    Begin Object class=GUIToolTip Name=GUISliderToolTip
    End Object
    ToolTip=GUISliderToolTip

    MaxValue=100.000000
    bShowMarker=true
    bShowValueTooltip=true
    WinHeight=0.030000
    MarkerWidth=0.008
    StyleName="HxButton"
    BarStyleName="HxSliderBar"
    FillStyleName="HxSliderFill"
    bTabStop=true
    bAcceptsInput=true
    bCaptureMouse=true
    bRequireReleaseClick=true
    bRequiresStyle=true
    OnClickSound=CS_Click
    OnClick=InternalOnClick
    OnMousePressed=InternalOnMousePressed
    OnMouseRelease=InternalOnMouseRelease
    OnKeyEvent=InternalOnKeyEvent
    OnCapturedMouseMove=InternalCapturedMouseMove
    OnDraw=InternalOnDraw
}
