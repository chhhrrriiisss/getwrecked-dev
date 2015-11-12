//
//      Name: deployRace
//      Desc: Prepares vehicle for deployment, checks for empty areas and fail conditions
//      Return: None
//

params ['_vehicleToDeploy', '_unit', '_targetRace'];
private ['_pad', '_unit', '_location', '_vehicleToDeploy'];

if (GW_DEPLOY_ACTIVE) exitWith { systemChat 'Cant deploy more than one vehicle at once.'; false };
GW_DEPLOY_ACTIVE = true;

// Set as last loaded vehicle
_targetName = _vehicleToDeploy getVariable ['name', ''];
GW_LASTLOAD = _targetName;

_success = [_vehicleToDeploy, _unit, true] call preVehicleDeploy;
if (!_success) exitWith {
	GW_DEPLOY_ACTIVE = false; 
	false 
};

_targetRace = [_this, 2, [], [[]]] call filterParam;
if (count _targetRace == 0) exitWith { systemchat 'Invalid race data, deploy aborted'; GW_DEPLOY_ACTIVE = false; false };

// Determine the start checkpoint
_racePoints = _targetRace select 1;
_raceName = (_targetRace select 0) select 0;
_raceHost = _targetRace select 2;
_startPosition = _racePoints select 0;
_firstPosition = _racePoints select 1;
_raceStatus = [_targetRace, 3, -1, [0]] call filterParam;

// Find a position, 30m back from first checkpoint and begin alignment
_dirTo = [_startPosition, _firstPosition] call dirTo;
_dirOpp = [_dirTo + 180] call normalizeAngle;
_initPosition = [_startPosition, 30, _dirOpp] call relPos;

_initPosition set [2, 5];
_vehicleToDeploy setPos _initPosition;
_vehicleToDeploy setDir _dirTo;

// If location is null (debug) dont deploy 
if ( (_initPosition distance [0,0,0]) <= 1000) exitWith {
	systemChat 'No valid deploy location available.';
	GW_DEPLOY_ACTIVE = false;
	false
};

// Clean up all deployables owned by this player (particularily bad for races due to clogging up checkpoints)
{
	deleteVehicle _x;
} foreach GW_DEPLOYLIST;

// Set ZoneImmune and broadcast (for checkInZone checks)
_vehicleToDeploy setVariable ['GW_ZoneImmune', true, true];
[_vehicleToDeploy] call initVehicleDeploy;
['globalZone'] call setCurrentZone;

// Everything is ok, return true
GW_DEPLOY_ACTIVE = false;

// Record a successful deployment
['deploy', GW_SPAWN_VEHICLE, 1] call logStat; 

[_targetRace] execVM 'client\zones\race_status.sqf';

TRUE
