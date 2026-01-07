class HxGUIMapVoteListBox extends HxGUIMapVoteBaseListBox;

function SetSelectedGameType(int Type)
{
    HxGUIMapVoteList(List).SetSelectedGameType(Type);
}

function int GetSelectedMapIndex()
{
    return HxGUIMapVoteList(List).GetSelectedMapIndex();
}

function string GetSelectedMapName()
{
    return HxGUIMapVoteList(List).GetSelectedMapName();
}

defaultproperties
{
    HeaderColumnPerc(0)=0.50
    HeaderColumnPerc(1)=0.175
    HeaderColumnPerc(2)=0.175
    HeaderColumnPerc(3)=0.10
    DefaultListClass="HexedPatches.HxGUIMapVoteList"
}
