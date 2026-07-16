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
var automated moComboBox co_HighlightMode;
var automated moComboBox co_SpectateAs;
var automated GUIButton b_CustomizeColors;

var localized string DisabledLabel;
var localized string DefaultLabel;
var localized string SkinLabels[3];
var localized string ModeLabels[2];
var localized string RoleLabels[2];
var localized string TeamLabels[2];

var private HxUTClient Client;
var private HxSkinHighlightConfig Config;
var private HxColors Colors;
var private HxSkinHighlightPreview TeammatePreview;
var private HxSkinHighlightPreview EnemyPreview;
var private bool bRenderPreviews;
var private float HighlightIntensity;
var private bool bCanForceModels;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    super.InitComponent(MyController, MyOwner);
    Sections[SECTION_TEAMMATES].Insert(co_Teammates);
    Sections[SECTION_TEAMMATES].Insert(co_TeammateSkin);
    Sections[SECTION_TEAMMATES].Insert(ch_ForceTeammateModel);
    Sections[SECTION_TEAMMATES].Insert(b_ChangeTeammateModel);
    Sections[SECTION_TEAMMATES].Insert(b_TeammatePreviewBox);
    Sections[SECTION_ENEMIES].Insert(co_Enemies);
    Sections[SECTION_ENEMIES].Insert(co_EnemySkin);
    Sections[SECTION_ENEMIES].Insert(ch_ForceEnemyModel);
    Sections[SECTION_ENEMIES].Insert(b_ChangeEnemyModel);
    Sections[SECTION_ENEMIES].Insert(b_EnemyPreviewBox);
    Sections[SECTION_HIT_EFFECTS].Insert(co_ShieldHit);
    Sections[SECTION_HIT_EFFECTS].Insert(co_LinkHit);
    Sections[SECTION_HIT_EFFECTS].Insert(co_ShockHit);
    Sections[SECTION_HIT_EFFECTS].Insert(co_LightningHit);
    Sections[SECTION_ADVANCED].Insert(ch_Randomize);
    Sections[SECTION_ADVANCED].Insert(ch_DisableOnDeadBodies);
    Sections[SECTION_ADVANCED].Insert(co_HighlightMode);
    Sections[SECTION_ADVANCED].Insert(co_SpectateAs);
    Sections[SECTION_ADVANCED].Insert(b_CustomizeColors);
    Client = HxUTClient(ClientManager.Find(class'HxUTClient'));
    Config = HxSkinHighlightConfig(Client.FindConfig(class'HxSkinHighlightConfig'));
    Colors = Client.GetSkinHighlightColors();
    HighlightIntensity = float(Client.GetServerProperty("SkinHighlightIntensity"));
    PopulateColorComboBoxes();
    PopulateSkinTypeComboBox(co_TeammateSkin);
    PopulateSkinTypeComboBox(co_EnemySkin);
    co_HighlightMode.MyComboBox.MyListBox.MyList.bInitializeList = false;
    for (i = 0; i < ArrayCount(ModeLabels); ++i)
    {
        co_HighlightMode.AddItem(ModeLabels[i],,string(GetEnum(enum'EHxHighlightMode', i)));
    }
    co_SpectateAs.MyComboBox.MyListBox.MyList.bInitializeList = false;
    for (i = 0; i < ArrayCount(TeamLabels); ++i)
    {
        co_SpectateAs.AddItem(TeamLabels[i],,string(i));
    }
}

function bool CanShowPanel()
{
    return Client != None;
}

event Opened(GUIComponent Sender)
{
    if (TeammatePreview == None)
    {
        TeammatePreview = ClientManager.Spawn(class'HxSkinHighlightPreview');
        TeammatePreview.HighlightIntensity = HighlightIntensity;
        TeammatePreview.TeamNumber = 0;
        TeammatePreview.DisplayFOV = 15;
        TeammatePreview.Setup(Config.CurrentTeammateModel);
    }
    if (EnemyPreview == None)
    {
        EnemyPreview = ClientManager.Spawn(class'HxSkinHighlightPreview');
        EnemyPreview.HighlightIntensity = HighlightIntensity;
        EnemyPreview.TeamNumber = 1;
        EnemyPreview.DisplayFOV = 15;
        EnemyPreview.Setup(Config.CurrentEnemyModel);
    }
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
    if (Client != None)
    {
        HighlightIntensity = float(Client.GetServerProperty("SkinHighlightIntensity"));
    }
    if (TeammatePreview != None)
    {
        TeammatePreview.HighlightIntensity = HighlightIntensity;
        TeammatePreview.Setup(Config.CurrentTeammateModel);
    }
    if (EnemyPreview != None)
    {
        EnemyPreview.HighlightIntensity = HighlightIntensity;
        EnemyPreview.Setup(Config.CurrentEnemyModel);
    }
    bCanForceModels = Config.CanForceModels();
    SetEnable(ch_ForceTeammateModel, bCanForceModels);
    SetEnable(b_ChangeTeammateModel, bCanForceModels);
    SetEnable(ch_ForceEnemyModel, bCanForceModels);
    SetEnable(b_ChangeEnemyModel, bCanForceModels);
    UpdateSectionHeaders();
    Super.Refresh();
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    GUIMenuOption(Sender).SetComponentValue(Config.GetProperty(Sender.Tag), true);
}

function InternalOnChange(GUIComponent Sender)
{
    Config.SetProperty(Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
    if (Sender == co_HighlightMode)
    {
        UpdateSectionHeaders();
    }
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

function UpdateSectionHeaders()
{
    if (Config.HighlightMode == HX_SHM_TeamBased)
    {
        Sections[SECTION_TEAMMATES].SetHeader(TeamLabels[0]@"("$Config.CurrentTeammateModel$")");
        Sections[SECTION_ENEMIES].SetHeader(TeamLabels[1]@"("$Config.CurrentEnemyModel$")");
    }
    else
    {
        Sections[SECTION_TEAMMATES].SetHeader(RoleLabels[0]@"("$Config.CurrentTeammateModel$")");
        Sections[SECTION_ENEMIES].SetHeader(RoleLabels[1]@"("$Config.CurrentEnemyModel$")");
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
    TeammatePreview.Spin(DeltaX);
    return true;
}

function bool EnemyPreviewOnCapturedMouseMove(float DeltaX, float DeltaY)
{
    EnemyPreview.Spin(DeltaX);
    return true;
}

function bool OnClickChangeTeammateModel(GUIComponent Sender)
{
    local HxGUIModelSelect Page;

    if (Controller.OpenMenu(string(class'HxGUIModelSelect'), Config.CurrentTeammateModel, ""))
    {
        Page = HxGUIModelSelect(Controller.ActivePage);
        Page.OnClose = OnCloseChangeTeammateModel;
        Page.bUseAllowedList = Config.GetAllowedModelList(Page.AllowedList);
        Page.RefreshCharacterList();
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
            Config.SetProperty(12, CharName);
            TeammatePreview.Setup(Config.CurrentTeammateModel);
            UpdateSectionHeaders();
        }
    }
    bRenderPreviews = true;
}

function bool OnClickChangeEnemyModel(GUIComponent Sender)
{
    local HxGUIModelSelect Page;

    if (Controller.OpenMenu(string(class'HxGUIModelSelect'), Config.CurrentEnemyModel, ""))
    {
        Page = HxGUIModelSelect(Controller.ActivePage);
        Page.OnClose = OnCloseChangeEnemyModel;
        Page.bUseAllowedList = Config.GetAllowedModelList(Page.AllowedList);
        Page.RefreshCharacterList();
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
            Config.SetProperty(14, CharName);
            EnemyPreview.Setup(Config.CurrentEnemyModel);
            UpdateSectionHeaders();
        }
    }
    bRenderPreviews = true;
}

function bool OnClickCustomizeColors(GUIComponent Sender)
{
    bRenderPreviews = false;
    Controller.OpenMenu(string(class'HxGUISkinHighlightColorsWindow'));
    Controller.ActivePage.OnClose = OnCloseCustomizeColors;
    return true;
}

function OnCloseCustomizeColors(optional bool bCancelled)
{
    bRenderPreviews = true;
    PopulateColorComboBoxes();
    Refresh();
}

static function PopulateSkinTypeComboBox(moComboBox ComboBox, optional bool bInitializeList)
{
    local int i;

    ComboBox.MyComboBox.MyListBox.MyList.bInitializeList = bInitializeList;
    for (i = 0; i < 3; ++i)
    {
        ComboBox.AddItem(default.SkinLabels[i],,string(GetEnum(enum'EHxSkinType', i)));
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
        WinHeight=0.52
        LineSpacing=0.012
        ColumnSpacing=0.01
        ColumnWidths=(0.6,0.4)
        ExpandIndices=(-1,4)
        MaxItemsPerColumn=4
    End Object

    Begin Object class=HxGUIFramedSection Name=EnemiesSection
        WinHeight=0.52
        LineSpacing=0.012
        ColumnSpacing=0.01
        ColumnWidths=(0.6,0.4)
        ExpandIndices=(-1,4)
        MaxItemsPerColumn=4
    End Object

    Begin Object class=HxGUIFramedSection Name=HitEffectsSection
        Caption="On-Hit Overlay Effects"
        WinHeight=0.48
    End Object

    Begin Object class=HxGUIFramedSection Name=AdvancedSection
        Caption="Advanced Options"
        WinHeight=0.48
    End Object

    Begin Object class=moComboBox Name=TeammatesComboBox
        Caption="Highlight"
        Hint="Highlight color for you and your teammates."
        INIOption="@INTERNAL"
        Tag=0
        CaptionWidth=0.42
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=0
    End Object
    co_Teammates=TeammatesComboBox

    Begin Object class=moComboBox Name=TeammateSkinComboBox
        Caption="Skin type"
        Hint="Skin type to use below the highlight color."
        INIOption="@INTERNAL"
        Tag=6
        CaptionWidth=0.42
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=1
    End Object
    co_TeammateSkin=TeammateSkinComboBox

    Begin Object class=moCheckBox Name=ForceTeammateModel
        Caption="Force model"
        Hint="Force the selected model on teammates."
        INIOption="@INTERNAL"
        Tag=13
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
        CaptionWidth=0.42
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
        CaptionWidth=0.42
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
        CaptionWidth=0.42
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
        CaptionWidth=0.42
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
        CaptionWidth=0.42
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=8
    End Object
    co_Enemies=EnemiesComboBox

    Begin Object class=moComboBox Name=EnemySkinComboBox
        Caption="Skin type"
        Hint="Skin type to use below the highlight color."
        INIOption="@INTERNAL"
        Tag=7
        CaptionWidth=0.42
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=9
    End Object
    co_EnemySkin=EnemySkinComboBox

    Begin Object class=moCheckBox Name=ForceEnemyModel
        Caption="Force model"
        Hint="Force the selected model on enemies."
        INIOption="@INTERNAL"
        Tag=15
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

    Begin Object class=moComboBox Name=HighlightModeComboBox
        Caption="Highlight mode"
        Hint="Choose if highlight is applied based on roles (teammates/enemies) or based on teams (red/blue)."
        INIOption="@INTERNAL"
        Tag=10
        CaptionWidth=0.42
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=14
    End Object
    co_HighlightMode=HighlightModeComboBox

    Begin Object class=moComboBox Name=SpectateAsComboBox
        Caption="Spectate as"
        Hint="Select which team's perspective to spectate as."
        INIOption="@INTERNAL"
        Tag=11
        CaptionWidth=0.42
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=15
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
        TabOrder=16
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
    ModeLabels(0)="Role-based"
    ModeLabels(1)="Team-based"
    RoleLabels(0)="Teammates"
    RoleLabels(1)="Enemies"
    TeamLabels(0)="Red Team"
    TeamLabels(1)="Blue Team"
    bRenderPreviews=true
}
