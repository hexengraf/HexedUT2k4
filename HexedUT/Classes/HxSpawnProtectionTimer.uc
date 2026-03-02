class HxSpawnProtectionTimer extends HudOverlay
    config(User)
    notplaceable;

#exec texture Import File=Textures\HxSpawnProtectionTimer.tga Name=HxSPTimerIcon Mips=Off Alpha=1

var config bool bShowTimer;
var config bool bFollowHUDColor;
var config bool bPulsingDigits;
var config float PosX;
var config float PosY;
var config Color DefaultColor;

var private HudBase.DigitSet Digits;
var private HudBase.NumericWidget Counter;
var private HudBase.SpriteWidget Icon;
var private float Duration;
var private float Timestamp;

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
        if (Counter.Value <= 0 || Pawn == None
            || Pawn.OverlayTimer == 0 || Pawn.OverlayTimer > Duration)
        {
            Counter.Value = 0;
            GoToState('Unprotected');
        }
    }

    simulated function Render(Canvas C)
    {
        local HudBase HUD;

        if (default.bShowTimer)
        {
            HUD = HudBase(Owner);
            HUD.DrawSpriteWidget(C, Icon);
            HUD.DrawNumericWidget(C, Counter, Digits);
        }
    }
}

state Dead
{
    simulated Event Tick(float DeltaTime)
    {
        if (!PlayerIsDead())
        {
            if (HudBase(Owner).PlayerOwner.IsSpectating())
            {
                GoToState('Unprotected');
            }
            else
            {
                Timestamp = Level.TimeSeconds;
                Duration = Ceil(HudBase(Owner).PawnOwner.OverlayTimer);
                Update();
                GoToState('Protected');
            }
        }
    }
}

simulated function Update()
{
    local HudBase HUD;

    Counter.PosX = default.PosX;
    Counter.PosY = default.PosY;
    Icon.PosX = default.PosX;
    Icon.PosY = default.PosY;
    HUD = HudBase(Owner);
    if (!default.bFollowHUDColor)
    {
        Icon.Tints[0] = default.DefaultColor;
        Icon.Tints[1] = default.DefaultColor;
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
    if (default.bPulsingDigits)
    {
        Digits = class'HudCDeathMatch'.default.DigitsBigPulse;
    }
    else
    {
        Digits = class'HudCDeathMatch'.default.DigitsBig;
    }
}

simulated function bool PlayerIsDead()
{
    return HudBase(Owner) == None
        || HudBase(Owner).PawnOwner == None
        || HudBase(Owner).PawnOwner.Health == 0;
}

static function Setup(PlayerController PC)
{
    local int i;

    for (i = 0; i < PC.myHUD.Overlays.Length; ++i)
    {
        if (HxSpawnProtectionTimer(PC.myHUD.Overlays[i]) != None)
        {
            return;
        }
    }
    PC.myHUD.AddHudOverlay(PC.myHUD.Spawn(class'HxSpawnProtectionTimer', PC.myHUD));
}

defaultproperties
{
    bShowTimer=true
    bFollowHUDColor=true
    bPulsingDigits=false
    PosX=0.95
    PosY=0.64
    DefaultColor=(R=239,G=191,B=4,A=255)
    Counter=(TextureScale=0.49,DrawPivot=DP_UpperMiddle,RenderStyle=STY_Alpha,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    Icon=(WidgetTexture=Texture'HxSPTimerIcon',TextureScale=0.22,DrawPivot=DP_MiddleMiddle,RenderStyle=STY_Alpha,TextureCoords=(X1=0,Y1=0,X2=256,Y2=256))
}
