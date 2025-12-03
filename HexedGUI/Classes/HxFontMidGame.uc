class HxFontMidGame extends HxFont;

static function Font GetMidGameFont(int xRes)
{
    return GetFontStatic(xRes);
}

defaultproperties
{
    KeyName="UT2MidGameFont"

    FontArrayNames(0)=""
    FontArrayNames(1)="UT2003Fonts.FontEurostile21"
    FontArrayNames(2)="UT2003Fonts.FontEurostile17" // last original
    FontArrayNames(3)="UT2003Fonts.FontEurostile14"
    FontArrayNames(4)="UT2003Fonts.FontEurostile11"
    FontArrayNames(5)="UT2003Fonts.FontEurostile11"
    FontArrayNames(6)="UT2003Fonts.FontEurostile9"

    FontArrayFonts(0)=Font'FontEurostile31'
}
