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
    HeaderColumnPerc(1)=0.5
    HeaderColumnPerc(2)=0.35
    HeaderColumnPerc(3)=0.1
    DefaultListClass="HexedPatches.HxGUIVotingVoteList"
}
