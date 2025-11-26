class HxMenuEnumComboBox extends HxMenuComboBox;

var object EnumType;
var int EnumCount;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    if (EnumCount > DisplayNames.Length)
    {
        for (i = 0; i < EnumCount; ++i)
        {
            if (i <= DisplayNames.Length)
            {
                DisplayNames[DisplayNames.Length] = string(GetEnum(EnumType, i));
            }
        }
    }
    else
    {
        EnumCount = DisplayNames.Length;
    }
    Super.InitComponent(MyController, MyOwner);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
    local int i;

    i = SearchIndex(NewValue);
    if (i != -1)
    {
        if (bNoChange)
        {
            bIgnoreChange = True;
        }
        ComboBox.SetIndex(i);
        bIgnoreChange = False;
    }
}

function string GetComponentValue()
{
    return string(GetEnum(EnumType, ComboBox.GetIndex()));
}

function int SearchIndex(string EnumValue)
{
    local int i;

    for (i = 0; i < EnumCount; ++i)
    {
        if (string(GetEnum(EnumType, i)) == EnumValue)
        {
            return i;
        }
    }
    return -1;
}

defaultproperties
{
}
