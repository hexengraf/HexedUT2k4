class HxPlayerSettings extends UT2K4Tab_PlayerSettings;

var float AspectRatio;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    nu_FOV.MaxValue = 170;
    Super.InitComponent(MyController, MyOwner);
}

function bool InternalDraw(Canvas C)
{
    local float NewAspectRatio;

    NewAspectRatio = C.ClipX / C.ClipY;
    if (nFov == default.nFov || AspectRatio != NewAspectRatio)
    {
        AspectRatio = NewAspectRatio;
        nFov = class'HxAspectRatio'.static.GetScaledFOV(default.nFOV, AspectRatio);
    }
    return Super.InternalDraw(C);
}
