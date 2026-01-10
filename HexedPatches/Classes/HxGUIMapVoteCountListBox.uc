class HxGUIMapVoteCountListBox extends HxGUIMapVoteBaseListBox;

function UpdatedVoteCount(int UpdatedIndex, bool bRemoved)
{
    HXGUIMapVoteCountList(MyVoteBaseList).UpdatedVoteCount(UpdatedIndex, bRemoved);
}

function int GetSelectedGameTypeIndex()
{
    return HXGUIMapVoteCountList(MyVoteBaseList).GetSelectedGameTypeIndex();
}

defaultproperties
{
    HeaderColumnPerc(0)=0.4
    HeaderColumnPerc(1)=0.45
    HeaderColumnPerc(2)=0.15
    DefaultListClass="HexedPatches.HXGUIMapVoteCountList"
}
