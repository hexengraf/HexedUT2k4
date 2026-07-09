class HxSBBombingRun extends HxSBCaptureTheFlag;

simulated function HxSBColumnConfig GetCapturesColumnConfig()
{
    local HxSBColumnConfig Config;

    Config = Super.GetCapturesColumnConfig();
    Config.Heading = GoalsLabel;
    return Config;
}

defaultproperties
{
}
