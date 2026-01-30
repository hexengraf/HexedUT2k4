class HxGUIFramedMultiComponent extends GUIMultiComponent
    abstract;

var Material FrameMaterial;
var Color FrameColor;
var float FrameThickness;
var bool bHideFrame;

var array<GUIComponent> AlignedComponents;

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
        Thickness = Round(C.ClipY * FrameThickness);
        AlignedComponents[i].WinLeft = Thickness / ActualWidth();
        AlignedComponents[i].WinTop = Thickness / ActualHeight();
        AlignedComponents[i].WinWidth = 1.0 - (2 * AlignedComponents[i].WinLeft);
        AlignedComponents[i].WinHeight = 1.0 - (2 * AlignedComponents[i].WinTop);
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

static function bool GetFontSize(GUIComponent Comp,
                                 Canvas C,
                                 optional string Text,
                                 optional out float Width,
                                 optional out float Height)
{
    local Font OldFont;

    if (Text == "")
    {
        Text = "q|W";
    }
    if (Comp.Style != None)
    {
        Comp.Style.TextSize(C, Comp.MenuState, Text, Width, Height, Comp.FontScale);
        return true;
    }
    if (GUILabel(Comp) != None)
    {
        OldFont = C.Font;
        C.Font = Comp.Controller.GetMenuFont(GUILabel(Comp).TextFont).GetFont(C.SizeX);
	    C.TextSize(Text, Width, Height);
        C.Font = OldFont;
        return true;
    }
    return false;
}

defaultproperties
{
    bNeverFocus=true
    FrameMaterial=Material'engine.WhiteSquareTexture'
    FrameColor=(R=113,G=159,B=205,A=255)
    FrameThickness=0.001
    bHideFrame=false
    OnPreDraw=InternalOnPreDraw
    OnRendered=InternalOnRendered
}
