class HxGUIFramedMultiComponent extends GUIMultiComponent
    abstract;

const MED_FONT_SPACING = 1.44;
const SMALL_FONT_SPACING = 1.2;

var Material FrameMaterial;
var Color FrameColor;
var float FrameThickness;
var bool bHideFrame;

var protected array<GUIComponent> AlignedComponents;

delegate bool OnPreDrawInit(Canvas C)
{
    return false;
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
        AlignToFrame(C);
        bInit = OnPreDrawInit(C);
        return true;
    }
    return false;
}

function InternalOnRendered(Canvas C)
{
    if (bVisible && !bHideFrame)
    {
        DrawFrame(C);
    }
}

function GUIComponent CreateComponent(string ComponentClass, optional bool bAlignToFrame)
{
    local GUIComponent NewComp;

    NewComp = AddComponent(ComponentClass);
    if (NewComp != None && bAlignToFrame)
    {
        NewComp.bBoundToParent = true;
        NewComp.bScaleToParent = true;
        AlignedComponents[AlignedComponents.Length] = NewComp;
    }
    return NewComp;
}

function AlignToFrame(Canvas C)
{
    local float Thickness;
    local float Width;
    local float Height;
    local int i;

    Width = ActualWidth();
    Height = ActualHeight();
    for (i = 0; i < AlignedComponents.Length; ++i)
    {
        Thickness = ActualFrameThickness(C);
        AlignedComponents[i].WinLeft = Thickness / ActualWidth();
        AlignedComponents[i].WinTop = Thickness / ActualHeight();
        AlignedComponents[i].WinWidth = 1.0 - (2 * AlignedComponents[i].WinLeft);
        AlignedComponents[i].WinHeight = 1.0 - (2 * AlignedComponents[i].WinTop);
    }
}

function DrawFrame(Canvas C)
{
    local float Offset;

    Offset = ActualFrameThickness(C);
    C.DrawColor = FrameColor;
    C.Style = 5;
    class'HxGUIStyles'.static.DrawFrame(
        C,
        FrameMaterial,
        MenuState,
        ActualLeft(),
        ActualTop(),
        ActualWidth(),
        ActualHeight() - (2 * Offset),
        Offset);
}

function float ActualFrameThickness(Canvas C)
{
    return Round(C.ClipY * FrameThickness);
}

static function bool GetFontSize(GUIComponent Comp,
                                 Canvas C,
                                 optional string Text,
                                 optional out float Width,
                                 optional out float Height)
{
    return class'HxGUIStyles'.static.GetFontSize(Comp, C, Text, Width, Height);
}

defaultproperties
{
    bNeverFocus=true
    FrameMaterial=Material'engine.WhiteSquareTexture'
    FrameColor=(R=113,G=159,B=205,A=255)
    FrameThickness=0.001
    bHideFrame=false
    bScaleToParent=true
    bBoundToParent=true
    OnPreDraw=InternalOnPreDraw
    OnRendered=InternalOnRendered
}
