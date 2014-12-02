//
//      Name: flipVehicle
//      Desc: Restores vehicle position in the event it is upside down or cant move
//      Return: None
//

private ['_vehicle', '_dir', '_pos', '_alt', '_vel'];

_vehicle = [_this,0, objNull, [objNull]] call BIS_fnc_param;
_full = [_this,1, false, [false]] call BIS_fnc_param; 

if (isNull _vehicle) exitWith {};

_dir = getDir _vehicle;
_pos = (ASLtoATL getPosASL _vehicle);
_alt = _pos select 2;
_vel = [0,0,0] distance (velocity _vehicle);

if (_vel > 2) exitWith {}; // Going too fast
if (_alt > 30) exitWith {}; // Going too high


if (_full) then {

	_pos set[2,1];
	_vehicle setDir _dir;
	_vehicle setPosATL _pos;

} else {	
	
	_dir = getDir _vehicle;
	_dir = [_dir + 90] call normalizeAngle;
	_vel = velocity _vehicle;
	_vector = [0,0,1] distance (vectorUp _vehicle);

	_speed = 2 - _vector;

	_vehicle setVelocity [(_vel select 0)+(sin _dir*_speed),(_vel select 1)+(cos _dir*_speed),0];

};