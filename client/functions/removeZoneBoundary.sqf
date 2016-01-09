private ['_zoneName'];

_zoneName = [_this, 0, "", [""]] call filterParam;

// Bad zone name
if (count toArray _zoneName == 0) exitWith { FALSE };

// Global zone doesn't need a boundary
if (_zoneName == "globalZone") exitWith { FALSE };

// Retrieve boundary data for zone
_boundaries = [];
_index = -1;
{
	if ((_x select 0) == _zoneName) exitWith { _index = _forEachIndex; _boundaries = (_x select 1); };
} foreach GW_ACTIVE_BOUNDARIES;

if (count _boundaries == 0 || _index == -1) exitWith { FALSE };

{
	deleteVehicle _x;
	false
} count _boundaries;

if (GW_DEBUG) then { systemchat format['Deleted boundaries at %1', _zoneName]; };

GW_ACTIVE_BOUNDARIES deleteAt _index;

TRUE
