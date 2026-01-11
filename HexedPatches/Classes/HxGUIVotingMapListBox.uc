class HxGUIVotingMapListBox extends HxGUIVotingBaseListBox;

function SetFilter(HxMapVoteFilter Filter)
{
    HxGUIVotingMapList(MyVoteBaseList).SetFilter(Filter);
}

function FilterUpdated()
{
    HxGUIVotingMapList(MyVoteBaseList).FilterUpdated();
}

defaultproperties
{
    HeaderColumnPerc(0)=0.55
    HeaderColumnPerc(1)=0.175
    HeaderColumnPerc(2)=0.15
    HeaderColumnPerc(3)=0.075
    DefaultListClass="HexedPatches.HxGUIVotingMapList"
}
