//
//      Name: nitroPad
//      Desc: Boosts a vehicle if close enough to a valid pad
//      Return: None
//

private ["_pad", "_vehicle"];

_pad = [_this,0, objNull, [objNull]] call BIS_fnc_param;
_vehicle = [_this,1, objNull, [objNull]] call BIS_fnc_param;

if (isNull _vehicle || isNull _pad || (player == _vehicle)) exitWith {};

_status = _vehicle getVariable ["status", []];

if ("boost" in _status) exitWith {};

[       
    [
        _vehicle,
        ['boost'],
        3
    ],
    "addVehicleStatus",
    _vehicle,
    false 
] call BIS_fnc_MP;  

_pb = _vehicle call BIS_fnc_getPitchBank;

_dir = [getDir _pad] call flipDir; 
_maxSpeed = 100;
_vel = velocity _vehicle;

[
	[
		_vehicle,
		3
	],
	"nitroEffect"
] call BIS_fnc_MP;

for "_i" from 1 to _maxSpeed step 0.1 do {

	_v = [0,0,0] distance (velocity _vehicle);
	if (_v > _maxSpeed) exitWith {};
	_vehicle setVelocity [(_vel select 0)+(sin _dir*_i*_i),(_vel select 1)+(cos _dir*_i*_i),(_vel select 2) + (_i / 3)];
	addCamShake [0.2 * _i, .3 * _i, 20 * _i];

};


// _extraFuel = _vehicle getVariable ["fuel", 0];
// _fuel = (fuel _vehicle) + _extraFuel;

// _number = ['NTO', _vehicle] call hasType;
// _cost = (['NTO'] call getTagData) select 1;
// _cost = (_cost * _number);

// _status = _vehicle getVariable ["status", []];
// if ('tyresPopped' in _status || 'disabled' in _status) exitWith { false };

// _s = if (_fuel < _cost) then {
// 	["LOW FUEL  ", 0.3, warningIcon, colorRed, "warning"] spawn createAlert;

// 	[       
// 	    [
// 	        _vehicle,
// 	        ['nofuel'],
// 	        3
// 	    ],
// 	    "addVehicleStatus",
// 	    _vehicle,
// 	    false 
// 	] call BIS_fnc_MP;  

// 	false
// } else {
		
// 		_vel = velocity _vehicle;
// 		_alt = (ASLtoATL (getPosASL _vehicle)) select 2;		
// 		_limit = 60 + (20 * _number);
// 		_velX = abs (_vel select 0);
// 		_velY = abs (_vel select 1);
// 		_velTotal = _velX + _velY;

// 		// If we're already going too fast, abort
// 		if ( (_velTotal > _limit) ) exitWith { false };	
		
// 		_mass = getMass _vehicle;

// 		// Calculate power based off of weight
// 		_power = (15 - (_mass * 0.0002)) max 1;

// 		_speed = _power; 
		
// 		// Wheels aren't touching the ground
// 		if ( _alt > 1 ) exitWith {};	

// 		// Is the engine on? hah.
// 		if (!isEngineOn _vehicle) exitWith { false};

// 		[
// 			[
// 			_vehicle,
// 			0.75
// 			],
// 			"nitroEffect"
// 		] call BIS_fnc_MP;

// 		_final = _fuel - _cost;	

// 		if (_final > 1) then {
// 			_allocated = _final - 1;
// 			_vehicle setVariable["fuel", _allocated];
// 			_vehicle setFuel 1;
// 		} else {
// 			_vehicle setVariable["fuel", 0.01];
// 			_vehicle setFuel _final;
// 		};						
		
// 		_dir = direction _vehicle;
// 		_vehicle setVelocity [(_vel select 0)+(sin _dir*_speed),(_vel select 1)+(cos _dir*_speed),(_vel select 2) + 0.1];	

// 		addCamShake [0.2, .3,20];

// 		true
// };

// _s

