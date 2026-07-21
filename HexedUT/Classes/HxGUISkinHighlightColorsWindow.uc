class HxGUISkinHighlightColorsWindow extends HxGUIFloatingWindow;

var automated HxGUIFramedSection LeftSection;
var automated HxGUIFramedSection RightSection;

var automated moComboBox co_EditColor;
var automated moSlider sl_ColorRed;
var automated moSlider sl_ColorGreen;
var automated moSlider sl_ColorBlue;
var automated moCheckBox ch_AllowOnRandom;
var automated GUILabel l_ButtonAnchor;
var automated GUIButton b_NewColor;
var automated GUIButton b_RenameColor;
var automated GUIButton b_DeleteColor;

var automated moComboBox co_PreviewSkin;
var automated GUIButton b_PreviewBox;
var automated GUIButton b_ChangeModel;

var localized string NameLabel;
var localized string NewColorPageCaption;
var localized string RenameColorPageCaption;
var localized string ConfirmColorDeletionLabel;
var localized string InvalidNameMessage;

var HxClientManager ClientManager;
var private HxUTClient Client;
var private HxSkinHighlightConfig Config;
var private HxColors Colors;
var private HxSkinHighlightPreview Preview;
var private string PreviewCharacterName;
var private bool bRenderPreview;
var private float HighlightIntensity;
var private float OverlayIntensity;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
    Super.InitComponent(MyController, MyComponent);
    LeftSection.Insert(co_EditColor);
    LeftSection.Insert(sl_ColorRed);
    LeftSection.Insert(sl_ColorGreen);
    LeftSection.Insert(sl_ColorBlue);
    LeftSection.Insert(ch_AllowOnRandom);
    LeftSection.Insert(l_ButtonAnchor);
    RightSection.Insert(co_PreviewSkin);
    RightSection.Insert(b_PreviewBox);
    RightSection.Insert(b_ChangeModel);
    ForEach PlayerOwner().DynamicActors(class'HxClientManager', ClientManager) break;
    Client = HxUTClient(ClientManager.Find(class'HxUTClient'));
    Config = HxSkinHighlightConfig(Client.FindConfig(class'HxSkinHighlightConfig'));
    Colors = Client.GetSkinHighlightColors();
    PreviewCharacterName = Config.CurrentEnemyModel;
    HighlightIntensity = float(Client.GetServerProperty("SkinHighlightIntensity"));
    OverlayIntensity = float(Client.GetServerProperty("SkinOverlayIntensity"));
    PopulateColorComboBoxes();
    class'HxGUIMenuSkinHighlightPanel'.static.PopulateSkinTypeComboBox(co_PreviewSkin);
    co_PreviewSkin.SetIndex(class'HxSkinHighlightPreview'.default.ActiveSkin);
}

event Opened(GUIComponent Sender)
{
    if (Preview == None)
    {
        Preview = ClientManager.Spawn(class'HxSkinHighlightPreview');
        Preview.DisplayFOV = 33;
        Preview.SetIntensities(HighlightIntensity, OverlayIntensity);
        Preview.SetTeamNumber(2);
        Preview.SetPropertyText("ActiveColor", co_EditColor.GetComponentValue());
        Preview.SetPropertyText("ActiveSkin", co_PreviewSkin.GetComponentValue());
        Preview.Setup(PreviewCharacterName);
    }
    Preview.UpdateRotation(PlayerOwner());
    Super.Opened(Sender);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    if (Preview != None)
    {
        Preview.Destroy();
        Preview = None;
    }
    Super.Closed(Sender, bCancelled);
}

function PopulateColorComboBoxes()
{
    local int Index;
    local int i;

    Index = co_EditColor.GetIndex();
    co_EditColor.ResetComponent();
    co_EditColor.MyComboBox.MyListBox.MyList.bInitializeList = Index < 0;
    for (i = 0; i < Colors.ColorList.Length; ++i)
    {
        co_EditColor.AddItem(Colors.ColorList[i].Name,, Colors.ColorList[i].Name);
    }
    if (Index > -1)
    {
        co_EditColor.SilentSetIndex(Min(Index, co_EditColor.ItemCount() - 1));
    }
}

function InternalOnLoadINI(GUIComponent Sender, string s)
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
}

function InternalOnChange(GUIComponent Sender)
{
    local int Index;

    Index = co_EditColor.GetIndex();
    if (Sender == co_EditColor)
    {
        UpdateDisplayedColor(co_EditColor.GetComponentValue());
    }
    else if (Sender == ch_AllowOnRandom)
    {
        if (Colors.SetRandom(Index, ch_AllowOnRandom.IsChecked()))
        {
            Config.UpdateDynamicActors();
        }
    }
    else if (Index < Colors.ColorList.Length)
    {
        switch (Sender)
        {
            case sl_ColorRed:
                Colors.ColorList[Index].Color.R = sl_ColorRed.GetValue();
                break;
            case sl_ColorGreen:
                Colors.ColorList[Index].Color.G = sl_ColorGreen.GetValue();
                break;
            case sl_ColorBlue:
                Colors.ColorList[Index].Color.B = sl_ColorBlue.GetValue();
                break;
        }
        Config.UpdateDynamicActors();
    }
}

function PreviewSkinOnChange(GUIComponent Sender)
{
    Preview.SetPropertyText("ActiveSkin", GUIMenuOption(Sender).GetComponentValue());
    Preview.Restart();
}

function UpdateDisplayedColor(string ColorName)
{
    local HxColors.HxColor ColorEntry;

    Colors.FindEntry(ColorName, ColorEntry);
    sl_ColorRed.SetComponentValue(ColorEntry.Color.R, true);
    sl_ColorGreen.SetComponentValue(ColorEntry.Color.G, true);
    sl_ColorBlue.SetComponentValue(ColorEntry.Color.B, true);
    ch_AllowOnRandom.Checked(ColorEntry.bRandom);
    Preview.SetPropertyText("ActiveColor", co_EditColor.GetComponentValue());
    Preview.Restart();
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

function bool InternalButtonsOnPreDraw(Canvas C)
{
    if (l_ButtonAnchor.bInit)
    {
        l_ButtonAnchor.bInit = LeftSection.bInit;
        b_NewColor.WinLeft = l_ButtonAnchor.WinLeft;
        b_NewColor.WinTop = l_ButtonAnchor.WinTop;
        b_NewColor.WinWidth = (l_ButtonAnchor.WinWidth - 0.01) / 3;
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
        bRenderPreview = false;
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
            UpdateDisplayedColor(ColorName);
        }
        else
        {
            ShowInvalidNameDialog(ColorName);
        }
    }
    bRenderPreview = true;
}

function bool OnClickRenameColor(GUIComponent Sender)
{
    if (Controller.OpenMenu(string(class'HxGUIGetDataMenu'), RenameColorPageCaption, NameLabel))
    {
        Controller.ActivePage.SetDataString(co_EditColor.GetText());
        Controller.ActivePage.OnClose = OnCloseRenameColor;
        bRenderPreview = false;
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
            }
            else
            {
                ShowInvalidNameDialog(ColorName);
            }
        }
    }
    bRenderPreview = true;
}

function bool OnClickDeleteColor(GUIComponent Sender)
{
    if (Controller.OpenMenu(string(class'HxGUIQuestionPage')))
    {
        GUIQuestionPage(Controller.ActivePage).SetupQuestion(
            ConfirmColorDeletionLabel, QBTN_YesNo, QBTN_Yes);
        GUIQuestionPage(Controller.ActivePage).OnButtonClick = OnButtonClickDeleteColor;
        GUIQuestionPage(Controller.ActivePage).OnClose = OnCloseDeleteColor;
        bRenderPreview = false;
    }
    return true;
}

function OnButtonClickDeleteColor(byte bButton)
{
    if (bButton == QBTN_Yes && Colors.Remove(co_EditColor.GetIndex()))
    {
        PopulateColorComboBoxes();
        UpdateDisplayedColor(co_EditColor.GetComponentValue());
        Config.ValidateColors(Colors);
    }
}

function OnCloseDeleteColor(optional bool bCancelled)
{
    bRenderPreview = true;
}

function ShowInvalidNameDialog(string Name)
{
    if (Controller.OpenMenu(string(class'HxGUIQuestionPage')))
    {
        GUIQuestionPage(Controller.ActivePage).SetupQuestion(
            Repl(InvalidNameMessage, "%", Name), QBTN_Ok, QBTN_Ok);
    }
}

function bool OnClickChangeModel(GUIComponent Sender)
{
    if (Controller.OpenMenu(string(class'HxGUIModelSelect'), PreviewCharacterName, ""))
    {
        Controller.ActivePage.OnClose = OnCloseChangeModel;
        bRenderPreview = false;
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
            PreviewCharacterName = CharName;
            Preview.Setup(CharName);
        }
    }
    bRenderPreview = true;
}

function bool PreviewOnDraw(Canvas C)
{
    b_PreviewBox.Style.Draw(
        C,
        MenuState,
        b_PreviewBox.Bounds[0],
        b_PreviewBox.Bounds[1],
        b_PreviewBox.Bounds[2] - b_PreviewBox.Bounds[0],
        b_PreviewBox.Bounds[3] - b_PreviewBox.Bounds[1]);
    if (bRenderPreview)
    {
        Preview.DrawPreview(
            C,
            b_PreviewBox.ClientBounds[0],
            b_PreviewBox.ClientBounds[1],
            b_PreviewBox.ClientBounds[2] - b_PreviewBox.ClientBounds[0],
            b_PreviewBox.ClientBounds[3] - b_PreviewBox.ClientBounds[1]);
    }
    return true;
}

function bool PreviewOnCapturedMouseMove(float DeltaX, float DeltaY)
{
    Preview.Spin(DeltaX);
    return true;
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=ColorEditorSection
        Caption="Color Editor"
    End Object
    LeftSection=ColorEditorSection

    Begin Object class=HxGUIFramedSection Name=PreviewSection
        Caption="Color Preview"
        ExpandIndices=(1)
    End Object
    RightSection=PreviewSection

    Begin Object class=moComboBox Name=EditColorComboBox
        Caption="Color"
        Hint="Color to customize."
        StandardHeight=0.03
        bStandardized=true
        ComponentWidth=0.64
        bReadOnly=true
        OnChange=InternalOnChange
        TabOrder=0
    End Object
    co_EditColor=EditColorComboBox

    Begin Object class=moSlider Name=ColorRedSlider
        Caption="Red"
        INIOption="@INTERNAL"
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=1
    End Object
    sl_ColorRed=ColorRedSlider

    Begin Object class=moSlider Name=ColorGreenSlider
        Caption="Green"
        INIOption="@INTERNAL"
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=2
    End Object
    sl_ColorGreen=ColorGreenSlider

    Begin Object class=moSlider Name=ColorBlueSlider
        Caption="Blue"
        INIOption="@INTERNAL"
        ComponentWidth=0.64
        MinValue=0
        MaxValue=255
        bIntSlider=true
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=3
    End Object
    sl_ColorBlue=ColorBlueSlider

    Begin Object class=moCheckBox Name=AllowOnRandomCheckBox
        Caption="Allow Color On Random Highlight"
        Hint="Allow this color to be used on random highlight."
        INIOption="@INTERNAL"
        CaptionWidth=0.8
        OnLoadINI=InternalOnLoadINI
        OnChange=InternalOnChange
        TabOrder=4
    End Object
    ch_AllowOnRandom=AllowOnRandomCheckBox

    Begin Object class=GUILabel Name=ButtonAnchorLabel
        StandardHeight=0.03
        bStandardized=true
        bInit=true
        OnPreDraw=InternalButtonsOnPreDraw
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
        TabOrder=5
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
        TabOrder=6
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
        TabOrder=7
    End Object
    b_DeleteColor=DeleteColorButton

    Begin Object class=GUIButton Name=PreviewBoxButton
        StyleName="HxBackgroundDarker"
        bStandardized=false
        bTabStop=false
        bNeverFocus=true
        bDropTarget=true
        OnDraw=PreviewOnDraw
        OnCapturedMouseMove=PreviewOnCapturedMouseMove
    End Object
    b_PreviewBox=PreviewBoxButton

    Begin Object class=moComboBox Name=PreviewSkinComboBox
        Caption="Skin Type"
        Hint="Select skin type to be used on the preview."
        INIOption="@INTERNAL"
        ComponentWidth=0.64
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bReadOnly=true
        OnChange=PreviewSkinOnChange
        TabOrder=8
    End Object
    co_PreviewSkin=PreviewSkinComboBox

    Begin Object class=GUIButton Name=ChangeModelButton
        Caption="Change Preview Character"
        Hint="Select a different preview character."
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=OnClickChangeModel
        TabOrder=9
    End Object
    b_ChangeModel=ChangeModelButton

    WindowName="Skin Highlight - Customize Colors"
    WinWidth=0.75
    WinHeight=0.4
    WinLeft=0.125
    WinTop=0.3
    bPersistent=false

    NameLabel="Name"
    NewColorPageCaption="New Color"
    RenameColorPageCaption="Rename Color"
    ConfirmColorDeletionLabel="Are you sure you want to delete this color?"
    InvalidNameMessage="The name '%' is already in use or invalid."
    bRenderPreview=true
}
