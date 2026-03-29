class HxGUIListBox extends GUIListBox
    DependsOn(HxPatternMatch);

var bool bAutoSpacing;
var float LineSpacing;
var float LeftPadding;
var float ScrollbarWidth;
var eTextAlign TextAlign;

var private HxPatternMatch.HxStringPattern ItemFilter;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    DefaultListClass = string(class'HxGUIList');
    Super.InitComponent(MyController, MyOwner);
    List.TextAlign = TextAlign;
    HxGUIList(List).bAutoSpacing = bAutoSpacing;
    HxGUIList(List).LineSpacing = LineSpacing;
    HxGUIList(List).LeftPadding = LeftPadding;
    MyScrollBar.WinWidth = ScrollbarWidth;
}

function bool Add(string NewItem, optional Object obj, optional string Str, optional bool bSection)
{
    if (class'HxPatternMatch'.static.StringPatternMatch(NewItem, ItemFilter))
    {
        List.Add(NewItem, obj, Str, bSection);
        return true;
    }
    return false;
}

function RemoveItem(string Item)
{
    local int Index;

    Index = List.Index;
    List.RemoveItem(Item);
    List.SetIndex(Min(List.ItemCount - 1, Index));
}

function int AddLinkObject(GUIComponent NewObj, optional bool bNoCheck)
{
    return List.AddLinkObject(NewObj, bNoCheck);
}

function array<GUIListElem> GetPendingElements(optional bool bGuarantee)
{
    return List.GetPendingElements(bGuarantee);
}

function ClearPendingElements()
{
    List.ClearPendingElements();
}

function string Get(optional bool bGuarantee)
{
    return List.Get(bGuarantee);
}

function string GetItemAtIndex(int Index)
{
    return List.GetItemAtIndex(Index);
}

function SetFilter(string Pattern)
{
    ItemFilter = class'HxPatternMatch'.static.ParseStringPattern(Pattern);
}

function int SetIndex(int Index)
{
    return List.SetIndex(Index);
}

function bool IsEnabled()
{
    return MenuState != MSAT_Disabled;
}

function Clear()
{
    List.Clear();
}

function Subtract(HxGUIListBox Other)
{
    local bool bOldNotify;
    local int i;

    bOldNotify = List.bNotify;
    List.bNotify = False;
    for (i = 0; i < Other.List.Elements.Length; ++i)
    {
        List.RemoveItem(Other.List.Elements[i].Item);
    }
    List.bNotify = bOldNotify;
}

defaultproperties
{
    Begin Object Class=HxGUIVertScrollBar Name=NewScrollbar
        bScaleToParent=true
    End Object
    MyScrollBar=NewScrollbar

    bAutoSpacing=true
    LineSpacing=0.003
    LeftPadding=0.015
    ScrollbarWidth=0.017
    TextAlign=TXTA_Left
    StyleName="HxSmallList"
    SelectedStyleName="HxSmallListSelection"
    OutlineStyleName=""
}
