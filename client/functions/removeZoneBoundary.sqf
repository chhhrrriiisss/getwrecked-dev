_zoneName = [_this, 0, "", [""]] call filterParam;

// Bad zone name
if (count toArray _zoneName == 0) exitWith {};

// Global zone doesn't need a boundary
if (_zoneName == "globalZone") exitWith { systemchat 'bad zone'; };

// Retrieve boundary data for zone
_boundaries = [];
_index = -1;
{
	if ((_x select 0) == _zoneName) exitWith { _index = _forEachIndex; _boundaries = (_x select 1); };
} foreach GW_ACTIVE_BOUNDARIES;
if (count _boundaries == 0 || _index == -1) exitWith {  systemchat 'no boundary to delete'; };

{
	deleteVehicle _x;
} foreach _boundaries;

if (GW_DEBUG) then { systemchat format['%1 boundaries removed.', _zonename]; };

GW_ACTIVE_BOUNDARIES deleteAt _index;

