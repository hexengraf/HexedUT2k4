class HxGUIQuestionPage extends GUI2K4QuestionPage;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    AdjustWindowSize(Controller.ResX, Controller.ResY);
}

function bool InternalOnPreDraw(Canvas C)
{
    if (bInit)
    {
        AdjustWindowSize(C.ClipX, C.ClipY);
        bInit = false;
    }
    return false;
}

function AdjustWindowSize(coerce float X, coerce float Y)
{
    WinWidth = default.WinWidth * ((4.0 / 3.0) / (X / Y));
    WinLeft = default.WinLeft + ((default.WinWidth - WinWidth) / 2);
}

event ResolutionChanged(int ResX, int ResY)
{
    bInit = true;
    Super.ResolutionChanged(ResX, ResY);
}


function LayoutButtons(byte ActiveButton)
{
    local int i;

    Super.LayoutButtons(ActiveButton);
    for (i = 0; i<Buttons.Length; i++)
    {
        class'HxGUITheme'.static.ApplySquareButtonStyle(Controller, Buttons[i]);
        Buttons[i].WinTop = 0.675;
        Buttons[i].bBoundToParent = true;
        Buttons[i].bScaleToParent = true;
        Buttons[i].bStandardized = true;
        Buttons[i].StandardHeight = 0.0325;
    }
}

defaultproperties
{
    Begin Object Class=HxGUIBackground Name=HxBackground
        WinLeft=0
        WinTop=0
        WinWidth=1
        WinHeight=1
        RenderWeight=0.000001
        StyleName="HxPopupBackground"
        bScaleToParent=true
        bBoundToParent=true
    End Object
    Controls(0)=HxBackground

    Begin Object Class=GUILabel Name=NewlblQuestion
        WinLeft=0.05
        WinTop=0.125
        WinWidth=0.9
        WinHeight=0.5
        bMultiLine=true
        StyleName="HxTextLabel"
        VertAlign=TXTA_Center
        TextAlign=TXTA_Center
        bBoundToParent=true
        bScaleToParent=true
    End Object
    Controls(1)=NewlblQuestion

    WinLeft=0.275
    WinTop=0.4125
    WinWidth=0.45
    WinHeight=0.175
    OnPreDraw=InternalOnPreDraw
}
