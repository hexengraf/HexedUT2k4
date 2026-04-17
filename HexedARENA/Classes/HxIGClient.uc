class HxIGClient extends HxClientReplicationInfo;

var private bool bPickupBasesDisabled;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    if (Level.NetMode != NM_DedicatedServer)
    {
        ApplyScopeConfiguration();
    }
}

simulated function ApplyScopeConfiguration()
{
    local PlayerController PC;
    local Inventory Inv;

    class'HxIGScope'.static.ApplyConfiguration(class'HxZoomSuperShockRifle');
    PC = Level.GetLocalPlayerController();
    if (PC != None && PC.Pawn != None)
    {
        for (Inv = PC.Pawn.Inventory; Inv != None; Inv = Inv.inventory)
        {
            if (HxZoomSuperShockRifle(Inv) != None)
            {
                HxZoomSuperShockRifle(Inv).RefreshConfiguration();
            }
        }
    }
}

simulated function Tick(float DeltaTime)
{
    if (Level.NetMode == NM_Client && !bPickupBasesDisabled)
    {
        class'MutHexedINSTAGIB'.static.HidePickupBases(Self);
        bPickupBasesDisabled = true;
    }
    Super.Tick(DeltaTime);
}

simulated function string GetProperty(int Index)
{
    switch (Index)
    {
        case 0:
            return string(
                GetEnum(enum'EHxScopeOverlay', class'HxIGScope'.default.ScopeOverlay));
        case 1:
            return string(class'HxIGScope'.default.bSoundEffects);
        case 2:
            return string(class'HxIGScope'.default.bShowChargeBar);
        case 3:
            return string(class'HxIGScope'.default.ReticleColor.R);
        case 4:
            return string(class'HxIGScope'.default.ReticleColor.G);
        case 5:
            return string(class'HxIGScope'.default.ReticleColor.B);
        case 6:
            return string(class'HxIGScope'.default.ReticleColor.A / 255.0);
        case 7:
            return string(class'HxIGScope'.default.ReticleScale);
        case 8:
            return string(class'HxIGScope'.default.BackgroundOpacity);
        case 9:
            return string(class'HxIGScope'.default.bCustomZoomCrosshair);
        case 10:
            return string(class'HxIGScope'.default.CustomZoomCrosshair);
        case 11:
            return string(class'HxIGScope'.default.CustomZoomCrosshairColor.R);
        case 12:
            return string(class'HxIGScope'.default.CustomZoomCrosshairColor.G);
        case 13:
            return string(class'HxIGScope'.default.CustomZoomCrosshairColor.B);
        case 14:
            return string(class'HxIGScope'.default.CustomZoomCrosshairColor.A / 255.0);
        case 15:
            return string(class'HxIGScope'.default.CustomZoomCrosshairScale);
    }
    return "";
}

simulated function SetProperty(int Index, string Value)
{
    switch (Index)
    {
        case 0:
            class'HxIGScope'.static.SetScopeOverlay(Value);
            break;
        case 1:
            class'HxIGScope'.default.bSoundEffects = bool(Value);
            break;
        case 2:
            class'HxIGScope'.default.bShowChargeBar = bool(Value);
            break;
        case 3:
            class'HxIGScope'.default.ReticleColor.R = byte(Value);
            break;
        case 4:
            class'HxIGScope'.default.ReticleColor.G = byte(Value);
            break;
        case 5:
            class'HxIGScope'.default.ReticleColor.B = byte(Value);
            break;
        case 6:
            class'HxIGScope'.default.ReticleColor.A = float(Value) * 255;
            break;
        case 7:
            class'HxIGScope'.default.ReticleScale = float(Value);
            break;
        case 8:
            class'HxIGScope'.default.BackgroundOpacity = float(Value);
            break;
        case 9:
            class'HxIGScope'.default.bCustomZoomCrosshair = bool(Value);
            break;
        case 10:
            class'HxIGScope'.static.SetCustomCrosshair(Value);
            break;
        case 11:
            class'HxIGScope'.default.CustomZoomCrosshairColor.R = byte(Value);
            break;
        case 12:
            class'HxIGScope'.default.CustomZoomCrosshairColor.G = byte(Value);
            break;
        case 13:
            class'HxIGScope'.default.CustomZoomCrosshairColor.B = byte(Value);
            break;
        case 14:
            class'HxIGScope'.default.CustomZoomCrosshairColor.A = float(Value) * 255;
            break;
        case 15:
            class'HxIGScope'.default.CustomZoomCrosshairScale = float(Value);
            break;
    }
    class'HxIGScope'.static.StaticSaveConfig();
    ApplyScopeConfiguration();
}

defaultproperties
{
    MutatorClass=class'MutHexedINSTAGIB'
    Properties(0)=(Name="ScopeOverlay",Caption="Scope overlay",Hint="Choose which scope overlay to use.",Type=PIT_Select,Data="HX_SCOPE_Default;Default;HX_SCOPE_Custom;Custom;HX_SCOPE_Hidden;Hidden",Dependency="bZoomInstagib")
    Properties(1)=(Name="bSoundEffects",Section="Custom Scope Overlay",Caption="Zoom sound effects",Hint="Enable sound effects when zooming in/out.",Type=PIT_Check,Dependency="bZoomInstagib")
    Properties(2)=(Name="bShowChargeBar",Section="Custom Scope Overlay",Caption="Show charge bar",Hint="Show charge bar to indicate when it is ready to shoot.",Type=PIT_Check,Dependency="bZoomInstagib")
    Properties(3)=(Name="ReticleRed",Section="Custom Scope Overlay",Caption="Red",Hint="Change the color of the reticle.",Type=PIT_Text,Data="3;0:255",Step=5,Dependency="bZoomInstagib")
    Properties(4)=(Name="ReticleGreen",Section="Custom Scope Overlay",Caption="Green",Hint="Change the color of the reticle.",Type=PIT_Text,Data="3;0:255",Step=5,Dependency="bZoomInstagib")
    Properties(5)=(Name="ReticleBlue",Section="Custom Scope Overlay",Caption="Blue",Hint="Change the color of the reticle.",Type=PIT_Text,Data="3;0:255",Step=5,Dependency="bZoomInstagib")
    Properties(6)=(Name="ReticleAlpha",Section="Custom Scope Overlay",Caption="Opacity",Hint="Change the opacity of the reticle.",Type=PIT_Text,Data="8;0.0:1.0",Step=0.05,Dependency="bZoomInstagib")
    Properties(7)=(Name="ReticleScale",Section="Custom Scope Overlay",Caption="Scale",Hint="Change the scale of the reticle.",Type=PIT_Text,Data="8;0.0:1.0",Step=0.05,Dependency="bZoomInstagib")
    Properties(8)=(Name="BackgroundOpacity",Section="Custom Scope Overlay",Caption="Background opacity",Hint="Change the opacity of the black background around the scope.",Type=PIT_Text,Data="8;0.0:1.0",Step=0.05,Dependency="bZoomInstagib")
    Properties(9)=(Name="bCustomZoomCrosshair",Section="Custom Crosshair",Caption="Use custom crosshair",Hint="Use custom crosshair while zooming. Requires custom weapon crosshairs enabled to work.",Type=PIT_Check,Dependency="bZoomInstagib")
    Properties(10)=(Name="CustomZoomCrosshair",Section="Custom Crosshair",Caption="Custom Crosshair",Hint="Choose which crosshair to use.",Type=PIT_Select,Data="CROSSHAIRS",Dependency="bZoomInstagib")
    Properties(11)=(Name="CrosshairRed",Section="Custom Crosshair",Caption="Red",Hint="Change the color of the crosshair.",Type=PIT_Text,Data="3;0:255",Step=5,Dependency="bZoomInstagib")
    Properties(12)=(Name="CrosshairGreen",Section="Custom Crosshair",Caption="Green",Hint="Change the color of the crosshair.",Type=PIT_Text,Data="3;0:255",Step=5,Dependency="bZoomInstagib")
    Properties(13)=(Name="CrosshairBlue",Section="Custom Crosshair",Caption="Blue",Hint="Change the color of the crosshair.",Type=PIT_Text,Data="3;0:255",Step=5,Dependency="bZoomInstagib")
    Properties(14)=(Name="CrosshairAlpha",Section="Custom Crosshair",Caption="Opacity",Hint="Change the opacity of the crosshair.",Type=PIT_Text,Data="8;0.0:1.0",Step=0.05,Dependency="bZoomInstagib")
    Properties(15)=(Name="CustomZoomCrosshairScale",Section="Custom Crosshair",Caption="Scale",Hint="Change the scale of the crosshair.",Type=PIT_Text,Data="8;0.0:5.0",Step=0.05,Dependency="bZoomInstagib")
}
