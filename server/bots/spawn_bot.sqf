//
//
//
//
//

_botToSpawn = _this select 0;
_zoneToSpawn = _this select 1;

// Determine the location to deploy to
_targetPosition = if (typename _zoneToSpawn == "ARRAY") then { _zoneToSpawn } else {

	// Get the list of deployment locations
	_deployData = [];
	{
		if ((_x select 0) == format['%1Zone', _zoneToSpawn]) exitWith {
			_deployData = _x select 1;
		};
		false
	} count GW_ZONE_DEPLOY_TARGETS > 0;		

	// Find a new, empty location from that data
	_targetPosition = [_deployData, ["Car", "Man"], 150] call findEmpty;
	_targetPosition set [2, 0];
	_targetPosition
};

systemChat str _targetPosition;

player setPos ([_targetPosition, 20, 20] call BIS_fnc_relPos);

GW_BOT_ACTIVE = nil;

[player, _targetPosition, _botToSpawn, true] call loadVehicle;

_timeout = time + 10;
waitUntil {		
	Sleep 0.1;
	(!isNil "GW_BOT_ACTIVE" || time > _timeout)
};

SYSTEMCHAT STR GW_BOT_ACTIVE;

if (time < _timeout) then {

	systemChat format['%1 / %2', _botToSpawn select 1, GW_BOT_ACTIVE];

	[(_botToSpawn select 1), GW_BOT_ACTIVE] spawn controlBot;
};