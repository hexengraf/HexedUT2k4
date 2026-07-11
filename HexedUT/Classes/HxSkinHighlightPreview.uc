class HxSkinHighlightPreview extends HxSkinHighlight;

var string ActiveColor;
var EHxSkinType ActiveSkin;
var float DisplayFOV;
var vector PreviewOffset;

var private SpinnyWeap PreviewModel;
var private xUtil.PlayerRecord Record;
var private Rotator PreviewRotation;
var private float PreviewSpin;

function Setup(string CharacterModelName)
{
    local Mesh ModelMesh;
    local string BodySkinName;
    local string FaceSkinName;
    local int Team;

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
    if (CharacterModelName != Record.DefaultName)
    {
        Record = class'xUtil'.static.FindPlayerRecord(CharacterModelName);
        ModelMesh = Mesh(DynamicLoadObject(Record.MeshName, class'Mesh'));
        if (ModelMesh != None)
        {
            PreviewModel.LinkMesh(ModelMesh);
            PreviewModel.LoopAnim('Idle_Rest', 1.0 / PreviewModel.Level.TimeDilation);
        }
    }
    BodySkinName = Record.BodySkinName;
    FaceSkinName = Record.FaceSkinName;
    Team = Clamp(TeamNumber, 0, 1);
    if (class'DMMutator'.default.bBrightSkins && Left(BodySkinName, 12) ~= "PlayerSkins.")
    {
        BodySkinName = "Bright"$BodySkinName$"_"$Team$"B";
    }
    else
    {
        BodySkinName $= "_"$Team;
    }
    if (Record.TeamFace)
    {
        FaceSkinName $= "_"$Team;
    }
    PreviewModel.Skins[0] = Material(DynamicLoadObject(BodySkinName, class'Material', true));
    PreviewModel.Skins[1] = Material(DynamicLoadObject(FaceSkinName, class'Material', true));
    OriginalSkins.Length = 0;
    Restart();
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

auto state Startup
{
    simulated function bool ValidateCharacterModel()
    {
        class'HxGUIModelSelect'.static.LoadXanAbdomen(Base);
        return true;
    }
}

state Reskin
{
    simulated function TryReplaceSkins()
    {
        ReplaceSkins();
    }
}

state Enabled
{
    simulated function TryGotoStateOverlayed()
    {
        HitIndex = GetHitOverlayIndex();
        if (HitIndex < 0 || bDisableHitEffect[HitIndex] == 0)
        {
            GotoState('Overlayed');
        }
    }

    simulated function Restart()
    {
        if (OriginalSkins.Length > 0)
        {
            Base.Skins = OriginalSkins;
        }
        Global.Restart();
    }

    simulated function ToggleBaseSkins()
    {
        local array<Material> TempSkins;

        TempSkins = Base.Skins;
        Base.Skins = BaseSkins;
        BaseSkins = TempSkins;
    }
}

state Overlayed
{
    simulated function TryGotoEnableState()
    {
        GotoState('Enabled');
    }
}

simulated function string GetHighlightColorName()
{
    if (TeamNumber == 0)
    {
        return Teammates;
    }
    if (TeamNumber == 1)
    {
        return Enemies;
    }
    return ActiveColor;
}

simulated function EHxSkinType GetSkinType()
{
    if (TeamNumber == 0)
    {
        return TeammateSkin;
    }
    if (TeamNumber == 1)
    {
        return EnemySkin;
    }
    return ActiveSkin;
}

defaultproperties
{
    ActiveSkin=HX_SKIN_Normal
    ActiveColor="DEFAULT"
    DisplayFOV=36
    PreviewOffset=(X=425,Z=-3)
}
