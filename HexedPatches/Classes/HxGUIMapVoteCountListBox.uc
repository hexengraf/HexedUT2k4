class HxGUIMapVoteCountListBox extends HxGUIMapVoteBaseListBox;

function UpdatedVoteCount(int UpdatedIndex, bool bRemoved)
{
    HXGUIMapVoteCountList(MyVoteBaseList).UpdatedVoteCount(UpdatedIndex, bRemoved);
}

function int GetGameTypeIndex()
{
    return HXGUIMapVoteCountList(MyVoteBaseList).GetGameTypeIndex();
}

defaultproperties
{
    HeaderColumnPerc(0)=0.4
    HeaderColumnPerc(1)=0.45
    HeaderColumnPerc(2)=0.15
    DefaultListClass="HexedPatches.HXGUIMapVoteCountList"
}
