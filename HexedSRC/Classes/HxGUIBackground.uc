class HxGUIBackground extends GUIMultiComponent;

var automated GUIImage i_CustomBG;

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
        if (HxGUIStyles(Style) != None)
        {
            HxGUIStyles(Style).UpdateBorderOffsets();
            HxGUIStyles(Style).FillFrame(Self, i_CustomBG);
        }
        bInit = OnPreDrawInit(C);
        return true;
    }
    return false;
}

function bool InternalOnDraw(Canvas C)
{
    if (bVisible)
    {
        Style.Draw(
            C, MenuState, Bounds[0], Bounds[1], Bounds[2] - Bounds[0], Bounds[3] - Bounds[1]);
    }
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

function SetCustomBackground(string BackgroundName)
{
    if (BackgroundName == "")
    {
        i_CustomBG.Image = None;
    }
    else
    {
        i_CustomBG.Image = Material(DynamicLoadObject(BackgroundName, class'Material'));
    }
}

defaultproperties
{
    Begin Object Class=GUIImage Name=CustomBackgroundImage
        RenderWeight=0.5
        bBoundToParent=true
        bScaleToParent=true
    End Object
    i_CustomBG=CustomBackgroundImage

    StyleName="HxBackgroundFrame"
    bScaleToParent=true
    bBoundToParent=true
    OnPreDraw=InternalOnPreDraw
    OnDraw=InternalOnDraw
}
