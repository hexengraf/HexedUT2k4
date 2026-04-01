class HxGUIMapPreviewBanner extends HxGUIBackground;

var automated GUILabel l_Header;
var automated HxGUIBackground b_Preview;
var automated GUIImage i_Preview;
var automated GUILabel l_NoPreview;
var automated HxGUIScrollTextBox lb_Information;
var automated HxGUIBackground b_DescriptionFrame;
var automated GUIImage i_DescriptionBG;
var automated HxGUIScrollTextBox lb_Description;
var automated GUILabel l_NoInformation;

var float MaxPreviewWidth;
var localized string NoMapLabel;
var localized string NoInfoLabel;
var localized string PlayersLabel;
var localized string AuthorLabel;

var private string DisplayedMap;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    SetCustomBackground("");
}

function ResetBanner(string Caption)
{
    DisplayedMap = "";
    l_Header.SetVisibility(false);
    b_Preview.SetVisibility(false);
    i_Preview.SetVisibility(false);
    l_NoPreview.SetVisibility(false);
    b_DescriptionFrame.SetVisibility(false);
    i_DescriptionBG.SetVisibility(false);
    lb_Description.SetVisibility(false);
    l_NoInformation.SetVisibility(true);
    l_Header.Caption = "";
    l_NoInformation.Caption = Caption;
    lb_Information.SetContent("");
    lb_Description.SetContent("");
}

function SetMap(string MapName)
{
    local CacheManager.MapRecord Record;

    if (MapName == "")
    {
        ResetBanner(NoMapLabel);
        return;
    }
    if (MapName != DisplayedMap)
    {
        DisplayedMap = MapName;
        Record = class'CacheManager'.static.GetMapRecord(MapName);
        if (Record.MapName == "")
        {
            ResetBanner(NoInfoLabel);
            return;
        }
        if (Record.ScreenshotRef != "")
        {
            i_Preview.Image = Material(DynamicLoadObject(Record.ScreenshotRef, class'Material'));
        }
        else
        {
            i_Preview.Image = None;
        }
        l_Header.Caption = Record.FriendlyName;
        SetMapInformation(Record);
        lb_Description.SetContent(GetMapDescription(Record));
        l_Header.SetVisibility(true);
        b_Preview.SetVisibility(true);
        i_Preview.SetVisibility(true);
        l_NoPreview.SetVisibility(i_Preview.Image == None);
        l_NoInformation.SetVisibility(false);
        b_DescriptionFrame.SetVisibility(true);
        i_DescriptionBG.SetVisibility(true);
        lb_Description.SetVisibility(true);
    }
}

function SetMapInformation(CacheManager.MapRecord Record)
{
    if (Record.PlayerCountMax == 0)
    {
        lb_Information.SetContent("?"@PlayersLabel);
    }
    else if (Record.PlayerCountMin == Record.PlayerCountMax)
    {
        lb_Information.SetContent(Record.PlayerCountMin@PlayersLabel);
    }
    else
    {
        lb_Information.SetContent(Record.PlayerCountMin@"-"@Record.PlayerCountMax@PlayersLabel);
    }
    if (Record.Author != "")
    {
        lb_Information.AddText(AuthorLabel$":"@Record.Author);
    }
    else
    {
        lb_Information.AddText(AuthorLabel$": N/A");
    }
}

function string GetMapDescription(CacheManager.MapRecord Record)
{
    local DecoText Deco;
    local string Description;
    local string PackageName;
    local string DecoTextName;
    local int i;

    if (class'CacheManager'.static.Is2003Content(Record.MapName) && Record.TextName != "")
    {
        if (!Divide(Record.TextName, ".", PackageName, DecoTextName))
        {
            PackageName = "XMaps";
            DecoTextName = Record.TextName;
        }
        Deco = class'xUtil'.static.LoadDecoText(PackageName, DecoTextName);
        if (Deco != None)
        {
            for (i = 0; i < Deco.Rows.Length; ++i)
            {
                if (Description != "")
                {
                    Description $= "|";
                }
                Description $= Deco.Rows[i];
            }
            return Description;
        }
    }
    return Record.Description;
}

function bool InternalOnPreDrawInit(Canvas C)
{
    local float MaxHeight;
    local float ItemHeight;

    class'HxGUIStyles'.static.FillFrame(Self, l_NoInformation);
    class'HxGUIStyles'.static.AlignToBottomOf(l_Header, b_Preview);
    ItemHeight = lb_Information.GetItemHeight(C);
    MaxHeight = 1.0 - b_Preview.WinTop - b_Preview.RelativeHeight(7 * ItemHeight);
    b_Preview.WinWidth = MaxPreviewWidth;
    b_Preview.WinHeight = (2 / 3) * b_Preview.WinWidth * (ActualWidth() / ActualHeight());
    if (b_Preview.WinHeight > MaxHeight)
    {
        b_Preview.WinHeight = MaxHeight;
        b_Preview.WinWidth = (3 / 2) * b_Preview.WinHeight * (ActualHeight() / ActualWidth());
    }
    b_Preview.WinLeft = (1.0 - b_Preview.WinWidth) / 2;
    class'HxGUIStyles'.static.FillFrame(b_Preview, i_Preview);
    class'HxGUIStyles'.static.FillFrame(b_Preview, l_NoPreview);
    class'HxGUIStyles'.static.FillFrameWidth(Self, lb_Information);
    lb_Information.WinTop = b_Preview.WinTop + b_Preview.WinHeight;
    lb_Information.WinHeight = lb_Information.RelativeHeight(ItemHeight * 2.3);
    b_DescriptionFrame.WinTop = lb_Information.WinTop + lb_Information.WinHeight;
    b_DescriptionFrame.WinHeight = 1.0 - b_DescriptionFrame.WinTop;
    class'HxGUIStyles'.static.FillFrame(b_DescriptionFrame, i_DescriptionBG);
    class'HxGUIStyles'.static.CopyPosition(i_DescriptionBG, lb_Description);
    return false;
}

defaultproperties
{
    Begin Object class=GUILabel Name=HeaderLabel
        WinLeft=0
        WinTop=0
        WinWidth=1
        StandardHeight=0.0325
        bStandardized=true
        StyleName="HxBackgroundFrame"
        TextColor=(R=255,G=210,B=0,A=255)
        TextAlign=TXTA_Center
        bTransparent=true
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_Header=HeaderLabel

    Begin Object Class=HxGUIBackground Name=PreviewBackground
        RenderWeight=0.2
        StyleName="HxBackgroundDarker"
        bBoundToParent=true
        bScaleToParent=true
    End Object
    b_Preview=PreviewBackground

    Begin Object Class=GUIImage Name=PreviewImage
        RenderWeight=0.3
        ImageStyle=ISTY_Scaled
        bScaleToParent=true
        bBoundToParent=true
    End Object
    i_Preview=PreviewImage

    Begin Object Class=GUILabel Name=NoPreviewLabel
        Caption="No Preview Available"
        StyleName="HxTextGolden"
        FontScale=FNS_Medium
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        RenderWeight=1
        bVisible=false
        bMultiline=true
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_NoPreview=NoPreviewLabel

    Begin Object Class=HxGUIScrollTextBox Name=InformationTextBox
        FontScale=FNS_Small
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        LineSpacing=0.005
        LeftPadding=0.04
        RightPadding=0.04
        Separator=""
        bTabStop=false
        bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
        bStripColors=false
        bBoundToParent=true
        bScaleToParent=true
    End Object
    lb_Information=InformationTextBox

    Begin Object Class=HxGUIBackground Name=DescriptionBackground
        WinLeft=0
        WinWidth=1
        RenderWeight=0.2
        StyleName="HxBackgroundFrame"
        bBoundToParent=true
        bScaleToParent=true
    End Object
    b_DescriptionFrame=DescriptionBackground

    Begin Object Class=GUIImage Name=DescriptionBackgroundImage
        RenderWeight=0.3
        Image=Material'2K4Menus.BKRenders.ScanLines'
        ImageColor=(R=113,G=159,B=205,A=32)
        ImageStyle=ISTY_Stretched
        X1=0
        Y1=0
        X2=8
        Y2=128
        bBoundToParent=true
        bScaleToParent=true
    End Object
    i_DescriptionBG=DescriptionBackgroundImage

    Begin Object Class=HxGUIScrollTextBox Name=DescriptionTextBox
        WinLeft=0
        WinWidth=1
        CharDelay=0.0065
        EOLDelay=0.5
        FontScale=FNS_Small
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        LeftPadding=0.04
        TopPadding=0.04
        RightPadding=0.04
        BottomPadding=0.04
        bTabStop=false
        bVisibleWhenEmpty=true
        bNoTeletype=false
        bNeverFocus=true
        bStripColors=false
        bBoundToParent=true
        bScaleToParent=true
    End Object
    lb_Description=DescriptionTextBox

    Begin Object Class=GUILabel Name=NoInformationLabel
        StyleName="HxTextGolden"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        RenderWeight=1
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_NoInformation=NoInformationLabel

    StyleName="HxBackgroundGradient"
    MaxPreviewWidth=0.94
    NoMapLabel="No Map Selected"
    NoInfoLabel="Map Information Unavailable"
    PlayersLabel="players"
    AuthorLabel="Author"
    OnPReDrawInit=InternalOnPreDrawInit
}
