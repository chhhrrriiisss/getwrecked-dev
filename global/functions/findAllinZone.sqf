//
//      Name: findAllInZone
//      Desc: Finds all units in requested zone, optionally just find vehicles
//      Return: Array 
//

private ['_zone', '_arr', '_zoneCenter', '_vehiclesOnly'];

_zone = [_this, 0, "", [""]] call filterParam;
_vehiclesOnly = [_this, 1, false, [false]] call filterParam;

if (_zone isEqualTo "") exitWith { [] };
if (count allUnits isEqualTo 0) exitWith { [] };


_arr = [];
_isGlobal = if (_zone == "globalZone") then { true } else { false };

{
	// If the unit is alive
	if (alive _x) then {

		// If we're checking global, look for zone immunity
		_zoneImmune = (vehicle _x) getVariable ['GW_ZoneImmune', false];
		if (_isGlobal && !_zoneImmune) exitWith {};

		// Otherwise check the position
		_inZone = if (_isGlobal) then { true } else { ([(ASLtoATL getPosASL _x), _zone] call checkInZone) };
		if (!_inZone) exitWith {};

		_inVehicle = if ((vehicle _x) == _x) then { false } else { _x = vehicle _x; true };

		// If we're only looking for vehicles, do nothing
		if (_vehiclesOnly && !_inVehicle) then {} else {
			_arr pushback _x;
		};

	}; 

	false	
	
} count allUnits > 0;

_arr