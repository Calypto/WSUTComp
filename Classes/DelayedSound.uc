class DelayedSound extends Info;

var Sound SoundToPlay;
var PlayerController PC;
var float Atten;

function Timer()
{
    if(PC != None && SoundToPlay != None)
    {
        if(PC.ViewTarget != None)
            PC.ClientPlaySound(SoundToPlay, true, Atten);
        else
            PC.PlayOwnedSound(SoundToPlay, SLOT_Pain, Atten,,,,false);
    }

    // One-shot: each award spawns a new one, which used to stay until the map ended.
    Destroy();
}

defaultproperties
{
    bHidden=true
    Atten=1.0
}