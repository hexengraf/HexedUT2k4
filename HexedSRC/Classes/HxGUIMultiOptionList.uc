class HxGUIMultiOptionList extends GUIMultiOptionList;

var Color SectionColor;
var Color SubSectionColor;

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    if (EInputAction(State) == IST_Hold)
    {
        if (EInputKey(Key) == IK_Up && Up())
        {
            return true;
        }
        if (EInputKey(Key) == IK_Down && Down())
        {
            return true;
        }
    }
    return Super.InternalOnKeyEvent(Key, State, Delta);
}

function bool InternalOnDraw(Canvas C)
{
    local float Left;
    local float Width;
    local int Count;
    local int i;

    Count = Min(Elements.Length, Top + ItemsPerPage);
    Left = ActualLeft();
    Width = ActualWidth();
    for (i = Top; i < Count; ++i)
    {
        if (Elements[i].Tag == -7)
        {
            DrawSectionBackground(C, i, SectionColor, Left, Width);
            Elements[i].Style.DrawText(
                C,
                Elements[i].MenuState,
                Left,
                Elements[i].ActualTop(),
                MenuOwner.ActualWidth(),
                Elements[i].ActualHeight(),
                TXTA_Center,
                HxGUIMultiOptionListHeader(Elements[i]).SectionCaption,
                Elements[i].FontScale);
        }
        else if (Elements[i].Tag == -6)
        {
            DrawSectionBackground(C, i, SubSectionColor, Left, Width);
        }
    }
    return false;
}

function DrawSectionBackground(Canvas C, int Index, Color DrawColor, float Left, float Width)
{
    C.DrawColor = DrawColor;
    C.SetPos(Left, Elements[Index].ActualTop());
    C.DrawTileStretched(
        Material'engine.WhiteSquareTexture', Width, Elements[Index].ActualHeight());
}

defaultproperties
{
    bDrawSelectionBorder=false
    ItemScaling=0.0435
    ItemPadding=0.2
    SectionColor=(R=28,G=47,B=96,A=255)
    SubSectionColor=(R=28,G=47,B=96,A=152)
    OnDraw=InternalOnDraw
}
