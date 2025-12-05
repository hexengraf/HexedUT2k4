class HxGUIPlayerSettings extends UT2K4Tab_PlayerSettings;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    nu_FOV.MaxValue = class'HxAspectRatio'.static.GetMaximumFOV();
    UpdateFOV(MyController.ResX, MyController.ResY);
    Super.InitComponent(MyController, MyOwner);
}

event ResolutionChanged(int NewX, int NewY)
{
    UpdateFOV(NewX, NewY);
    Super.ResolutionChanged(NewX, NewY);
}

function UpdateFOV(coerce float X, coerce float Y)
{
    nFov = class'HxAspectRatio'.static.GetScaledFOV(default.nFOV, X / Y);
}
