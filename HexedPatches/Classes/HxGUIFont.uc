class HxGUIFont extends GUIFont
    config(User);

#exec new TrueTypeFontFactory Name="Impact52" Height=52 Kerning=2 DropShadowX=2 DropShadowY=2 Style=500 AntiAlias=1 USize=512 VSize=512 XPad=2 YPad=2 FontName="Impact"
#exec new TrueTypeFontFactory Name="FontEurostile31" Height=31 Kerning=2 DropShadowX=2 DropShadowY=2 Style=700 AntiAlias=1 USize=512 VSize=512 FontName="Eurostile"
#exec new TrueTypeFontFactory Name="Verdana36" Height=36 Kerning=1 DropShadowX=0 DropShadowY=0 Style=700 AntiAlias=1 USize=256 VSize=256 XPad=2 YPad=2 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana40" Height=40 Kerning=1 DropShadowX=0 DropShadowY=0 Style=700 AntiAlias=1 USize=512 VSize=512 XPad=2 YPad=2 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana48" Height=48 Kerning=1 DropShadowX=0 DropShadowY=0 Style=700 AntiAlias=1 USize=512 VSize=512 XPad=2 YPad=2 FontName="Verdana"

const FONT_COUNT = 7;

var config bool bScaleWithY;
var config int OverrideFontSize;

var int NormalYRes;
var int ScreenWidths[FONT_COUNT];
var int ScreenHeights[FONT_COUNT];

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
        return GetFontFromY(XRes);
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

function Font GetFontFromY(int XRes)
{
    local int i;
    local int YRes;

    YRes = Controller.ResY * (float(XRes) / Controller.ResX);
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
    if (bScaleWithY)
    {
        XRes *= (float(NormalXRes) / NormalYRes) / (float(Controller.ResX) / Controller.ResY);
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

    ScreenHeights(0)=500
    ScreenHeights(1)=640
    ScreenHeights(2)=800
    ScreenHeights(3)=1024
    ScreenHeights(4)=1440
    ScreenHeights(5)=1600
    ScreenHeights(6)=2160
}
