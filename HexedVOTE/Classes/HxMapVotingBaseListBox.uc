class HxMapVotingBaseListBox extends HxGUIMultiColumnListBox
    abstract
    DependsOn(HxFavorites);

var private Material ColumnIcons[2];

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

function OnRenderedHeader(Canvas C)
{
    local float Offset;
    local float Left;
    local float Top;
    local float Height;

    Super.OnRenderedHeader(C);
    Offset = class'HxGUIStyles'.static.GetActualFrameThickness(b_ListBackground);
    Height = Header.ActualHeight();
    Top = Header.ActualTop() + Height * 0.13;
    Height = Height * 0.75;
    Left = Header.ActualLeft() + (List.ColumnWidths[0] - Height) / 2  + (Offset / 2);
    DrawHeaderColumnIcon(C, 0, Left, Top, Height);
    DrawHeaderColumnIcon(C, 1, Left + List.ColumnWidths[1], Top, Height);
}

function DrawHeaderColumnIcon(Canvas C, int Column, float Left, float Top, float Height)
{
    if (List.SortColumn == Column)
    {
        C.DrawColor = Header.Style.FontColors[2];
    }
    else
    {
        C.DrawColor = Header.Style.FontColors[0];
    }
    C.SetPos(Left, Top);
    C.DrawTile(ColumnIcons[Column], Height, Height, 0, 0, 64, 64);
}

defaultproperties
{
    HeaderColumnPerc(0)=0.045
    HeaderColumnPerc(1)=0.045
    HeaderColumnPerc(2)=0.41
    ColumnIcons(0)=Material'HxClockIcon'
    ColumnIcons(1)=Material'HxStarIcon'
    OnKeyEvent=InternalOnKeyEvent
}
