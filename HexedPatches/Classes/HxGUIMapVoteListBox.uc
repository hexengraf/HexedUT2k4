class HxGUIMapVoteListBox extends HxGUIMapVoteBaseListBox;

function SetFilter(HxMapVoteFilter Filter)
{
    HxGUIMapVoteList(MyVoteBaseList).SetFilter(Filter);
}

function FilterUpdated()
{
    HxGUIMapVoteList(MyVoteBaseList).FilterUpdated();
}

defaultproperties
{
    HeaderColumnPerc(0)=0.50
    HeaderColumnPerc(1)=0.175
    HeaderColumnPerc(2)=0.175
    HeaderColumnPerc(3)=0.10
    DefaultListClass="HexedPatches.HxGUIMapVoteList"
}
