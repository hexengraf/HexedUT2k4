class HxGUIMenuBasePanel extends MidGamePanel
    abstract;

const HIDE_DUE_INIT = "Initializing...";
const HIDE_DUE_DISABLE = "Feature disabled on this server";
const HIDE_DUE_ADMIN = "Requires administrator privileges";

const BASE_WIN_TOP = 0.005;
const BASE_WIN_BOTTOM = 0.961;
const MINIMUM_SECTION_HEIGHT = 0.115;
const COMPONENT_HEIGHT = 0.0515;

var localized string PanelHint;
var bool bInsertFront;
var bool bDoubleColumn;
var bool bFillPanelHeight;

var automated array<AltSectionBackground> Sections;
var private automated array<AltSectionBackground> HideSections;
var private automated array<GUILabel> HideMessages;
var private bool bPanelAdded;

function bool Initialize();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);
    InitSections();
    HideAllSections(true, HIDE_DUE_INIT);
}

function ShowPanel(bool bShow)
{
    Super.ShowPanel(bShow);

    if (bShow)
    {
        if (Initialize())
        {
            HideAllSections(false);
            Refresh();
        }
        else
        {
            SetTimer(0.1, true);
        }
    }
}

event Timer()
{
    if (Initialize())
    {
        HideAllSections(false);
        Refresh();
        KillTimer();
    }
}

function DefaultOnLoadINI(GUIComponent Sender, string s)
{
    if (GUIMenuOption(Sender) != None && s != "")
    {
        GUIMenuOption(Sender).SetComponentValue(s, true);
    }
}

function DefaultOnChange(GUIComponent Sender, object Target)
{
    local array<string> Parts;

    if (Sender.INIOption != "")
    {
        Split(Sender.INIOption, " ", Parts);
        Target.SetPropertyText(Parts[1], GUIMenuOption(Sender).GetComponentValue());
        Target.SaveConfig();
    }
}

function InitSections()
{
    local int i;

    for (i = 0; i < Sections.Length; ++i)
    {
        InitSection(i);
        InitHideSection(i);
    }
    if (bFillPanelHeight)
    {
        if (bDoubleColumn)
        {
            AutoFillColumnHeight(0, 2);
            AutoFillColumnHeight(1, 2);
        }
        else
        {
            AutoFillColumnHeight(0, 1);
        }
    }
}

function InitSection(int i)
{
    if (Sections[i] == None)
    {
        return;
    }
    if (i == 0)
    {
        Sections[i].WinTop = BASE_WIN_TOP;
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
    Sections[i].LeftPadding = 0.00995;
    Sections[i].RightPadding = 0.00995;
    Sections[i].TopPadding = 0.04;
    if (bDoubleColumn)
    {
        if (i % 2 == 1)
        {
            Sections[i].WinLeft = 0.5025;
            Sections[i].WinWidth = 0.49749;
            Sections[i].LeftPadding = 0.02;
            Sections[i].RightPadding = 0.02;
        }
        else if (i + 1 < Sections.Length && (Sections[i].NumColumns == 1 || Sections[i + 1] != None))
        {
            Sections[i].WinWidth = 0.49749;
            Sections[i].LeftPadding = 0.02;
            Sections[i].RightPadding = 0.02;
        }
    }
    Sections[i].WinHeight = MINIMUM_SECTION_HEIGHT + (
        (Sections[i].AlignStack.Length / Sections[i].NumColumns) * COMPONENT_HEIGHT);
    Sections[i].bBoundToParent = true;
    Sections[i].bScaleToParent = true;
    Sections[i].bFillClient = true;
}

function InitHideSection(int i)
{
    if (Sections[i] == None)
    {
        HideSections[HideSections.Length] = None;
        HideMessages[HideMessages.Length] = None;
        return;
    }
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

function AutoFillColumnHeight(int StartAt, int Step)
{
    local int i;
    local int Count;
    local float RemainingHeight;

    for (i = StartAt; i < Sections.Length; i += Step)
    {
        if (Sections[i] != None)
        {
            RemainingHeight = BASE_WIN_BOTTOM - (Sections[i].WinTop + Sections[i].WinHeight);
            ++Count;
        }
    }
    if (RemainingHeight > 0)
    {
        RemainingHeight = RemainingHeight / Count;
    }
    for (i = StartAt; i < Sections.Length; i += Step)
    {
        if (Sections[i] != None)
        {
            if (i > StartAt)
            {
                Sections[i].WinTop += RemainingHeight;
                HideSections[i].WinTop += RemainingHeight;
            }
            Sections[i].WinHeight += RemainingHeight;
            HideSections[i].WinHeight += RemainingHeight;
        }
    }
}

function HideSection(int Section, bool bHidden, optional String Reason)
{
    if (Sections[Section] != None)
    {
        HideMessages[Section].Caption = Reason;
        HideSections[Section].SetVisibility(bHidden);
        Sections[Section].SetVisibility(!bHidden);
    }
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
    return PC != None
        && (PC.Level.NetMode == NM_Standalone
            || (PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo.bAdmin));
}

static function bool AddToMenu()
{
    if (!default.bPanelAdded)
    {
        default.bPanelAdded = true;
        class'HxGUIMenu'.static.AddPanel(
            default.Class, default.PanelCaption, default.PanelHint, default.bInsertFront);
        return true;
    }
    return false;
}

defaultproperties
{
    bInsertFront=false
    bDoubleColumn=false
    bFillPanelHeight=true

    Begin Object class=GUILabel Name=HideMessage
        TextAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
    End Object
}
