class HxAspectRatio extends Object;

const MINIMUM_FOV = 1;
const MAXIMUM_FOV = 170;
const DEFAULT_ASPECT_RATIO = 1.3333333333333333;
const TO_RADIANS = 0.017453292519943295;
const TO_DEGREES = 57.29577951308232;

static simulated function bool IsDefault(float AspectRatio)
{
    return AspectRatio ~= DEFAULT_ASPECT_RATIO;
}

static simulated function float GetScale(float AspectRatio)
{
    return AspectRatio / DEFAULT_ASPECT_RATIO;
}

static simulated function float GetScaledFOV(float FOV, float AspectRatio)
{
    return FClamp(
        TO_DEGREES * (2 * ATan(GetScale(AspectRatio) * Tan(FOV / 2 * TO_RADIANS), 1)),
        MINIMUM_FOV,
        MAXIMUM_FOV);
}
