class HxSkinHighlightPreview extends HxSkinHighlight;

var string ActiveColor;
var float DisplayFOV;
var vector PreviewOffset;

var private SpinnyWeap PreviewModel;
var private xUtil.PlayerRecord PreviewRec;
var private Rotator PreviewRotation;
var private float PreviewSpin;

function Setup(string CharacterModelName, int Team)
{
    local Mesh ModelMesh;

    if (PreviewModel == None)
    {
        PreviewModel = Spawn(class'XInterface.SpinnyWeap');
        PreviewModel.SetDrawType(DT_Mesh);
        PreviewModel.SetDrawScale(1.0);
        PreviewModel.bHidden = true;
        PreviewModel.bPlayCrouches = false;
        PreviewModel.bPlayRandomAnims = false;
        PreviewModel.SpinRate = 0;
        PreviewModel.AmbientGlow = 40;
        SetBase(PreviewModel);
    }
    PreviewRec = class'xUtil'.static.FindPlayerRecord(CharacterModelName);
    ModelMesh = Mesh(DynamicLoadObject(PreviewRec.MeshName, class'Mesh'));
    if (ModelMesh != None)
    {
        PreviewModel.LinkMesh(ModelMesh);
        PreviewModel.LoopAnim('Idle_Rest', 1.0 / PreviewModel.Level.TimeDilation);
    }
    SetPreviewSkin(Team);
}

function SetPreviewSkin(int Team)
{
    local string BodySkinName;
    local string FaceSkinName;

    BodySkinName = PreviewRec.BodySkinName;
    FaceSkinName = PreviewRec.FaceSkinName;
    if (Team > -1)
    {
        if (class'DMMutator'.default.bBrightSkins && Left(BodySkinName, 12) ~= "PlayerSkins.")
        {
            BodySkinName = "Bright"$BodySkinName$"_"$Team$"B";
        }
        else
        {
            BodySkinName $= "_"$Team;
        }
        if (PreviewRec.TeamFace)
        {
            FaceSkinName $= "_"$Team;
        }
    }
    PreviewModel.Skins[0] = Material(DynamicLoadObject(BodySkinName, class'Material', true));
    PreviewModel.Skins[1] = Material(DynamicLoadObject(FaceSkinName, class'Material', true));
    Reinitialize();
}

function UpdateRotation(PlayerController PC)
{
    PreviewRotation = PC.Rotation;
    PreviewRotation.Pitch += 32768;
    PreviewRotation.Roll += 32768;
    PreviewModel.SetRotation(PreviewRotation);
    PreviewSpin = 0;
}

function Spin(float DeltaX)
{
    local Rotator Delta;
    local Vector X;
    local Vector Y;
    local Vector Z;

    PreviewSpin -= 256 * DeltaX;
    Delta.Yaw = PreviewSpin;
    GetAxes(PreviewRotation, X, Y, Z);
    X = vector(Delta) >> PreviewRotation;
    Delta.Yaw += 16384;
    Y = vector(Delta) >> PreviewRotation;
    PreviewModel.SetRotation(OrthoRotation(X, Y, Z));
}


function bool DrawPreview(Canvas C, float Left, float Top, float Width, float Height)
{
    local rotator CameraRotation;
    local vector CameraPosition;
    local vector X;
    local vector Y;
    local vector Z;

    C.GetCameraLocation(CameraPosition, CameraRotation);
    GetAxes(CameraRotation, X, Y, Z);
    PreviewModel.SetLocation(
        CameraPosition + (PreviewOffset.X * X) + (PreviewOffset.Y * Y) + (PreviewOffset.Z * Z));
    C.DrawActorClipped(PreviewModel, false, Left, Top, Width, Height, true, DisplayFOV);
    return true;
}

simulated event Destroyed()
{
    if (PreviewModel != None)
    {
        PreviewModel.Destroy();
        PreviewModel = None;
    }
    Super.Destroyed();
}

state Enabled
{
    simulated event Tick(float DeltaTime)
    {
        if (Base.OverlayMaterial != None)
        {
            HitIndex = GetHitOverlayIndex();
            if (HitIndex < 0 || bDisableHitEffect[HitIndex] == 0)
            {
                GotoState('Overlayed');
            }
        }
    }

    simulated function Reinitialize()
    {
        Global.Reinitialize();
    }
}

simulated function bool IsSetupFinished()
{
    return true;
}

simulated function bool IsHighlightable()
{
    return true;
}

simulated function string GetHighlightColorName()
{
    return ActiveColor;
}

defaultproperties
{
    DisplayFOV=33
    PreviewOffset=(X=425,Z=-3)
}
