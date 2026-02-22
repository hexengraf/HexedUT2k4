class HxSkinHighlightMenuPanel extends HxMenuPanel;

const SECTION_HIGHLIGHTS = 0;
const SECTION_COLOR_EDITOR = 1;
const SECTION_COLOR_PREVIEW = 3;

const NO_HIGHLIGHT = "";
const RANDOM_HIGHLIGHT = "*";

var automated moComboBox co_YourTeam;
var automated moComboBox co_EnemyTeam;
var automated moComboBox co_SoloPlayer;
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

var localized string NameLabel;
var localized string NewColorPageCaption;
var localized string RenameColorPageCaption;
var localized string ConfirmColorDeletionLabel;
var localized string InvalidNamePrefix;
var localized string InvalidNameSuffix;
var localized string SkinLabels[3];
var localized string TeamLabels[2];

var private HxClientProxy Proxy;
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

    super.InitComponent(MyController, MyOwner);
    Sections[SECTION_HIGHLIGHTS].ManageComponent(co_YourTeam);
    Sections[SECTION_HIGHLIGHTS].ManageComponent(co_EnemyTeam);
    Sections[SECTION_HIGHLIGHTS].ManageComponent(co_SoloPlayer);
    Sections[SECTION_HIGHLIGHTS].ManageComponent(ch_DisableOnDeadBodies);
    Sections[SECTION_HIGHLIGHTS].ManageComponent(ch_ForceNormalSkins);
    Sections[SECTION_HIGHLIGHTS].ManageComponent(co_SpectateAs);
    Sections[SECTION_COLOR_EDITOR].ManageComponent(co_EditColor);
    Sections[SECTION_COLOR_EDITOR].ManageComponent(sl_ColorRed);
    Sections[SECTION_COLOR_EDITOR].ManageComponent(sl_ColorGreen);
    Sections[SECTION_COLOR_EDITOR].ManageComponent(sl_ColorBlue);
    Sections[SECTION_COLOR_EDITOR].ManageComponent(ch_AllowOnRandom);
    Sections[SECTION_COLOR_EDITOR].ManageComponent(l_ButtonAnchor);
    Sections[SECTION_COLOR_PREVIEW].ManageComponent(co_PreviewSkin);
    Sections[SECTION_COLOR_PREVIEW].ManageComponent(b_PreviewBox);
    Sections[SECTION_COLOR_PREVIEW].ManageComponent(b_ChangeModel);
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

function bool Initialize()
{
    if (Proxy != None)
    {
        return true;
    }
    Proxy = class'HxClientProxy'.static.GetClientProxy(PlayerOwner());
    return Proxy != None;
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
    HideSection(SECTION_HIGHLIGHTS, !Proxy.bAllowSkinHighlight, HIDE_DUE_DISABLE);
}

function bool InternalOnPreDraw(Canvas C)
{
    b_NewColor.WinLeft = l_ButtonAnchor.WinLeft;
    b_NewColor.WinTop = l_ButtonAnchor.WinTop;
    b_NewColor.WinWidth = l_ButtonAnchor.WinWidth / 3;
    b_RenameColor.WinLeft = b_NewColor.WinLeft + b_NewColor.WinWidth;
    b_RenameColor.WinTop = l_ButtonAnchor.WinTop;
    b_RenameColor.WinWidth = b_NewColor.WinWidth;
    b_DeleteColor.WinLeft = b_RenameColor.WinLeft + b_RenameColor.WinWidth;
    b_DeleteColor.WinTop = l_ButtonAnchor.WinTop;
    b_DeleteColor.WinWidth = b_NewColor.WinWidth;
    return false;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    if (GUIMenuOption(Sender) != None)
    {
        GUIMenuOption(Sender).SetComponentValue(s, true);
    }
}

function CustomizeColorOnLoadINI(GUIComponent Sender, string s)
{
    local HxSkinHighlight.HxColorEntry ColorEntry;

    if (Sender == ch_AllowOnRandom)
    {
        class'HxSkinHighlight'.static.FindColorEntry(co_EditColor.GetComponentValue(), ColorEntry);
        ch_AllowOnRandom.Checked(ColorEntry.bRandom);
    }
    else
    {
        class'HxSkinHighlight'.static.FindColorEntry(co_EditColor.GetComponentValue(), ColorEntry);
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

function InternalOnChange(GUIComponent Sender)
{
    switch (Sender)
    {
        case co_YourTeam:
            class'HxSkinHighlight'.default.YourTeam = moComboBox(Sender).GetExtra();
            break;
        case co_EnemyTeam:
            class'HxSkinHighlight'.default.EnemyTeam = moComboBox(Sender).GetExtra();
            break;
        case co_SoloPlayer:
            class'HxSkinHighlight'.default.SoloPlayer = moComboBox(Sender).GetExtra();
            break;
        case ch_DisableOnDeadBodies:
            class'HxSkinHighlight'.default.bDisableOnDeadBodies = moCheckBox(Sender).IsChecked();
            break;
        case ch_ForceNormalSkins:
            class'HxSkinHighlight'.default.bForceNormalSkins = moCheckBox(Sender).IsChecked();
            break;
        case co_SpectateAs:
            class'HxSkinHighlight'.default.SpectatorTeam = int(moComboBox(Sender).GetExtra());
            break;
    }
    SaveHighlightChanges(PlayerOwner());
}

function CustomizeColorOnChange(GUIComponent Sender)
{
    local int Index;

    Index = co_EditColor.GetIndex();
    if (Sender == co_EditColor)
    {
        UpdateCustomizeColorSection(co_EditColor.GetComponentValue());
    }
    else if (Sender == ch_AllowOnRandom)
    {
        if (class'HxSkinHighlight'.static.SetColorRandom(Index, ch_AllowOnRandom.IsChecked()))
        {
            SaveHighlightChanges(PlayerOwner());
        }
    }
    else if (Index < class'HxSkinHighlight'.default.Colors.Length)
    {
        switch (Sender)
        {
            case sl_ColorRed:
                class'HxSkinHighlight'.default.Colors[Index].Color.R = sl_ColorRed.GetValue();
                break;
            case sl_ColorGreen:
                class'HxSkinHighlight'.default.Colors[Index].Color.G = sl_ColorGreen.GetValue();
                break;
            case sl_ColorBlue:
                class'HxSkinHighlight'.default.Colors[Index].Color.B = sl_ColorBlue.GetValue();
                break;
        }
        SaveHighlightChanges(PlayerOwner());
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
    ComboBoxes[3] = co_EditColor;

    for (i = 0; i < ComboBoxes.Length - 1; ++i)
    {
        ComboBoxes[i].bIgnoreChange = true;
        ComboBoxes[i].ResetComponent();
        ComboBoxes[i].AddItem("Disabled",,NO_HIGHLIGHT);
    }
    Index = co_EditColor.GetIndex();
    co_EditColor.bIgnoreChange = true;
    co_EditColor.ResetComponent();
    co_SoloPlayer.AddItem("Random",,RANDOM_HIGHLIGHT);
    for (i = 0; i < class'HxSkinHighlight'.default.Colors.Length; ++i)
    {
        for (j = 0; j < ComboBoxes.Length; ++j)
        {
            ComboBoxes[j].AddItem(
                class'HxSkinHighlight'.default.Colors[i].Name,,
                class'HxSkinHighlight'.default.Colors[i].Name);

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

function SaveHighlightChanges(PlayerController PC)
{
    local HxSkinHighlight SkinHighlight;

    if (PC != None)
    {
        ForEach PC.DynamicActors(class'HxSkinHighlight', SkinHighlight)
        {
            SkinHighlight.Reinitialize();
        }
    }
    class'HxSkinHighlight'.static.StaticSaveConfig();
}

function UpdateCustomizeColorSection(string ColorName)
{
    local HxSkinHighlight.HxColorEntry ColorEntry;

    class'HxSkinHighlight'.static.FindColorEntry(ColorName, ColorEntry);
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

function bool PreviewSectionOnPreDraw(canvas C)
{
    local AltSectionBackground Section;
    local float AH;
    local float TopPad;
    local float BottomPad;

    Section = Sections[SECTION_COLOR_PREVIEW];
    Section.InternalPreDraw(C);
    AH = Section.ActualHeight();

    TopPad = (Section.TopPadding * AH) + Section.ImageOffset[1];
    BottomPad = (Section.BottomPadding * AH) + Section.ImageOffset[3];

    if (Section.Style != None)
    {
        TopPad += Section.BorderOffsets[1];
        BottomPad += Section.BorderOffsets[3];
    }
    co_PreviewSkin.WinHeight = co_PreviewSkin.RelativeHeight(
        C.CLipY * co_PreviewSkin.StandardHeight);
    b_ChangeModel.WinHeight = b_ChangeModel.RelativeHeight(C.CLipY * b_ChangeModel.StandardHeight);
    b_PreviewBox.WinHeight = b_PreviewBox.RelativeHeight(
        AH - TopPad - BottomPad) - co_PreviewSkin.WinHeight - b_ChangeModel.WinHeight - 0.004;
    b_PreviewBox.WinTop = co_PreviewSkin.RelativeTop() + co_PreviewSkin.WinHeight + 0.002;
    b_ChangeModel.WinTop = b_PreviewBox.RelativeTop() + b_PreviewBox.WinHeight + 0.002;
    return false;
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
    class'HxSkinHighlight'.static.FindColor(co_EditColor.GetComponentValue(), PreviewEffect.Color);
    PreviewEffect.Color.R = PreviewEffect.Color.R * Proxy.SkinHighlightFactor;
    PreviewEffect.Color.G = PreviewEffect.Color.G * Proxy.SkinHighlightFactor;
    PreviewEffect.Color.B = PreviewEffect.Color.B * Proxy.SkinHighlightFactor;
}

function bool OnClickNewColor(GUIComponent Sender)
{
    if (Controller.OpenMenu(Controller.RequestDataMenu, NewColorPageCaption, NameLabel))
    {
        Controller.ActivePage.SetDataString(class'HxSkinHighlight'.static.RandomColorName());
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
        Index = class'HxSkinHighlight'.static.AllocateColor(ColorName);
        if (Index != -1)
        {
            class'HxSkinHighlight'.static.StaticSaveConfig();
            PopulateColorComboBoxes();
            co_EditColor.SilentSetIndex(Index);
            UpdateCustomizeColorSection(ColorName);
        }
        else
        {
            ShowInvalidNameDialog(ColorName);
        }
    }
}

function bool OnClickRenameColor(GUIComponent Sender)
{
    if (Controller.OpenMenu(Controller.RequestDataMenu, RenameColorPageCaption, NameLabel))
    {
        Controller.ActivePage.SetDataString(co_EditColor.GetText());
        Controller.ActivePage.OnClose = OnCloseRenameColor;
    }
    return true;
}

function OnCloseRenameColor(optional bool bCancelled)
{
    local string ColorName;

    if (!bCancelled)
    {
        ColorName = Controller.ActivePage.GetDataString();
        if (ColorName != co_EditColor.GetText())
        {
            if (class'HxSkinHighlight'.static.ChangeColorName(co_EditColor.GetIndex(), ColorName))
            {
                PopulateColorComboBoxes();
                SaveHighlightChanges(PlayerOwner());
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
    Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
    GUIQuestionPage(Controller.TopPage()).SetupQuestion(
        ConfirmColorDeletionLabel, QBTN_YesNo, QBTN_Yes);
    GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnCloseDeleteColor;
    return true;
}

function OnCloseDeleteColor(byte bButton)
{
    if (bButton == QBTN_Yes && class'HxSkinHighlight'.static.DeleteColor(co_EditColor.GetIndex()))
    {
        class'HxSkinHighlight'.static.StaticSaveConfig();
        PopulateColorComboBoxes();
        UpdateCustomizeColorSection(co_EditColor.GetComponentValue());
        SaveHighlightChanges(PlayerOwner());
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
    Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
    GUIQuestionPage(Controller.TopPage()).SetupQuestion(
        InvalidNamePrefix@"\""$Name$"\""@InvalidNameSuffix, QBTN_Ok, QBTN_Ok);
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
    Begin Object class=AltSectionBackground Name=HighlightsSection
        Caption="Highlights"
        bRemapStack=false
    End Object

    Begin Object class=AltSectionBackground Name=ColorEditorSection
        Caption="Color Editor"
        bRemapStack=false
    End Object

    Begin Object class=AltSectionBackground Name=ColorPreviewSection
        Caption="Color Preview"
        bRemapStack=false
        OnPreDraw=PreviewSectionOnPreDraw
    End Object

    Begin Object class=moComboBox Name=YourTeamComboBox
        Caption="Your team"
        Hint="Highlight color for your team."
        INIOption="HxSkinHighlight YourTeam"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=0
    End Object
    co_YourTeam=YourTeamComboBox

    Begin Object class=moComboBox Name=EnemyTeamComboBox
        Caption="Enemy team"
        Hint="Highlight color for the enemy team."
        INIOption="HxSkinHighlight EnemyTeam"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bAlwaysNotify=false
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=1
    End Object
    co_EnemyTeam=EnemyTeamComboBox

    Begin Object class=moComboBox Name=SoloPlayerComboBox
        Caption="Solo player"
        Hint="Highlight color for players on game modes with no team. Random assigns a random color for each player."
        INIOption="HxSkinHighlight SoloPlayer"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bAlwaysNotify=false
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=2
    End Object
    co_SoloPlayer=SoloPlayerComboBox

    Begin Object class=moCheckBox Name=DisableOnDeadBodiesCheckBox
        Caption="Disable highlight on dead bodies"
        Hint="Disable any active highlights on dead bodies."
        INIOption="HxSkinHighlight bDisableOnDeadBodies"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=-1
        CaptionWidth=0.8
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=3
    End Object
    ch_DisableOnDeadBodies=DisableOnDeadBodiesCheckBox

    Begin Object class=moCheckBox Name=ForceNormalSkinsCheckBox
        Caption="Force normal skins"
        Hint="When highlight is enabled, force normal (uncolored) variation of the underlying skin."
        INIOption="HxSkinHighlight bForceNormalSkins"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=-1
        CaptionWidth=0.8
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=4
    End Object
    ch_ForceNormalSkins=ForceNormalSkinsCheckBox

    Begin Object class=moComboBox Name=SpectateAsComboBox
        Caption="Spectate as"
        Hint="Select which team's perspective to spectate as."
        INIOption="HxSkinHighlight SpectatorTeam"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=5
    End Object
    co_SpectateAs=SpectateAsComboBox

    Begin Object class=moComboBox Name=EditColorComboBox
        Caption="Color"
        Hint="Color to customize."
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bAlwaysNotify=false
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnChange=CustomizeColorOnChange
        TabOrder=6
    End Object
    co_EditColor=EditColorComboBox

    Begin Object class=moSlider Name=ColorRedSlider
        Caption="Red"
        INIOption="@INTERNAL"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        MinValue=0
        MaxValue=255
        bIntSlider=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
        TabOrder=7
    End Object
    sl_ColorRed=ColorRedSlider

    Begin Object class=moSlider Name=ColorGreenSlider
        Caption="Green"
        INIOption="@INTERNAL"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        MinValue=0
        MaxValue=255
        bIntSlider=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
        TabOrder=8
    End Object
    sl_ColorGreen=ColorGreenSlider

    Begin Object class=moSlider Name=ColorBlueSlider
        Caption="Blue"
        INIOption="@INTERNAL"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        MinValue=0
        MaxValue=255
        bIntSlider=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
        TabOrder=9
    End Object
    sl_ColorBlue=ColorBlueSlider

    Begin Object class=moCheckBox Name=AllowOnRandomCheckBox
        Caption="Allow color on random highlight"
        Hint="Allow this color to be used on random highlight."
        INIOption="@INTERNAL"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=-1
        CaptionWidth=0.8
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
        TabOrder=10
    End Object
    ch_AllowOnRandom=AllowOnRandomCheckBox

    Begin Object class=GUILabel Name=ButtonAnchorLabel
    End Object
    l_ButtonAnchor=ButtonAnchorLabel

    Begin Object Class=GUIButton Name=NewColorButton
        Caption="New"
        Hint="Add new color to the list of colors."
        StandardHeight=0.035
        bStandardized=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickNewColor
        TabOrder=11
    End Object
    b_NewColor=NewColorButton

    Begin Object Class=GUIButton Name=RenameColorButton
        Caption="Rename"
        Hint="Rename current color."
        StandardHeight=0.035
        bStandardized=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickRenameColor
        TabOrder=12
    End Object
    b_RenameColor=RenameColorButton

    Begin Object Class=GUIButton Name=DeleteColorButton
        Caption="Delete"
        Hint="Delete current color from the list of colors."
        StandardHeight=0.035
        bStandardized=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickDeleteColor
        TabOrder=13
    End Object
    b_DeleteColor=DeleteColorButton

    Begin Object class=GUIComboBox Name=PreviewSkinComboBox
        Hint="Select skin variation to be used on the preview."
        StandardHeight=0.03
        bStandardized=true
        bReadOnly=true
        bBoundToParent=true
        bScaleToParent=true
        OnChange=PreviewSkinOnChange
        TabOrder=14
    End Object
    co_PreviewSkin=PreviewSkinComboBox

    Begin Object class=GUIButton Name=PreviewBoxButton
        StyleName="NoBackground"
        bStandardized=false
        bTabStop=false
        bNeverFocus=true
        bDropTarget=true
        bScaleToParent=true
        bBoundToParent=true
        OnDraw=PreviewOnDraw
        OnCapturedMouseMove=PreviewOnCapturedMouseMove
    End Object
    b_PreviewBox=PreviewBoxButton

    Begin Object class=GUIButton Name=ChangeModelButton
        Caption="Change Preview Character"
        Hint="Select a different preview character."
        StandardHeight=0.035
        bStandardized=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickChangeModel
        TabOrder=15
    End Object
    b_ChangeModel=ChangeModelButton

    PanelCaption="Skin Highlight"
    PanelHint="Skin highlight options"
    bInsertFront=true
    bDoubleColumn=true
    Sections(0)=HighlightsSection
    Sections(1)=ColorEditorSection
    Sections(2)=None
    Sections(3)=ColorPreviewSection
    NameLabel="Name:"
    NewColorPageCaption="New Color"
    RenameColorPageCaption="Rename Color"
    ConfirmColorDeletionLabel="Are you sure you want to delete this color?"
    InvalidNamePrefix="The name"
    InvalidNameSuffix="is invalid or already in use."
    SkinLabels(0)="View Normal Skin"
    SkinLabels(1)="View Red Team Skin"
    SkinLabels(2)="View Blue Team Skin"
    TeamLabels(0)="Red Team"
    TeamLabels(1)="Blue Team"
    PreviewSkinVariation=-1
    PreviewOffset=(X=450,Z=-5)
    OnPreDraw=InternalOnPreDraw
}
