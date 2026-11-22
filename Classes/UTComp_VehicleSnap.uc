// Client only, spawned locally by BS_xPlayer.SetVehicleSnapMode when Settings.VehicleSnapMode != 0,
// so the default setting costs nothing.
//
// Turns off bSmoothKarmaStateUpdates on the chosen vehicles. With it on (stock), physKarma_internal()
// never sets a moving vehicle's position for errors under 224 uu (KUPDATE_LINEAR_INTERP_THRESHOLD):
// it only feeds them back as velocity, so whatever the client's copy loses between server states
// builds up as lag, then snaps. With it off, each server state is applied as-is.
//
// Mode bits: 1 your vehicle (PlayerController.Pawn), 2 everyone else's. A gunner's Pawn is the turret,
// so the vehicle under a gunner counts as someone else's.
class UTComp_VehicleSnap extends Info;

const SWEEP_INTERVAL = 0.25;

var byte Mode;
var SVehicle Mine;  // the vehicle last given the "own" value

function SetMode(byte NewMode)
{
    Mode = NewMode;
    Mine = SVehicle(PlayerController(Owner).Pawn);
    Sweep();

    // Only other vehicles need the sweep: new ones spawn or become relevant with smoothing on.
    // Your own vehicle only changes through ClientRestart (PawnChanged).
    if ((Mode & 2) != 0)
        SetTimer(SWEEP_INTERVAL, true);
    else
        SetTimer(0.0, false);
}

function Timer()
{
    Sweep();
}

function Sweep()
{
    local SVehicle V;
    local bool bSmoothOwn, bSmoothOthers;

    bSmoothOwn = (Mode & 1) == 0;
    bSmoothOthers = (Mode & 2) == 0;

    foreach DynamicActors(class'SVehicle', V)
    {
        if (V == Mine)
            V.bSmoothKarmaStateUpdates = bSmoothOwn;
        else
            V.bSmoothKarmaStateUpdates = bSmoothOthers;
    }
}

// From BS_xPlayer.ClientRestart, on entering or leaving a vehicle and on respawn
function PawnChanged(Pawn P)
{
    if (Mine != None && Mine != P)
        Mine.bSmoothKarmaStateUpdates = (Mode & 2) == 0;

    Mine = SVehicle(P);
    if (Mine != None)
        Mine.bSmoothKarmaStateUpdates = (Mode & 1) == 0;
}
