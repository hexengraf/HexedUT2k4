class HxSpawnProtectionTimer extends HudOverlay
    config(User)
    notplaceable;

#exec texture Import File=Textures\HxSpawnProtectionTimer.tga Name=HxSPTimerIcon Mips=Off Alpha=1

var config bool bShowTimer;
var config bool bUseHUDColor;
var config bool bPulsingDigits;
var config float PosX;
var config float PosY;
var config Color DefaultColor;

var private HudBase.DigitSet Digits;
var private HudBase.NumericWidget Counter;
var private HudBase.SpriteWidget Icon;
var private float Duration;
var private float Timestamp;

auto state Inactive
{
}

state Setup
{
    simulated Event Tick(float DeltaTime)
    {
        if (HudBase(Owner).PawnOwner != None)
        {
            GoToState('Active');
        }
    }
}

state Active
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
            GoToState('Inactive');
        }
    }

    simulated function Render(Canvas C)
    {
        HudBase(Owner).DrawSpriteWidget(C, Icon);
        HudBase(Owner).DrawNumericWidget(C, Counter, Digits);
    }
}

simulated function SetProtected(float ProtectionDuration)
{
    if (bShowTimer)
    {
        Timestamp = Level.TimeSeconds;
        Duration = ProtectionDuration;
        Update();
        GoToState('Setup');
    }
}

simulated function Update()
{
    Counter.PosX = PosX;
    Counter.PosY = PosY;
    Icon.PosX = PosX;
    Icon.PosY = PosY;

    if (!bUseHUDColor)
    {
        Icon.Tints[0] = DefaultColor;
        Icon.Tints[1] = DefaultColor;
    }
    else if (HudBase(Owner).bUsingCustomHUDColor)
    {
        Icon.Tints[0] = HudBase(Owner).CustomHUDColor;
        Icon.Tints[1] = HudBase(Owner).CustomHUDColor;
    }
    else
    {
        Icon.Tints[0] = HudBase(Owner).GetTeamColor(0);
        Icon.Tints[1] = HudBase(Owner).GetTeamColor(1);
    }
    if (bPulsingDigits)
    {
        Digits = class'HudCDeathMatch'.default.DigitsBigPulse;
    }
    else
    {
        Digits = class'HudCDeathMatch'.default.DigitsBig;
    }
}

defaultproperties
{
    bShowTimer=true
    bUseHUDColor=true
    bPulsingDigits=false
    PosX=0.95
    PosY=0.64
    DefaultColor=(R=239,G=191,B=4,A=255)
    Counter=(TextureScale=0.49,DrawPivot=DP_UpperMiddle,RenderStyle=STY_Alpha,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
    Icon=(WidgetTexture=Texture'HxSPTimerIcon',TextureScale=0.22,DrawPivot=DP_MiddleMiddle,RenderStyle=STY_Alpha,TextureCoords=(X1=0,Y1=0,X2=256,Y2=256))
}
