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

// Determine the start checkpoint
_racePoints = _targetRace select 1;
_raceName = (_targetRace select 0) select 0;
_raceHost = _targetRace select 2;
_startPosition = _racePoints select 0;
_firstPosition = _racePoints select 1;
_raceStatus = [_targetRace, 3, -1, [0]] call filterParam;

if (_raceStatus == -1) exitWith {
	systemChat 'Error joining race [Bad status code]';
	GW_DEPLOY_ACTIVE = false;
};

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

// Set ZoneImmune and broadcast (for checkInZone checks)
_vehicleToDeploy setVariable ['GW_ZoneImmune', true, true];
[_vehicleToDeploy] call initVehicleDeploy;
['globalZone'] call setCurrentZone;

// If we are the host, create supply boxes along the route
// if (_raceHost == (name player)) then {
// 	_maxSupply = 15;
// 	_supplyCount = 0;
// 	{
// 		// Limit maximum number of supply drops
// 		if (_supplyCount >= _maxSupply) exitWith {};

// 		// Dont put crates at the last checkpoint
// 		if (_forEachIndex == ((count _racePoints)-1)) exitWith {}; 

// 		for "_i" from 0 to (random 3) step 1 do { 

// 			// Only a chance of a crate, increasing with proximity to end
// 			if (random 100 < (20 - (_forEachIndex * 2))) exitWith {};
// 			_supplyCount = _supplyCount + 1;			

// 			// Random position, between this and next point
// 			_nextPos = _racePoints select (_forEachIndex + 1);
// 			_dirNext = [_x, _nextPos] call dirTo;
// 			_distNext = _x distance _nextPos;
// 			_pos = ([_x, random _distNext, _dirNext] call relPos) vectorAdd [((random 150) - 75), ((random 150) - 75), 0];
// 			_pos set [2, 0];

// 			// Care packages at least 50% of the time
// 			_type = if (random 100 > 50) then { "care" } else { "" };
// 			[
// 				[_pos, false, _type],
// 				'createSupplyDrop',
// 				false,
// 				false
// 			] call bis_fnc_mp;	

// 		};

// 	} foreach _racePoints;
// };

// Everything is ok, return true
GW_DEPLOY_ACTIVE = false;

// Record a successful deployment
['deploy', GW_SPAWN_VEHICLE, 1] call logStat; 

GW_HUD_ACTIVE = false;
GW_HUD_LOCK = true;

[_targetRace] execVM 'client\zones\race_status.sqf';

TRUE
