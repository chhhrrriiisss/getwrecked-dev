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


_success = [_vehicleToDeploy, _unit] call preVehicleDeploy;

if (!_success) exitWith { GW_DEPLOY_ACTIVE = false; false };

// Determine the start checkpoint
_racePoints = _targetRace select 1;
_raceName = (_targetRace select 0) select 0;
_raceHost = _targetRace select 2;
_startPosition = _racePoints select 0;
_firstPosition = _racePoints select 1;

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

[_racePoints, 9999] execVM 'testcheckpoints.sqf';

// If we are the host, create supply boxes along the route
if (_raceHost == (name player)) then {
	_maxSupply = 15;
	_supplyCount = 0;
	{
		// Limit maximum number of supply drops
		if (_supplyCount >= _maxSupply) exitWith {};

		// Dont put crates at the last checkpoint
		if (_forEachIndex == ((count _racePoints)-1)) exitWith {}; 

		for "_i" from 0 to (random 3) step 1 do { 

			// Only a chance of a crate, increasing with proximity to end
			if (random 100 < (20 - (_forEachIndex * 2))) exitWith {};
			_supplyCount = _supplyCount + 1;			

			// Random position
			_pos = _x vectorAdd [(random 100), (random 100), 0];
			_pos set [2, 0];

			// Care packages at least 50% of the time
			_type = if (random 100 > 50) then { "care" } else { "" };
			[
				[_pos, true, _type],
				'createSupplyDrop',
				false,
				false
			] call bis_fnc_mp;	

		};

	} foreach _racePoints;
};
// _unit action ["engineoff", _targetVehicle];
// _targetPosition set [2, 5];
// _targetVehicle setPos _targetPosition;
// _targetVehicle setDir (random 360);
// [format['%1Zone', GW_SPAWN_LOCATION]] call setCurrentZone;

// Everything is ok, return true
GW_DEPLOY_ACTIVE = false;

// Tell everyone else where we've gone
// _str = if (_zoneDisplayName == "Downtown") then { "" } else { "the "};
// systemChat format['You deployed to %1%2.', _str, _zoneDisplayName];

// _strBroadcast = format['%1 deployed to %2%3', name player, _str, _zoneDisplayName];
// pubVar_systemChat = _strBroadcast;
// publicVariable "pubVar_systemChat";

// // Log on server
// pubVar_logDiag = _strBroadcast;
// publicVariableServer "pubVar_logDiag";

// Record a successful deployment
['deploy', GW_SPAWN_VEHICLE, 1] call logStat; 

true