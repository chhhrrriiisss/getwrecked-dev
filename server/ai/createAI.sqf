private ['_vehicle'];

_vehicle = _this select 0;
_skill = _this select 1;

_skill = 1;

_isAI = _vehicle getVariable ['isAI', false];
if (_isAI) exitWith {};
_isAI = _vehicle setVariable ['isAI', true, true];

createVehicleCrew _vehicle;

systemChat format ['Created AI pilot for %1', _vehicle];

// Always restore ammo when firing
if (isNil { _vehicle getVariable "GW_firedEH"}) then { 	_vehicle setVariable ['GW_firedEH', _vehicle addEventHandler['fired', {	(_this select 0) setVehicleAmmo 1; }] ]; };

// Set AI attributes and skill
_vehicle lock true;
_ai = driver _vehicle;
_vehicle setVariable ['GW_Owner', (name _ai), true];
_group = group _ai;
_group allowFleeing 0;
_combatMode = if (_skill > 0.5) then { "RED" } else { "YELLOW" };
_group setCombatMode _combatMode;

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
	// _x disableAI "FSM";
	_x disableAI "AIMINGERROR";
	_x disableAI "AUTOTARGET";
} foreach crew _vehicle;

_sleepTime = [5 - (_skill * 3), 2, 10] call limitToRange;
_currentZone = "";

// Hide all attached objects so we can aim efficiently
{ _x hideObject true; _x enableSimulation false; } foreach (attachedObjects _vehicle);

// Module trigger configuration
_moduleConfig = 
[

	[
		"EMP", 
		10,
		75, 
		{
			(count (_this select 0) > 1)
		},
		empDevice
	],
	[
		"MAG", // Tag
		15, // Reload
		30, // Chance of use %
		{
			(count (_this select 0) > 1)
		},
		magneticCoil
	],
	[
		"REP", // Tag
		30, // Reload
		90, // Chance of use %
		{
			((_this select 1) getVariable ['GW_Health'] <= 50)
		},
		emergencyRepair
	],
	[
		"SMK", // Tag
		10, // Reload
		80, // Chance of use %
		{
			("locking" in (_this select 2) || "locked" in (_this select 2) || "fire" in (_this select 2) || "inferno" in (_this select 2))
		},
		smokeBomb
	]

];

// Delete module triggers we dont need for this vehicle
{
	_tag = _x select 0;
	if (([_tag, _vehicle] call hasType) <= 0) then {	_moduleConfig deleteAt _forEachIndex; };
} foreach _moduleConfig;

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

	// If we can use modules
	_canUse = if ("emp" in _status) then { false } else { true };
	if (_canUse) then {

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

	// Determine a target to pursue
	_currentTarget = objNull;	

	_targetsInZone = [_currentZone, true] call findAllInZone;	
	{
		_tStatus = _x getVariable ['status', []];
		_canSee = if ("cloak" in _tStatus) then { false } else {
			if (_vehicle distance _x > 2000) exitWith { false }; 
			if ("nolock" in _tStatus && (random 100) > 65) exitWith { false };
			true 
		};

		if (isPlayer (driver _x) && (alive _x) && _x != _vehicle && _canSee) exitWith {			
			_currentTarget = _x;
			false
		};
		false
	} count _targetsInZone;	

	// If we have a target, lets try move or shoot to it
	if (!isNull _currentTarget) then {

		{ _x hideObject true; _x enableSimulation false; } foreach (attachedObjects _currentTarget);

		// If target is too far, move to it's position
		if (_currentTarget distance _vehicle > 200) then {
			_vehicle doMove (_currentTarget modelToWorld [0, ([((velocity _currentTarget) distance [0,0,0]) * 3, -100, 100] call limitToRange), 0]);
		};			
		
		// If we can fire weapons, find a target
		_canFire = if ("emp" in _status) then { false } else { true };
		if (!_canFire) exitWith {};			
		if ((random 100) < (_skill * 100)) then {

			_vehicle doTarget _currentTarget;
			_vehicle doWatch _currentTarget;
			_vehicle doFire _currentTarget;
			_vehicle commandFire _currentTarget;		

			_vName = _vehicle getVariable ['name', 'AI'];
			_currentTarget setVariable['killedBy', format['%1', [_vName, '',_vName, (typeOf _vehicle) ] ], true];	
			
		};

	} else {
		_vehicle doMove (_currentZone call findLocationInZone);
	};

	Sleep _sleepTime;

	((!alive _vehicle) || (!alive _ai) || (_ai != (driver _vehicle)))

};

// Cleanup
deleteGroup (group _ai); 
_ai setDammage 1;
