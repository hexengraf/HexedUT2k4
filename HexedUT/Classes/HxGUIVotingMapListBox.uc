class HxGUIVotingMapListBox extends HxGUIVotingBaseListBox;

var localized string CaseSensitiveLabels[2];
var private bool bCaseSensitive;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    DefaultListClass = string(class'HxGUIVotingMapList');
    Super.InitComponent(MyController, MyOwner);
    SearchBar.ed_Columns[0].EditBox.ToolTip.ExpirationSeconds = 5;
    SearchBar.ed_Columns[1].EditBox.ToolTip.ExpirationSeconds = 10;
    SearchBar.ed_Columns[2].EditBox.ToolTip.ExpirationSeconds = 6;
    SearchBar.ed_Columns[0].ContextMenu.AddItem(CaseSensitiveLabels[0]);
    SearchBar.ed_Columns[0].ContextMenu.OnSelect = OnSelectCaseSensitive;
}

function SetFilter(HxMapVoteFilter Filter)
{
    HxGUIVotingMapList(MyBaseList).SetFilter(Filter);
}

function SetPrefix(string Prefix)
{
    HxGUIVotingMapList(MyBaseList).SetPrefix(Prefix);
}

function SetMapSource(int Source)
{
    HxGUIVotingMapList(MyBaseList).SetMapSource(Source);
}

function OnChangeNameSearch(GUIComponent Sender)
{
    HxGUIVotingMapList(MyBaseList).SearchName(GUIEditBox(Sender).GetText(), bCaseSensitive);
}

function OnChangePlayersSearch(GUIComponent Sender)
{
    HxGUIVotingMapList(MyBaseList).SearchPlayers(GUIEditBox(Sender).GetText());
}

function OnChangePlayedSearch(GUIComponent Sender)
{
    HxGUIVotingMapList(MyBaseList).SearchPlayed(GUIEditBox(Sender).GetText());
}

function OnChangeRecentSearch(GUIComponent Sender)
{
    HxGUIVotingMapList(MyBaseList).SearchRecent(GUIEditBox(Sender).GetText());
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

    Begin Object class=HxGUIFramedEditBox Name=NameSearch
        Hint="Search by map name. * matches anything. ^ and $ matches begin and end of name."
        TabOrder=0
        bBoundToParent=true
        bScaleToParent=true
        ContextMenu=CaseSensitiveContextMenu
        OnChange=OnChangeNameSearch
    End Object

    Begin Object class=HxGUIFramedEditBox Name=PlayersSearch
        Hint="Search by player count. One number shows maps that support it. Two numbers separated by - shows min-max player counts. * matches anything. > or < or = followed by a number matches with comparison."
        TabOrder=2
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangePlayersSearch
    End Object

    Begin Object class=HxGUIFramedEditBox Name=PlayedSearch
        Hint="Search by played count. * matches anything. > or < or = followed by a number matches with comparison."
        TabOrder=3
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangePlayedSearch
    End Object

    Begin Object Class=HxGUIVotingSearchBar Name=HxSearchBar
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
    // DefaultListClass="HexedPatches.HxGUIVotingMapList"
    CaseSensitiveLabels(0)="Enable Case-Sensitive Search"
    CaseSensitiveLabels(1)="Disable Case-Sensitive Search"
}
