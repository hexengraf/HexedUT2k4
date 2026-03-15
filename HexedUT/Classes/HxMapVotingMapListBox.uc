class HxMapVotingMapListBox extends HxMapVotingBaseListBox;

var localized string CaseSensitiveLabels[2];
var private bool bCaseSensitive;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    DefaultListClass = string(class'HxMapVotingMapList');
    Super.InitComponent(MyController, MyOwner);
    SearchBar.ed_Columns[0].ToolTip.ExpirationSeconds = 5;
    SearchBar.ed_Columns[1].ToolTip.ExpirationSeconds = 10;
    SearchBar.ed_Columns[2].ToolTip.ExpirationSeconds = 6;
    SearchBar.ed_Columns[0].ContextMenu.AddItem(CaseSensitiveLabels[0]);
    SearchBar.ed_Columns[0].ContextMenu.OnSelect = OnSelectCaseSensitive;
}

function SetFilter(HxMapVotingFilter Filter)
{
    HxMapVotingMapList(List).SetFilter(Filter);
}

function SetPrefix(string Prefix)
{
    HxMapVotingMapList(List).SetPrefix(Prefix);
}

function SetMapSource(int Source)
{
    HxMapVotingMapList(List).SetMapSource(Source);
}

function OnChangeNameSearch(GUIComponent Sender)
{
    HxMapVotingMapList(List).SearchName(GUIEditBox(Sender).GetText(), bCaseSensitive);
}

function OnChangePlayersSearch(GUIComponent Sender)
{
    HxMapVotingMapList(List).SearchPlayers(GUIEditBox(Sender).GetText());
}

function OnChangePlayedSearch(GUIComponent Sender)
{
    HxMapVotingMapList(List).SearchPlayed(GUIEditBox(Sender).GetText());
}

function OnChangeRecentSearch(GUIComponent Sender)
{
    HxMapVotingMapList(List).SearchRecent(GUIEditBox(Sender).GetText());
}

function OnSelectCaseSensitive(GUIContextMenu Sender, int Index)
{
    bCaseSensitive = !bCaseSensitive;
    SearchBar.ed_Columns[0].ContextMenu.ReplaceItem(0, CaseSensitiveLabels[int(bCaseSensitive)]);
    OnChangeNameSearch(SearchBar.ed_Columns[0]);
}

defaultproperties
{
    Begin Object Class=GUIContextMenu Name=CaseSensitiveContextMenu
    End Object

    Begin Object class=GUIEditBox Name=NameSearch
        Hint="Search by map name. * matches anything. ^ and $ matches begin and end of name."
        StyleName="HxEditBox"
        FontScale=FNS_Small
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=0
        ContextMenu=CaseSensitiveContextMenu
        OnChange=OnChangeNameSearch
    End Object

    Begin Object class=GUIEditBox Name=PlayersSearch
        Hint="Search by player count. One number shows maps that support it. Two numbers separated by - shows min-max player counts. * matches anything. > or < or = followed by a number matches with comparison."
        StyleName="HxEditBox"
        FontScale=FNS_Small
        bBoundToParent=true
        bScaleToParent=true
        TabOrder=1
        OnChange=OnChangePlayersSearch
    End Object

    Begin Object class=GUIEditBox Name=PlayedSearch
        Hint="Search by played count. * matches anything. > or < or = followed by a number matches with comparison."
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
    // DefaultListClass="HexedPatches.HxMapVotingMapList"
    CaseSensitiveLabels(0)="Enable Case-Sensitive Search"
    CaseSensitiveLabels(1)="Disable Case-Sensitive Search"
}
