class HxPlayerModifiers extends Info;

var private PlayerController PC;
var private byte DisabledCombos[4];
var private class<Combo> NullComboClass;
var private string NullComboName;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    PC = PlayerController(Owner);
    NullComboName = string(NullComboClass);
}

simulated function bool ShouldDisableCombo(coerce string Name)
{
    if (Name ~= "XGame.ComboSpeed")
    {
        return DisabledCombos[0] == 1;
    }
    if (Name ~= "XGame.ComboBerserk")
    {
        return DisabledCombos[1] == 1;
    }
    if (Name ~= "XGame.ComboDefensive")
    {
        return DisabledCombos[2] == 1;
    }
    if (Name ~= "XGame.ComboInvis")
    {
        return DisabledCombos[3] == 1;
    }
    return false;
}

simulated function SetDisabledCombos(HxUTClient Client)
{
    DisabledCombos[0] = byte(bool(Client.GetServerProperty("bDisableSpeedCombo")));
    DisabledCombos[1] = byte(bool(Client.GetServerProperty("bDisableBerserkCombo")));
    DisabledCombos[2] = byte(bool(Client.GetServerProperty("bDisableBoosterCombo")));
    DisabledCombos[3] = byte(bool(Client.GetServerProperty("bDisableInvisibleCombo")));
    ModifyPlayerCombos(xPlayer(PC));
}

simulated function ModifyPlayerCombos(xPlayer Player)
{
    local int i;

    if (Player != None)
    {
        for (i = 0; i < ArrayCount(Player.ComboNameList); ++i)
        {
            if (Player.ComboNameList[i] == "")
            {
                break;
            }
            if (Player.ComboNameList[i] == NullComboName)
            {
                if (!ShouldDisableCombo(Player.default.ComboNameList[i]))
                {
                    Player.ComboNameList[i] = Player.default.ComboNameList[i];
                    Player.ComboList[i] = class<Combo>(
                        DynamicLoadObject(Player.ComboNameList[i], class'Class', true));
                }
            }
            else if (ShouldDisableCombo(Player.ComboNameList[i]))
            {
                Player.ComboNameList[i] = NullComboName;
                Player.ComboList[i] = NullComboClass;
            }
        }
    }
}

defaultproperties
{
    NullComboClass=class'HxComboNull'
}
