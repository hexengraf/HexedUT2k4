class HxGUIFont extends GUIFont
    config(User);

#exec new TrueTypeFontFactory Name="Impact52" Height=52 Kerning=2 DropShadowX=2 DropShadowY=2 Style=500 AntiAlias=1 USize=512 VSize=512 XPad=2 YPad=2 FontName="Impact"
#exec new TrueTypeFontFactory Name="FontEurostile31" Height=31 Kerning=2 DropShadowX=2 DropShadowY=2 Style=600 AntiAlias=1 USize=512 VSize=512 XPad=4 YPad=4 FontName="Eurostile"
#exec new TrueTypeFontFactory Name="Verdana11" Height=11 Kerning=1 DropShadowX=0 DropShadowY=0 Style=600 AntiAlias=1 USize=256 VSize=256 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana12" Height=12 Kerning=1 DropShadowX=0 DropShadowY=0 Style=600 AntiAlias=1 USize=256 VSize=256 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana13" Height=13 Kerning=1 DropShadowX=0 DropShadowY=0 Style=600 AntiAlias=1 USize=256 VSize=256 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana14" Height=14 Kerning=1 DropShadowX=0 DropShadowY=0 Style=600 AntiAlias=1 USize=256 VSize=256 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana18" Height=18 Kerning=1 DropShadowX=0 DropShadowY=0 Style=600 AntiAlias=1 USize=256 VSize=256 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana24" Height=24 Kerning=1 DropShadowX=0 DropShadowY=0 Style=600 AntiAlias=1 USize=256 VSize=256 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana36" Height=36 Kerning=1 DropShadowX=0 DropShadowY=0 Style=600 AntiAlias=1 USize=256 VSize=256 XPad=2 YPad=2 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana40" Height=40 Kerning=1 DropShadowX=0 DropShadowY=0 Style=600 AntiAlias=1 USize=512 VSize=512 XPad=2 YPad=2 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana48" Height=48 Kerning=1 DropShadowX=0 DropShadowY=0 Style=600 AntiAlias=1 USize=512 VSize=512 XPad=2 YPad=2 FontName="Verdana"

const FONT_COUNT = 7;

var config bool bScaleWithY;
var config int OverrideFontSize;

var int ScreenWidths[FONT_COUNT];
var int ScreenHeights[FONT_COUNT];
var int HxNormalYRes;
var bool bNormalYResFixed;

function Font GetFont(int XRes)
{
    if (bScaled)
    {
        return GetFontScaled(XRes);
    }
    if (OverrideFontSize >= 0)
    {
        return LoadFont(OverrideFontSize);
    }
    if (bScaleWithY)
    {
        if (HxGUIController(Controller).bOldUnrealPatch)
        {
            return GetFontFromY(Super.GetPropertyText("parm_YRes"));
        }
        return GetFontFromY(Controller.ResY * (float(XRes) / Controller.ResX));
    }
    return GetFontFromX(XRes);
}

function Font GetFontFromX(int XRes)
{
    local int i;

    for (i = 0; i < FONT_COUNT; ++i)
    {
        if (XRes < ScreenWidths[i])
        {
            return LoadFont(i);
        }
    }
    return LoadFont(i - 1);
}

function Font GetFontFromY(coerce int YRes)
{
    local int i;

    for (i = 0; i < FONT_COUNT; ++i)
    {
        if (YRes < ScreenHeights[i])
        {
            return LoadFont(i);
        }
    }
    return LoadFont(i - 1);
}

function Font GetFontScaled(int XRes)
{
    if (HxGUIController(Controller).bOldUnrealPatch)
    {
        if (!bNormalYResFixed)
        {
            Super.SetPropertyText("NormalYRes", string(HxNormalYRes));
            bNormalYResFixed = true;
        }
        return Super.GetFont(XRes);
    }
    if (bScaleWithY)
    {
        XRes *= (float(NormalXRes) / HxNormalYRes) / (float(Controller.ResX) / Controller.ResY);
    }
    return Super.GetFont(XRes);
}

static function Font GetFontStatic(int XRes)
{
    local int i;

    if (default.OverrideFontSize >= 0)
    {
        return LoadFontStatic(default.OverrideFontSize);
    }
    for (i = 0; i < FONT_COUNT; ++i)
    {
        if (XRes < default.ScreenWidths[i])
        {
            return LoadFontStatic(i);
        }
    }
    return LoadFontStatic(i - 1);
}

defaultproperties
{
    bScaleWithY=true
    OverrideFontSize=-1

    ScreenWidths(0)=800
    ScreenWidths(1)=1024
    ScreenWidths(2)=1360
    ScreenWidths(3)=1600
    ScreenWidths(4)=1920
    ScreenWidths(5)=2560
    ScreenWidths(6)=3840

    ScreenHeights(0)=600
    ScreenHeights(1)=800
    ScreenHeights(2)=960
    ScreenHeights(3)=1024
    ScreenHeights(4)=1440
    ScreenHeights(5)=1600
    ScreenHeights(6)=2160
}
