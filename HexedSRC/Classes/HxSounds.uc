class HxSounds extends Info;

var array<Sound> HitSounds;

static simulated function AddHitSound(Sound HitSound, optional bool bPrepend)
{
    local int i;

    for (i = 0; i < default.HitSounds.Length; ++i)
    {
        if (default.HitSounds[i] == HitSound)
        {
            return;
        }
    }
    if (bPrepend)
    {
        default.HitSounds.Insert(0, 1);
        default.HitSounds[0] = HitSound;
    }
    else
    {
        default.HitSounds[default.HitSounds.Length] = HitSound;
    }
}

defaultproperties
{
}
