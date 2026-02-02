class HxGUIVotingVoteListBox extends HxGUIVotingBaseListBox
    DependsOn(HxFavorites);

function UpdatedVoteCount(int UpdatedIndex, bool bRemoved)
{
    HxGUIVotingVoteList(MyVotingBaseList).UpdatedVoteCount(UpdatedIndex, bRemoved);
}

function UpdateMapMark(int MapIndex, HxFavorites.EHxMark NewMark)
{
    HxGUIVotingVoteList(MyVotingBaseList).UpdateMapMark(MapIndex, NewMark);
}

function int GetGameTypeIndex()
{
    return HxGUIVotingVoteList(MyVotingBaseList).GetGameTypeIndex();
}

defaultproperties
{
    HeaderColumnPerc(0)=0.1
    HeaderColumnPerc(1)=0.45
    HeaderColumnPerc(2)=0.35
    HeaderColumnPerc(3)=0.1
    DefaultListClass="HexedPatches.HxGUIVotingVoteList"
}
