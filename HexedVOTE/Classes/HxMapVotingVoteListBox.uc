class HxMapVotingVoteListBox extends HxMapVotingBaseListBox
    DependsOn(HxFavorites);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    DefaultListClass = string(class'HxMapVotingVoteList');
    Super.InitComponent(MyController, MyOwner);
}

function UpdateVoteCount(int UpdatedIndex, bool bRemoved)
{
    HxMapVotingVoteList(List).UpdateVoteCount(UpdatedIndex, bRemoved);
}

function int GetGameTypeIndex()
{
    return HxMapVotingVoteList(List).GetGameTypeIndex();
}

defaultproperties
{
    HeaderColumnPerc(3)=0.49
    HeaderColumnPerc(4)=0.1
}
