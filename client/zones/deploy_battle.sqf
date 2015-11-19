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

_zoneType = "battle";
_zoneName = format['%1Zone', GW_SPAWN_LOCATION];
_zoneDisplayName = "";

// Prep + check vehicle for deployment
_success = [_vehicleToDeploy, _unit] call preVehicleDeploy;
if (!_success) exitWith { GW_DEPLOY_ACTIVE = false; false };

// Find index of deploy zone in GW_ZONE_DEPLOY_TARGETS
_index = -1;
{
	if (_zoneName == (_x select 0)) exitWith { _index = _forEachIndex; };
} foreach GW_ZONE_DEPLOY_TARGETS;

// Zone isn't valid therefore no valid deploy locations available
if (_index == -1) exitWith {
	systemChat 'No deploy locations available.';
	GW_DEPLOY_ACTIVE = false;
	false
};

// Build zone perimeter (if it doesn't exist) while we're waiting for server to move us
[_zoneName] spawn buildZoneBoundary;

// Add a listener incase server setPosEmpty fails
_vehicleToDeploy spawn {

	_p = getPos _this;
	_timeout = time + 5;
	waitUntil {
		_d = (getPos _this) distance _p;
		((time > _timeout) || (_d > 1))
	};

	_fail = if ( (getpos _this) distance _p <= 10) then { true } else { false };
	if (_fail) exitWith {
		systemChat 'No deploy locations available.';
		GW_DEPLOY_ACTIVE = false;
		_this call destroyInstantly;
	};

	// If success, set new current zone
	_currentZone =  ([_this] call findCurrentZone);
	[ ([_this] call findCurrentZone) ] call setCurrentZone;

	// Enable simulation for all relevant vehicles in target zone
	{ 	_x enableSimulation true; false  } count ([_currentZone] call findAllInZone) > 0;

	// Initialize vehicle
	[_this] call initVehicleDeploy;

	// Tell everyone else where we've gone
	_str = if (GW_SPAWN_LOCATION == "Downtown") then { "" } else { "the "};
	systemChat format['You deployed to %1%2.', _str, GW_SPAWN_LOCATION];

	_strBroadcast = format['%1 deployed to %2%3', name player, _str, GW_SPAWN_LOCATION];
	pubVar_systemChat = _strBroadcast;
	publicVariable "pubVar_systemChat";

	// Log on server
	pubVar_logDiag = _strBroadcast;
	publicVariableServer "pubVar_logDiag";

	// Record a successful deployment
	['deploy', GW_SPAWN_VEHICLE, 1] call logStat; 

	// Everything is ok, return true
	GW_DEPLOY_ACTIVE = false;

	// Refresh HUD
	GW_HUD_ACTIVE = false;
};

[format["<br /><t size='3' color='#ffffff' align='center'>%1</t>", "DEPLOYING..."], "", [false, { false }] , { GW_DEPLOY_ACTIVE }, 5, true] spawn createTitle;

// Request server deploy using those deploy targets
[
	[format["[((GW_ZONE_DEPLOY_TARGETS select %1) select 1),['Car', 'Man'], 150]", _index],_vehicleToDeploy],
	'setPosEmpty',
	false,
	false
] call bis_fnc_mp;	

true