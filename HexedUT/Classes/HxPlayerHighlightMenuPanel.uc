class HxPlayerHighlightMenuPanel extends HxMenuPanel;

const SECTION_HIGHLIGHTS = 0;
const SECTION_CUSTOMIZE_COLORS = 1;
const SECTION_COLOR_PREVIEW = 3;

const NO_HIGHLIGHT = "";
const RANDOM_HIGHLIGHT = "*";

var automated array<GUIComponent> Options;
var automated GUIButton b_NewColor;
var automated GUIButton b_DeleteColor;

var localized string SkinLabels[3];

var private moComboBox co_EditColor;
var private moEditBox ed_ColorName;
var private moSlider sl_ColorRed;
var private moSlider sl_ColorGreen;
var private moSlider sl_ColorBlue;
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
    for (i = 0; i < 5; ++i)
    {
        Sections[SECTION_HIGHLIGHTS].ManageComponent(Options[i]);
    }
    for (i = 5; i < 11; ++i)
    {
        Sections[SECTION_CUSTOMIZE_COLORS].ManageComponent(Options[i]);
    }
    for (i = 11; i < 14; ++i)
    {
        Sections[SECTION_COLOR_PREVIEW].ManageComponent(Options[i]);
    }
    co_EditColor = moComboBox(Options[5]);
    ed_ColorName = moEditBox(Options[6]);
    sl_ColorRed = moSlider(Options[7]);
    sl_ColorGreen = moSlider(Options[8]);
    sl_ColorBlue = moSlider(Options[9]);
    ed_ColorName.MyEditBox.bAlwaysNotify = false;
    PreviewEffect = New(Self) class'ConstantColor';
    PreviewShader = New(Self) class'Shader';
    PreviewShader.Specular = PreviewEffect;
    PopulateColorComboBoxes();

    for (i = 0; i < 3; ++i)
    {
        moComboBox(Options[11]).AddItem(SkinLabels[i]);
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
    HideSection(SECTION_HIGHLIGHTS, !Proxy.bAllowPlayerHighlight, HIDE_DUE_DISABLE);
}

function ResolutionChanged(int ResX, int ResY)
{
    bInit = true;
    Super.ResolutionChanged(ResX, ResY);
}

function bool InternalOnPreDraw(Canvas C)
{
    if (bInit)
    {
        b_NewColor.WinLeft = Options[10].WinLeft;
        b_NewColor.WinTop = Options[10].WinTop;
        b_NewColor.WinWidth = Options[10].WinWidth / 2;
        b_DeleteColor.WinLeft = b_NewColor.WinLeft + b_NewColor.WinWidth;
        b_DeleteColor.WinTop = Options[10].WinTop;
        b_DeleteColor.WinWidth = b_NewColor.WinWidth;
    }
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
    local Color C;

    if (Sender == ed_ColorName)
    {
        ed_ColorName.SetComponentValue(co_EditColor.GetComponentValue(), true);
    }
    else
    {
        class'HxPlayerHighlight'.static.FindColor(co_EditColor.GetComponentValue(), C);
        switch (Sender)
        {
            case sl_ColorRed:
                sl_ColorRed.SetComponentValue(C.R, true);
                break;
            case sl_ColorGreen:
                sl_ColorGreen.SetComponentValue(C.G, true);
                break;
            case sl_ColorBlue:
                sl_ColorBlue.SetComponentValue(C.B, true);
                break;
        }
    }
    UpdatePreviewColor();
}

function InternalOnChange(GUIComponent Sender)
{
    switch (Sender)
    {
        case Options[0]:
            class'HxPlayerHighlight'.default.YourTeam = moComboBox(Sender).GetExtra();
            break;
        case Options[1]:
            class'HxPlayerHighlight'.default.EnemyTeam = moComboBox(Sender).GetExtra();
            break;
        case Options[2]:
            class'HxPlayerHighlight'.default.SoloPlayer = moComboBox(Sender).GetExtra();
            break;
        case Options[3]:
            class'HxPlayerHighlight'.default.bDisableOnDeadBodies = moCheckBox(Sender).IsChecked();
            break;
        case Options[4]:
            class'HxPlayerHighlight'.default.bForceNormalSkins = moCheckBox(Sender).IsChecked();
            break;
    }
    UpdateOutstandingHighlights(PlayerOwner());
    class'HxPlayerHighlight'.static.StaticSaveConfig();
}

function CustomizeColorOnChange(GUIComponent Sender)
{
    local int Index;

    Index = co_EditColor.GetIndex();
    if (Sender == co_EditColor)
    {
        UpdateCustomizeColorSection(co_EditColor.GetComponentValue());
    }
    else if (Sender == ed_ColorName)
    {
        if (class'HxPlayerHighlight'.static.ChangeColorName(Index, ed_ColorName.GetComponentValue()))
        {
            PopulateColorComboBoxes();
            UpdateOutstandingHighlights(PlayerOwner());
        }
    }
    else if (Index < class'HxPlayerHighlight'.default.Colors.Length)
    {
        switch (Sender)
        {
            case sl_ColorRed:
                class'HxPlayerHighlight'.default.Colors[Index].Color.R = sl_ColorRed.GetValue();
                break;
            case sl_ColorGreen:
                class'HxPlayerHighlight'.default.Colors[Index].Color.G = sl_ColorGreen.GetValue();
                break;
            case sl_ColorBlue:
                class'HxPlayerHighlight'.default.Colors[Index].Color.B = sl_ColorBlue.GetValue();
                break;
        }
        UpdateOutstandingHighlights(PlayerOwner());
    }
    UpdatePreviewColor();
}

function PreviewSkinOnChange(GUIComponent Sender)
{
    PreviewSkinVariation = moComboBox(Sender).GetIndex() - 1;
    UpdatePreviewModelSkins();
}

function PopulateColorComboBoxes()
{
    local int Index;
    local int i;
    local int j;

    for (i = 0; i < 3; ++i)
    {
        moComboBox(Options[i]).bIgnoreChange = true;
        moComboBox(Options[i]).ResetComponent();
        moComboBox(Options[i]).AddItem("Default",,NO_HIGHLIGHT);
    }
    moComboBox(Options[2]).AddItem("Random",,RANDOM_HIGHLIGHT);
    for (i = 0; i < class'HxPlayerHighlight'.default.Colors.Length; ++i)
    {
        for (j = 0; j < 3; ++j)
        {
            moComboBox(Options[j]).AddItem(
                class'HxPlayerHighlight'.default.Colors[i].Name,,
                class'HxPlayerHighlight'.default.Colors[i].Name);

        }
    }
    for (i = 0; i < 3; ++i)
    {
        Options[i].LoadINI();
        moComboBox(Options[i]).bIgnoreChange = false;
    }
    Index = co_EditColor.GetIndex();
    co_EditColor.bIgnoreChange = true;
    co_EditColor.ResetComponent();
    for (i = 0; i < class'HxPlayerHighlight'.default.Colors.Length; ++i)
    {
        co_EditColor.AddItem(
            class'HxPlayerHighlight'.default.Colors[i].Name,,
            class'HxPlayerHighlight'.default.Colors[i].Name);
    }
    if (Index > -1)
    {
        co_EditColor.SilentSetIndex(Min(Index, co_EditColor.ItemCount() - 1));
    }
    co_EditColor.bIgnoreChange = false;
}

function UpdateOutstandingHighlights(PlayerController PC)
{
    local HxPlayerHighlight PlayerHighlight;

    if (PC != None)
    {
        ForEach PC.DynamicActors(class'HxPlayerHighlight', PlayerHighlight)
        {
            PlayerHighlight.Reinitialize();
        }
    }
}

function UpdateCustomizeColorSection(string ColorName)
{
    local Color C;

    ed_ColorName.SetComponentValue(ColorName, true);
    class'HxPlayerHighlight'.static.FindColor(ColorName, C);
    sl_ColorRed.SetComponentValue(C.R, true);
    sl_ColorGreen.SetComponentValue(C.G, true);
    sl_ColorBlue.SetComponentValue(C.B, true);
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
            Options[12].ActualLeft(),
            Options[12].ActualTop(),
            Options[12].ActualWidth(),
            Options[12].ActualHeight(),
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
    Options[11].WinHeight = Options[11].RelativeHeight(C.CLipY * Options[11].StandardHeight);
    Options[13].WinHeight = Options[13].RelativeHeight(C.CLipY * Options[13].StandardHeight);
    Options[12].WinHeight = Options[12].RelativeHeight(
        AH - TopPad - BottomPad) - Options[11].WinHeight - Options[13].WinHeight - 0.004;
    Options[12].WinTop = Options[11].RelativeTop() + Options[11].WinHeight + 0.002;
    Options[13].WinTop = Options[12].RelativeTop() + Options[12].WinHeight + 0.002;
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
    class'HxPlayerHighlight'.static.FindColor(co_EditColor.GetComponentValue(), PreviewEffect.Color);
    PreviewEffect.Color.R = PreviewEffect.Color.R * Proxy.PlayerHighlightFactor;
    PreviewEffect.Color.G = PreviewEffect.Color.G * Proxy.PlayerHighlightFactor;
    PreviewEffect.Color.B = PreviewEffect.Color.B * Proxy.PlayerHighlightFactor;
}

function bool OnClickNewColor(GUIComponent Sender)
{
    local string ColorName;
    local int Index;

    Index = class'HxPlayerHighlight'.static.AllocateColor(ColorName);
    class'HxPlayerHighlight'.static.StaticSaveConfig();
    PopulateColorComboBoxes();
    co_EditColor.SilentSetIndex(Index);
    UpdateCustomizeColorSection(ColorName);
    return true;
}

function bool OnClickDeleteColor(GUIComponent Sender)
{
    if (class'HxPlayerHighlight'.static.DeleteColor(co_EditColor.GetIndex()))
    {
        class'HxPlayerHighlight'.static.StaticSaveConfig();
        PopulateColorComboBoxes();
        UpdateCustomizeColorSection(co_EditColor.GetComponentValue());
        UpdateOutstandingHighlights(PlayerOwner());
    }
    return true;
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

static function bool AddToMenu()
{
    local int i;

    if (Super.AddToMenu())
    {
        for (i = 0; i < default.Options.Length; ++i)
        {
            default.Options[i].TabOrder = i;
        }
        return true;
    }
    return false;
}

defaultproperties
{
    Begin Object class=AltSectionBackground Name=HighlightsSection
        Caption="Highlights"
    End Object

    Begin Object class=AltSectionBackground Name=CustomizeColorsSection
        Caption="Customize Colors"
    End Object

    Begin Object class=AltSectionBackground Name=ColorPreviewSection
        Caption="Color Preview"
        OnPreDraw=PreviewSectionOnPreDraw
    End Object

    Begin Object class=moComboBox Name=YourTeamComboBox
        Caption="Your team"
        INIOption="HxPlayerHighlight YourTeam"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
    End Object

    Begin Object class=moComboBox Name=EnemyTeamComboBox
        Caption="Enemy team"
        INIOption="HxPlayerHighlight EnemyTeam"
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
    End Object

    Begin Object class=moComboBox Name=SoloPlayerComboBox
        Caption="Solo player"
        INIOption="HxPlayerHighlight SoloPlayer"
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
    End Object

    Begin Object class=moCheckBox Name=DisableOnDeadBodiesCheckBox
        Caption="Disable highlight on dead bodies"
        INIOption="HxPlayerHighlight bDisableOnDeadBodies"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=-1
        CaptionWidth=0.8
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
    End Object

    Begin Object class=moCheckBox Name=ForceNormalSkinsCheckBox
        Caption="Force normal (uncolored) skins"
        INIOption="HxPlayerHighlight bForceNormalSkins"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=-1
        CaptionWidth=0.8
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
    End Object

    Begin Object class=moComboBox Name=EditColorComboBox
        Caption="Color"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bAlwaysNotify=false
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnChange=CustomizeColorOnChange
    End Object

    Begin Object class=moEditBox Name=ColorNameEditBox
        Caption="Name"
        INIOption="@INTERNAL"
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnLoadINI=CustomizeColorOnLoadINI
        OnChange=CustomizeColorOnChange
    End Object

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
    End Object

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
    End Object

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
    End Object

    Begin Object class=GUILabel Name=ButtonAnchorLabel
    End Object

    Begin Object class=moComboBox Name=PreviewSkinComboBox
        Caption="Variation"
        StandardHeight=0.03
        bStandardized=true
        LabelJustification=TXTA_Left
        ComponentJustification=TXTA_Right
        ComponentWidth=0.7
        bReadOnly=true
        bAutoSizeCaption=true
        bBoundToParent=true
        bScaleToParent=true
        OnChange=PreviewSkinOnChange
    End Object

    Begin Object class=GUIButton Name=PreviewBackgroundImage
        StyleName="NoBackground"
        bStandardized=false
        MouseCursorIndex=5
        bTabStop=false
        bNeverFocus=true
        bDropTarget=true
        bScaleToParent=true
        bBoundToParent=true
        OnDraw=PreviewOnDraw
        OnCapturedMouseMove=PreviewOnCapturedMouseMove
    End Object

    Begin Object class=GUIButton Name=ChangeModelButton
        Caption="Change Preview Character"
        StandardHeight=0.035
        bStandardized=true
        bNeverFocus=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickChangeModel
    End Object

    Begin Object Class=GUIButton Name=NewColorButton
        Caption="New Color"
        StandardHeight=0.035
        bStandardized=true
        bNeverFocus=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickNewColor
    End Object

    Begin Object Class=GUIButton Name=DeleteColorButton
        Caption="Delete Color"
        StandardHeight=0.035
        bStandardized=true
        bNeverFocus=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickDeleteColor
    End Object

    PanelCaption="Player Highlight"
    PanelHint="Player highlight options"
    bInsertFront=true
    bDoubleColumn=true
    Sections(0)=HighlightsSection
    Sections(1)=CustomizeColorsSection
    Sections(2)=None
    Sections(3)=ColorPreviewSection
    Options(0)=YourTeamComboBox
    Options(1)=EnemyTeamComboBox
    Options(2)=SoloPlayerComboBox
    Options(3)=DisableOnDeadBodiesCheckBox
    Options(4)=ForceNormalSkinsCheckBox
    Options(5)=EditColorComboBox
    Options(6)=ColorNameEditBox
    Options(7)=ColorRedSlider
    Options(8)=ColorGreenSlider
    Options(9)=ColorBlueSlider
    Options(10)=ButtonAnchorLabel
    Options(11)=PreviewSkinComboBox
    Options(12)=PreviewBackgroundImage
    Options(13)=ChangeModelButton
    SkinLabels(0)="Normal Skin"
    SkinLabels(1)="Red Team Skin"
    SkinLabels(2)="Blue Team Skin"
    PreviewSkinVariation=-1
    PreviewOffset=(X=450,Z=-5)
    b_NewColor=NewColorButton
    b_DeleteColor=DeleteColorButton
    OnPreDraw=InternalOnPreDraw
}
