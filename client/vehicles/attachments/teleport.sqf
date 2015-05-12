//
//      Name: dropTeleport
//      Desc: Drops a teleport pad
//      Return: None
//

private ["_obj", "_vehicle", "_o"];

if (isNull ( _this select 0) || isNull (_this select 1)) exitWith { false };

[] spawn cleanDeployList;

_obj = _this select 0;
_vehicle = _this select 1;


// Ok, let's position it behind the vehicle
_maxLength = ([_vehicle] call getBoundingBox) select 1;
_pos = _vehicle modelToWorldVisual [0, (-1 * ((_maxLength/2) + 2)), 0];
_pos set [2, 0];

playSound3D ["a3\sounds_f\sfx\vehicle_drag_end.wss",_vehicle, false, (ASLtoATL visiblePositionASL _vehicle), 10, 1, 50];
deleteVehicle _obj;
_obj = createVehicle ["containmentArea_02_sand_F", _pos, [], 0, 'CAN_COLLIDE']; // So it doesnt collide when spawned in]
_obj setVectorUp (surfaceNormal _pos);
_obj setDir (random 360);
_obj enableSimulationGlobal false;

// Recompile the vehicle to account for dropping one bag
[_this select 2] call compileAttached;

// Refresh hud bars
GW_HUD_REFRESH = true;

_releaseTime = time;
_timer = 360;
_timeout = time + _timer;

// Handlers to trigger effect early
_obj addEventHandler['HandleDamage', { (_this select 0) setVariable ["triggered", true]; }];
_obj addEventHandler['killed', {  (_this select 0) setVariable ["triggered", true]; }];
_obj addEventHandler['Explosion', {	 (_this select 0) setVariable ["triggered", true]; }];
_obj addEventHandler['Hit', { (_this select 0) setVariable ["triggered", true]; }];

// Add to targets array
_existingTargets = _vehicle getVariable ["GW_teleportTargets", []];
_newTargets = _existingTargets + [_obj];
_vehicle setVariable ["GW_teleportTargets", _newTargets];

GW_WARNINGICON_ARRAY = GW_WARNINGICON_ARRAY + [_obj];
GW_DEPLOYLIST = GW_DEPLOYLIST + [_obj];

[_obj, _timeout, _vehicle] spawn {
	
	_o = _this select 0;
	_t = _this select 1;
	_v = _this select 2;

	_triggered = false;

	for "_i" from 0 to 1 step 0 do {

		if (!alive _o || time >= _t || _triggered) exitWith {};

		_triggered = _o getVariable ["triggered", false];
		playSound3D ["a3\sounds_f\sfx\beep_target.wss", _o, false, getPos _o, 2, 1, 25]; 
		Sleep 0.5;
	};

	// If the object is still alive, let's use it
	if (alive _o && time < _t) then {

		_pos = (ASLtoATL visiblePositionASL _o);

		playSound3D ["a3\sounds_f\weapons\mines\electron_trigger_1.wss", _o, false, _pos, 5, 1, 100]; 

		[
			[
				_o,
				8
			],
			"magnetEffect"
		] call gw_fnc_mp;

		[
			[
				_v,
				4,
				0.5
			],
			"magnetEffect"
		] call gw_fnc_mp;

		Sleep 0.5;

		_v spawn {
			_timeout = time + 2;
			_n = 0;
			waitUntil {
				Sleep 0.25;
				_n = _n + 1;
				[_this, 14, 15] call shockwaveEffect;
				addCamShake[(random _n), 1, 10];
				(time > _timeout)
			};
		};		

		Sleep 0.5 + (random 1);

		playSound3D ["a3\sounds_f\sfx\special_sfx\sparkles_wreck_1.wss", _o, false, _pos, 10, 1, 150];	

		_v setPos _pos;
		deleteVehicle _o;		
				
	};

	// Cleanup
	_o removeAllEventHandlers "Hit";
	_o removeAllEventHandlers "Explosion";
	_o removeAllEventHandlers "HandleDamage";

	_detonateTargets = _v getVariable ["GW_teleportTargets", []];
	_newTargets = _detonateTargets - [_o];
	_v setVariable ["GW_teleportTargets", _newTargets];	

	GW_WARNINGICON_ARRAY = GW_WARNINGICON_ARRAY - [_o];
	GW_DEPLOYLIST = GW_DEPLOYLIST - [_o];

};

true