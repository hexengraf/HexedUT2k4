class HxGUIFontMidGame extends GUIFont;

const FONT_COUNT = 8;

var localized string BigFontNames[FONT_COUNT];
var localized string MediumFontNames[FONT_COUNT];
var localized string SmallFontNames[FONT_COUNT];
var localized string TinyFontNames[FONT_COUNT];
var localized string HugeNumericFontNames[FONT_COUNT];

var private Font BigFonts[FONT_COUNT];
var private Font MediumFonts[FONT_COUNT];
var private Font SmallFonts[FONT_COUNT];
var private Font TinyFonts[FONT_COUNT];
var private Font HugeNumericFonts[FONT_COUNT];
var private int ScreenHeights[FONT_COUNT];

static final function PrecacheFonts()
{
    local int Index;

    for (Index = 0; Index < FONT_COUNT; ++Index)
    {
        if (default.BigFonts[Index] == None)
        {
            default.BigFontNames[Index] = ValidateFontName(default.BigFontNames[Index]);
            default.BigFonts[Index] = Font(
                DynamicLoadObject(default.BigFontNames[Index], class'Font'));
        }
        if (default.MediumFonts[Index] == None)
        {
            default.MediumFontNames[Index] = ValidateFontName(default.MediumFontNames[Index]);
            default.MediumFonts[Index] = Font(
                DynamicLoadObject(default.MediumFontNames[Index], class'Font'));
        }
        if (default.SmallFonts[Index] == None)
        {
            default.SmallFontNames[Index] = ValidateFontName(default.SmallFontNames[Index]);
            default.SmallFonts[Index] = Font(
                DynamicLoadObject(default.SmallFontNames[Index], class'Font'));
        }
        if (default.HugeNumericFonts[Index] == None)
        {
            default.HugeNumericFontNames[Index] = ValidateFontName(
                default.HugeNumericFontNames[Index]);
            default.HugeNumericFonts[Index] = Font(
                DynamicLoadObject(default.HugeNumericFontNames[Index], class'Font'));
        }
    }
}

static final function Font GetBigFontFor(int Index)
{
    if (default.BigFonts[Index] == None)
    {
        default.BigFontNames[Index] = ValidateFontName(default.BigFontNames[Index]);
        default.BigFonts[Index] = Font(DynamicLoadObject(default.BigFontNames[Index], class'Font'));
    }
    return default.BigFonts[Index];
}

static final function Font GetMediumFontFor(int Index)
{
    if (default.MediumFonts[Index] == None)
    {
        default.MediumFontNames[Index] = ValidateFontName(default.MediumFontNames[Index]);
        default.MediumFonts[Index] = Font(
            DynamicLoadObject(default.MediumFontNames[Index], class'Font'));
    }
    return default.MediumFonts[Index];
}

static final function Font GetSmallFontFor(int Index)
{
    if (default.SmallFonts[Index] == None)
    {
        default.SmallFontNames[Index] = ValidateFontName(default.SmallFontNames[Index]);
        default.SmallFonts[Index] = Font(
            DynamicLoadObject(default.SmallFontNames[Index], class'Font'));
    }
    return default.SmallFonts[Index];
}

static final function Font GetTinyFontFor(int Index)
{
    if (default.TinyFonts[Index] == None)
    {
        default.TinyFontNames[Index] = ValidateFontName(default.TinyFontNames[Index]);
        default.TinyFonts[Index] = Font(
            DynamicLoadObject(default.TinyFontNames[Index], class'Font'));
    }
    return default.TinyFonts[Index];
}

static final function Font GetHugeNumericFontFor(int Index)
{
    if (default.HugeNumericFonts[Index] == None)
    {
        default.HugeNumericFontNames[Index] = ValidateFontName(default.HugeNumericFontNames[Index]);
        default.HugeNumericFonts[Index] = Font(
            DynamicLoadObject(default.HugeNumericFontNames[Index], class'Font'));
    }
    return default.HugeNumericFonts[Index];
}

static final function int GetFontIndex(Canvas C, optional int Modifier)
{
    local int Index;

    for (Index = 0; Index < FONT_COUNT - 1; ++Index)
    {
        if (C.ClipY < default.ScreenHeights[Index])
        {
            break;
        }
    }
    return Min(Max(0, Index + Modifier), FONT_COUNT - 1);
}

static final function string ValidateFontName(string FontName)
{
    local string PackageName;
    local string ClassName;

    if (StrCmp(FontName, "HxFont", 6) == 0)
    {
        if (Divide(string(class'HxFonts_rc'), ".", PackageName, ClassName))
        {
            return PackageName$"."$FontName;
        }
    }
    return FontName;
}

defaultproperties
{
    BigFontNames(0)="UT2003Fonts.FontEurostile9"
    BigFontNames(1)="UT2003Fonts.FontEurostile12"
    BigFontNames(2)="UT2003Fonts.FontEurostile14"
    BigFontNames(3)="UT2003Fonts.FontEurostile17"
    BigFontNames(4)="UT2003Fonts.FontEurostile21"
    BigFontNames(5)="HxFontEurostile28"
    BigFontNames(6)="HxFontEurostile32"
    BigFontNames(7)="HxFontEurostile42"
    MediumFontNames(0)="UT2003Fonts.FontSmallText"
    MediumFontNames(1)="UT2003Fonts.FontEurostile11"
    MediumFontNames(2)="UT2003Fonts.FontEurostile12"
    MediumFontNames(3)="UT2003Fonts.FontEurostile14"
    MediumFontNames(4)="UT2003Fonts.FontEurostile17"
    MediumFontNames(5)="UT2003Fonts.FontEurostile21"
    MediumFontNames(6)="UT2003Fonts.FontEurostile29"
    MediumFontNames(7)="HxFontEurostile32"
    SmallFontNames(0)="UT2003Fonts.FontSmallText"
    SmallFontNames(1)="UT2003Fonts.FontEurostile9"
    SmallFontNames(2)="UT2003Fonts.FontEurostile11"
    SmallFontNames(3)="UT2003Fonts.FontEurostile12"
    SmallFontNames(4)="UT2003Fonts.FontEurostile14"
    SmallFontNames(5)="UT2003Fonts.FontEurostile17"
    SmallFontNames(6)="UT2003Fonts.FontEurostile24"
    SmallFontNames(7)="HxFontEurostile27"
    TinyFontNames(0)="UT2003Fonts.FontSmallText"
    TinyFontNames(1)="HxFontEurostileL9"
    TinyFontNames(2)="HxFontEurostileL11"
    TinyFontNames(3)="HxFontEurostileL12"
    TinyFontNames(4)="HxFontEurostileL14"
    TinyFontNames(5)="HxFontEurostileL17"
    TinyFontNames(6)="HxFontEurostileL24"
    TinyFontNames(7)="HxFontEurostileL27"
    HugeNumericFontNames(0)="HxFontEurostile18"
    HugeNumericFontNames(1)="HxFontEurostile22"
    HugeNumericFontNames(2)="HxFontEurostile28"
    HugeNumericFontNames(3)="HxFontEurostile35"
    HugeNumericFontNames(4)="HxFontNumEurostile39"
    HugeNumericFontNames(5)="HxFontNumEurostile52"
    HugeNumericFontNames(6)="HxFontNumEurostile65"
    HugeNumericFontNames(7)="HxFontNumEurostile78"
    ScreenHeights(0)=500 // calibrated for 480
    ScreenHeights(1)=768 // calibrated for 600
    ScreenHeights(2)=800 // calibrated for 768
    ScreenHeights(3)=1024 // calibrated for 960
    ScreenHeights(4)=1440 // calibrated for 1080
    ScreenHeights(5)=1600 // calibrated for 1440
    ScreenHeights(6)=2048 // calibrated for 1600
    ScreenHeights(7)=2160 // calibrated for 2160
}
