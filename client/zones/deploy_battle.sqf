//
//      Name: deployBattle
//      Desc: Prepares vehicle for deployment, checks for empty areas and fail conditions
//      Return: None
//

params ['_vehicleToDeploy', '_unit', '_location'];
private ['_pad', '_unit', '_location', '_vehicleToDeploy'];

if (GW_DEPLOY_ACTIVE) exitWith { systemChat 'Cant deploy more than one vehicle at once.'; false };
GW_DEPLOY_ACTIVE = true;

// Set as last loaded vehicle
_targetName = _vehicleToDeploy getVariable ['name', ''];
GW_LASTLOAD = _targetName;

_success = [_vehicleToDeploy, _unit] call preVehicleDeploy;

if (!_success) exitWith { GW_DEPLOY_ACTIVE = false; false };
if (_success) then {
	// Enable simulation for all relevant vehicles in current zone
	{ 	_x enableSimulation true; false  } count ([GW_CURRENTZONE] call findAllInZone) > 0;
};

_zoneType = "battle";
_zoneDisplayName = "";
_deployData = [];

// Determine the deploy locations and properties
_targetPosition = if (typename _location == "ARRAY") then { _location } else {

	{
		if ((_x select 0) == GW_SPAWN_LOCATION) exitWith {
			_zoneType = (_x select 1);
			_zoneDisplayName = (_x select 2);
		};
		false
	} count GW_VALID_ZONES > 0;

	// Get the list of deployment locations	
	{
		if ((_x select 0) == format['%1Zone', GW_SPAWN_LOCATION]) exitWith {	
			_deployData = (_x select 1);
		};
		false
	} count GW_ZONE_DEPLOY_TARGETS > 0;		

	_rangeCheck = 150;

	// Find a new, empty location from that data
	_targetPosition = [_deployData, ["Car", "Man"], _rangeCheck] call findEmpty;
	_targetPosition set [2, _rangeCheck];
	_targetPosition
};

// If location is null (debug) dont deploy 
if ( (_targetPosition distance [0,0,0]) <= 1000) exitWith {
	systemChat 'No deploy locations available.';
	GW_DEPLOY_ACTIVE = false;
	false
};

_targetPosition set [2, 5];
_vehicleToDeploy setPos _targetPosition;
_vehicleToDeploy setDir (random 360);
[format['%1Zone', GW_SPAWN_LOCATION]] call setCurrentZone;

[_vehicleToDeploy] call initVehicleDeploy;

// Everything is ok, return true
GW_DEPLOY_ACTIVE = false;

// Tell everyone else where we've gone
_str = if (_zoneDisplayName == "Downtown") then { "" } else { "the "};
systemChat format['You deployed to %1%2.', _str, _zoneDisplayName];

_strBroadcast = format['%1 deployed to %2%3', name player, _str, _zoneDisplayName];
pubVar_systemChat = _strBroadcast;
publicVariable "pubVar_systemChat";

// Log on server
pubVar_logDiag = _strBroadcast;
publicVariableServer "pubVar_logDiag";

// Record a successful deployment
['deploy', GW_SPAWN_VEHICLE, 1] call logStat; 

true