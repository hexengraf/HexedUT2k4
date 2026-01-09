class HxGUIMapVoteCountListBox extends HxGUIMapVoteBaseListBox;

function UpdatedVoteCount(int UpdatedIndex, bool bRemoved)
{
    HXGUIMapVoteCountList(List).UpdatedVoteCount(UpdatedIndex, bRemoved);
}

defaultproperties
{
    HeaderColumnPerc(0)=0.4
    HeaderColumnPerc(1)=0.45
    HeaderColumnPerc(2)=0.15
    DefaultListClass="HexedPatches.HXGUIMapVoteCountList"
}
