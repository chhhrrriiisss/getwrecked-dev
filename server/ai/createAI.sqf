private ['_vehicle', '_location', '_skill', '_aiToCreate', '_group', '_ai'];

if (((count GW_AI_ACTIVE) -1) >= GW_AI_MAX) exitWith { 'Cant create AI - Max Limit reached.' call _exitCode; };

_location = [_this, 0, [], [[]]] call filterParam;
_aiToCreate = [_this, 1, (GW_AI_LIBRARY call BIS_fnc_selectRandom), ["", []] ] call filterParam;
_skill = [_this,2, ([(random 1), 0.1, 1] call limitToRange), [0]] call filterParam;

_exitCode = {
	_msg = _this;
	diag_log _msg;
	systemChat _msg;	
};

if (count _location == 0) exitWith { 'Bad spawn location specified' call _exitCode; };
if (typename _aiToCreate == "STRING") then {
	{
		_name = (_x select 0) select 1;
		if (_name == _aiToCreate) exitWith { _aiToCreate = _x; };
	} foreach GW_AI_LIBRARY;
};
if (typename _aiToCreate == "STRING") exitWith { 'No AI with that name found.' call _exitCode; };

// Load the vehicle and wait for object creation
GW_LOADEDVEHICLE = nil;					
[objNull, _location, (_aiToCreate select 0), true] spawn loadVehicle;

_timeout = time + 5;
waitUntil {
	((time > _timeout) || (!isNil "GW_LOADEDVEHICLE"))
};
if (time > _timeout || isNil "GW_LOADEDVEHICLE") exitWith { 'Error creating AI, load vehicle timeout.' call _exitCode; };

// Mark vehicle as AI and create crew
_vehicle = GW_LOADEDVEHICLE;
_isAI = _vehicle setVariable ['isAI', true, true];
GW_AI_ACTIVE pushback _vehicle;
createVehicleCrew _vehicle;

// Set AI attributes and skill
_vehicle lock true;
_vehicle lockDriver true;
_ai = driver _vehicle;

// Set AI's name to last name to avoid remote name calls not finding it
_lastName = ([name _ai," "] call BIS_fnc_splitString) select 1;
_ai setName _lastName;

_ai allowDamage false;

_vehicle setVariable ['GW_Owner', (name _ai), true];
_vehicle setVariable ['GW_Skill', _skill];
_vehicle setVariable ['GW_WantedValue', (_aiToCreate select 1)];
[_vehicle, ['nanoarmor'], 360] call addVehicleStatus;
_group = group _ai;
_group allowFleeing 0;
_group setCombatMode "RED";

{
	_x setskill ["courage",_skill];
	_x setskill ["aimingAccuracy",_skill];
	_x setskill ["aimingShake",_skill];
	_x setskill ["aimingSpeed",_skill];
	_x setskill ["endurance",_skill];
	_x setskill ["spotDistance",_skill];
	_x setskill ["spotTime",_skill];
	_x setskill ["reloadSpeed",_skill];
	_x setskill ["courage",_skill];
	_x setskill ["general",_skill];
	_x setskill ["commanding",_skill];
	_x setCombatMode "RED";
	_x setSkill _skill;
	_x setUnitAbility 100;
	_x allowDamage false;
	_x disableAI "AIMINGERROR";
	_x disableAI "AUTOTARGET";
} foreach crew _vehicle;

// Default sleep tick based off of skill
_sleepTime = [5 - (_skill * 3), 2, 10] call limitToRange;

// Always restore ammo when firing
if (isNil { _vehicle getVariable "GW_firedEH"}) then { 	_vehicle setVariable ['GW_firedEH', _vehicle addEventHandler['fired', {	(_this select 0) setVehicleAmmo 1; }] ]; };

// Hide all attached objects so we can aim efficiently
{ _x hideObject true; } foreach (attachedObjects _vehicle);

// Module trigger configuration
_moduleConfig = [];

// Delete module triggers we dont need for this vehicle
for "_i" from (count GW_AI_MODULE_DEFAULTS)-1 to 0 step -1 do {
	_module = GW_AI_MODULE_DEFAULTS select _i;
	_tag = _module select 0;
	if (([_tag, _vehicle] call hasType) > 0) then { 
		_moduleConfig pushBack _module;
		systemchat format['Has %1', _tag]; 
	};
};

// Determine current location and zone
_currentZone = "";
_currentPos = (ASLtoATL getPosASL _vehicle);


_currentTarget = _vehicle call findAITarget;
_vehicle setVariable ['GW_Target', _currentTarget];

waitUntil {
	
	// Get current status effects on vehicle
	_status = _vehicle getVariable ['status', []];	
	_currentPos = (ASLtoATL getPosASL _vehicle);

	// Avoid flipping or getting stuck
	if (alive _vehicle && !canMove _vehicle) then {
		_vehicle setPos (_vehicle modelToWorld [0,0,1]);
		_vehicle setVectorUp [0,0,1];
	};

	// If current target is dead or null, find a new target
	_currentTarget = if (isNull _currentTarget) then {
		(_vehicle call findAITarget)
	} else {
		if (alive _currentTarget) exitWith { _currentTarget };
		(_vehicle call findAITarget)
	};
	_vehicle setVariable ['GW_Target', _currentTarget];

	// If we can use modules
	_canUse = if ("emp" in _status) then { false } else { true };
	if (_canUse && !isNull _currentTarget) then {

		if (count _moduleConfig == 0) exitWith {};

		_nearby = _currentPos nearEntities [["Car", "Tank"], 60];

		{

			_reload = (_x select 1);
			_lastUse = [_x, 5, (time - _reload), [0]] call filterParam;
			_x set [5, _lastUse];

			if (time - _lastUse > _reload) then {
				_x set [5, time];

				// Check it fulfills random chance 
				_chance =  (_x select 2) * (_skill * 10);
				if ((random 100) > _chance) exitWith {};

				_condition = [_nearby, _vehicle, _status] call (_x select 3);
				if (!_condition) exitWith {};

				[_vehicle, _vehicle] call (_x select 4);
			};

		} foreach _moduleConfig;

	};

	// If we have a target, lets try move or shoot to it
	if (!isNull _currentTarget) then {

		// If target is too far, move to it's position
		if (_currentTarget distance _vehicle > 50) then {
			_vehicle doMove (_currentTarget modelToWorld [0, ([((velocity _currentTarget) distance [0,0,0]) * 3, -100, 100] call limitToRange), 0]);
		};			

		// No turret or weapon for this vehicle, abort
		if ((currentWeapon _vehicle) == "CarHorn") exitWith {};

		{ _x hideObject true; } foreach (attachedObjects _currentTarget);		
		
		// If we can fire weapons, find a target
		_canFire = if ("emp" in _status) then { false } else { true };
		if (!_canFire) exitWith {};			
		if ((random 100) < ([(_skill * 100), 30, 100] call limitToRange)) then {

			_vehicle doTarget _currentTarget;			
			_vehicle doWatch _currentTarget;	
			_vehicle doFire _currentTarget;
			_vehicle commandFire _currentTarget;			
			_targetVisibility = _vehicle aimedAtTarget [_currentTarget];
			if (_targetVisibility == 0) exitWith {};		
			
			_vName = _vehicle getVariable ['name', 'AI']; 
			_currentTarget setVariable['killedBy', format['%1', [name _ai, '',_vName, (typeOf _vehicle) ] ], true];
			
			[_vehicle, _currentTarget, _skill] spawn {

				_s = _this select 2;

				for "_i" from 0 to 5 + (_s * 10) step 1 do {					
					(_this select 0) fireAtTarget [_this select 1, (currentWeapon (_this select 0))];
					Sleep ([0.25 - (_s / 10), 0.1, 0.25] call limitToRange);
				};

			};			
		};

	} else {
		_vehicle doMove (_currentZone call findLocationInZone);
	};

	Sleep _sleepTime;

	((!alive _vehicle) || (!alive _ai) || (_ai != (driver _vehicle)))

};

// Cleanup
GW_AI_ACTIVE = GW_AI_ACTIVE - [_vehicle];
{ _x setdammage 1; } foreach (units (group _ai));
deleteGroup (group _ai); 
