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
    HeaderColumnPerc(0)=0.62
    HeaderColumnPerc(1)=0.14
    HeaderColumnPerc(2)=0.13
    HeaderColumnPerc(3)=0.11
    DefaultListClass="HexedPatches.HxGUIVotingMapList"
}
