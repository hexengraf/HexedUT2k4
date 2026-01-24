class HxGUIVotingMapBanner extends HxGUIFramedImage;

const MEDIUM_FONT_SPACING = 1.44;
const SMALL_FONT_SPACING = 1.2;

var automated HxGUIFramedLabel fl_Header;
var automated HxGUIFramedImage fi_Preview;
var automated GUILabel l_NoPreview;
var automated HxGUIScrollTextBox lb_Information;
var automated HxGUIScrollTextBox lb_Description;
var automated GUILabel l_NoInformation;
var automated HxGUIFramedButton fb_SelectRandom;
var automated HxGUIFramedButton fb_SubmitVote;

var float MaxPreviewWidth;
var localized string NoMapLabel;
var localized string NoInfoLabel;
var localized string PlayersLabel;
var localized string AuthorLabel;

var string DisplayedMap;

delegate SelectRandom();
delegate SubmitVote();

function ResetBanner(string Caption)
{
    DisplayedMap = "";
    fl_Header.SetCaption("");
    fi_Preview.SetVisibility(false);
    l_NoPreview.SetVisibility(false);
    lb_Information.SetContent("");
    lb_Description.SetContent("");
    l_NoInformation.Caption = Caption;
    l_NoInformation.SetVisibility(true);
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
            fi_Preview.SetImage(Material(DynamicLoadObject(Record.ScreenshotRef, class'Material')));
        }
        else
        {
            fi_Preview.SetImage(None);
        }
        fl_Header.SetCaption(Record.FriendlyName);
        SetMapInformation(Record);
        lb_Description.SetContent(GetMapDescription(Record));
        fi_Preview.SetVisibility(true);
        l_NoPreview.SetVisibility(fi_Preview.Image == None);
        l_NoInformation.SetVisibility(false);
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

function bool AlignComponents(Canvas C)
{
    AlignPreview(C, AlignHeader(C) + AlignFooter(C));
    AlignDescription(C);
    AlignNoInformationLabel();
    return false;
}

function AlignNoInformationLabel()
{
    l_NoInformation.WinLeft = FramedImage.WinLeft;
    l_NoInformation.WinTop = FramedImage.WinTop;
    l_NoInformation.WinWidth = FramedImage.WinWidth;
    l_NoInformation.WinHeight = FramedImage.WinHeight - fb_SelectRandom.WinHeight;
}

function float AlignHeader(Canvas C)
{
    fl_Header.WinHeight = fl_Header.RelativeHeight(
        fl_Header.GetFontHeight(C) * MEDIUM_FONT_SPACING);
    return fl_Header.WinHeight;
}

function float AlignFooter(Canvas C)
{
    fb_SelectRandom.WinWidth += FramedImage.WinLeft / 2;
    fb_SelectRandom.WinHeight = fb_SelectRandom.RelativeHeight(
        fb_SelectRandom.GetFontHeight(C) * MEDIUM_FONT_SPACING);
    fb_SelectRandom.WinTop = 1.0 - fb_SelectRandom.WinHeight;
    fb_SubmitVote.WinLeft -= FramedImage.WinLeft / 2;
    fb_SubmitVote.WinTop = fb_SelectRandom.WinTop;
    fb_SubmitVote.WinWidth = fb_SelectRandom.WinWidth;
    fb_SubmitVote.WinHeight = fb_SelectRandom.WinHeight;
    return fb_SelectRandom.WinHeight;
}

function AlignPreview(Canvas C, float FilledHeight)
{
    local float TotalWidth;
    local float TotalHeight;
    local float MaxHeight;

    TotalWidth = ActualWidth();
    TotalHeight = ActualHeight();
    MaxHeight = fi_Preview.RelativeHeight(
        TotalHeight - (TotalHeight * FilledHeight) - (7 * lb_Information.GetItemHeight(C)));
    fi_Preview.WinWidth = MaxPreviewWidth;
    fi_Preview.WinHeight = (2 / 3) * fi_Preview.WinWidth * (TotalWidth / TotalHeight);
    if (fi_Preview.WinHeight > MaxHeight)
    {
        fi_Preview.WinHeight = MaxHeight;
        fi_Preview.WinWidth = (3 / 2) * fi_Preview.WinHeight * (TotalHeight / TotalWidth);
    }
    fi_Preview.WinLeft = (1.0 - fi_Preview.WinWidth) / 2;
    fi_Preview.WinTop = fl_Header.WinTop + fl_Header.WinHeight - FramedImage.WinTop;
    l_NoPreview.WinLeft = fi_Preview.WinLeft;
    l_NoPreview.WinTop = fi_Preview.WinTop;
    l_NoPreview.WinWidth = fi_Preview.WinWidth;
    l_NoPreview.WinHeight = fi_Preview.WinHeight;
}

function AlignDescription(Canvas C)
{
    local float ItemHeight;

    ItemHeight = lb_Information.GetItemHeight(C);
    lb_Information.WinTop = fi_Preview.WinTop + fi_Preview.WinHeight - FramedImage.WinTop;
    lb_Information.WinHeight = lb_Information.RelativeHeight(ItemHeight * 2 * SMALL_FONT_SPACING);
    lb_Description.WinTop = lb_Information.WinTop + lb_Information.WinHeight - FramedImage.WinTop;
    lb_Description.WinHeight = fb_SelectRandom.WinTop - lb_Description.WinTop + FramedImage.WinTop;
}

function bool OnClickSelectRandom(GUIComponent Sender)
{
    SelectRandom();
    return true;
}

function bool OnClickSubmitVote(GUIComponent Sender)
{
    SubmitVote();
    return true;
}

defaultproperties
{
    Begin Object class=HxGUIFramedLabel Name=HeaderLabel
        WinLeft=0
        WinTop=0
        WinWidth=1
        bTransparent=true
        FrameColor=(R=0,G=0,B=0,A=0)
        bScaleToParent=true
        bBoundToParent=true
    End Object
    fl_Header=HeaderLabel

    Begin Object Class=HxGUIFramedImage Name=PreviewImage
        RenderWeight=0.5
        ImageStyle=ISTY_Scaled
        ImageRenderStyle=MSTY_Normal
        FrameColor=(R=113,G=159,B=205,A=255)
        bScaleToParent=true
        bBoundToParent=true
    End Object
    fi_Preview=PreviewImage

    Begin Object Class=GUILabel Name=NoPreviewLabel
        Caption="No Preview Available"
        TextFont="MediumFont"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        RenderWeight=1
        bVisible=false
        bMultiline=true
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_NoPreview=NoPreviewLabel

    Begin Object Class=HxGUIScrollTextBox Name=InformationTextBox
        WinLeft=0
        WinWidth=1
        FontScale=FNS_Small
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        LineSpacing=0.005
        LeftPadding=0.04
        RightPadding=0.04
        Separator=""
        bBackgroundVisible=false
        bTabStop=false
        bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
        bStripColors=false
        bBoundToParent=true
        bScaleToParent=true
    End Object
    lb_Information=InformationTextBox

    Begin Object Class=HxGUIScrollTextBox Name=DescriptionTextBox
        WinLeft=0
        WinWidth=1
        CharDelay=0.0065
        EOLDelay=0.5
        FontScale=FNS_Small
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        bBackgroundVisible=true
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
        TextFont="MediumFont"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        BackColor=(R=38,G=59,B=126,A=255)
        bTransparent=false
        RenderWeight=1
        bScaleToParent=true
        bBoundToParent=true
    End Object
    l_NoInformation=NoInformationLabel

    Begin Object Class=HxGUIFramedButton Name=SelectRandomButton
        Caption="Select Random"
        Hint="Select a random map from the map list (or vote list if focused and non-empty)."
        WinLeft=0
        WinWidth=0.5
        bNeverFocus=true
        bRepeatClick=true
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickSelectRandom
    End Object
    fb_SelectRandom=SelectRandomButton

    Begin Object Class=HxGUIFramedButton Name=SubmitVoteButton
        Caption="Submit Vote"
        Hint="Vote for the currently selected map."
        WinLeft=0.5
        WinWidth=0.5
        bNeverFocus=true
        bRepeatClick=false
        bBoundToParent=true
        bScaleToParent=true
        OnClick=OnClickSubmitVote
    End Object
    fb_SubmitVote=SubmitVoteButton

    MaxPreviewWidth=0.95
    NoMapLabel="No Map Selected"
    NoInfoLabel="Map Information Unavailable"
    PlayersLabel="players"
    AuthorLabel="Author"

    ImageColor=(R=32,G=50,B=106,A=255)
    OnPreDrawInit=AlignComponents
}
