class HxFont extends GUIFont;

#exec new TrueTypeFontFactory Name="Impact38" Height=38 Kerning=2 DropShadowX=2 DropShadowY=2 Style=500 AntiAlias=1 USize=512 VSize=512 XPad=2 YPad=2 FontName="Impact"
#exec new TrueTypeFontFactory Name="FontEurostile31" Height=31 Kerning=2 DropShadowX=2 DropShadowY=2 Style=700 AntiAlias=1 USize=512 VSize=512 FontName="Eurostile"
#exec new TrueTypeFontFactory Name="Verdana36" Height=36 Kerning=1 DropShadowX=0 DropShadowY=0 Style=700 AntiAlias=1 USize=256 VSize=256 XPad=2 YPad=2 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana40" Height=40 Kerning=1 DropShadowX=0 DropShadowY=0 Style=700 AntiAlias=1 USize=512 VSize=512 XPad=2 YPad=2 FontName="Verdana"
#exec new TrueTypeFontFactory Name="Verdana48" Height=48 Kerning=1 DropShadowX=0 DropShadowY=0 Style=700 AntiAlias=1 USize=512 VSize=512 XPad=2 YPad=2 FontName="Verdana"

const FONT_COUNT = 7;

var config int OverrideX;

var int ScreenWidths[FONT_COUNT];

function Font GetFont(int ScreenWidth)
{
    local int i;

    if (OverrideX > 0)
    {
        ScreenWidth = OverrideX;
    }
    if (bScaled)
    {
        return super.GetFont(ScreenWidth);
    }
    for (i = 0; i < FONT_COUNT; ++i)
    {
        if (ScreenWidths[i] <= ScreenWidth)
        {
            return LoadFont(i);
        }
    }
    return LoadFont(i - 1);
}

static function Font GetFontStatic(int ScreenWidth)
{
    local int i;

    if (default.OverrideX > 0)
    {
        ScreenWidth = default.OverrideX;
    }
    for (i = 0; i < FONT_COUNT; ++i)
    {
        if (default.ScreenWidths[i] <= ScreenWidth)
        {
            return LoadFontStatic(i);
        }
    }
    return LoadFontStatic(i - 1);
}

defaultproperties
{
    OverrideX=0

    ScreenWidths(0)=3840
    ScreenWidths(1)=2560
    ScreenWidths(2)=1920
    ScreenWidths(3)=1600
    ScreenWidths(4)=1366
    ScreenWidths(5)=1024
    ScreenWidths(6)=800
}
