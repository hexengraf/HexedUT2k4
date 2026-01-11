class HxGUIVotingVoteListBox extends HxGUIVotingBaseListBox;

function UpdatedVoteCount(int UpdatedIndex, bool bRemoved)
{
    HxGUIVotingVoteList(MyVoteBaseList).UpdatedVoteCount(UpdatedIndex, bRemoved);
}

function int GetGameTypeIndex()
{
    return HxGUIVotingVoteList(MyVoteBaseList).GetGameTypeIndex();
}

defaultproperties
{
    HeaderColumnPerc(0)=0.4
    HeaderColumnPerc(1)=0.45
    HeaderColumnPerc(2)=0.15
    DefaultListClass="HexedPatches.HxGUIVotingVoteList"
}
