class HxGUIMenuSkinHighlightPanel extends HxGUIMenuPanel;

const SECTION_HIGHLIGHTS = 0;
const SECTION_COLOR_EDITOR = 1;

const NO_HIGHLIGHT = "DISABLED";
const RANDOM_HIGHLIGHT = "RANDOM";
const DEFAULT_HIGHLIGHT = "DEFAULT";

var automated moComboBox co_YourTeam;
var automated moComboBox co_EnemyTeam;
var automated moComboBox co_SoloPlayer;
var automated moComboBox co_ShieldHit;
var automated moComboBox co_LinkHit;
var automated moComboBox co_ShockHit;
var automated moComboBox co_LightningHit;
var automated moCheckBox ch_DisableOnDeadBodies;
var automated moCheckBox ch_ForceNormalSkins;
var automated moComboBox co_SpectateAs;
var automated moComboBox co_EditColor;
var automated moSlider sl_ColorRed;
var automated moSlider sl_ColorGreen;
var automated moSlider sl_ColorBlue;
var automated moCheckBox ch_AllowOnRandom;
var automated GUILabel l_ButtonAnchor;
var automated GUIButton b_NewColor;
var automated GUIButton b_RenameColor;
var automated GUIButton b_DeleteColor;
var automated GUIComboBox co_PreviewSkin;
var automated GUIButton b_PreviewBox;
var automated GUIButton b_ChangeModel;

var localized string DisabledLabel;
var localized string DefaultLabel;
var localized string NameLabel;
var localized string NewColorPageCaption;
var localized string RenameColorPageCaption;
var localized string ConfirmColorDeletionLabel;
var localized string InvalidNamePrefix;
var localized string InvalidNameSuffix;
var localized string SkinLabels[3];
var localized string TeamLabels[2];

var private HxUTClient Client;
var private HxSkinHighlightConfig Config;
var private HxColors Colors;
var private xUtil.PlayerRecord PreviewRec;
var private int PreviewSkinVariation;
var private SpinnyWeap PreviewModel;
var private ConstantColor PreviewEffect;
var private Shader PreviewShader;
var private Rotator PreviewRotation;
var private vector PreviewOffset;
var private float PreviewSpin;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Client = HxUTClient(ClientManager.Find(class'HxUTClient'));
    Config = HxSkinHighlightConfig(Client.FindConfig(class'HxSkinHighlightConfig'));
    Colors = Client.GetSkinHighlightColors();
    super.InitComponent(MyController, MyOwner);
    Sections[SECTION_HIGHLIGHTS].Insert(co_YourTeam);
    Sections[SECTION_HIGHLIGHTS].Insert(co_EnemyTeam);
    Sections[SECTION_HIGHLIGHTS].Insert(co_SoloPlayer);
    Sections[SECTION_HIGHLIGHTS].Insert(ch_DisableOnDeadBodies);
    Sections[SECTION_HIGHLIGHTS].Insert(ch_ForceNormalSkins);
    Sections[SECTION_HIGHLIGHTS].Insert(co_ShieldHit);
    Sections[SECTION_HIGHLIGHTS].Insert(co_LinkHit);
    Sections[SECTION_HIGHLIGHTS].Insert(co_ShockHit);
    Sections[SECTION_HIGHLIGHTS].Insert(co_LightningHit);
    Sections[SECTION_HIGHLIGHTS].Insert(co_SpectateAs);
    Sections[SECTION_COLOR_EDITOR].Insert(co_EditColor);
    Sections[SECTION_COLOR_EDITOR].Insert(sl_ColorRed);
    Sections[SECTION_COLOR_EDITOR].Insert(sl_ColorGreen);
    Sections[SECTION_COLOR_EDITOR].Insert(sl_ColorBlue);
    Sections[SECTION_COLOR_EDITOR].Insert(ch_AllowOnRandom);
    Sections[SECTION_COLOR_EDITOR].Insert(l_ButtonAnchor);
    Sections[SECTION_COLOR_EDITOR].Insert(co_PreviewSkin);
    Sections[SECTION_COLOR_EDITOR].Insert(b_PreviewBox);
    Sections[SECTION_COLOR_EDITOR].Insert(b_ChangeModel);
    PreviewEffect = New(Self) class'ConstantColor';
    PreviewShader = New(Self) class'Shader';
    PreviewShader.Specular = PreviewEffect;
    PopulateColorComboBoxes();

    for (i = 0; i < 3; ++i)
    {
        co_PreviewSkin.AddItem(SkinLabels[i]);
    }
    for (i = 0; i < 2; ++i)
    {
        co_SpectateAs.AddItem(TeamLabels[i],,string(i));
    }
}

event Opened(GUIComponent Sender)
{
    if (PreviewModel != None)
    {
        UpdatePreviewModelRotation(PlayerOwner());
    }
    Super.Opened(Sender);
}

function Refresh()
{
    UpdatePreviewColor();
    Sections[SECTION_HIGHLIGHTS].SetHide(
        !bool(Client.GetServerProperty("bAllowSkinHighlight")), HideDueDisable);
    Super.Refresh();
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    GUIMenuOption(Sender).SetComponentValue(Config.GetProperty(Sender.Tag), true);
}

function InternalOnChange(GUIComponent Sender)
{
    Client.SetConfigProperty(
        Config.Index, Sender.Tag, GUIMenuOption(Sender).GetComponentValue());
    Config.ApplyDefaultConfiguration();
    ApplyHighlightChanges(PlayerOwner());
}

function CustomizeColorOnLoadINI(GUIComponent Sender, string s)
{
    local HxColors.HxColor ColorEntry;

    if (Sender == ch_AllowOnRandom)
    {
        Colors.FindEntry(co_EditColor.GetComponentValue(), ColorEntry);
        ch_AllowOnRandom.Checked(ColorEntry.bRandom);
    }
    else
    {
        Colors.FindEntry(co_EditColor.GetComponentValue(), ColorEntry);
        switch (Sender)
        {
            case sl_ColorRed:
                sl_ColorRed.SetComponentValue(ColorEntry.Color.R, true);
                break;
            case sl_ColorGreen:
                sl_ColorGreen.SetComponentValue(ColorEntry.Color.G, true);
                break;
            case sl_ColorBlue:
                sl_ColorBlue.SetComponentValue(ColorEntry.Color.B, true);
                break;
        }
    }
    UpdatePreviewColor();
}

function CustomizeColorOnChange(GUIComponent Sender)
{
    local int Index;

    Index = co_EditColor.GetIndex();
    if (Sender == co_EditColor)
    {
        UpdateColorEditorSection(co_EditColor.GetComponentValue());
    }
    else if (Sender == ch_AllowOnRandom)
    {
        if (Colors.SetRandom(Index, ch_AllowOnRandom.IsChecked()))
        {
            ApplyHighlightChanges(PlayerOwner());
        }
    }
    else if (Index < Colors.List.Length)
    {
        switch (Sender)
        {
            case sl_ColorRed:
                Colors.List[Index].Color.R = sl_ColorRed.GetValue();
                break;
            case sl_ColorGreen:
                Colors.List[Index].Color.G = sl_ColorGreen.GetValue();
                break;
            case sl_ColorBlue:
                Colors.List[Index].Color.B = sl_ColorBlue.GetValue();
                break;
        }
        ApplyHighlightChanges(PlayerOwner());
    }
    UpdatePreviewColor();
}

function PreviewSkinOnChange(GUIComponent Sender)
{
    PreviewSkinVariation = GUIComboBox(Sender).GetIndex() - 1;
    if (PreviewModel != None)
    {
        UpdatePreviewModelSkins();
    }
}

function PopulateColorComboBoxes()
{
    local array<moComboBox> ComboBoxes;
    local int Index;
    local int i;
    local int j;

    ComboBoxes.Length = 4;
    ComboBoxes[0] = co_YourTeam;
    ComboBoxes[1] = co_EnemyTeam;
    ComboBoxes[2] = co_SoloPlayer;
    ComboBoxes[3] = co_ShieldHit;
    ComboBoxes[4] = co_LinkHit;
    ComboBoxes[5] = co_ShockHit;
    ComboBoxes[6] = co_LightningHit;
    ComboBoxes[7] = co_EditColor;

    Index = co_EditColor.GetIndex();
    for (i = 0; i < ComboBoxes.Length; ++i)
    {
        ComboBoxes[i].bIgnoreChange = true;
        ComboBoxes[i].ResetComponent();
    }
    for (i = 0; i < ComboBoxes.Length - 1; ++i)
    {
        ComboBoxes[i].AddItem(DisabledLabel,,NO_HIGHLIGHT);
    }
    for (i = 3; i < ComboBoxes.Length - 1; ++i)
    {
        ComboBoxes[i].AddItem(DefaultLabel,,DEFAULT_HIGHLIGHT);
    }
    co_SoloPlayer.AddItem("Random",,RANDOM_HIGHLIGHT);
    for (i = 0; i < Colors.List.Length; ++i)
    {
        for (j = 0; j < ComboBoxes.Length; ++j)
        {
            ComboBoxes[j].AddItem(Colors.List[i].ColorName,, Colors.List[i].ColorName);
        }
    }
    for (i = 0; i < ComboBoxes.Length - 1; ++i)
    {
        ComboBoxes[i].LoadINI();
        ComboBoxes[i].bIgnoreChange = false;
    }
    if (Index > -1)
    {
        co_EditColor.SilentSetIndex(Min(Index, co_EditColor.ItemCount() - 1));
    }
    co_EditColor.bIgnoreChange = false;
}

function ApplyHighlightChanges(PlayerController PC)
{
    local HxSkinHighlight SkinHighlight;

    if (PC != None)
    {
        ForEach PC.DynamicActors(class'HxSkinHighlight', SkinHighlight)
        {
            SkinHighlight.Reinitialize();
        }
    }
}

function UpdateColorEditorSection(string ColorName)
{
    local HxColors.HxColor ColorEntry;

    Colors.FindEntry(ColorName, ColorEntry);
    sl_ColorRed.SetComponentValue(ColorEntry.Color.R, true);
    sl_ColorGreen.SetComponentValue(ColorEntry.Color.G, true);
    sl_ColorBlue.SetComponentValue(ColorEntry.Color.B, true);
    ch_AllowOnRandom.Checked(ColorEntry.bRandom);
}

function bool PreviewOnDraw(canvas C)
{
    local rotator CameraRotation;
    local vector CameraPosition;
    local vector X;
    local vector Y;
    local vector Z;

    if (PreviewModel == None)
    {
        SpawnPreviewModel(PlayerOwner());
    }
    else
    {
        if (PreviewModel.OverlayMaterial == None)
        {
            PreviewModel.SetOverlayMaterial(PreviewShader, 300, false);
        }
        C.GetCameraLocation(CameraPosition, CameraRotation);
        GetAxes(CameraRotation, X, Y, Z);
        PreviewModel.SetLocation(
            CameraPosition + (PreviewOffset.X * X) + (PreviewOffset.Y * Y) + (PreviewOffset.Z * Z));
        C.DrawActorClipped(
            PreviewModel,
            false,
            b_PreviewBox.ActualLeft(),
            b_PreviewBox.ActualTop(),
            b_PreviewBox.ActualWidth(),
            b_PreviewBox.ActualHeight(),
            true,
            30);
    }
    return true;
}

function bool PreviewOnCapturedMouseMove(float DeltaX, float DeltaY)
{
    local Rotator Delta;
    local Vector X;
    local Vector Y;
    local Vector Z;

    PreviewSpin -= 256 * DeltaX;
    Delta.Yaw = PreviewSpin;
    GetAxes(PreviewRotation, X, Y, Z);
    X = vector(Delta) >> PreviewRotation;
    Delta.Yaw += 16384;
    Y = vector(Delta) >> PreviewRotation;
    PreviewModel.SetRotation(OrthoRotation(X, Y, Z));
    return true;
}

function SpawnPreviewModel(PlayerController PC)
{
    if (PC == None || PC.PlayerReplicationInfo == None)
    {
        return;
    }
    if (PC.PlayerReplicationInfo.CharacterName != "")
    {
        PreviewRec = class'xUtil'.static.FindPlayerRecord(PC.PlayerReplicationInfo.CharacterName);
    }
    else
    {
        PreviewRec = class'xUtil'.static.FindPlayerRecord(class'xPawn'.default.PlacedCharacterName);
    }
    PreviewModel = PC.spawn(class'XInterface.SpinnyWeap');
    PreviewModel.SetDrawType(DT_Mesh);
    PreviewModel.SetDrawScale(1.0);
    PreviewModel.bHidden = true;
    PreviewModel.bPlayCrouches = false;
    PreviewModel.bPlayRandomAnims = false;
    PreviewModel.SpinRate = 0;
    PreviewModel.AmbientGlow = 40;
    UpdatePreviewModelRotation(PC);
    UpdatePreviewModelSkins();
}

function UpdatePreviewModelRotation(PlayerController PC)
{
    PreviewRotation = PC.Rotation;
    PreviewRotation.Pitch += 32768;
    PreviewRotation.Roll += 32768;
    PreviewModel.SetRotation(PreviewRotation);
    PreviewSpin = 0;
}

function UpdatePreviewModelSkins()
{
    local string BodySkinName;
    local string FaceSkinName;
    local Mesh ModelMesh;

    ModelMesh = Mesh(DynamicLoadObject(PreviewRec.MeshName, class'Mesh'));
    BodySkinName = PreviewRec.BodySkinName;
    FaceSkinName = PreviewRec.FaceSkinName;
    if (PreviewSkinVariation > -1)
    {
        if (class'DMMutator'.default.bBrightSkins && Left(BodySkinName, 12) ~= "PlayerSkins.")
        {
            BodySkinName = "Bright"$BodySkinName$"_"$PreviewSkinVariation$"B";
        }
        else
        {
            BodySkinName $= "_"$PreviewSkinVariation;
        }
        if (PreviewRec.TeamFace)
        {
            FaceSkinName $= "_"$PreviewSkinVariation;
        }
    }
    PreviewModel.Skins[0] = Material(DynamicLoadObject(BodySkinName, class'Material', true));
    PreviewModel.Skins[1] = Material(DynamicLoadObject(FaceSkinName, class'Material', true));
    if(ModelMesh != None && PreviewModel.Skins[0] != None && PreviewModel.Skins[1] != None)
    {
        PreviewModel.LinkMesh(ModelMesh);
        PreviewModel.LoopAnim('Idle_Rest', 1.0 / PreviewModel.Level.TimeDilation);
    }
}

function UpdatePreviewColor()
{
    local float ColorMultiplier;

    ColorMultiplier = float(Client.GetServerProperty("SkinHighlightIntensity"));
    Colors.Find(co_EditColor.GetComponentValue(), PreviewEffect.Color);
    PreviewEffect.Color.R = PreviewEffect.Color.R * ColorMultiplier;
    PreviewEffect.Color.G = PreviewEffect.Color.G * ColorMultiplier;
    PreviewEffect.Color.B = PreviewEffect.Color.B * ColorMultiplier;
}

function bool ColorEditorButtonsOnPreDraw(Canvas C)
{
    if (l_ButtonAnchor.bInit)
    {
        l_ButtonAnchor.bInit = Sections[SECTION_COLOR_EDITOR].bInit;
        b_NewColor.WinLeft = l_ButtonAnchor.WinLeft;
        b_NewColor.WinTop = l_ButtonAnchor.WinTop;
        b_NewColor.WinWidth = l_ButtonAnchor.WinWidth / 3 - 0.0025;
        b_RenameColor.WinLeft = b_NewColor.WinLeft + b_NewColor.WinWidth + 0.005;
        b_RenameColor.WinTop = l_ButtonAnchor.WinTop;
        b_RenameColor.WinWidth = b_NewColor.WinWidth;
        b_DeleteColor.WinLeft = b_RenameColor.WinLeft + b_RenameColor.WinWidth + 0.005;
        b_DeleteColor.WinTop = l_ButtonAnchor.WinTop;
        b_DeleteColor.WinWidth = b_NewColor.WinWidth;
    }
    return false;
}

function bool OnClickNewColor(GUIComponent Sender)
{
    if (Controller.OpenMenu(string(class'HxGUIGetDataMenu'), NewColorPageCaption, NameLabel))
    {
        Controller.ActivePage.SetDataString(Colors.RandomName());
        Controller.ActivePage.OnClose = OnCloseNewColor;
    }
    return true;
}

function OnCloseNewColor(optional bool bCancelled)
{
    local string ColorName;
    local int Index;

    if (!bCancelled)
    {
        ColorName = Controller.ActivePage.GetDataString();
        Index = Colors.Insert(ColorName);
        if (Index != -1)
        {
            PopulateColorComboBoxes();
            co_EditColor.SilentSetIndex(Index);
            UpdateColorEditorSection(ColorName);
        }
        else
        {
            ShowInvalidNameDialog(ColorName);
        }
    }
}

function bool OnClickRenameColor(GUIComponent Sender)
{
    if (Controller.OpenMenu(string(class'HxGUIGetDataMenu'), RenameColorPageCaption, NameLabel))
    {
        Controller.ActivePage.SetDataString(co_EditColor.GetText());
        Controller.ActivePage.OnClose = OnCloseRenameColor;
    }
    return true;
}

function OnCloseRenameColor(optional bool bCancelled)
{
    local string OldColorName;
    local string ColorName;

    if (!bCancelled)
    {
        OldColorName = co_EditColor.GetText();
        ColorName = Controller.ActivePage.GetDataString();
        if (ColorName != OldColorName)
        {
            if (Colors.Rename(co_EditColor.GetIndex(), ColorName))
            {
                Config.RenameColor(OldColorName, ColorName);
                PopulateColorComboBoxes();
                ApplyHighlightChanges(PlayerOwner());
            }
            else
            {
                ShowInvalidNameDialog(ColorName);
            }
        }
    }
}

function bool OnClickDeleteColor(GUIComponent Sender)
{
    if (Controller.OpenMenu(string(class'HxGUIQuestionPage')))
    {
        GUIQuestionPage(Controller.ActivePage).SetupQuestion(
            ConfirmColorDeletionLabel, QBTN_YesNo, QBTN_Yes);
        GUIQuestionPage(Controller.ActivePage).OnButtonClick = OnCloseDeleteColor;
    }
    return true;
}

function OnCloseDeleteColor(byte bButton)
{
    if (bButton == QBTN_Yes && Colors.Remove(co_EditColor.GetIndex()))
    {
        PopulateColorComboBoxes();
        UpdateColorEditorSection(co_EditColor.GetComponentValue());
        Config.ValidateColors(Colors);
        ApplyHighlightChanges(PlayerOwner());
    }
}

function bool OnClickChangeModel(GUIComponent Sender)
{
    if (Controller.OpenMenu("GUI2K4.UT2K4ModelSelect", PreviewRec.DefaultName, ""))
    {
        Controller.ActivePage.OnClose = OnCloseChangeModel;
    }
    return true;
}

function OnCloseChangeModel(optional bool bCancelled)
{
    local string CharName;

    if (!bCancelled)
    {
        CharName = Controller.ActivePage.GetDataString();
        if (CharName != "")
        {
            PreviewRec = class'xUtil'.static.FindPlayerRecord(CharName);
            UpdatePreviewModelSkins();
        }
    }
}

function ShowInvalidNameDialog(string Name)
{
    if (Controller.OpenMenu(string(class'HxGUIQuestionPage')))
    {
        GUIQuestionPage(Controller.ActivePage).SetupQuestion(
            InvalidNamePrefix@"\""$Name$"\""@InvalidNameSuffix, QBTN_Ok, QBTN_Ok);
    }
}

function Free()
{
    if (PreviewModel != None)
    {
        PreviewModel.Destroy();
        PreviewModel = None;
    }
    PreviewEffect = None;
    PreviewShader = None;
    Super.Free();
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=HighlightsSection
        Caption="Highlights"
        WinHeight=0.44
        ColumnWidths=(0.5,0.5)
        MaxItemsPerColumn=5
    End Object

    Begin Object class=HxGUIFramedSection Name=ColorEditorSection
        Caption="Color Editor"
        WinHeight=0.56
        ColumnWidths=(0.5,0.5)
        MaxItemsPerColumn=6
        ExpandIndex=7
    End Object

    Begin Object class=moComboBox Name=YourTeamComboBox
        Caption="Your team"
        Hint="Highlight color for your team."
        INIOption="@INTERNAL"
        Tag=0
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=0
    End Object
    co_YourTeam=YourTeamComboBox

    Begin Object class=moComboBox Name=EnemyTeamComboBox
        Caption="Enemy team"
        Hint="Highlight color for the enemy team."
        INIOption="@INTERNAL"
        Tag=1
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=1
    End Object
    co_EnemyTeam=EnemyTeamComboBox

    Begin Object class=moComboBox Name=SoloPlayerComboBox
        Caption="Solo player"
        Hint="Highlight color for players on game modes with no team. Random assigns a random color for each player."
        INIOption="@INTERNAL"
        Tag=2
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=2
    End Object
    co_SoloPlayer=SoloPlayerComboBox

    Begin Object class=moCheckBox Name=DisableOnDeadBodiesCheckBox
        Caption="Disable highlight on dead bodies"
        Hint="Disable any active highlights on dead bodies."
        INIOption="@INTERNAL"
        Tag=7
        CaptionWidth=0.8
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=3
    End Object
    ch_DisableOnDeadBodies=DisableOnDeadBodiesCheckBox

    Begin Object class=moCheckBox Name=ForceNormalSkinsCheckBox
        Caption="Force normal skins"
        Hint="When highlight is enabled, force normal (uncolored) variation of the underlying skin."
        INIOption="@INTERNAL"
        Tag=8
        CaptionWidth=0.8
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=4
    End Object
    ch_ForceNormalSkins=ForceNormalSkinsCheckBox

    Begin Object class=moComboBox Name=ShieldHitComboBox
        Caption="Shield hit"
        Hint="Highlight color to use when a shielded player is hit or has spawn protection."
        INIOption="@INTERNAL"
        Tag=3
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=5
    End Object
    co_ShieldHit=ShieldHitComboBox

    Begin Object class=moComboBox Name=LinkHitComboBox
        Caption="Link hit"
        Hint="Highlight color to use when a player is hit with a link gun."
        INIOption="@INTERNAL"
        Tag=4
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=6
    End Object
    co_LinkHit=LinkHitComboBox

    Begin Object class=moComboBox Name=ShockHitComboBox
        Caption="Shock hit"
        Hint="Highlight color to use when a player is hit with a shock rifle."
        INIOption="@INTERNAL"
        Tag=5
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=7
    End Object
    co_ShockHit=ShockHitComboBox

    Begin Object class=moComboBox Name=LightningHitComboBox
        Caption="Lightning hit"
        Hint="Highlight color to use when a player is hit with a lightning gun."
        INIOption="@INTERNAL"
        Tag=6
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=8
    End Object
    co_LightningHit=LightningHitComboBox

    Begin Object class=moComboBox Name=SpectateAsComboBox
        Caption="Spectate as"
        Hint="Select which team's perspective to spectate as."
        INIOption="@INTERNAL"
        Tag=9
        ComponentWidth=0.64
        bReadOnly=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=9
    End Object
    co_SpectateAs=SpectateAsComboBox

    Begin Object class=moComboBox Name=EditColorComboBox
        Caption="Color"
        Hint="Color to customize."
        ComponentWidth=0.64
        bReadOnly=true
        OnChange=CustomizeColorOnChange
        TabOrder=10
    End Object
    co_EditColor=EditColorComboBox

    Begin Object class=moSlider Name=ColorRedSlider
        Caption="Red"
        INIOption="@INTERNAL"
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
        TabOrder=11
    End Object
    sl_ColorRed=ColorRedSlider

    Begin Object class=moSlider Name=ColorGreenSlider
        Caption="Green"
        INIOption="@INTERNAL"
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
        TabOrder=12
    End Object
    sl_ColorGreen=ColorGreenSlider

    Begin Object class=moSlider Name=ColorBlueSlider
        Caption="Blue"
        INIOption="@INTERNAL"
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
        TabOrder=13
    End Object
    sl_ColorBlue=ColorBlueSlider

    Begin Object class=moCheckBox Name=AllowOnRandomCheckBox
        Caption="Allow color on random highlight"
        Hint="Allow this color to be used on random highlight."
        INIOption="@INTERNAL"
        CaptionWidth=0.8
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
        TabOrder=14
    End Object
    ch_AllowOnRandom=AllowOnRandomCheckBox

    Begin Object class=GUILabel Name=ButtonAnchorLabel
        StandardHeight=0.03
        bStandardized=true
        bInit=true
        OnPreDraw=ColorEditorButtonsOnPreDraw
    End Object
    l_ButtonAnchor=ButtonAnchorLabel

    Begin Object Class=GUIButton Name=NewColorButton
        Caption="New"
        Hint="Add new color."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickNewColor
        TabOrder=15
    End Object
    b_NewColor=NewColorButton

    Begin Object Class=GUIButton Name=RenameColorButton
        Caption="Rename"
        Hint="Rename current color."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickRenameColor
        TabOrder=16
    End Object
    b_RenameColor=RenameColorButton

    Begin Object Class=GUIButton Name=DeleteColorButton
        Caption="Delete"
        Hint="Delete current color."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickDeleteColor
        TabOrder=17
    End Object
    b_DeleteColor=DeleteColorButton

    Begin Object class=GUIComboBox Name=PreviewSkinComboBox
        Hint="Select skin variation to be used on the preview."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bReadOnly=true
        OnChange=PreviewSkinOnChange
        TabOrder=18
    End Object
    co_PreviewSkin=PreviewSkinComboBox

    Begin Object class=GUIButton Name=PreviewBoxButton
        StyleName="NoBackground"
        bStandardized=false
        bTabStop=false
        bNeverFocus=true
        bDropTarget=true
        OnDraw=PreviewOnDraw
        OnCapturedMouseMove=PreviewOnCapturedMouseMove
    End Object
    b_PreviewBox=PreviewBoxButton

    Begin Object class=GUIButton Name=ChangeModelButton
        Caption="Change Preview Character"
        Hint="Select a different preview character."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickChangeModel
        TabOrder=19
    End Object
    b_ChangeModel=ChangeModelButton

    PanelCaption="Skin Highlight"
    PanelHint="Skin highlight options"
    bInsertFront=true
    bDoubleColumn=false
    bFillPanelHeight=false
    Sections(0)=HighlightsSection
    Sections(1)=ColorEditorSection
    DisabledLabel="Disabled"
    DefaultLabel="Default"
    NameLabel="Name"
    NewColorPageCaption="New Color"
    RenameColorPageCaption="Rename Color"
    ConfirmColorDeletionLabel="Are you sure you want to delete this color?"
    InvalidNamePrefix="The name"
    InvalidNameSuffix="is already in use or invalid."
    SkinLabels(0)="View Normal Skin"
    SkinLabels(1)="View Red Team Skin"
    SkinLabels(2)="View Blue Team Skin"
    TeamLabels(0)="Red Team"
    TeamLabels(1)="Blue Team"
    PreviewSkinVariation=-1
    PreviewOffset=(X=425,Z=-3)
}
