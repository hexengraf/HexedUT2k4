class HxGUIFramedComponent extends GUIMultiComponent
    abstract;

var Material FrameMaterial;
var Color FrameColor;
var float FrameThickness;

var string DefaultComponentClass;
var GUIComponent MyComponent;

delegate bool OnPreDrawInit(Canvas C)
{
    return false;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    if (DefaultComponentClass != "")
    {
        MyComponent = AddComponent(DefaultComponentClass);
    }
    if (MyComponent != None)
    {
        MyComponent.bBoundToParent = true;
        MyComponent.bScaleToParent = true;
    }
}

function ResolutionChanged(int ResX, int ResY)
{
    bInit = true;
    Super.ResolutionChanged(ResX, ResY);
}

function bool InternalOnPreDraw(Canvas C)
{
    if (bInit)
    {
        AlignToBorders(C);
        bInit = OnPreDrawInit(C);
        return true;
    }
    return false;
}

function InternalOnRendered(Canvas C)
{
    if (bVisible && FrameThickness > 0.0 && FrameColor.A > 0.0)
    {
        DrawFrame(C);
    }
}

function AlignToBorders(Canvas C)
{
    local float Thickness;

    if (MyComponent != None)
    {
        Thickness = Round(C.ClipY * FrameThickness);
        MyComponent.WinLeft = Thickness / ActualWidth();
        MyComponent.WinTop = Thickness / ActualHeight();
        MyComponent.WinWidth = 1.0 - (2 * MyComponent.WinLeft);
        MyComponent.WinHeight = 1.0 - (2 * MyComponent.WinTop);
    }
}

function DrawFrame(Canvas C)
{
    local float Thickness;
    local float Width;
    local float Height;

    Thickness = Round(C.ClipY * FrameThickness);
    Width = ActualWidth();
    Height = ActualHeight() - (2 * Thickness);

    C.DrawColor = FrameColor;
    C.Style = 5;
    C.SetPos(ActualLeft(), ActualTop());
    C.DrawTileStretched(FrameMaterial, Width, Thickness);
    C.SetPos(C.CurX, C.CurY + Thickness);
    C.DrawTileStretched(FrameMaterial, Thickness, Height);
    C.SetPos(C.CurX + Width - Thickness, C.CurY);
    C.DrawTileStretched(FrameMaterial, Thickness, Height);
    C.SetPos(C.CurX - Width + Thickness, C.CurY + Height);
    C.DrawTileStretched(FrameMaterial, Width, Thickness);
}

function float GetFontHeight(Canvas C)
{
    local float Ignore;
    local float Height;

    MyComponent.Style.TextSize(
        C, MyComponent.MenuState, "q|W", Ignore, Height, MyComponent.FontScale);
    return Height;
}

defaultproperties
{
    bNeverFocus=true
    FrameMaterial=Material'engine.WhiteSquareTexture'
    FrameColor=(R=113,G=159,B=205,A=255)
    FrameThickness=0.001
    OnPreDraw=InternalOnPreDraw
    OnRendered=InternalOnRendered
}
