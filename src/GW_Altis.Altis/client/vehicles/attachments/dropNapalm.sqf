//
//      Name: dropNapalm
//      Desc: Drops a tank that explodes as napalm, burning nearby vehicles
//      Return: None
//

private ["_obj", "_vehicle", "_o"];

if (isNull ( _this select 0) || isNull (_this select 1)) exitWith { false };

[] spawn cleanDeployList;

params ['_obj', '_vehicle'];

playSound3D ["a3\sounds_f\sfx\vehicle_drag_end.wss",_vehicle, false, getPosATL _vehicle, 2, 1, 50];

_type = typeOf _obj;
deleteVehicle _obj;

// Ok, let's position it behind the vehicle
_maxLength = ([_vehicle] call getBoundingBox) select 1;
_pos = _vehicle modelToWorldVisual [0, (-1 * ((_maxLength/2) + 2)), 0];

// Spawn it
_obj = nil;
_obj = createVehicle [_type, _pos, [], 0, 'CAN_COLLIDE']; // So it doesnt collide when spawned in]
_holder = createVehicle ["Land_PenBlack_F", _pos, [], 0, 'CAN_COLLIDE']; // So it doesnt collide when spawned in]

_obj attachTo [_holder, [0,0,0.1]];

createNapalm = {
	
	_pos = _this;

	_objectsArray = [];

	// _src = createVehicle ["Land_PenBlack_F", _pos, [], 0, "CAN_COLLIDE"];
	// [_src, 10, 0.8] spawn infernoEffect;
	// _objectsArray pushback _src;


	for "_i" from 0 to 4 step 1 do {

		_theta = random 360;

		_size = 0.75;

		_r = 7;
		_phi = 1;

		_rx = _r * (sin _theta) * (cos _phi);
		_ry = _r * (cos _theta) * (cos _phi);	

		_nPos = _pos vectorAdd [_rx, _ry, 0];

		_src = createVehicle ["Land_PenBlack_F", _nPos, [], 0, "CAN_COLLIDE"];
		[_src, 10, _size] spawn infernoEffect;
		_objectsArray pushback _src;

	};	
	
	for "_i" from 0 to 4 step 1 do {
		_src = createVehicle ["Land_PenBlack_F", _pos, [], 0, "CAN_COLLIDE"];
		
		[_src, 10] spawn flameEffect;
		_src setVelocity [(random 16)-8, (random 16)-8, 1];	

		_objectsArray pushback _src;

	};

	_bomb = createVehicle ["M_AT", _pos, [], 0, "CAN_COLLIDE"];		
	_bomb setVelocity [0,0,-100];

	_objectsArray spawn {	
		Sleep 10;
		{ deleteVehicle _x; } foreach _this;
	};

};


[_obj, _holder, _vehicle] spawn { 

	params ['_o'];

	_timeout = time + 10;
	waitUntil {
		Sleep 0.1;
		((((getPos (_o)) select 2) < 1) || time > _timeout)
	};

	detach _o;
	deleteVehicle (_this select 1);
	_p = (ASLtoATL visiblePositionASL _o);
	_p set [2, 0];
	_o setPos _p;

	// Recompile the vehicle to account for dropping one bag
	[_this select 2] call compileAttached;

	// Refresh hud bars
	GW_HUD_REFRESH = true;

};

_releaseTime = time;
_timer = 2;
_timeout = time + _timer;

// Handlers to trigger effect early
_obj addEventHandler['HandleDamage', {	(_this select 0) setVariable ["triggered", true]; false }];
_obj addEventHandler['killed', {	(_this select 0) setVariable ["triggered", true]; }];
_obj addEventHandler['Explosion', {	(_this select 0) setVariable ["triggered", true]; }];
_obj addEventHandler['Hit', { (_this select 0) setVariable ["triggered", true]; }];


// Add to targets array
_existingTargets = _vehicle getVariable ["GW_detonateTargets", []];
_newTargets = _existingTargets + [_obj];
_vehicle setVariable ["GW_detonateTargets", _newTargets];

GW_WARNINGICON_ARRAY = GW_WARNINGICON_ARRAY + [_obj];
GW_DEPLOYLIST = GW_DEPLOYLIST + [_obj];

[_obj, _timeout, _vehicle] spawn {
	
	params ['_o', '_t', '_v'];

	_triggered = false;
	_delay = 1;

	for "_i" from 0 to 1 step 0 do {

		if (!alive _o || time > _t) exitWith {};

		_delay = [_delay * 0.65, 0.1, 1] call limitToRange;
		playSound3D ["a3\sounds_f\sfx\beep_target.wss", _o, false, getPos _o, 4, 1, 200]; 
		Sleep _delay;
	
	};

	// If the object is still alive, let's go boom
	if (alive _o) then {

		_pos = (ASLtoATL visiblePositionASL _o);

		playSound3D ["a3\sounds_f\weapons\mines\electron_trigger_1.wss", _o, false, _pos, 4, 1, 200]; 
			

		_pos set [2,2];

		[		
			[
				_o,
				"flamethrower",
				50
			],
			"playSoundAll",
			true,
			false
		] call bis_fnc_mp;	  

		_pos call createNapalm;

		_nearby = _pos nearEntities [["Car", "Tank"], 30];	

		if (count _nearby > 0) then {
			{
				_status = _x getVariable ['status', []];

				if ('nofire' in _status) then {} else {

					if (_x != (_v)) then { [_x, "NPA"] call markAsKilledBy; };

					_modifier = [1 - (30 / ( _x distance _pos)), 0.5, 1] call limitToRange;					
					_d = 0.1;

					_armor = _x getVariable ['GW_Armor', 1];
					_d = [(_d / (_armor / 15)), 0, _d] call limitToRange;

					_d = _d * _modifier;			

					_x setDammage ((getdammage _x) + _d);

					[       
						_x,
						"updateVehicleDamage",
						_x,
						false
					] call bis_fnc_mp; 		

					[_x, 100, 6] spawn setVehicleOnFire;
					[_x, 'NPA'] call markAsKilledBy;				

				};
				
				false
				
			} count _nearby > 0;
		};


		// _flames = [];
		// for "_i" from 0 to 10 step 1 do {

		// // Fire sound effect


	
		// 	_src = createVehicle ["Land_PenBlack_F", _pos, [], 0, "CAN_COLLIDE"];
		// 	_flames pushback _src;
		// 	[_src, 5] spawn flameEffect;
		// 	_src setVelocity [(random 30)-15, (random 30)-15, 0];

		// 	// [_src, 1.5] spawn flameEffect;

		// 	// [
		// 	// 	[
		// 	// 		_src,
		// 	// 		_lifetime
		// 	// 	],
		// 	// 	"flameEffect",
		// 	// 	false,
		// 	// 	false
		// 	// ] call bis_fnc_mp;


		// };

		// // Cleanup
		// _flames spawn {
		// 	Sleep 10;
		// 	{ deletevehicle _x; } foreach _this;
		// };



		// _bomb = createVehicle ["Bo_GBU12_LGB", _pos, [], 0, "FLY"];		
		// _bomb setVelocity [0,0,-10];
		// [_pos, 40, 15] call shockwaveEffect;		

		// _nearby = _pos nearEntities [["Car", "Tank"], 30];	

		// if (count _nearby > 0) then {
		// 	{
		// 		_status = _x getVariable ['status', []];

		// 		if ('invulnerable' in _status) then {} else {

		// 			if (_x != (_v)) then { [_x, "EPL"] call markAsKilledBy; };

		// 			_modifier = [1 - (30 / ( _x distance _pos)), 0.5, 1] call limitToRange;					
		// 			_d = if ('nanoarmor' in _status) then { 0.05 } else { (random (0.1) + 0.5) };

		// 			_armor = _x getVariable ['GW_Armor', 1];
		// 			_d = [(_d / (_armor / 15)), 0, _d] call limitToRange;

		// 			_d = _d * _modifier;

		// 			if (_d > 0) then {

		// 				_x setDammage ((getdammage _x) + _d);

		// 				[       
		// 					_x,
		// 					"updateVehicleDamage",
		// 					_x,
		// 					false
		// 				] call bis_fnc_mp; 

		// 			};

		// 		};
				
		// 		false
				
		// 	} count _nearby > 0;
		// };

		
		

	};

	// Cleanup
	_o removeAllEventHandlers "Hit";
	_o removeAllEventHandlers "Explosion";
	_o removeAllEventHandlers "HandleDamage";

	GW_WARNINGICON_ARRAY = GW_WARNINGICON_ARRAY - [_o];
	GW_DEPLOYLIST = GW_DEPLOYLIST - [_o];

	deleteVehicle _o;
};

true