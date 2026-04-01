class HxGUIBackground extends GUIMultiComponent;

var protected array<GUIComponent> AlignedComponents;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
}

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
        bInit = OnPreDrawInit(C);
        return true;
    }
    return false;
}

function bool InternalOnDraw(Canvas C)
{
    Style.Draw(C, MenuState, Bounds[0], Bounds[1], Bounds[2] - Bounds[0], Bounds[3] - Bounds[1]);
    return false;
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
    StyleName="HxTextLabel"
    bScaleToParent=true
    bBoundToParent=true
    OnPreDraw=InternalOnPreDraw
    OnDraw=InternalOnDraw
}
