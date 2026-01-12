class HxGUIScrollText extends GUIScrollText;

var float LineSpacing;

function float GetSpacedItemHeight(Canvas C)
{
    local float XL;
    local float YL;

    Style.TextSize(C, MenuState, "A", XL, YL, FontScale);
    return Round(YL + LineSpacing * C.ClipY);
}

defaultproperties
{
    LineSpacing=0.002
    StyleName="HxSmallText"
    SelectedStyleName="HxSmallText"
    GetItemHeight=GetSpacedItemHeight
}
