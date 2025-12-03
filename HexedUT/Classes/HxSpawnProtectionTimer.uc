class HxSpawnProtectionTimer extends HudOverlay
    config(User)
    notplaceable;

var config bool bShowTimer;
var config bool bUseHUDColor;
var config bool bPulsingDigits;
var config float PosX;
var config float PosY;
var config Color DefaultColor;

var HudBase.DigitSet Digits;
var HudBase.NumericWidget Counter;
var HudBase.SpriteWidget Icon;
var float Duration;
var float Timestamp;

simulated event PreBeginPlay()
{
    super.PreBeginPlay();
    UpdatePosition();
}

auto state Unprotected
{
    simulated Event Tick(float DeltaTime)
    {
        if (PlayerIsDead())
        {
            GoToState('Dead');
        }
    }
}

state Protected
{
    simulated Event Tick(float DeltaTime)
    {
        local xPawn Pawn;

        Counter.Value = Ceil(Duration - (Level.TimeSeconds - Timestamp));
        Pawn = xPawn(HudBase(Owner).PawnOwner);
        if (Counter.Value <= 0 || Pawn == None || Pawn.OverlayMaterial != Pawn.ShieldHitMat)
        {
            Counter.Value = 0;
            GoToState('Unprotected');
        }
    }

    simulated function Render(Canvas C)
    {
        local HudBase HUD;
        local float OldResScaleX;

        HUD = HudBase(Owner);
        OldResScaleX = HUD.ResScaleX;
        HUD.ResScaleX = HUD.ResScaleY;
        HUD.DrawSpriteWidget(C, Icon);
        HUD.DrawNumericWidget(C, Counter, Digits);
        HUD.ResScaleX = OldResScaleX;
    }
}

state Dead
{
    simulated Event Tick(float DeltaTime)
    {
        if (!PlayerIsDead())
        {
            if (bShowTimer)
            {
                Timestamp = Level.TimeSeconds;
                Duration = Ceil(HudBase(Owner).PawnOwner.ClientOverlayCounter);
                UpdatePosition();
                UpdateColor(HudBase(Owner));
                UpdateDigits();
                GoToState('Protected');
            }
            else
            {
                GoToState('Unprotected');
            }
        }
    }
}

simulated function SetShowTimer(bool bValue)
{
    bShowTimer = bValue;
    if (bShowTimer)
    {
        Enable('Tick');
    }
    else
    {
        Disable('Tick');
    }
}

simulated function UpdateColor(HudBase HUD)
{
    if (!bUseHUDColor)
    {
        Icon.Tints[0] = DefaultColor;
        Icon.Tints[1] = DefaultColor;
    }
    else if (HUD.bUsingCustomHUDColor)
    {
        Icon.Tints[0] = HUD.CustomHUDColor;
        Icon.Tints[1] = HUD.CustomHUDColor;
    }
    else
    {
        Icon.Tints[0] = HUD.GetTeamColor(0);
        Icon.Tints[1] = HUD.GetTeamColor(1);
    }
}

simulated function UpdateDigits()
{
    if (bPulsingDigits)
    {
        Digits = class'HudCDeathMatch'.default.DigitsBigPulse;
    }
    else
    {
        Digits = class'HudCDeathMatch'.default.DigitsBig;
    }
}

simulated function UpdatePosition()
{
    Counter.PosX = PosX;
    Counter.PosY = PosY;
    Icon.PosX = PosX;
    Icon.PosY = PosY;
}

simulated function bool PlayerIsDead()
{
    return HudBase(Owner).PawnOwner == None || HudBase(Owner).PawnOwner.Health == 0;
}

defaultproperties
{
    bShowTimer=true
    bUseHUDColor=true
    bPulsingDigits=false
    PosX=0.95
    PosY=0.63
    DefaultColor=(R=239,G=191,B=4,A=255)
    Counter=(RenderStyle=STY_Alpha,TextureScale=0.49,DrawPivot=DP_UpperMiddle,OffsetX=0,OffsetY=0,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    Icon=(WidgetTexture=Texture'HxSpawnProtectionTimer',OffsetX=0,OffsetY=0,DrawPivot=DP_MiddleMiddle,RenderStyle=STY_Alpha,TextureCoords=(X1=0,Y1=0,X2=256,Y2=256),TextureScale=0.22,ScaleMode=SM_None,Scale=1,Tints[0]=(G=255,R=255,B=255,A=255),Tints[1]=(G=255,R=255,B=255,A=255))
}
