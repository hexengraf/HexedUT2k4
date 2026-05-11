class HxMapPreviewBanner extends HxGUIBackground;

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
var localized string PlayersLabel;
var localized string AuthorLabel;

var private HxVTClient Client;
var private int DisplayedMapIndex;

function Refresh()
{
    if (DisplayedMapIndex > -1)
    {
        if (lb_Description.IsEmpty())
        {
            lb_Description.SetContent(Client.GetMapDescription(DisplayedMapIndex));
        }
        if (i_Preview.Image == None)
        {
            i_Preview.Image = Client.GetMapPreview(DisplayedMapIndex);
            l_NoPreview.SetVisibility(i_Preview.Image == None);
        }
    }
}

function ResetBanner(string Caption)
{
    DisplayedMapIndex = -1;
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

function SetClient(HxVTClient C)
{
    Client = C;
}

function SetMap(int MapIndex)
{
    local HxVTClient.HxMapEntry Entry;

    if (MapIndex == -1)
    {
        ResetBanner(NoMapLabel);
        return;
    }
    if (MapIndex != DisplayedMapIndex)
    {
        DisplayedMapIndex = MapIndex;
        Entry = Client.Maps[MapIndex];
        i_Preview.Image = Client.GetMapPreview(MapIndex);
        l_Header.Caption = Entry.Label;
        SetMapInformation(Entry.Author, Entry.MinPlayers, Entry.MaxPlayers);
        lb_Description.SetContent(Client.GetMapDescription(MapIndex));
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

function SetMapInformation(string Author, int MinPlayers, int MaxPlayers)
{
    if (MaxPlayers == 0)
    {
        lb_Information.SetContent("?"@PlayersLabel);
    }
    else if (MinPlayers == MaxPlayers)
    {
        lb_Information.SetContent(MinPlayers@PlayersLabel);
    }
    else
    {
        lb_Information.SetContent(MinPlayers@"-"@MaxPlayers@PlayersLabel);
    }
    if (Author != "")
    {
        lb_Information.AddText(AuthorLabel$":"@Author);
    }
    else
    {
        lb_Information.AddText(AuthorLabel$": N/A");
    }
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
    PlayersLabel="players"
    AuthorLabel="Author"
    OnPReDrawInit=InternalOnPreDrawInit
}
