class HxGUIBasePanel extends MidGamePanel
    abstract;

const BASE_WIN_TOP = 0.01;
const BASE_HEIGHT = 0.955;
const BASE_WIN_BOTTOM = 0.965;
const COMPONENT_HEIGHT = 0.05;
const SPACING = 0.007;

var automated array<HxGUIFramedSection> Sections;
var localized string HideDueInit;
var localized string HideDueDisable;
var localized string HideDueAdmin;

var array<float> SectionHeights;
var bool bDoubleColumn;
var bool bFillPanelHeight;

var private float VerticalSpacing;
var private float HorizontalSpacing;
var private automated array<GUILabel> HideMessages;

function bool Initialize();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);
    HideAllSections(true, HideDueInit);
    bInit = true;
}

function bool InternalOnPreDraw(Canvas C)
{
    local float ActualSpacing;

    if (bInit)
    {
        ActualSpacing = SPACING * C.ClipY;
        VerticalSpacing = ActualSpacing / ActualHeight();
        HorizontalSpacing = ActualSpacing / ActualWidth() / 2;
        InitSections();
        bInit = false;
    }
    return false;
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
    if (GUIMenuOption(Sender) != None && StrCmp("Unrecognized property", s, 21) != 0)
    {
        GUIMenuOption(Sender).SetComponentValue(s, true);
    }
    else
    {
        Warn("Failed to initialize component:"@s);
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

    if (bDoubleColumn)
    {
        ShrinkToFit(0, 2);
        ShrinkToFit(1, 2);
    }
    else
    {
        ShrinkToFit(0, 1);
    }
    for (i = 0; i < Sections.Length; ++i)
    {
        if (Sections[i] != None)
        {
            InitSection(i);
        }
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
    Sections[i].WinLeft = 0;
    Sections[i].WinWidth = 1;

    if (bDoubleColumn)
    {
        if (i == 0)
        {
            Sections[i].WinTop = BASE_WIN_TOP;
        }
        else if (i == 1 || (i % 2 == 1 && Sections[i - 2] == None))
        {
            Sections[i].WinTop = Sections[i - 1].WinTop;
        }
        else
        {
            Sections[i].WinTop =
                Sections[i - 2].WinTop + Sections[i - 2].WinHeight + VerticalSpacing;
        }
        if (i % 2 == 1)
        {
            Sections[i].WinLeft = 0.5 + HorizontalSpacing;
            Sections[i].WinWidth = 0.5 - HorizontalSpacing;
        }
        else if (i + 1 < Sections.Length)
        {
            if (Sections[i].ColumnCount() == 1 || Sections[i + 1] != None)
            {
                Sections[i].WinWidth = 0.5 - HorizontalSpacing;
            }
            else if (i > 1 && Sections[i - 1] != None)
            {
                Sections[i - 1].WinHeight =
                    Sections[i].WinTop - Sections[i - 1].WinTop - VerticalSpacing;
            }
        }
    }
    else if (i == 0)
    {
        Sections[i].WinTop = BASE_WIN_TOP;
    }
    else
    {
        Sections[i].WinTop = Sections[i - 1].WinTop + Sections[i - 1].WinHeight + VerticalSpacing;
    }
    if (Sections[i].WinHeight <= 0)
    {
        Sections[i].WinHeight =
            ((Sections[i].Count() / Sections[i].ColumnCount()) + 1) * COMPONENT_HEIGHT;
    }
}

function ShrinkToFit(int StartAt, int Step)
{
    local float Height;
    local int Count;
    local int i;

    for (i = StartAt; i < Sections.Length; i += Step)
    {
        if (Sections[i] != None)
        {
            ++Count;
            Height += Sections[i].WinHeight;
            if (i != StartAt)
            {
                Height += VerticalSpacing;
            }
        }
        else if (i > 0 && Sections[i - 1] != None && Sections[i - 1].ColumnCount() > 1)
        {
            ++Count;
            Height += Sections[i - 1].WinHeight;
            if (i != StartAt)
            {
                Height += VerticalSpacing;
            }
        }
    }
    if (Height > BASE_HEIGHT)
    {
        Height = (Height - BASE_HEIGHT) / Count;
        for (i = StartAt; i < Sections.Length; i += Step)
        {
            if (Sections[i] != None)
            {
                Sections[i].WinHeight -= Height;
            }
        }
    }
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
            }
            Sections[i].WinHeight += RemainingHeight;
        }
    }
}

function HideAllSections(bool bHidden, optional String Reason)
{
    local int i;

    for (i = 0; i < Sections.Length; ++i)
    {
        if (Sections[i] != None)
        {
            Sections[i].SetHide(bHidden, Reason);
        }
    }
}

function SetEnable(GUIComponent Comp, bool bEnable)
{
    if (bEnable)
    {
        EnableComponent(Comp);
    }
    else
    {
        DisableComponent(Comp);
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

defaultproperties
{
    HideDueInit="Initializing..."
    HideDueDisable="Feature disabled on this server"
    HideDueAdmin="Requires administrator privileges"
    Sections(0)=None
    bDoubleColumn=false
    bFillPanelHeight=true
    OnPreDraw=InternalOnPreDraw
}
