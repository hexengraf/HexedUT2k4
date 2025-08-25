class HxHitEffectsFont extends Actor;

const FONT_COUNT = 7;

var Font Fonts[FONT_COUNT];
var localized string FontNames[FONT_COUNT];
var int ScreenWidths[FONT_COUNT];

static function Font LoadFontStatic(int i)
{
	if (default.Fonts[i] == None)
	{
		default.Fonts[i] = Font(DynamicLoadObject(default.FontNames[i], class'Font'));
		if (default.Fonts[i] == None)
        {
			Log(default.Name@" couldn't dynamically load font "$default.FontNames[i]);
        }
	}
	return default.Fonts[i];
}

static function Font GetFont(int ScreenWidth)
{
	local int i;

	for (i = 0; i < FONT_COUNT; ++i)
	{
		if (default.ScreenWidths[i] <= ScreenWidth)
        {
			return LoadFontStatic(i);
        }
	}
	return LoadFontStatic(i);
}

defaultproperties
{
	FontNames(0)="UT2003Fonts.FontEurostile37"
    FontNames(1)="UT2003Fonts.FontEurostile24"
    FontNames(2)="UT2003Fonts.FontEurostile17"
    FontNames(3)="UT2003Fonts.FontEurostile14"
    FontNames(4)="UT2003Fonts.FontEurostile12"
    FontNames(5)="UT2003Fonts.FontEurostile11"
    FontNames(6)="UT2003Fonts.FontEurostile8"

    ScreenWidths(0)=3840
    ScreenWidths(1)=2560
    ScreenWidths(2)=1920
    ScreenWidths(3)=1360
    ScreenWidths(4)=1280
    ScreenWidths(5)=1024
    ScreenWidths(6)=800
}
