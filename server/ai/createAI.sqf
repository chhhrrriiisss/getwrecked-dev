private ['_vehicle'];

_vehicle = _this;
_isAI = _vehicle getVariable ['isAI', false];
if (_isAI) exitWith {};
_isAI = _vehicle setVariable ['isAI', true, true];

createVehicleCrew _vehicle;

systemChat format ['Created AI pilot for %1', _vehicle];

_currentZone = "";
_currentPos = (ASLtoATL getPosASL _vehicle);

WEST setFriend [CIVILIAN, 0];
CIVILIAN setFriend [WEST, 0];

_vehicle lock true;
_ai = driver _vehicle;
_group = group _ai;
_group allowFleeing 0;
_group setCombatMode "RED";

{
	_x setskill ["courage",1];
	_x setskill ["aimingAccuracy",1];
	_x setskill ["aimingShake",1];
	_x setskill ["aimingSpeed",1];
	_x setskill ["endurance",1];
	_x setskill ["spotDistance",1];
	_x setskill ["spotTime",1];
	_x setskill ["reloadSpeed",1];
	_x setskill ["courage",1];
	_x setskill ["general",1];
	_x setskill ["commanding",1];
	_x setCombatMode "RED";
	_x setSkill 1;
	_x setUnitAbility 10;
	_x allowDamage false;

} foreach crew _vehicle;

// Hide current attached objects to make targetting easier
// {
// 	_x enableSimulationGlobal false;
// 	_x hideObject true;
// } foreach (attachedObjects _vehicle);

_sleepTime = 1;

_minEmp = 5;
_lastEmp = time - _minEmp;
_minCoil = 15;
_lastCoil = time - _minCoil;

_vehicle setVariable ['GW_Owner', (name _ai), true];

// Always restore ammo when firing
_vehicle addEventHandler['fired', {	
	(_this select 0) setVehicleAmmo 1;
}];

waitUntil {
	
	_status = _vehicle getVariable ['status', []];
	_canUse = if ("emp" in _status) then { false } else { true };
	_canFire = if ("emp" in _status) then { false } else { true };
	
	// Avoid flipping or getting stuck
	if (alive _vehicle && !canMove _vehicle) then {
		_vehicle setPos (_vehicle modelToWorld [0,0,1]);
		_vehicle setVectorUp [0,0,1];
	};

	if ((vehicle player) distance _vehicle > 200 || (velocity (vehicle player)) distance [0,0,0] < 1) then {
		_vehicle doMove (getpos (vehicle player));
	};

	// If we can use modules
	if (_canUse) then {

		if ((vehicle player) distance _vehicle < 70 && (time - _lastCoil) > _minCoil && (random 100) > 80) then {
			_lastCoil = time;
			[_vehicle, _vehicle] call magneticCoil;
		};

		if ((vehicle player) distance _vehicle < 40 && (time - _lastEmp) > _minEmp && (random 100) > 80) then {
			_lastEmp = time;
			[_vehicle, _vehicle] call empDevice;
			[_vehicle, ['emp']] call removeVehicleStatus;
			_vehicle doMove ((vehicle player) modelToWorld [0,-20,0]);
		};

	};
	
	// If we can fire weapons, find a target
	if (_canFire) then {

		_target = (vehicle player);
		{ 
			if (!(_x call isWeapon) && !(_x call isModule) && { (_x getVariable ['GW_Health', 0] > 0) }) exitWith { _target = _x; };
		} foreach (attachedObjects (vehicle player));

		_tStatus = (vehicle player) getVariable ["status", []];
		_canSee = if ("cloak" in _tStatus) then { false } else { 
			if (_vehicle distance _target > 2000) exitWith { false };
			if ("nolock" in _tStatus && (random 100) > 65) exitWith { false };
			true 

		};

		// If we cant see the target, dont bother shooting
		if (!_canSee) exitWith {};

		_vehicle doTarget _target;
		_vehicle doWatch _target;
		_vehicle doFire _target;
		_vehicle commandFire _target;		

		[_vehicle, _target] spawn {
			for "_i" from 0 to 5 step 1 do {
				(_this select 0) fireAtTarget [(_this select 1),currentWeapon (_this select 0)];
				Sleep 0.2;
			};
		};	
		
	};

	
	// _targets = [_currentZone, true] call findAllInZone;
	
	// {
	// 	if (isPlayer (driver _x) && (alive _x) && _x != _vehicle) exitWith {
	// 		_currentTarget = _x;
	// 		false
	// 	};
	// 	false
	// } count _targets;

	// _sleepTime = if (!isNil "_currentTarget") then {
	// 	_dist = _ai distance _currentTarget;
	// 	_location = if (_dist < 100) then {
	// 		_dirTo = [_ai, _currentTarget] call dirTo;
	// 		([_ai, (_dist / 2), _dirTo] call relPos)

	// 	} else {
	// 		(_currentTarget modelToWorld [0, [((velocity _currentTarget) distance [0,0,0]) * 3, -100, 100] call limitToRange, 0])
	// 	};

	// 	_ai doMove _location;
	// 	systemChat format ['Moving to %1', _currentTarget];

	// 	_dirTo = [_vehicle, _currentTarget] call dirTo;
	// 	_vehDir = getDir _vehicle;

	// 	{
	// 		_tag = _x getVariable ['GW_Tag', ''];
	// 		if (_tag == "HMG") then {

	// 			_objDir = [(getDir _x) - (_vehDir)] call normalizeAngle;
	// 			_dif = [_objDir - _dirTo] call flattenAngle;
	// 			if (_dif < 40) then {

	// 				_tagData = ['HMG'] call getTagData;
	// 				_reloadTime = _tagData select 0;

	// 				for "_i" from 0 to 8 step 1 do {

	// 					[_x, _currentTarget modelToWorld [0,0,1], _vehicle] call fireHmg;

	// 					[			
	// 						[
	// 							_currentTarget,
	// 							"motor",
	// 							0.1,
	// 							nil,
	// 							"B_127x99_Ball"
	// 						],
	// 						"handleDamageVehicle",
	// 						_currentTarget,
	// 						false
	// 					] call gw_fnc_mp;	

	// 					Sleep (_reloadTime / 2);
	// 				};
					
	// 				systemchat 'firing!';
	// 			};
	// 			false
	// 		};
	// 	} count (attachedObjects _vehicle);

	// 	// [
	// 	// 	["FLM", { systemchat 'flames!'; }],
	// 	// 	["RPG", { systemchat 'rpgs!!'; }],
	// 	// 	["LSR", { systemchat 'lsers!!'; }],
	// 	// 	["MIS", { systemchat 'missiles!'; }],
	// 	// 	["HMG", { systemchat 'hmgs!'; }]
	// 	// ];

	// 	([(velocity _currentTarget) distance [0,0,0], 1, 15] call limitToRange)

	// } else {
	// 	10
	// };

	Sleep _sleepTime;

	((!alive _vehicle) || (!alive _ai) || (_ai != (driver _vehicle)))

};

// Cleanup
deleteGroup (group _ai); 
_ai setDammage 1;

//deleteVehicle _ai;
// };