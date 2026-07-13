class HxGUIScoreBoardAppearanceWindow extends HxGUIFloatingWindow;

var automated HxGUIFramedSection LeftSection;
var automated HxGUIFramedSection RightSection;

var automated moComboBox co_BoardAlignment;
var automated moComboBox co_HeadingAlignment;
var automated moSlider sl_BorderSize;
var automated moSlider sl_DividerSize;
var automated moSlider sl_FontSize;
var automated moCheckBox ch_AlternateRowColors;
var automated moComboBox co_ChangeColor;
var automated moSlider sl_ColorRed;
var automated moSlider sl_ColorBlue;
var automated moSlider sl_ColorGreen;
var automated moSlider sl_ColorAlpha;
var automated GUIButton b_RestoreColors;

var localized string AlignmentLabels[3];
var localized string ColorNameLabels[24];

var private HxClientManager ClientManager;
var private HxUTClient Client;
var private HxScoreBoardConfig Config;
var private int SelectedColorIndex;
var Color SelectedColor;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    local string EnumValue;
    local int i;

    Super.InitComponent(MyController, MyComponent);
    ForEach PlayerOwner().DynamicActors(class'HxClientManager', ClientManager) break;
    LeftSection.Insert(co_BoardAlignment);
    LeftSection.Insert(co_HeadingAlignment);
    LeftSection.Insert(sl_BorderSize);
    LeftSection.Insert(sl_DividerSize);
    LeftSection.Insert(sl_FontSize);
    LeftSection.Insert(ch_AlternateRowColors);
    RightSection.Insert(co_ChangeColor);
    RightSection.Insert(sl_ColorRed);
    RightSection.Insert(sl_ColorGreen);
    RightSection.Insert(sl_ColorBlue);
    RightSection.Insert(sl_ColorAlpha);
    RightSection.Insert(b_RestoreColors);
    Client = HxUTClient(ClientManager.Find(class'HxUTClient'));
    Config = HxScoreBoardConfig(Client.FindConfig(class'HxScoreBoardConfig'));
    co_BoardAlignment.MyComboBox.MyListBox.MyList.bInitializeList = false;
    co_HeadingAlignment.MyComboBox.MyListBox.MyList.bInitializeList = false;
    for (i = 0; i < ArrayCount(AlignmentLabels); ++i)
    {
        EnumValue = string(GetEnum(enum'EHxVertAlignment', i));
        co_BoardAlignment.AddItem(AlignmentLabels[i],,EnumValue);
        co_HeadingAlignment.AddItem(AlignmentLabels[i],,EnumValue);
    }
    for (i = 0; i < ArrayCount(ColorNameLabels); ++i)
    {
        co_ChangeColor.AddItem(ColorNameLabels[i]);
    }
}

function AdjustWindowSize(coerce float X, coerce float Y)
{
    Super.AdjustWindowSize(X, Y);
    DefaultWidth = WinWidth;
    DefaultHeight = WinHeight;
    DefaultLeft = WinLeft;
    DefaultTop = WinTop;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    if (Config != None)
    {
        GUIMenuOption(Sender).SetComponentValue(Config.GetProperty(Sender.Tag), true);
    }
}

function ColorOnLoadINI(GUIComponent Sender, string s)
{
    if (Sender == co_ChangeColor)
    {
        co_ChangeColor.SilentSetIndex(SelectedColorIndex);
        if (Config != None)
        {
            SetPropertyText("SelectedColor", Config.GetProperty(Sender.Tag + SelectedColorIndex));
        }
    }
    else
    {
        switch (Sender)
        {
            case sl_ColorRed:
                sl_ColorRed.SetComponentValue(SelectedColor.R, true);
                break;
            case sl_ColorGreen:
                sl_ColorGreen.SetComponentValue(SelectedColor.G, true);
                break;
            case sl_ColorBlue:
                sl_ColorBlue.SetComponentValue(SelectedColor.B, true);
                break;
            case sl_ColorAlpha:
                sl_ColorAlpha.SetComponentValue(SelectedColor.A, true);
                break;
        }
    }
}

function InternalOnChange(GUIComponent Sender)
{
    Config.SetProperty(Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
}

function ColorOnChange(GUIComponent Sender)
{
    if (Sender == co_ChangeColor)
    {
        SelectedColorIndex = co_ChangeColor.GetIndex();
        if (Config != None)
        {
            SetPropertyText("SelectedColor", Config.GetProperty(Sender.Tag + SelectedColorIndex));
            sl_ColorRed.SetComponentValue(SelectedColor.R, true);
            sl_ColorGreen.SetComponentValue(SelectedColor.G, true);
            sl_ColorBlue.SetComponentValue(SelectedColor.B, true);
            sl_ColorAlpha.SetComponentValue(SelectedColor.A, true);
        }
    }
    else
    {
        switch (Sender)
        {
            case sl_ColorRed:
                SelectedColor.R = byte(sl_ColorRed.GetValue());
                break;
            case sl_ColorGreen:
                SelectedColor.G = byte(sl_ColorGreen.GetValue());
                break;
            case sl_ColorBlue:
                SelectedColor.B = byte(sl_ColorBlue.GetValue());
                break;
            case sl_ColorAlpha:
                SelectedColor.A = byte(sl_ColorAlpha.GetValue());
                break;
        }
        Config.SetProperty(Sender.Tag + SelectedColorIndex, GetPropertyText("SelectedColor"));
    }
}

function bool FloatingPreDraw(Canvas C)
{
    local float ActualSpacing;
    local float VerticalSpacing;
    local float HorizontalSpacing;

    if (bInit)
    {
        ActualSpacing = SPACING * C.ClipY;
        VerticalSpacing = ActualSpacing / ActualHeight();
        HorizontalSpacing = ActualSpacing / ActualWidth() / 2;
        LeftSection.WinLeft = 3.5 * HorizontalSpacing;
        LeftSection.WinTop =
            (HxGUIHeader(t_WindowTitle).GetDesiredHeight(C) + 1.5 * ActualSpacing) / ActualHeight();
        LeftSection.WinWidth = 0.5 - (4.5 * HorizontalSpacing);
        LeftSection.WinHeight = 1.0 - (2 * VerticalSpacing) - LeftSection.WinTop;
        RightSection.WinLeft = 0.5 + HorizontalSpacing;
        RightSection.WinTop = LeftSection.WinTop;
        RightSection.WinWidth = LeftSection.WinWidth;
        RightSection.WinHeight = LeftSection.WinHeight;
    }
    return Super.FloatingPreDraw(C);
}

function bool OnClickRestoreColors(GUIComponent Sender)
{
    local int PropertyIndex;
    local int i;

    for (i = 0; i < ArrayCount(ColorNameLabels); ++i)
    {
        PropertyIndex = co_ChangeColor.Tag + i;
        Config.ResetProperty(PropertyIndex);
        Config.SetProperty(PropertyIndex, Config.GetProperty(PropertyIndex));
    }
    ColorOnChange(co_ChangeColor);
    return true;
}

event Free()
{
    ClientManager = None;
    Client = None;
    Config = None;
    Super.Free();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=GeneralOptionsSection
        bNoHeader=true
    End Object
    LeftSection=GeneralOptionsSection

    Begin Object class=HxGUIFramedSection Name=ColorEditorSection
        bNoHeader=true
    End Object
    RightSection=ColorEditorSection

    Begin Object class=moComboBox Name=BoardAlignmentComboBox
        Caption="Board alignment"
        Hint="Vertical alignment for the scoreboard."
        INIOption="@INTERNAL"
        Tag=1
        bReadOnly=true
        CaptionWidth=0.5
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=0
    End Object
    co_BoardAlignment=BoardAlignmentComboBox

    Begin Object class=moComboBox Name=HeadingAlignmentComboBox
        Caption="Heading alignment"
        Hint="Vertical alignment for single line headings."
        INIOption="@INTERNAL"
        Tag=2
        bReadOnly=true
        CaptionWidth=0.5
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=1
    End Object
    co_HeadingAlignment=HeadingAlignmentComboBox

    Begin Object class=moSlider Name=BorderSizeSlider
        Caption="Border size"
        Hint="Border size (% of screen height)."
        INIOption="@INTERNAL"
        Tag=4
        MinValue=0
        MaxValue=0.5
        CaptionWidth=0.35
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=2
    End Object
    sl_BorderSize=BorderSizeSlider

    Begin Object class=moSlider Name=DividerSizeSlider
        Caption="Divider size"
        Hint="Row divider size (% of screen height)."
        INIOption="@INTERNAL"
        Tag=5
        MinValue=0
        MaxValue=0.5
        CaptionWidth=0.35
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=3
    End Object
    sl_DividerSize=DividerSizeSlider

    Begin Object class=moSlider Name=FontSizeSlider
        Caption="Font size"
        Hint="Increase or decrease the font sizes of all fonts used by the scoreboard."
        INIOption="@INTERNAL"
        Tag=6
        MinValue=-2
        MaxValue=2
        bIntSlider=true
        CaptionWidth=0.35
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=4
    End Object
    sl_FontSize=FontSizeSlider

    Begin Object class=moCheckBox Name=AlternateRowColorsCheckBox
        Caption="Alternate row colors"
        Hint="Use the alternative row color to alternate row colors."
        INIOption="@INTERNAL"
        Tag=7
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=5
    End Object
    ch_AlternateRowColors=AlternateRowColorsCheckBox

    Begin Object class=moComboBox Name=ChangeColorComboBox
        Caption="Change"
        Hint="Select a color to change."
        INIOption="@INTERNAL"
        Tag=10
        bReadOnly=true
        CaptionWidth=0.22
        OnLoadINI=ColorOnLoadINI
        OnChange=ColorOnChange
        TabOrder=6
    End Object
    co_ChangeColor=ChangeColorComboBox

    Begin Object class=moSlider Name=RedSlider
        Caption="Red"
        INIOption="@INTERNAL"
        Tag=10
        MinValue=0
        MaxValue=255
        bIntSlider=true
        CaptionWidth=0.22
        OnLoadINI=ColorOnLoadINI
        OnChange=ColorOnChange
        TabOrder=7
    End Object
    sl_ColorRed=RedSlider

    Begin Object class=moSlider Name=GreenSlider
        Caption="Green"
        INIOption="@INTERNAL"
        Tag=10
        MinValue=0
        MaxValue=255
        bIntSlider=true
        CaptionWidth=0.22
        OnLoadINI=ColorOnLoadINI
        OnChange=ColorOnChange
        TabOrder=8
    End Object
    sl_ColorGreen=GreenSlider

    Begin Object class=moSlider Name=BlueSlider
        Caption="Blue"
        INIOption="@INTERNAL"
        Tag=10
        MinValue=0
        MaxValue=255
        bIntSlider=true
        CaptionWidth=0.22
        OnLoadINI=ColorOnLoadINI
        OnChange=ColorOnChange
        TabOrder=9
    End Object
    sl_ColorBlue=BlueSlider

    Begin Object class=moSlider Name=AlphaSlider
        Caption="Alpha"
        INIOption="@INTERNAL"
        Tag=10
        MinValue=0
        MaxValue=255
        bIntSlider=true
        CaptionWidth=0.22
        OnLoadINI=ColorOnLoadINI
        OnChange=ColorOnChange
        TabOrder=10
    End Object
    sl_ColorAlpha=AlphaSlider

    Begin Object class=GUIButton Name=RestoreColorsButton
        Caption="Restore Default Colors"
        Hint="Customize colors, alignments, and more."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickRestoreColors
        TabOrder=11
    End Object
    b_RestoreColors=RestoreColorsButton

    WindowName="Enhanced Scoreboards - Appearance"
    WinWidth=0.75
    WinHeight=0.35
    WinLeft=0.125
    WinTop=0.325
    bPersistent=false
    bMoveAllowed=true

    AlignmentLabels(0)="Top"
    AlignmentLabels(1)="Center"
    AlignmentLabels(2)="Bottom"
    ColorNameLabels(0)="Header color"
    ColorNameLabels(1)="Red team header color"
    ColorNameLabels(2)="Blue team header color"
    ColorNameLabels(3)="Row color"
    ColorNameLabels(4)="Red team row color"
    ColorNameLabels(5)="Blue team row color"
    ColorNameLabels(6)="Alternate row color"
    ColorNameLabels(7)="Red team alternate row color"
    ColorNameLabels(8)="Blue team alternate row color"
    ColorNameLabels(9)="Border color"
    ColorNameLabels(10)="Red team border color"
    ColorNameLabels(11)="Blue team border color"
    ColorNameLabels(12)="Divider color"
    ColorNameLabels(13)="Red team divider color"
    ColorNameLabels(14)="Blue team divider color"
    ColorNameLabels(15)="Scroll thumb color"
    ColorNameLabels(16)="Red team scroll thumb color"
    ColorNameLabels(17)="Blue team scroll thumb color"
    ColorNameLabels(18)="Red team color"
    ColorNameLabels(19)="Blue team color"
    ColorNameLabels(20)="Text color"
    ColorNameLabels(21)="Second text color"
    ColorNameLabels(22)="Highlight text color"
    ColorNameLabels(23)="Ready color"
}
