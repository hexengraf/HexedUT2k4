class HxSpawnProtectionTimer extends HudOverlay
    config(User)
    notplaceable;

var config bool bShowTimer;
var config bool bUseHUDColor;
var config float PosX;
var config float PosY;

var Color GoldColor;
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
        Icon.Tints[0] = GoldColor;
        Icon.Tints[1] = GoldColor;
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
    PosX=0.95
    PosY=0.63
    GoldColor=(R=239,G=191,B=4,A=255)
    Digits=(DigitTexture=Texture'HudContent.Generic.HUD',TextureCoords[0]=(X1=0,Y1=0,X2=38,Y2=38),TextureCoords[1]=(X1=39,Y1=0,X2=77,Y2=38),TextureCoords[2]=(X1=78,Y1=0,X2=116,Y2=38),TextureCoords[3]=(X1=117,Y1=0,X2=155,Y2=38),TextureCoords[4]=(X1=156,Y1=0,X2=194,Y2=38),TextureCoords[5]=(X1=195,Y1=0,X2=233,Y2=38),TextureCoords[6]=(X1=234,Y1=0,X2=272,Y2=38),TextureCoords[7]=(X1=273,Y1=0,X2=311,Y2=38),TextureCoords[8]=(X1=312,Y1=0,X2=350,Y2=38),TextureCoords[9]=(X1=351,Y1=0,X2=389,Y2=38),TextureCoords[10]=(X1=390,Y1=0,X2=428,Y2=38))
    Counter=(RenderStyle=STY_Alpha,TextureScale=0.49,DrawPivot=DP_UpperMiddle,OffsetX=0,OffsetY=0,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
	Icon=(WidgetTexture=Texture'HxSpawnProtectionTimer',OffsetX=0,OffsetY=0,DrawPivot=DP_MiddleMiddle,RenderStyle=STY_Alpha,TextureCoords=(X1=0,Y1=0,X2=256,Y2=256),TextureScale=0.22,ScaleMode=SM_None,Scale=1,Tints[0]=(G=255,R=255,B=255,A=255),Tints[1]=(G=255,R=255,B=255,A=255))
}
