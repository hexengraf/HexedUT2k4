class HxSpawnProtectionTimer extends HudOverlay
    config(User)
    notplaceable;

var config bool bShowTimer;
var config float PosX;
var config float PosY;

var HudBase.DigitSet Digits;
var HudBase.NumericWidget Counter;
var HudBase.SpriteWidget Icon;
var bool bEnded;

simulated event PreBeginPlay()
{
    super.PreBeginPlay();
    UpdatePosition();
}

simulated Event Tick(float DeltaTime)
{
    if (PlayerIsDead())
    {
        bEnded = false;
        Counter.Value = 0;
    }
    else if (!bEnded)
    {
        Counter.Value = Ceil(HudBase(Owner).PawnOwner.ClientOverlayCounter);
        if (Counter.Value <= 0)
        {
            bEnded = true;
        }

    }
}

simulated function Render(Canvas C)
{
    local HudBase HUD;
    local float OldResScaleX;

    if (bShowTimer && Counter.Value > 0) {
        HUD = HudBase(Owner);
        UpdateColor(HUD);
        OldResScaleX = HUD.ResScaleX;
        HUD.ResScaleX = HUD.ResScaleY;
        HUD.DrawSpriteWidget(C, Icon);
        HUD.DrawNumericWidget(C, Counter, Digits);
        HUD.ResScaleX = OldResScaleX;
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

simulated function SetPosX(float X)
{
    PosX = X;
    UpdatePosition();
}

simulated function SetPosY(float Y)
{
    PosY = Y;
    UpdatePosition();
}

simulated function UpdateColor(HudBase HUD)
{
    if (HUD.CustomHUDColorAllowed())
    {
        Icon.Tints[HUD.TeamIndex] = HUD.CustomHUDColor;
    }
    else
    {
        Icon.Tints[HUD.TeamIndex] = HUD.GetTeamColor(HUD.TeamIndex);
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
    bShowTimer = true
    PosX = 0.95
    PosY = 0.63
    Digits = (DigitTexture=Texture'HudContent.Generic.HUD',TextureCoords[0]=(X1=0,Y1=0,X2=38,Y2=38),TextureCoords[1]=(X1=39,Y1=0,X2=77,Y2=38),TextureCoords[2]=(X1=78,Y1=0,X2=116,Y2=38),TextureCoords[3]=(X1=117,Y1=0,X2=155,Y2=38),TextureCoords[4]=(X1=156,Y1=0,X2=194,Y2=38),TextureCoords[5]=(X1=195,Y1=0,X2=233,Y2=38),TextureCoords[6]=(X1=234,Y1=0,X2=272,Y2=38),TextureCoords[7]=(X1=273,Y1=0,X2=311,Y2=38),TextureCoords[8]=(X1=312,Y1=0,X2=350,Y2=38),TextureCoords[9]=(X1=351,Y1=0,X2=389,Y2=38),TextureCoords[10]=(X1=390,Y1=0,X2=428,Y2=38))
    Counter = (RenderStyle=STY_Alpha,TextureScale=0.49,DrawPivot=DP_UpperMiddle,OffsetX=0,OffsetY=0,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
	Icon = (WidgetTexture=Texture'HxSpawnProtectionTimer',OffsetX=0,OffsetY=0,DrawPivot=DP_MiddleMiddle,RenderStyle=STY_Alpha,TextureCoords=(X1=0,Y1=0,X2=256,Y2=256),TextureScale=0.22,ScaleMode=SM_None,Scale=1,Tints[0]=(G=255,R=255,B=255,A=255),Tints[1]=(G=255,R=255,B=255,A=255))
    bEnded = false
}
