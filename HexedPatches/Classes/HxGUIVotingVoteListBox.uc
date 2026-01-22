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
    HeaderColumnPerc(1)=0.48
    HeaderColumnPerc(2)=0.12
    DefaultListClass="HexedPatches.HxGUIVotingVoteList"
}
