
params ['_id', '_vehicle'];
private ['_raceName', '_id', '_vehicle'];

_raceName = (((GW_ACTIVE_RACES select _id) select 0) select 0);
_raceStatus = [_raceName] call checkRaceStatus;

if (_raceStatus == 3) exitWith {};

// Set race to 'end'
[_raceName, 3] call checkRaceStatus;

// Get list of current vehicles
_vArray = GW_ACTIVE_RACE_VEHICLES select _id;
_vArray deleteAt (_vArray find _vehicle);

// Delete vehicles that are already dead
{
	if (!alive _x) then { _vArray deleteAt _forEachIndex; };
	_x call destroyInstantly;
} foreach _vArray;

true