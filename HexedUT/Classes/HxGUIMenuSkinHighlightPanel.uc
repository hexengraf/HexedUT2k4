class HxGUIMenuSkinHighlightPanel extends HxGUIMenuPanel;

const SECTION_TEAMMATES = 0;
const SECTION_ENEMIES = 1;
const SECTION_HIT_EFFECTS = 2;
const SECTION_ADVANCED = 3;

const NO_HIGHLIGHT = "DISABLED";
const DEFAULT_HIGHLIGHT = "DEFAULT";

var automated moComboBox co_Teammates;
var automated moComboBox co_TeammateSkin;
var automated moCheckBox ch_ForceTeammateModel;
var automated GUIButton b_TeammatePreviewBox;
var automated GUIButton b_ChangeTeammateModel;

var automated moComboBox co_Enemies;
var automated moComboBox co_EnemySkin;
var automated moCheckBox ch_ForceEnemyModel;
var automated GUIButton b_EnemyPreviewBox;
var automated GUIButton b_ChangeEnemyModel;

var automated moComboBox co_ShieldHit;
var automated moComboBox co_LinkHit;
var automated moComboBox co_ShockHit;
var automated moComboBox co_LightningHit;

var automated moCheckBox ch_Randomize;
var automated moCheckBox ch_DisableOnDeadBodies;
var automated moComboBox co_SpectateAs;
var automated GUIButton b_CustomizeColors;

var localized string DisabledLabel;
var localized string DefaultLabel;
var localized string SkinLabels[3];
var localized string TeamLabels[2];

var private HxUTClient Client;
var private HxSkinHighlightConfig Config;
var private HxColors Colors;
var private HxSkinHighlightPreview TeammatePreview;
var private HxSkinHighlightPreview EnemyPreview;
var private bool bRenderPreviews;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Client = HxUTClient(ClientManager.Find(class'HxUTClient'));
    Config = HxSkinHighlightConfig(Client.FindConfig(class'HxSkinHighlightConfig'));
    Colors = Client.GetSkinHighlightColors();
    super.InitComponent(MyController, MyOwner);
    Sections[SECTION_TEAMMATES].Insert(co_Teammates);
    Sections[SECTION_TEAMMATES].Insert(co_TeammateSkin);
    Sections[SECTION_TEAMMATES].Insert(ch_ForceTeammateModel);
    Sections[SECTION_TEAMMATES].Insert(b_TeammatePreviewBox);
    Sections[SECTION_TEAMMATES].Insert(b_ChangeTeammateModel);
    Sections[SECTION_ENEMIES].Insert(co_Enemies);
    Sections[SECTION_ENEMIES].Insert(co_EnemySkin);
    Sections[SECTION_ENEMIES].Insert(ch_ForceEnemyModel);
    Sections[SECTION_ENEMIES].Insert(b_EnemyPreviewBox);
    Sections[SECTION_ENEMIES].Insert(b_ChangeEnemyModel);
    Sections[SECTION_HIT_EFFECTS].Insert(co_ShieldHit);
    Sections[SECTION_HIT_EFFECTS].Insert(co_LinkHit);
    Sections[SECTION_HIT_EFFECTS].Insert(co_ShockHit);
    Sections[SECTION_HIT_EFFECTS].Insert(co_LightningHit);
    Sections[SECTION_ADVANCED].Insert(ch_Randomize);
    Sections[SECTION_ADVANCED].Insert(ch_DisableOnDeadBodies);
    Sections[SECTION_ADVANCED].Insert(co_SpectateAs);
    Sections[SECTION_ADVANCED].Insert(b_CustomizeColors);
    PopulateColorComboBoxes();
    PopulateSkinVariantComboBox(co_TeammateSkin);
    PopulateSkinVariantComboBox(co_EnemySkin);
    co_SpectateAs.MyComboBox.MyListBox.MyList.bInitializeList = false;
    for (i = 0; i < 2; ++i)
    {
        co_SpectateAs.AddItem(TeamLabels[i],,string(i));
    }
}

event Opened(GUIComponent Sender)
{
    if (TeammatePreview == None)
    {
        TeammatePreview = Client.Spawn(class'HxSkinHighlightPreview');
        TeammatePreview.HighlightIntensity = float(
            Client.GetServerProperty("SkinHighlightIntensity"));
        TeammatePreview.TeamNumber = 0;
        TeammatePreview.Setup(Config.TeammateModel);
    }
    if (EnemyPreview == None)
    {
        EnemyPreview = Client.Spawn(class'HxSkinHighlightPreview');
        EnemyPreview.HighlightIntensity = float(
            Client.GetServerProperty("SkinHighlightIntensity"));
        EnemyPreview.TeamNumber = 1;
        EnemyPreview.Setup(Config.EnemyModel);
    }
    AddModelName(ch_ForceTeammateModel, Config.TeammateModel);
    AddModelName(ch_ForceEnemyModel, Config.EnemyModel);
    TeammatePreview.UpdateRotation(PlayerOwner());
    EnemyPreview.UpdateRotation(PlayerOwner());
    Super.Opened(Sender);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    if (TeammatePreview != None)
    {
        TeammatePreview.Destroy();
        TeammatePreview = None;
    }
    if (EnemyPreview != None)
    {
        EnemyPreview.Destroy();
        EnemyPreview = None;
    }
    Super.Closed(Sender, bCancelled);
}

function Refresh()
{
    local float SkinHighlightIntensity;

    SkinHighlightIntensity = float(Client.GetServerProperty("SkinHighlightIntensity"));
    if (TeammatePreview != None)
    {
        TeammatePreview.HighlightIntensity = SkinHighlightIntensity;
    }
    if (EnemyPreview != None)
    {
        EnemyPreview.HighlightIntensity = SkinHighlightIntensity;
    }
    Super.Refresh();
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    GUIMenuOption(Sender).SetComponentValue(Config.GetProperty(Sender.Tag), true);
}

function InternalOnChange(GUIComponent Sender)
{
    Client.SetConfigProperty(Config.Index, Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
    class'HxSkinHighlightConfig'.static.UpdateDynamicActors(PlayerOwner());
}

function PopulateColorComboBoxes()
{
    local array<moComboBox> ComboBoxes;
    local int i;
    local int j;

    ComboBoxes.Length = 6;
    ComboBoxes[0] = co_Teammates;
    ComboBoxes[1] = co_Enemies;
    ComboBoxes[2] = co_ShieldHit;
    ComboBoxes[3] = co_LinkHit;
    ComboBoxes[4] = co_ShockHit;
    ComboBoxes[5] = co_LightningHit;

    for (i = 0; i < ComboBoxes.Length; ++i)
    {
        ComboBoxes[i].MyComboBox.MyListBox.MyList.bInitializeList = false;
        ComboBoxes[i].ResetComponent();
        ComboBoxes[i].AddItem(DisabledLabel,,NO_HIGHLIGHT);
    }
    for (i = 2; i < ComboBoxes.Length; ++i)
    {
        ComboBoxes[i].AddItem(DefaultLabel,,DEFAULT_HIGHLIGHT);
    }
    for (i = 0; i < ComboBoxes.Length; ++i)
    {
        for (j = 0; j < Colors.ColorList.Length; ++j)
        {
            ComboBoxes[i].AddItem(Colors.ColorList[j].Name,, Colors.ColorList[j].Name);
        }
        ComboBoxes[i].LoadINI();
    }
}

function bool TeammatePreviewOnDraw(Canvas C)
{
    b_TeammatePreviewBox.Style.Draw(
        C,
        MenuState,
        b_TeammatePreviewBox.Bounds[0],
        b_TeammatePreviewBox.Bounds[1],
        b_TeammatePreviewBox.Bounds[2] - b_TeammatePreviewBox.Bounds[0],
        b_TeammatePreviewBox.Bounds[3] - b_TeammatePreviewBox.Bounds[1]);
    if (bRenderPreviews)
    {
        TeammatePreview.DrawPreview(
            C,
            b_TeammatePreviewBox.ClientBounds[0],
            b_TeammatePreviewBox.ClientBounds[1],
            b_TeammatePreviewBox.ClientBounds[2] - b_TeammatePreviewBox.ClientBounds[0],
            b_TeammatePreviewBox.ClientBounds[3] - b_TeammatePreviewBox.ClientBounds[1]);
    }
    return true;
}

function bool EnemyPreviewOnDraw(Canvas C)
{
    b_EnemyPreviewBox.Style.Draw(
        C,
        MenuState,
        b_EnemyPreviewBox.Bounds[0],
        b_EnemyPreviewBox.Bounds[1],
        b_EnemyPreviewBox.Bounds[2] - b_EnemyPreviewBox.Bounds[0],
        b_EnemyPreviewBox.Bounds[3] - b_EnemyPreviewBox.Bounds[1]);
    if (bRenderPreviews)
    {
        EnemyPreview.DrawPreview(
            C,
            b_EnemyPreviewBox.ClientBounds[0],
            b_EnemyPreviewBox.ClientBounds[1],
            b_EnemyPreviewBox.ClientBounds[2] - b_EnemyPreviewBox.ClientBounds[0],
            b_EnemyPreviewBox.ClientBounds[3] - b_EnemyPreviewBox.ClientBounds[1]);
    }
    return true;
}

function bool TeammatePreviewOnCapturedMouseMove(float DeltaX, float DeltaY)
{
    if (TeammatePreview != None)
    {
        TeammatePreview.Spin(DeltaX);
    }
    return true;
}

function bool EnemyPreviewOnCapturedMouseMove(float DeltaX, float DeltaY)
{
    if (EnemyPreview != None)
    {
        EnemyPreview.Spin(DeltaX);
    }
    return true;
}

function bool OnClickChangeTeammateModel(GUIComponent Sender)
{
    if (Controller.OpenMenu(string(class'HxGUIModelSelect'), Config.TeammateModel, ""))
    {
        Controller.ActivePage.OnClose = OnCloseChangeTeammateModel;
        bRenderPreviews = false;
    }
    return true;
}

function OnCloseChangeTeammateModel(optional bool bCancelled)
{
    local string CharName;

    if (!bCancelled)
    {
        CharName = Controller.ActivePage.GetDataString();
        if (CharName != "")
        {
            Client.SetConfigProperty(Config.Index, 11, CharName);
            class'HxSkinHighlightConfig'.static.UpdateDynamicActors(PlayerOwner());
            TeammatePreview.Setup(Config.TeammateModel);
            AddModelName(ch_ForceTeammateModel, Config.TeammateModel);
        }
    }
    bRenderPreviews = true;
}

function bool OnClickChangeEnemyModel(GUIComponent Sender)
{
    if (Controller.OpenMenu(string(class'HxGUIModelSelect'), Config.EnemyModel, ""))
    {
        Controller.ActivePage.OnClose = OnCloseChangeEnemyModel;
        bRenderPreviews = false;
    }
    return true;
}

function OnCloseChangeEnemyModel(optional bool bCancelled)
{
    local string CharName;

    if (!bCancelled)
    {
        CharName = Controller.ActivePage.GetDataString();
        if (CharName != "")
        {
            Client.SetConfigProperty(Config.Index, 13, CharName);
            class'HxSkinHighlightConfig'.static.UpdateDynamicActors(PlayerOwner());
            EnemyPreview.Setup(Config.EnemyModel);
            AddModelName(ch_ForceEnemyModel, Config.EnemyModel);
        }
    }
    bRenderPreviews = true;
}

function bool OnClickCustomizeColors(GUIComponent Sender)
{
    bRenderPreviews = false;
    Controller.OpenMenu(string(class'HxGUISkinHighlightColorsMenu'));
    Controller.ActivePage.OnClose = OnCloseCustomizeColors;
    return true;
}

function OnCloseCustomizeColors(optional bool bCancelled)
{
    bRenderPreviews = true;
    PopulateColorComboBoxes();
    Refresh();
}

static function PopulateSkinVariantComboBox(moComboBox ComboBox, optional bool bInitializeList)
{
    local int i;

    ComboBox.MyComboBox.MyListBox.MyList.bInitializeList = bInitializeList;
    for (i = 0; i < 3; ++i)
    {
        ComboBox.AddItem(default.SkinLabels[i],,string(GetEnum(enum'EHxSkinVariant', i)));
    }
}

static function AddModelName(GUIMenuOption Option, string Name)
{
    local string Left;
    local string Right;

    if (Divide(Option.Caption, "(", Left, Right))
    {
        Option.SetCaption(Left$"("$Name$")");
    }
}

event Free()
{
    Client = None;
    Config = None;
    Colors = None;
    if (TeammatePreview != None)
    {
        TeammatePreview.Destroy();
        TeammatePreview = None;
    }
    if (EnemyPreview != None)
    {
        EnemyPreview.Destroy();
        EnemyPreview = None;
    }
    Super.Free();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=TeammatesSection
        Caption="Teammates"
        WinHeight=0.645
        LineSpacing=0.012
        ExpandIndices=(3)
    End Object

    Begin Object class=HxGUIFramedSection Name=EnemiesSection
        Caption="Enemies"
        WinHeight=0.645
        LineSpacing=0.012
        ExpandIndices=(3)
    End Object

    Begin Object class=HxGUIFramedSection Name=HitEffectsSection
        Caption="On-Hit Overlay Effects"
        WinHeight=0.355
    End Object

    Begin Object class=HxGUIFramedSection Name=AdvancedSection
        Caption="Advanced Options"
        WinHeight=0.355
    End Object

    Begin Object class=moComboBox Name=TeammatesComboBox
        Caption="Highlight"
        Hint="Highlight color for you and your teammates."
        INIOption="@INTERNAL"
        Tag=0
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=0
    End Object
    co_Teammates=TeammatesComboBox

    Begin Object class=moComboBox Name=TeammateSkinComboBox
        Caption="Skin variant"
        Hint="Skin variant to use below the highlight color."
        INIOption="@INTERNAL"
        Tag=6
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=1
    End Object
    co_TeammateSkin=TeammateSkinComboBox

    Begin Object class=moCheckBox Name=ForceTeammateModel
        Caption="Force model ()"
        Hint="Force the selected model on teammates."
        INIOption="@INTERNAL"
        Tag=12
        CaptionWidth=0.8
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=2
    End Object
    ch_ForceTeammateModel=ForceTeammateModel

    Begin Object class=GUIButton Name=TeammatePreviewBoxButton
        StyleName="HxBackgroundDarker"
        bStandardized=false
        bTabStop=false
        bNeverFocus=true
        bDropTarget=true
        OnDraw=TeammatePreviewOnDraw
        OnCapturedMouseMove=TeammatePreviewOnCapturedMouseMove
    End Object
    b_TeammatePreviewBox=TeammatePreviewBoxButton

    Begin Object class=GUIButton Name=ChangeTeammateModelButton
        Caption="Change Model"
        Hint="Select a different teammate model."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickChangeTeammateModel
        TabOrder=3
    End Object
    b_ChangeTeammateModel=ChangeTeammateModelButton

    Begin Object class=moComboBox Name=ShieldHitComboBox
        Caption="Shield hit"
        Hint="Highlight color to use when a shielded player is hit or has spawn protection."
        INIOption="@INTERNAL"
        Tag=2
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=4
    End Object
    co_ShieldHit=ShieldHitComboBox

    Begin Object class=moComboBox Name=LinkHitComboBox
        Caption="Link hit"
        Hint="Highlight color to use when a player is hit with a link gun."
        INIOption="@INTERNAL"
        Tag=3
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=5
    End Object
    co_LinkHit=LinkHitComboBox

    Begin Object class=moComboBox Name=ShockHitComboBox
        Caption="Shock hit"
        Hint="Highlight color to use when a player is hit with a shock rifle."
        INIOption="@INTERNAL"
        Tag=4
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=6
    End Object
    co_ShockHit=ShockHitComboBox

    Begin Object class=moComboBox Name=LightningHitComboBox
        Caption="Lightning hit"
        Hint="Highlight color to use when a player is hit with a lightning gun."
        INIOption="@INTERNAL"
        Tag=5
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=7
    End Object
    co_LightningHit=LightningHitComboBox

    Begin Object class=moComboBox Name=EnemiesComboBox
        Caption="Highlight"
        Hint="Highlight color for you and your enemies."
        INIOption="@INTERNAL"
        Tag=1
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=8
    End Object
    co_Enemies=EnemiesComboBox

    Begin Object class=moComboBox Name=EnemySkinComboBox
        Caption="Skin variant"
        Hint="Skin variant to use below the highlight color."
        INIOption="@INTERNAL"
        Tag=7
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=9
    End Object
    co_EnemySkin=EnemySkinComboBox

    Begin Object class=moCheckBox Name=ForceEnemyModel
        Caption="Force model ()"
        Hint="Force the selected model on enemies."
        INIOption="@INTERNAL"
        Tag=14
        CaptionWidth=0.8
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=10
    End Object
    ch_ForceEnemyModel=ForceEnemyModel

    Begin Object class=GUIButton Name=EnemyPreviewBoxButton
        StyleName="HxBackgroundDarker"
        bStandardized=false
        bTabStop=false
        bNeverFocus=true
        bDropTarget=true
        OnDraw=EnemyPreviewOnDraw
        OnCapturedMouseMove=EnemyPreviewOnCapturedMouseMove
    End Object
    b_EnemyPreviewBox=EnemyPreviewBoxButton

    Begin Object class=GUIButton Name=ChangeEnemyModelButton
        Caption="Change Model"
        Hint="Select a different teammate model."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickChangeEnemyModel
        TabOrder=11
    End Object
    b_ChangeEnemyModel=ChangeEnemyModelButton

    Begin Object class=moCheckBox Name=RandomizeCheckBox
        Caption="Randomize highlights"
        Hint="Assign a random highlight to each player. Only applies to DM and other modes with no teams."
        INIOption="@INTERNAL"
        Tag=8
        CaptionWidth=0.8
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=12
    End Object
    ch_Randomize=RandomizeCheckBox

    Begin Object class=moCheckBox Name=DisableOnDeadBodiesCheckBox
        Caption="Disable highlight on dead bodies"
        Hint="Disable any active highlights on dead bodies."
        INIOption="@INTERNAL"
        Tag=9
        CaptionWidth=0.8
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=13
    End Object
    ch_DisableOnDeadBodies=DisableOnDeadBodiesCheckBox

    Begin Object class=moComboBox Name=SpectateAsComboBox
        Caption="Spectate as"
        Hint="Select which team's perspective to spectate as."
        INIOption="@INTERNAL"
        Tag=10
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=14
    End Object
    co_SpectateAs=SpectateAsComboBox

    Begin Object class=GUIButton Name=CustomizeColorsBoxButton
        Caption="Customize Colors"
        Hint="Customize the colors available to use as highlight."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickCustomizeColors
        TabOrder=15
    End Object
    b_CustomizeColors=CustomizeColorsBoxButton

    PanelCaption="Skin Highlight"
    PanelHint="Skin highlight options"
    Dependencies=("bAllowSkinHighlight")
    bDoubleColumn=true
    bFillPanelHeight=false
    Sections(0)=TeammatesSection
    Sections(1)=EnemiesSection
    Sections(2)=HitEffectsSection
    Sections(3)=AdvancedSection
    DisabledLabel="Disabled"
    DefaultLabel="Default"
    SkinLabels(0)="Red Team"
    SkinLabels(1)="Blue Team"
    SkinLabels(2)="Normal"
    TeamLabels(0)="Red Team"
    TeamLabels(1)="Blue Team"
    bRenderPreviews=true
}
