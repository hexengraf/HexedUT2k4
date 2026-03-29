class HxMapVotingMapListBox extends HxMapVotingBaseListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    DefaultListClass = string(class'HxMapVotingMapList');
    Super.InitComponent(MyController, MyOwner);
    SearchBar.ed_Columns[0].ToolTip.ExpirationSeconds = 6;
    SearchBar.ed_Columns[0].SetHint(
        SearchBar.ed_Columns[0].Hint@class'HxPatternMatch'.default.StringPatternMatchHint);
    SearchBar.ed_Columns[1].AllowedCharSet = "0123456789<=>*-";
    SearchBar.ed_Columns[1].ToolTip.ExpirationSeconds = 20;
    SearchBar.ed_Columns[1].SetHint(
        SearchBar.ed_Columns[1].Hint@class'HxPatternMatch'.default.RangePatternMatchHint);
    SearchBar.ed_Columns[2].AllowedCharSet = "0123456789<=>*";
    SearchBar.ed_Columns[2].ToolTip.ExpirationSeconds = 8;
    SearchBar.ed_Columns[2].SetHint(
        SearchBar.ed_Columns[2].Hint@class'HxPatternMatch'.default.ValuePatternMatchHint);
}

function SetFilter(HxMapVotingFilter Filter)
{
    HxMapVotingMapList(List).SetFilter(Filter);
}

function SetPrefix(string Prefix)
{
    HxMapVotingMapList(List).SetPrefix(Prefix);
}

function OnChangeNameSearch(GUIComponent Sender)
{
    HxMapVotingMapList(List).SearchName(GUIEditBox(Sender).GetText());
}

function OnChangePlayersSearch(GUIComponent Sender)
{
    HxMapVotingMapList(List).SearchPlayers(GUIEditBox(Sender).GetText());
}

function OnChangePlayedSearch(GUIComponent Sender)
{
    HxMapVotingMapList(List).SearchPlayed(GUIEditBox(Sender).GetText());
}

defaultproperties
{
    Begin Object class=GUIEditBox Name=NameSearch
        Hint="Search by map name."
        StyleName="HxEditBox"
        FontScale=FNS_Small
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=0
        OnChange=OnChangeNameSearch
    End Object

    Begin Object class=GUIEditBox Name=PlayersSearch
        Hint="Search by player count."
        StyleName="HxEditBox"
        FontScale=FNS_Small
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=1
        OnChange=OnChangePlayersSearch
    End Object

    Begin Object class=GUIEditBox Name=PlayedSearch
        Hint="Search by played count."
        StyleName="HxEditBox"
        FontScale=FNS_Small
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=2
        OnChange=OnChangePlayedSearch
    End Object

    Begin Object Class=HxGUIMultiColumnListSearchBar Name=HxSearchBar
        WinLeft=0
        WinWidth=1
        FirstColumn=2
        ed_Columns=(NameSearch,PlayersSearch,PlayedSearch)
        bBoundToParent=true
        bScaleToParent=true
    End Object
    SearchBar=HxSearchBar

    HeaderColumnPerc(3)=0.25
    HeaderColumnPerc(4)=0.25
}
