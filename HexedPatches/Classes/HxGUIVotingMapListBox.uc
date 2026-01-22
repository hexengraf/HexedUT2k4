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
    HeaderColumnPerc(0)=0.565
    HeaderColumnPerc(1)=0.16
    HeaderColumnPerc(2)=0.15
    HeaderColumnPerc(3)=0.125
    DefaultListClass="HexedPatches.HxGUIVotingMapList"
}
