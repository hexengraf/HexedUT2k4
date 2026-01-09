class HxGUIMapVoteListBox extends HxGUIMapVoteBaseListBox;

function SetSelectedGameType(int Type)
{
    HxGUIMapVoteList(MyVoteBaseList).SetSelectedGameType(Type);
}

function SetSelectedMapSource(int Source)
{
    HxGUIMapVoteList(MyVoteBaseList).SetSelectedMapSource(Source);
}

defaultproperties
{
    HeaderColumnPerc(0)=0.50
    HeaderColumnPerc(1)=0.175
    HeaderColumnPerc(2)=0.175
    HeaderColumnPerc(3)=0.10
    DefaultListClass="HexedPatches.HxGUIMapVoteList"
}
