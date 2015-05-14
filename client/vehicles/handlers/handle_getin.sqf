//
//      Name: handleGetIn
//      Desc: Handler for jumping in vehicles
//      Return: None
//

private ['_vehicle', '_position', '_unit'];

_vehicle = _this select 0;   
_position = _this select 1;
_unit = _this select 2;		

// If we're a passenger and driver is vacant, move to slowly
if ( _position != "driver" ) then {
	_unit action ["eject", _vehicle];
	_unit action ["getInDriver", _vehicle];
};

// Still compiling? get out quick man!
if (GW_WAITCOMPILE) exitWith {
	_unit action ["eject", _vehicle];
};	

[_vehicle] call compileAttached;

// Ownership check
_isOwner = [_vehicle, _unit, true] call checkOwner;

// We're the owner, nothing to do here
if (_isOwner) exitWith {};

// We're not, lets grab some stuff!
_vehicle setVariable ["owner", (name _unit), true];

// Are we missing handlers? Add them!
_hasHandlers = _vehicle getVariable ['hasHandlers', false];
if (!_hasHandlers) then { [_vehicle] call setVehicleHandlers; };

_attached = attachedObjects _vehicle;

if (count _attached <= 0) exitWith {};

{
    _x setVariable ["owner", (name _unit), true];    
	_hasActions = _x getVariable ["hasActions", false];	
	_hasHandlers = _x getVariable ["hasHandlers", false];	
	_hasData = if (isNil { _x getVariable "GW_Data" }) then { false } else { true };
	_isObject = _x call isObject; 

	if (_isObject && !_hasData) then { [_x] call setObjectProperties; };

	if (!_hasHandlers) then {
		if (_isObject) then {
			[_x] call setObjectHandlers;
		};		
	};	
	false
} count (attachedObjects _vehicle) > 0;	

if (local _vehicle) then {
	systemChat "You are now the owner of this vehicle.";
};

// Set prevVeh reference on player (for stats tracking)
_name = _vehicle getVariable ['name', nil];
if (!isNil "_name") then { _unit setVariable ['GW_prevVeh', _name]; };