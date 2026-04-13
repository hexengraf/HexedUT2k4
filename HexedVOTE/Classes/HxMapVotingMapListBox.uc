class HxMapVotingMapListBox extends HxMapVotingBaseListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    DefaultListClass = string(class'HxMapVotingMapList');
    Super.InitComponent(MyController, MyOwner);
}

function SetFilter(HxMapFilter Filter)
{
    HxMapVotingMapList(List).SetFilter(Filter);
}

function SetPrefix(string Prefix)
{
    HxMapVotingMapList(List).SetPrefix(Prefix);
}

function InternalOnSearch(int Index, string Term)
{
    switch (Index)
    {
        case 0:
            HxMapVotingMapList(List).SearchName(Term);
            break;
        case 1:
            HxMapVotingMapList(List).SearchPlayers(Term);
            break;
        case 2:
            HxMapVotingMapList(List).SearchPlayed(Term);
            break;
    }
}

defaultproperties
{
    Begin Object Class=HxGUIMultiColumnListSearchBar Name=HxSearchBar
        WinLeft=0
        WinWidth=1
        StandardHeight=0.027
        bStandardized=true
        FirstColumn=2
        Types=(HX_PATTERN_String,HX_PATTERN_NumRange,HX_PATTERN_NumValue)
        Hints(0)="Search by map name."
        Hints(1)="Search by player count."
        Hints(2)="Search by played count."
        bBoundToParent=true
        bScaleToParent=true
        OnSearch=InternalOnSearch
    End Object
    SearchBar=HxSearchBar

    HeaderColumnPerc(3)=0.25
    HeaderColumnPerc(4)=0.25
}
