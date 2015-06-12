private ['_vehicle'];

if (((count GW_AI_ACTIVE) -1) >= GW_AI_MAX) exitWith {};

_location = [_this, 0, [], [[]]] call filterParam;
_aiToCreate = [_this, 1, (GW_AI_LIBRARY call BIS_fnc_selectRandom), ["", []] ] call filterParam;
_skill = [_this,2, ([(random 1), 0.1, 1] call limitToRange), [0]] call filterParam;

if (count _location == 0) exitWith { systemChat 'Bad spawn location specified'; };
if (typename _aiToCreate == "STRING") then {
	{
		_name = (_x select 0) select 1;
		if (_name == _aiToCreate) exitWith { _aiToCreate = _x; };
	} foreach GW_AI_LIBRARY;
};
if (typename _aiToCreate == "STRING") exitWith { systemchat 'No AI with that name found.'; };

// Load the vehicle and wait for object creation
GW_LOADEDVEHICLE = nil;					

[player, _location, (_aiToCreate select 0)] spawn loadVehicle;

_timeout = time + 3;
waitUntil {
	((time > _timeout) || (!isNil "GW_LOADEDVEHICLE"))
};
if (time > _timeout || isNil "GW_LOADEDVEHICLE") exitWith { systemchat 'Error creating AI, load vehicle timeout.'; };

// Mark vehicle as AI and create crew
_vehicle = GW_LOADEDVEHICLE;
_isAI = _vehicle setVariable ['isAI', true, true];
GW_AI_ACTIVE pushback _vehicle;
createVehicleCrew _vehicle;

// Set AI attributes and skill
_vehicle lock true;
_ai = driver _vehicle;
_ai allowDamage false;
_vehicle setVariable ['GW_Owner', (name _ai), true];
_group = group _ai;
_group allowFleeing 0;
_combatMode = if (_skill > 0.5) then { "RED" } else { "YELLOW" };
_group setCombatMode _combatMode;
_group setBehaviour "CARELESS";

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
	_x setCombatMode _combatMode;
	_x setSkill _skill;
	_x setUnitAbility 100;
	_x allowDamage false;
	_x disableAI "AIMINGERROR";
	_x disableAI "AUTOTARGET";
} foreach crew _vehicle;

// Default sleep tick based off of skill
_sleepTime = [5 - (_skill * 3), 2, 10] call limitToRange;
_hasWeapon = if (count toArray (currentWeapon (vehicle player)) > 0) then { true } else { false };

// Always restore ammo when firing
if (isNil { _vehicle getVariable "GW_firedEH"}) then { 	_vehicle setVariable ['GW_firedEH', _vehicle addEventHandler['fired', {	(_this select 0) setVehicleAmmo 1; }] ]; };

// Hide all attached objects so we can aim efficiently
{ _x hideObject true; _x enableSimulation false; } foreach (attachedObjects _vehicle);

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

// Determine current zone
{
	_z = format['%1Zone', (_x select 0)];
	_inZone = [_currentPos, _z] call checkInZone;
	if (_inZone) exitWith { _currentZone = _z; false };
	false
} count GW_VALID_ZONES;

waitUntil {
	
	// Get current status effects on vehicle
	_status = _vehicle getVariable ['status', []];	
	_currentPos = (ASLtoATL getPosASL _vehicle);

	// Avoid flipping or getting stuck
	if (alive _vehicle && !canMove _vehicle) then {
		_vehicle setPos (_vehicle modelToWorld [0,0,1]);
		_vehicle setVectorUp [0,0,1];
	};

	// Determine a target to pursue
	_currentTarget = objNull;	

	_targetsInZone = [_currentZone, true] call findAllInZone;	
	{
		_tStatus = _x getVariable ['status', []];
		_canSee = if ("cloak" in _tStatus) then { false } else {
			if (_vehicle distance _x > (1700 + (_skill * 100))) exitWith { false }; 
			if ("nolock" in _tStatus && (random 100) > (_skill * 10)) exitWith { false };
			true 
		};

		if (isPlayer (driver _x) && (alive _x) && _x != _vehicle && _canSee) exitWith {			
			_currentTarget = _x;
			false
		};
		false
	} count _targetsInZone;	

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
	if (!isNull _currentTarget ) then {

		// If target is too far, move to it's position
		if (_currentTarget distance _vehicle > 50) then {
			_vehicle doMove (_currentTarget modelToWorld [0, ([((velocity _currentTarget) distance [0,0,0]) * 3, -100, 100] call limitToRange), 0]);
		};			

		// No turret or weapon for this vehicle, abort
		if (!_hasWeapon) exitWith {};

		{ _x hideObject true; _x enableSimulation false; } foreach (attachedObjects _currentTarget);		
		
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
		
			_killedBy = _currentTarget getVariable ['killedBy', nil];
			if (!isNil "_killedBy") then {
				if (_killedBy select 0 != (name _ai)) then {
					_vName = _vehicle getVariable ['name', 'AI']; 
					_currentTarget setVariable['killedBy', format['%1', [name _ai, '',_vName, (typeOf _vehicle) ] ], true];
				};
			};
				
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
