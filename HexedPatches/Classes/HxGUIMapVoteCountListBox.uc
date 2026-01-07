class HxGUIMapVoteCountListBox extends HxGUIMapVoteBaseListBox;

function int GetSelectedGameTypeIndex()
{
    return HXGUIMapVoteCountList(List).GetSelectedGameTypeIndex();
}

function int GetSelectedMapIndex()
{
    return HXGUIMapVoteCountList(List).GetSelectedMapIndex();
}

function string GetSelectedMapName()
{
    return HXGUIMapVoteCountList(List).GetSelectedMapName();
}

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
