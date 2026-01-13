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
    HeaderColumnPerc(1)=0.475
    HeaderColumnPerc(2)=0.125
    DefaultListClass="HexedPatches.HxGUIVotingVoteList"
}
