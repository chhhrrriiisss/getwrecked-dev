_zoneName = [_this, 0, "", [""]] call filterParam;

// Bad zone name
if (count toArray _zoneName == 0) exitWith {};

// Global zone doesn't need a boundary
if (_zoneName == "globalZone") exitWith { };

// Retrieve boundary data for zone
_boundaries = [];
_index = -1;
{
	if ((_x select 0) == _zoneName) exitWith { _index = _forEachIndex; _boundaries = (_x select 1); };
} foreach GW_ACTIVE_BOUNDARIES;
if (count _boundaries == 0 || _index == -1) exitWith { };

{
	deleteVehicle _x;
	false
} count _boundaries;

if (GW_DEBUG) then { };

GW_ACTIVE_BOUNDARIES deleteAt _index;

