class HxGUIMenuInstagibPanel extends HxGUIMenuPanel;

const SECTION_SCOPE_OVERLAY = 0;
const SECTION_CUSTOM_SCOPE_OVERLAY = 2;
const SECTION_CROSSHAIR = 3;

var automated moComboBox co_ScopeOverlay;
var automated moCheckBox ch_SoundEffects;
var automated moCheckBox ch_ShowChargeBar;
var automated moSlider sl_ReticleRedColor;
var automated moSlider sl_ReticleGreenColor;
var automated moSlider sl_ReticleBlueColor;
var automated moSlider sl_ReticleOpacity;
var automated moSlider sl_ReticleScale;
var automated moSlider sl_BackgroundOpacity;
var automated moCheckBox ch_CustomCrosshair;
var automated moComboBox co_CustomCrosshair;
var automated moSlider sl_CrosshairRedColor;
var automated moSlider sl_CrosshairGreenColor;
var automated moSlider sl_CrosshairBlueColor;
var automated moSlider sl_CrosshairOpacity;
var automated moSlider sl_CrosshairScale;

var localized string ScopeOverlayNames[3];

var private HxIGClient Client;
var private HxZoomSuperShockRifleConfig Config;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);
    Sections[SECTION_SCOPE_OVERLAY].Insert(co_ScopeOverlay);
    Sections[SECTION_SCOPE_OVERLAY].Insert(ch_CustomCrosshair);
    Sections[SECTION_SCOPE_OVERLAY].Insert(ch_SoundEffects);
    Sections[SECTION_SCOPE_OVERLAY].Insert(ch_ShowChargeBar);
    Sections[SECTION_CUSTOM_SCOPE_OVERLAY].Insert(sl_BackgroundOpacity);
    Sections[SECTION_CUSTOM_SCOPE_OVERLAY].Insert(sl_ReticleRedColor);
    Sections[SECTION_CUSTOM_SCOPE_OVERLAY].Insert(sl_ReticleGreenColor);
    Sections[SECTION_CUSTOM_SCOPE_OVERLAY].Insert(sl_ReticleBlueColor);
    Sections[SECTION_CUSTOM_SCOPE_OVERLAY].Insert(sl_ReticleOpacity);
    Sections[SECTION_CUSTOM_SCOPE_OVERLAY].Insert(sl_ReticleScale);
    Sections[SECTION_CROSSHAIR].Insert(co_CustomCrosshair);
    Sections[SECTION_CROSSHAIR].Insert(sl_CrosshairRedColor);
    Sections[SECTION_CROSSHAIR].Insert(sl_CrosshairGreenColor);
    Sections[SECTION_CROSSHAIR].Insert(sl_CrosshairBlueColor);
    Sections[SECTION_CROSSHAIR].Insert(sl_CrosshairOpacity);
    Sections[SECTION_CROSSHAIR].Insert(sl_CrosshairScale);
    Client = HxIGClient(ClientManager.Find(class'HxIGClient'));
    Config = HxZoomSuperShockRifleConfig(Client.FindConfig(class'HxZoomSuperShockRifleConfig'));
    PopulateComboBoxes();
}

function bool CanShowPanel()
{
    return Client != None;
}

function PopulateComboBoxes()
{
    local array<CacheManager.CrosshairRecord> Crosshairs;
    local int i;

    co_ScopeOverlay.MyComboBox.MyListBox.MyList.bInitializeList = false;
    co_CustomCrosshair.MyComboBox.MyListBox.MyList.bInitializeList = false;
    for (i = 0; i < ArrayCount(ScopeOverlayNames); ++i)
    {
        co_ScopeOverlay.AddItem(ScopeOverlayNames[i],, string(GetEnum(enum'EHxScopeOverlay', i)));
    }
    class'CacheManager'.static.GetCrosshairList(Crosshairs);
    for (i = 0; i < Crosshairs.Length; ++i)
    {
        co_CustomCrosshair.AddItem(Crosshairs[i].FriendlyName,, string(i));
    }
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    switch (Sender)
    {
        case sl_ReticleRedColor:
            sl_ReticleRedColor.SetComponentValue(Config.ReticleColor.R, true);
            break;
        case sl_ReticleGreenColor:
            sl_ReticleGreenColor.SetComponentValue(Config.ReticleColor.G, true);
            break;
        case sl_ReticleBlueColor:
            sl_ReticleBlueColor.SetComponentValue(Config.ReticleColor.B, true);
            break;
        case sl_ReticleOpacity:
            sl_ReticleOpacity.SetComponentValue(Config.ReticleColor.A, true);
            break;
        case sl_CrosshairRedColor:
            sl_CrosshairRedColor.SetComponentValue(Config.CustomZoomCrosshairColor.R, true);
            break;
        case sl_CrosshairGreenColor:
            sl_CrosshairGreenColor.SetComponentValue(Config.CustomZoomCrosshairColor.G, true);
            break;
        case sl_CrosshairBlueColor:
            sl_CrosshairBlueColor.SetComponentValue(Config.CustomZoomCrosshairColor.B, true);
            break;
        case sl_CrosshairOpacity:
            sl_CrosshairOpacity.SetComponentValue(Config.CustomZoomCrosshairColor.A, true);
            break;
        default:
            GUIMenuOption(Sender).SetComponentValue(Config.GetProperty(Sender.Tag), true);
            break;
    }
}

function InternalOnChange(GUIComponent Sender)
{
    if (Client != None)
    {
        switch (Sender)
        {
            case sl_ReticleRedColor:
                Config.ReticleColor.R = byte(sl_ReticleRedColor.GetComponentValue());
                break;
            case sl_ReticleGreenColor:
                Config.ReticleColor.G = byte(sl_ReticleGreenColor.GetComponentValue());
                break;
            case sl_ReticleBlueColor:
                Config.ReticleColor.B = byte(sl_ReticleBlueColor.GetComponentValue());
                break;
            case sl_ReticleOpacity:
                Config.ReticleColor.A = byte(sl_ReticleOpacity.GetComponentValue());
                break;
            case sl_CrosshairRedColor:
                Config.CustomZoomCrosshairColor.R = byte(sl_CrosshairRedColor.GetComponentValue());
                break;
            case sl_CrosshairGreenColor:
                Config.CustomZoomCrosshairColor.G = byte(sl_CrosshairGreenColor.GetComponentValue());
                break;
            case sl_CrosshairBlueColor:
                Config.CustomZoomCrosshairColor.B = byte(sl_CrosshairBlueColor.GetComponentValue());
                break;
            case sl_CrosshairOpacity:
                Config.CustomZoomCrosshairColor.A = byte(sl_CrosshairOpacity.GetComponentValue());
                break;
            default:
                Client.SetProperty(
                    Config.Index, Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
                break;
        }
        switch (Config.Properties[Sender.Tag].Name)
        {
            case "ReticleColor":
            case "CustomZoomCrosshairColor":
                Client.SetProperty(
                    Config.Index, Sender.Tag, Config.GetProperty(Sender.Tag));
                break;
        }
    }
}

event Free()
{
    Client = None;
    Config = None;
    Super.Free();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=ScopeOverlaySection
        Caption="Scope Overlay"
        WinHeight=0.3
        TopPadding=0.02
        BottomPadding=0.02
        ColumnWidths=(0.5,0.5)
        MaxItemsPerColumn=2
    End Object

    Begin Object class=HxGUIFramedSection Name=CustomScopeOverlaySection
        Caption="Custom Scope Overlay"
        WinHeight=0.7
        TopPadding=0.02
        BottomPadding=0.02
    End Object

    Begin Object class=HxGUIFramedSection Name=CrosshairSection
        Caption="Custom Crosshair"
        WinHeight=0.7
        TopPadding=0.02
        BottomPadding=0.02
    End Object

    Begin Object class=moComboBox Name=ScopeOverlayComboBox
        Caption="Scope overlay"
        Hint="Choose which scope overlay to use."
        INIOption="@INTERNAL"
        Tag=0
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=0
    End Object
    co_ScopeOverlay=ScopeOverlayComboBox

    Begin Object class=moCheckBox Name=CustomCrosshairCheckBox
        Caption="Use custom crosshair"
        Hint="Use custom crosshair while zooming. Requires custom weapon crosshairs enabled to work."
        INIOption="@INTERNAL"
        Tag=6
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=1
    End Object
    ch_CustomCrosshair=CustomCrosshairCheckBox

    Begin Object class=moCheckBox Name=SoundEffectsCheckBox
        Caption="Zoom sound effects"
        Hint="Enable sound effects when zooming in/out."
        INIOption="@INTERNAL"
        Tag=1
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=2
    End Object
    ch_SoundEffects=SoundEffectsCheckBox

    Begin Object class=moCheckBox Name=ShowChargeBarCheckBox
        Caption="Show charge bar"
        Hint="Show charge bar to indicate when it is ready to shoot."
        INIOption="@INTERNAL"
        Tag=2
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=3
    End Object
    ch_ShowChargeBar=ShowChargeBarCheckBox

    Begin Object class=moSlider Name=BackgroundOpacitySlider
        Caption="BG opacity"
        Hint="Change the opacity of the black background around the scope."
        INIOption="@INTERNAL"
        Tag=5
        ComponentWidth=0.64
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=4
    End Object
    sl_BackgroundOpacity=BackgroundOpacitySlider

    Begin Object class=moSlider Name=ReticleRedSlider
        Caption="Red"
        Hint="Change the color of the reticle."
        INIOption="@INTERNAL"
        bIntSlider=true
        Tag=3
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=5
    End Object
    sl_ReticleRedColor=ReticleRedSlider

    Begin Object class=moSlider Name=ReticleGreenSlider
        Caption="Green"
        Hint="Change the color of the reticle."
        INIOption="@INTERNAL"
        bIntSlider=true
        Tag=3
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=6
    End Object
    sl_ReticleGreenColor=ReticleGreenSlider

    Begin Object class=moSlider Name=ReticleBlueSlider
        Caption="Blue"
        Hint="Change the color of the reticle."
        INIOption="@INTERNAL"
        bIntSlider=true
        Tag=3
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=7
    End Object
    sl_ReticleBlueColor=ReticleBlueSlider

    Begin Object class=moSlider Name=ReticleOpacitySlider
        Caption="Opacity"
        Hint="Change the opacity of the reticle."
        INIOption="@INTERNAL"
        bIntSlider=true
        Tag=3
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=8
    End Object
    sl_ReticleOpacity=ReticleOpacitySlider

    Begin Object class=moSlider Name=ReticleScaleSlider
        Caption="Scale"
        Hint="Change the scale of the reticle."
        INIOption="@INTERNAL"
        Tag=4
        ComponentWidth=0.64
        MinValue=0.0
        MaxValue=1.0
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=9
    End Object
    sl_ReticleScale=ReticleScaleSlider

    Begin Object class=moComboBox Name=CustomCrosshairComboBox
        Caption="Crosshair"
        Hint="Choose which crosshair to use."
        INIOption="@INTERNAL"
        Tag=7
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=10
    End Object
    co_CustomCrosshair=CustomCrosshairComboBox

    Begin Object class=moSlider Name=CrosshairRedSlider
        Caption="Red"
        Hint="Change the color of the crosshair."
        INIOption="@INTERNAL"
        bIntSlider=true
        Tag=8
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=11
    End Object
    sl_CrosshairRedColor=CrosshairRedSlider

    Begin Object class=moSlider Name=CrosshairGreenSlider
        Caption="Green"
        Hint="Change the color of the crosshair."
        INIOption="@INTERNAL"
        bIntSlider=true
        Tag=8
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=12
    End Object
    sl_CrosshairGreenColor=CrosshairGreenSlider

    Begin Object class=moSlider Name=CrosshairBlueSlider
        Caption="Blue"
        Hint="Change the color of the crosshair."
        INIOption="@INTERNAL"
        bIntSlider=true
        Tag=8
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=13
    End Object
    sl_CrosshairBlueColor=CrosshairBlueSlider

    Begin Object class=moSlider Name=CrosshairOpacitySlider
        Caption="Opacity"
        Hint="Change the opacity of the crosshair."
        INIOption="@INTERNAL"
        bIntSlider=true
        Tag=8
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=14
    End Object
    sl_CrosshairOpacity=CrosshairOpacitySlider

    Begin Object class=moSlider Name=CrosshairScaleSlider
        Caption="Scale"
        Hint="Change the scale of the crosshair."
        INIOption="@INTERNAL"
        Tag=4
        ComponentWidth=0.64
        MinValue=0.0
        MaxValue=2.0
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=15
    End Object
    sl_CrosshairScale=CrosshairScaleSlider

    PanelCaption="Instagib"
    PanelHint="Instagib options"
    Dependencies=("bZoomInstagib")
    bDoubleColumn=true
    bFillPanelHeight=false
    Sections(0)=ScopeOverlaySection
    Sections(1)=None
    Sections(2)=CustomScopeOverlaySection
    Sections(3)=CrosshairSection
    ScopeOverlayNames(0)="Default"
    ScopeOverlayNames(1)="Custom"
    ScopeOverlayNames(2)="Hidden"
}
