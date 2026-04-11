class HxCTClient extends HxClientReplicationInfo;

var private const class<Combo> NullComboClass;
var private byte DisabledCombos[4];
var private string NullComboName;
var private bool bInitialized;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    NullComboName = string(NullComboClass);
}

simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (!bInitialized)
        {
            bInitialized = InitializeClient();
        }
    }
}

simulated function bool InitializeClient()
{
    if (PlayerController(Owner) != None)
    {
        UpdateDisabledCombos();
        return true;
    }
    return false;
}

simulated function ServerInfoReady()
{
    UpdateDisabledCombos();
}

simulated function ServerPropertyChanged(int Index, string OldValue)
{
    UpdateDisabledCombos();
}

simulated function UpdateDisabledCombos()
{
    DisabledCombos[0] = byte(bool(GetServerProperty("bNoSpeedCombo")));
    DisabledCombos[1] = byte(bool(GetServerProperty("bNoBerserkCombo")));
    DisabledCombos[2] = byte(bool(GetServerProperty("bNoBoosterCombo")));
    DisabledCombos[3] = byte(bool(GetServerProperty("bNoInvisibleCombo")));
    ModifyPlayerCombos(xPlayer(Owner));
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
                if (!IsDisabledCombo(Player.default.ComboNameList[i]))
                {
                    Player.ComboNameList[i] = Player.default.ComboNameList[i];
                    Player.ComboList[i] = class<Combo>(
                        DynamicLoadObject(Player.ComboNameList[i], class'Class', true));
                }
            }
            else if (IsDisabledCombo(Player.ComboNameList[i]))
            {
                Player.ComboNameList[i] = NullComboName;
                Player.ComboList[i] = NullComboClass;
            }
        }
    }
}

simulated function bool IsDisabledCombo(coerce string Name)
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

defaultproperties
{
    MutatorClass=class'MutHexedCONTROL'
    NullComboClass=class'HxComboNull'
}
