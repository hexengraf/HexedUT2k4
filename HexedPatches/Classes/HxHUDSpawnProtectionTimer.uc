class HxHUDSpawnProtectionTimer extends HudOverlay
    config(User)
    notplaceable;

#exec texture Import File=Textures\HxSpawnProtectionTimer.tga Name=HxSPTimerIcon Mips=Off Alpha=1

var config bool bShowTimer;
var config bool bFollowHUDColor;
var config bool bPulsingDigits;
var config float PosX;
var config float PosY;
var config Color DefaultColor;

var HudBase.DigitSet Digits;
var HudBase.NumericWidget Counter;
var HudBase.SpriteWidget Icon;
var float Duration;
var float Timestamp;
var HxHUDSpawnProtectionTimer Instance;

simulated event PreBeginPlay()
{
    super.PreBeginPlay();
    default.Instance = Self;
}

simulated event Destroyed()
{
    if (default.Instance == Self)
    {
        default.Instance = None;
    }
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

        if (bShowTimer)
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
            Timestamp = Level.TimeSeconds;
            Duration = Ceil(HudBase(Owner).PawnOwner.ClientOverlayCounter);
            UpdatePosition();
            UpdateColor();
            UpdateDigits();
            GoToState('Protected');
        }
    }
}

simulated function UpdateColor()
{
    local HudBase HUD;

    HUD = HudBase(Owner);
    if (!bFollowHUDColor)
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

simulated static function SetShowTimer(bool bValue)
{
    default.bShowTimer = bValue;
    if (default.Instance != None)
    {
        default.Instance.bShowTimer = bValue;
    }
}

simulated static function SetFollowHUDColor(bool bValue)
{
    default.bFollowHUDColor = bValue;
    if (default.Instance != None)
    {
        default.Instance.bFollowHUDColor = bValue;
        default.Instance.UpdateColor();
    }
}

simulated static function SetPulsingDigits(bool bValue)
{
    default.bPulsingDigits = bValue;
    if (default.Instance != None)
    {
        default.Instance.bPulsingDigits = bValue;
        default.Instance.UpdateDigits();
    }
}

simulated static function SetPosX(float Value)
{
    default.PosX = Value;
    if (default.Instance != None)
    {
        default.Instance.PosX = Value;
        default.Instance.UpdatePosition();
    }
}

simulated static function SetPosY(float Value)
{
    default.PosY = Value;
    if (default.Instance != None)
    {
        default.Instance.PosY = Value;
        default.Instance.UpdatePosition();
    }
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
