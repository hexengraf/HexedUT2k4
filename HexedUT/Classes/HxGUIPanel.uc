class HxGUIPanel extends MidGamePanel;

const HIDE_DUE_INIT = "Initializing...";
const HIDE_DUE_DISABLE = "Feature disabled on this server";

var automated array<AltSectionBackground> Sections;
var private automated array<AltSectionBackground> HideSections;
var private automated array<GUILabel> HideMessages;
var bool bDoubleColumn;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);
    InitSections();
    HideAllSections(true, HIDE_DUE_INIT);
}

function InitSections()
{
    local int i;

    for (i = 0; i < Sections.Length; ++i)
    {
        InitSection(i);
        InitHideSection(i);
    }
}

function InitSection(int i)
{
    if (i == 0)
    {
        Sections[i].WinTop = 0.005;
    }
    else if (bDoubleColumn)
    {
        if (i == 1 || (i % 2 == 1 && Sections[i - 2] == None))
        {
            Sections[i].WinTop = Sections[i - 1].WinTop;
        }
        else
        {
            Sections[i].WinTop = Sections[i - 2].WinTop + Sections[i - 2].WinHeight + 0.005;
        }
    }
    else
    {
        Sections[i].WinTop = Sections[i - 1].WinTop + Sections[i - 1].WinHeight + 0.005;
    }
    Sections[i].WinLeft = 0.00001;
    Sections[i].WinWidth = 0.99998;
    Sections[i].LeftPadding = 0.00994999899998;
    Sections[i].RightPadding = 0.00994999899998;
    Sections[i].TopPadding = 0.04;
    Sections[i].ColPadding = 0.04;
    if (bDoubleColumn)
    {
        if (i % 2 == 1)
        {
            Sections[i].WinLeft = 0.5025;
            Sections[i].WinWidth = 0.49749;
            Sections[i].LeftPadding = 0.02;
            Sections[i].RightPadding = 0.02;
        }
        else if (i + 1 < Sections.Length && Sections[i + 1] != None)
        {
            Sections[i].WinWidth = 0.49749;
            Sections[i].LeftPadding = 0.02;
            Sections[i].RightPadding = 0.02;
        }
    }
    Sections[i].bBoundToParent = true;
    Sections[i].bScaleToParent = true;
    Sections[i].bFillClient = true;
}

function InitHideSection(int i)
{
    HideSections[HideSections.Length] = AltSectionBackground(
        AddComponent(String(class'AltSectionBackground'), true));

    if (HideSections[HideSections.Length - 1] == None)
    {
        warn(Name@"could not create hide section");
        return;
    }
    MirrorSection(HideSections[i], Sections[i]);
    InitHideMessage(i);
}

function InitHideMessage(int i)
{
    HideMessages[HideMessages.Length] = GUILabel(AddComponent(String(class'GUILabel'), true));

    if (HideMessages[HideMessages.Length - 1] == None)
    {
        warn(Name@"could not create hide message");
        return;
    }
    HideMessages[i].TextAlign = TXTA_Center;
    HideMessages[i].TextColor.R = 255;
    HideMessages[i].TextColor.G = 210;
    HideMessages[i].TextColor.B = 0;
    HideMessages[i].TextColor.A = 255;
    HideSections[i].ManageComponent(HideMessages[i]);
}

static function MirrorSection(AltSectionBackground Mirror, AltSectionBackground Original)
{
    Mirror.Caption = Original.Caption;
    Mirror.WinWidth = Original.WinWidth;
    Mirror.WinHeight = Original.WinHeight;
    Mirror.WinLeft = Original.WinLeft;
    Mirror.WinTop = Original.WinTop;
    Mirror.LeftPadding = Original.LeftPadding;
    Mirror.RightPadding = Original.RightPadding;
    Mirror.TopPadding = Original.TopPadding;
    Mirror.bBoundToParent = Original.bBoundToParent;
    Mirror.bScaleToParent = Original.bScaleToParent;
    Mirror.bFillClient = Original.bFillClient;
}

function HideSection(int Section, bool bHidden, optional String Reason)
{
    HideMessages[Section].Caption = Reason;
    HideSections[Section].SetVisibility(bHidden);
    Sections[Section].SetVisibility(!bHidden);
}

function HideAllSections(bool bHidden, optional String Reason)
{
    local int i;

    for (i = 0; i < Sections.Length; ++i)
    {
        HideSection(i, bHidden, Reason);
    }
}

function bool IsAdmin()
{
	local PlayerController PC;

	PC = PlayerOwner();
	return PC != None && PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo.bAdmin;
}

defaultproperties
{
    bDoubleColumn=false

    Begin Object class=GUILabel Name=HideMessage
        TextAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
    End Object
}
