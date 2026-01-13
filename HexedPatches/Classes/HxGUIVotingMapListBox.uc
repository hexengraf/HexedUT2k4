class HxGUIVotingMapListBox extends HxGUIVotingBaseListBox;

function SetFilter(HxMapVoteFilter Filter)
{
    HxGUIVotingMapList(MyVoteBaseList).SetFilter(Filter);
}

function bool FilterUpdated(optional string SelectMapName)
{
    return HxGUIVotingMapList(MyVoteBaseList).FilterUpdated(SelectMapName);
}

defaultproperties
{
    HeaderColumnPerc(0)=0.575
    HeaderColumnPerc(1)=0.175
    HeaderColumnPerc(2)=0.15
    HeaderColumnPerc(3)=0.10
    DefaultListClass="HexedPatches.HxGUIVotingMapList"
}
