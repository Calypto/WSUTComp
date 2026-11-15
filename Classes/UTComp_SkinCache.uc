//-----------------------------------------------------------
// Per-level cache of the brightskin lookups UTComp_xPawn.MakeDMSkin, MakeRedSkin and
// MakeBlueSkin, keyed by a pawn's original skin material.
//
// Those helpers build skin names and call DynamicLoadObject. A name in a package that
// doesn't exist (custom models get tried as "Bright<Package>.<Skin>_0B") makes the engine
// search every package path on disk, on every call; a name missing from a loaded package
// throws and catches a C++ exception. A result only depends on the source material, so
// each one is looked up once per level. Entries are distinct skins on the server, so a
// linear search is enough.
//
// Owned by the local BS_xPlayer instead of a class default, so it goes away with the
// level and never keeps a custom model's skins (and its package) loaded across maps.
//-----------------------------------------------------------
class UTComp_SkinCache extends Object;

var array<Material> Sources;
var array<Material> Results; // three per source: Results[index * 3 + UTComp_xPawn.SKIN_*]

// UTComp_xPawn.MakeSkinVariant(Source, Variant), computed on the first request.
function Material Get(Material Source, int Variant)
{
    local int i, r;

    // Every helper returns None for None; don't cache it.
    if(Source == None)
        return None;

    for(i = 0; i < Sources.Length; i++)
        if(Sources[i] == Source)
            break;
    if(i == Sources.Length)
        Sources[i] = Source;

    // A result is never None for a source that isn't (the helpers fall back to the
    // source), so None marks a variant not looked up yet.
    r = i * 3 + Variant;
    if(r >= Results.Length || Results[r] == None)
        Results[r] = class'UTComp_xPawn'.static.MakeSkinVariant(Source, Variant);
    return Results[r];
}
