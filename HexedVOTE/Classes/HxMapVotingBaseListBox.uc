class HxMapVotingBaseListBox extends HxGUIMultiColumnListBox
    abstract
    DependsOn(HxFavorites);

delegate OnTagUpdated(int MapIndex, HxFavorites.EHxTag NewTag);
delegate NotifySelection(GUIComponent Sender);
delegate bool NotifyVote(GUIComponent Sender);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    HxMapVotingBaseList(List).OnTagUpdated = InternalOnTagUpdated;
    HxMapVotingBaseList(List).OnChange = OnChangeList;
    HxMapVotingBaseList(List).OnDblClick = OnDbkClickList;
}

function OnChangeList(GUIComponent Sender)
{
    NotifySelection(Self);
}

function bool OnDbkClickList(GUIComponent Sender)
{
    NotifyVote(Self);
    return true;
}

function SetVRI(VotingReplicationInfo V)
{
    HxMapVotingBaseList(List).SetVRI(V);
}

function int GetMapIndex()
{
    return HxMapVotingBaseList(List).GetMapIndex();
}

function string GetMapName()
{
    return HxMapVotingBaseList(List).GetMapName();
}

function UpdateMapTag(int MapIndex, HxFavorites.EHxTag NewTag)
{
    HxMapVotingBaseList(List).UpdateMapTag(MapIndex, NewTag);
}

function bool InternalOnKeyEvent(out byte Key, out byte KeyState, float Delta)
{
    if (EInputKey(Key) == IK_Enter && HxMapVotingPage(PageOwner) != None)
    {
        NotifyVote(Self);
        return true;
    }
    return false;
}

function InternalOnTagUpdated(int MapIndex, HxFavorites.EHxTag NewTag)
{
    OnTagUpdated(MapIndex, NewTag);
}

defaultproperties
{
    HeaderColumnPerc(0)=0.045
    HeaderColumnPerc(1)=0.045
    HeaderColumnPerc(2)=0.41
    HeaderIcons(0)=Material'HxClockIcon'
    HeaderIcons(1)=Material'HxStarIcon'
    OnKeyEvent=InternalOnKeyEvent
}
