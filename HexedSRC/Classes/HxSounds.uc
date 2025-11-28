class HxSounds extends Info;

#exec AUDIO IMPORT FILE=Sounds\HitSound1.wav
#exec AUDIO IMPORT FILE=Sounds\HitSound2.wav
#exec AUDIO IMPORT FILE=Sounds\HitSound3.wav
#exec AUDIO IMPORT FILE=Sounds\HitSound4.wav
#exec AUDIO IMPORT FILE=Sounds\HitSound5.wav

var array<Sound> HitSounds;

static simulated function AddHitSound(Sound HitSound)
{
    local int i;

    for (i = 0; i < default.HitSounds.Length; ++i)
    {
        if (default.HitSounds[i] == HitSound)
        {
            return;
        }
    }
    default.HitSounds[default.HitSounds.Length] = HitSound;
}

defaultproperties
{
    HitSounds(0)=Sound'HitSound1'
    HitSounds(1)=Sound'HitSound2'
    HitSounds(2)=Sound'HitSound3'
    HitSounds(3)=Sound'HitSound4'
    HitSounds(4)=Sound'HitSound5'
}
