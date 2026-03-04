class HxGUIMenuBasePanel extends MidGamePanel
    abstract;

const HIDE_DUE_INIT = "Initializing...";
const HIDE_DUE_DISABLE = "Feature disabled on this server";
const HIDE_DUE_ADMIN = "Requires administrator privileges";

const BASE_WIN_TOP = 0.01;
const OFFSET_HEIGHT = 0.045;
const BASE_WIN_BOTTOM = 0.965;
const COMPONENT_HEIGHT = 0.05;
const HORIZONTAL_SPACING = 0.0085;
const VERTICAL_SPACING = 0.0035;

var automated array<HxGUIFramedSection> Sections;
var localized string PanelHint;

var array<float> SectionHeights;
var bool bInsertFront;
var bool bDoubleColumn;
var bool bFillPanelHeight;

var private automated array<GUILabel> HideMessages;
var private bool bPanelAdded;

function bool Initialize();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);
    HideAllSections(true, HIDE_DUE_INIT);
    bInit = true;
}

function bool InternalOnPreDraw(Canvas C)
{
    if (bInit)
    {
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
    Sections[i].WinLeft = 0;
    Sections[i].WinWidth = 1;
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
            if (Sections[i].WinHeight > 0)
            {
                Sections[i].WinHeight -= HORIZONTAL_SPACING;
            }
            Sections[i].WinTop =
                Sections[i - 2].WinTop + Sections[i - 2].WinHeight + HORIZONTAL_SPACING;
        }
    }
    else
    {
        if (Sections[i].WinHeight > 0)
        {
            Sections[i].WinHeight -= HORIZONTAL_SPACING;
        }
        Sections[i].WinTop =
            Sections[i - 1].WinTop + Sections[i - 1].WinHeight + HORIZONTAL_SPACING;
    }
    if (bDoubleColumn)
    {
        if (i % 2 == 1)
        {
            Sections[i].WinLeft = 0.5 + VERTICAL_SPACING;
            Sections[i].WinWidth = 0.5 - VERTICAL_SPACING;
        }
        else if (i + 1 < Sections.Length
            && (Sections[i].ColumnCount() == 1 || Sections[i + 1] != None))
        {
            Sections[i].WinWidth = 0.5 - VERTICAL_SPACING;
        }
    }
    if (Sections[i].WinHeight <= 0)
    {
        Sections[i].WinHeight =
            ((Sections[i].Count() / Sections[i].ColumnCount()) + 1) * COMPONENT_HEIGHT;
    }
    else if (bDoubleColumn)
    {
        Sections[i].WinHeight -= OFFSET_HEIGHT / int((Sections.Length + 1) / 2.0);
    }
    else
    {
        Sections[i].WinHeight -= OFFSET_HEIGHT / Sections.Length;
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
    Sections(0)=None
    bInsertFront=false
    bDoubleColumn=false
    bFillPanelHeight=true
    OnPreDraw=InternalOnPreDraw
}
