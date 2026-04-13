class HxCTClient extends HxClientReplicationInfo;

var private const class<Combo> NullComboClass;
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
        ModifyPlayerCombos(xPlayer(Owner));
        return true;
    }
    return false;
}

simulated function ServerInfoReady()
{
    local xPickUpBase PickupBase;

    ModifyPlayerCombos(xPlayer(Owner));
    foreach AllActors(class'xPickUpBase', PickupBase)
    {
        if (ClassIsChildOf(PickupBase.Class, class'WildcardBase'))
        {
            ModifyWildcardBase(WildcardBase(PickupBase));
        }
        else if (IsDisabledPickup(PickupBase.PowerUp))
        {
            class'MutHexedCONTROL'.static.ModifyPickupBase(PickupBase, true);
        }
    }
}

simulated function ServerPropertyChanged(int Index, string OldValue)
{
    switch (GetServerPropertyName(Index))
    {
        case "bNoSpeedCombo":
        case "bNoBerserkCombo":
        case "bNoBoosterCombo":
        case "bNoInvisibleCombo":
            ModifyPlayerCombos(xPlayer(Owner));
            break;
        case "bNoHealthPacks":
            ModifyPickupBases(class'HealthPack');
            break;
        case "bNoSuperHealthPacks":
            ModifyPickupBases(class'SuperHealthPack');
            break;
        case "bNoShieldPacks":
            ModifyPickupBases(class'ShieldPack');
            break;
        case "bNoSuperShieldPacks":
            ModifyPickupBases(class'SuperShieldPack');
            break;
        case "bNoUDamagePacks":
            ModifyPickupBases(class'UDamagePack');
            break;
    }
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

simulated function ModifyPickupBases(class<Pickup> PickupClass)
{
    local xPickUpBase PickupBase;
    local bool bDisabled;

    bDisabled = IsDisabledPickup(PickupClass);
    foreach AllActors(class'xPickUpBase', PickupBase)
    {
        if (PickupBase.IsA('WildcardBase'))
        {
            ModifyWildcardBase(WildcardBase(PickupBase));
        }
        else if (ClassIsChildOf(PickupBase.PowerUp, PickupClass))
        {
            class'MutHexedCONTROL'.static.ModifyPickupBase(PickupBase, bDisabled);
        }
    }
}

simulated function ModifyWildcardBase(WildcardBase PickupBase)
{
    local int i;
    local int j;

    for (i = 0; i < ArrayCount(PickupBase.default.PickupClasses); ++i)
    {
        if (PickupBase.default.PickupClasses[i] == None)
        {
            break;
        }
        if (IsDisabledPickup(PickupBase.default.PickupClasses[i]))
        {
            continue;
        }
        PickupBase.PickupClasses[j] = PickupBase.default.PickupClasses[i];
        ++j;
    }
    if (PickupBase.NumClasses != j)
    {
        if (PickupBase.NumClasses == 0)
        {
            class'MutHexedCONTROL'.static.ModifyPickupBase(PickupBase, false);
        }
        else if (j == 0)
        {
            class'MutHexedCONTROL'.static.ModifyPickupBase(PickupBase, true);
        }
        PickupBase.NumClasses = j;
    }
}

simulated function bool IsDisabledCombo(coerce string Name)
{
    if (Name ~= "XGame.ComboSpeed")
    {
        return bool(GetServerProperty("bNoSpeedCombo"));
    }
    if (Name ~= "XGame.ComboBerserk")
    {
        return bool(GetServerProperty("bNoBerserkCombo"));
    }
    if (Name ~= "XGame.ComboDefensive")
    {
        return bool(GetServerProperty("bNoBoosterCombo"));
    }
    if (Name ~= "XGame.ComboInvis")
    {
        return bool(GetServerProperty("bNoInvisibleCombo"));
    }
    return false;
}

simulated function bool IsDisabledPickup(class PickupClass)
{
    if (ClassIsChildOf(PickupClass, class'AdrenalinePickup'))
    {
        return bool(GetServerProperty("bNoAdrenalinePills"));
    }
    if (ClassIsChildOf(PickupClass, class'MiniHealthPack'))
    {
        return bool(GetServerProperty("bNoHealthVials"));
    }
    if (ClassIsChildOf(PickupClass, class'HealthPack'))
    {
        return bool(GetServerProperty("bNoHealthPacks"));
    }
    if (ClassIsChildOf(PickupClass, class'SuperHealthPack'))
    {
        return bool(GetServerProperty("bNoSuperHealthPacks"));
    }
    if (ClassIsChildOf(PickupClass, class'ShieldPack'))
    {
        return bool(GetServerProperty("bNoShieldPacks"));
    }
    if (ClassIsChildOf(PickupClass, class'SuperShieldPack'))
    {
        return bool(GetServerProperty("bNoSuperShieldPacks"));
    }
    if (ClassIsChildOf(PickupClass, class'UDamagePack'))
    {
        return bool(GetServerProperty("bNoUDamagePacks"));
    }
    if (ClassIsChildOf(PickupClass, class'Ammo'))
    {
        return bool(GetServerProperty("bNoAmmoPacks"));
    }
    return false;
}

defaultproperties
{
    MutatorClass=class'MutHexedCONTROL'
    NullComboClass=class'HxComboNull'
}
