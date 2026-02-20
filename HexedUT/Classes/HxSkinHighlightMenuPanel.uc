class HxSkinHighlightMenuPanel extends HxMenuPanel;

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
        GUIComboBox(Options[11]).AddItem(SkinLabels[i]);
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
        class'HxSkinHighlight'.static.FindColor(co_EditColor.GetComponentValue(), C);
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
            class'HxSkinHighlight'.default.YourTeam = moComboBox(Sender).GetExtra();
            break;
        case Options[1]:
            class'HxSkinHighlight'.default.EnemyTeam = moComboBox(Sender).GetExtra();
            break;
        case Options[2]:
            class'HxSkinHighlight'.default.SoloPlayer = moComboBox(Sender).GetExtra();
            break;
        case Options[3]:
            class'HxSkinHighlight'.default.bDisableOnDeadBodies = moCheckBox(Sender).IsChecked();
            break;
        case Options[4]:
            class'HxSkinHighlight'.default.bForceNormalSkins = moCheckBox(Sender).IsChecked();
            break;
    }
    UpdateOutstandingHighlights(PlayerOwner());
    class'HxSkinHighlight'.static.StaticSaveConfig();
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
        if (class'HxSkinHighlight'.static.ChangeColorName(Index, ed_ColorName.GetComponentValue()))
        {
            PopulateColorComboBoxes();
            UpdateOutstandingHighlights(PlayerOwner());
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
        UpdateOutstandingHighlights(PlayerOwner());
    }
    UpdatePreviewColor();
}

function PreviewSkinOnChange(GUIComponent Sender)
{
    PreviewSkinVariation = GUIComboBox(Sender).GetIndex() - 1;
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
        moComboBox(Options[i]).AddItem("Disabled",,NO_HIGHLIGHT);
    }
    moComboBox(Options[2]).AddItem("Random",,RANDOM_HIGHLIGHT);
    for (i = 0; i < class'HxSkinHighlight'.default.Colors.Length; ++i)
    {
        for (j = 0; j < 3; ++j)
        {
            moComboBox(Options[j]).AddItem(
                class'HxSkinHighlight'.default.Colors[i].Name,,
                class'HxSkinHighlight'.default.Colors[i].Name);

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
    for (i = 0; i < class'HxSkinHighlight'.default.Colors.Length; ++i)
    {
        co_EditColor.AddItem(
            class'HxSkinHighlight'.default.Colors[i].Name,,
            class'HxSkinHighlight'.default.Colors[i].Name);
    }
    if (Index > -1)
    {
        co_EditColor.SilentSetIndex(Min(Index, co_EditColor.ItemCount() - 1));
    }
    co_EditColor.bIgnoreChange = false;
}

function UpdateOutstandingHighlights(PlayerController PC)
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

function UpdateCustomizeColorSection(string ColorName)
{
    local Color C;

    ed_ColorName.SetComponentValue(ColorName, true);
    class'HxSkinHighlight'.static.FindColor(ColorName, C);
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
    class'HxSkinHighlight'.static.FindColor(co_EditColor.GetComponentValue(), PreviewEffect.Color);
    PreviewEffect.Color.R = PreviewEffect.Color.R * Proxy.SkinHighlightFactor;
    PreviewEffect.Color.G = PreviewEffect.Color.G * Proxy.SkinHighlightFactor;
    PreviewEffect.Color.B = PreviewEffect.Color.B * Proxy.SkinHighlightFactor;
}

function bool OnClickNewColor(GUIComponent Sender)
{
    local string ColorName;
    local int Index;

    Index = class'HxSkinHighlight'.static.AllocateColor(ColorName);
    class'HxSkinHighlight'.static.StaticSaveConfig();
    PopulateColorComboBoxes();
    co_EditColor.SilentSetIndex(Index);
    UpdateCustomizeColorSection(ColorName);
    return true;
}

function bool OnClickDeleteColor(GUIComponent Sender)
{
    if (class'HxSkinHighlight'.static.DeleteColor(co_EditColor.GetIndex()))
    {
        class'HxSkinHighlight'.static.StaticSaveConfig();
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
    End Object

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
    End Object

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
    End Object

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
    End Object

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
    End Object

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
    End Object

    Begin Object class=moEditBox Name=ColorNameEditBox
        Caption="Name"
        Hint="Edit color name"
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

    Begin Object class=GUIComboBox Name=PreviewSkinComboBox
        Hint="Select skin variation to be used on the preview."
        StandardHeight=0.03
        bStandardized=true
        bReadOnly=true
        bBoundToParent=true
        bScaleToParent=true
        OnChange=PreviewSkinOnChange
    End Object

    Begin Object class=GUIButton Name=PreviewBackgroundImage
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

    Begin Object class=GUIButton Name=ChangeModelButton
        Caption="Change Preview Character"
        Hint="Select a different preview character."
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
        Hint="Add new color to the list of colors."
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
        Hint="Delete current color from the list of colors."
        StandardHeight=0.035
        bStandardized=true
        bNeverFocus=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickDeleteColor
    End Object

    PanelCaption="Skin Highlight"
    PanelHint="Skin highlight options"
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
    SkinLabels(0)="View Normal Skin"
    SkinLabels(1)="View Red Team Skin"
    SkinLabels(2)="View Blue Team Skin"
    PreviewSkinVariation=-1
    PreviewOffset=(X=450,Z=-5)
    b_NewColor=NewColorButton
    b_DeleteColor=DeleteColorButton
    OnPreDraw=InternalOnPreDraw
}
