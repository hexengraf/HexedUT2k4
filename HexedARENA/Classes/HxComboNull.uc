class HxComboNull extends Combo;

simulated function Tick(float DeltaTime)
{
    Destroy();
}

defaultproperties
{
    ActivateSound=None
    ActivationEffectClass=None
}
