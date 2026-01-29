class HxGUIVotingMapListBox extends HxGUIVotingBaseListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    SearchBar.ed_Columns[0].ToolTip.ExpirationSeconds = 5;
    SearchBar.ed_Columns[1].ToolTip.ExpirationSeconds = 10;
    SearchBar.ed_Columns[2].ToolTip.ExpirationSeconds = 6;
    SearchBar.ed_Columns[3].ToolTip.ExpirationSeconds = 6;
}

function SetFilter(HxMapVoteFilter Filter)
{
    HxGUIVotingMapList(MyVotingBaseList).SetFilter(Filter);
}

function SetPrefix(string Prefix)
{
    HxGUIVotingMapList(MyVotingBaseList).SetPrefix(Prefix);
}

function SetMapSource(int Source)
{
    HxGUIVotingMapList(MyVotingBaseList).SetMapSource(Source);
}

function OnChangeNameSearch(GUIComponent Sender)
{
    HxGUIVotingMapList(MyVotingBaseList).SearchName(GUIEditBox(Sender).GetText(), false);
}

function OnChangePlayersSearch(GUIComponent Sender)
{
    HxGUIVotingMapList(MyVotingBaseList).SearchPlayers(GUIEditBox(Sender).GetText());
}

function OnChangePlayedSearch(GUIComponent Sender)
{
    HxGUIVotingMapList(MyVotingBaseList).SearchPlayed(GUIEditBox(Sender).GetText());
}

function OnChangeRecentSearch(GUIComponent Sender)
{
    HxGUIVotingMapList(MyVotingBaseList).SearchRecent(GUIEditBox(Sender).GetText());
}

defaultproperties
{
    Begin Object class=GUIEditBox Name=NameSearch
        Hint="Search by map name. * matches anything. ^ and $ matches begin and end of name."
        StyleName="HxEditBox"
        FontScale=FNS_Small
        TabOrder=0
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangeNameSearch
    End Object

    Begin Object class=GUIEditBox Name=PlayersSearch
        Hint="Search by player count. One number shows maps that support it. Two numbers separated by - shows min-max player counts. * matches anything. > or < or = followed by a number matches with comparison."
        StyleName="HxEditBox"
        FontScale=FNS_Small
        TabOrder=1
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangePlayersSearch
    End Object

    Begin Object class=GUIEditBox Name=PlayedSearch
        Hint="Search by played count. * matches anything. > or < or = followed by a number matches with comparison."
        StyleName="HxEditBox"
        FontScale=FNS_Small
        TabOrder=2
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangePlayedSearch
    End Object

    Begin Object class=GUIEditBox Name=RecentSearch
        Hint="Search by recent. * matches anything. > or < or = followed by a number matches with comparison."
        StyleName="HxEditBox"
        FontScale=FNS_Small
        TabOrder=3
        bBoundToParent=true
        bScaleToParent=true
        OnChange=OnChangeRecentSearch
    End Object

    Begin Object Class=HxGUIVotingSearchBar Name=HxSearchBar
        WinLeft=0
        WinWidth=1
        ed_Columns=(NameSearch,PlayersSearch,PlayedSearch,RecentSearch)
        bBoundToParent=true
        bScaleToParent=true
    End Object
    SearchBar=HxSearchBar

    HeaderColumnPerc(0)=0.62
    HeaderColumnPerc(1)=0.14
    HeaderColumnPerc(2)=0.13
    HeaderColumnPerc(3)=0.11
    DefaultListClass="HexedPatches.HxGUIVotingMapList"
}
