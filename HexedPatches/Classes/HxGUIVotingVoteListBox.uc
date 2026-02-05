class HxGUIVotingVoteListBox extends HxGUIVotingBaseListBox
    DependsOn(HxFavorites);

function UpdatedVoteCount(int UpdatedIndex, bool bRemoved)
{
    HxGUIVotingVoteList(MyBaseList).UpdatedVoteCount(UpdatedIndex, bRemoved);
}

function int GetGameTypeIndex()
{
    return HxGUIVotingVoteList(MyBaseList).GetGameTypeIndex();
}

defaultproperties
{
    HeaderColumnPerc(3)=0.49
    HeaderColumnPerc(4)=0.1
    DefaultListClass="HexedPatches.HxGUIVotingVoteList"
}
