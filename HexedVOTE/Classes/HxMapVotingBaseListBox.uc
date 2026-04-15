class HxMapVotingBaseListBox extends HxGUITableBox
    abstract
    DependsOn(HxFavorites);

delegate OnTagUpdated(int MapIndex, HxFavorites.EHxTag NewTag);
delegate NotifySelection(GUIComponent Sender);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    HxMapVotingBaseList(List).OnTagUpdated = InternalOnTagUpdated;
    HxMapVotingBaseList(List).OnChange = OnChangeList;
    HxMapVotingBaseList(List).OnDblClick = OnDbkClickList;
}

function Initialize()
{
    HxMapVotingBaseList(List).Initialize();
}

function OnChangeList(GUIComponent Sender)
{
    NotifySelection(Self);
}

function bool OnDbkClickList(GUIComponent Sender)
{
    return OnEnterKeyEvent(Self);
}

function SetClient(HxVTClient Client)
{
    HxMapVotingBaseList(List).SetClient(Client);
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
}
