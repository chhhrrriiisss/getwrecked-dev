//
//      Name: shieldEffect
//      Desc: Red bubble surrounding vehicle to simulate an "iron curtain" (If you've never played RA2, which rock have you been under?)
//   

_target = [_this,0, objNull, [objNull]] call BIS_fnc_param;
_duration = [_this,1, 1, [0]] call BIS_fnc_param;

if (isNull _target || _duration < 0) exitWith {};
_pos = visiblePositionASL _target;
if ((visiblePositionASL player) distance _pos > GW_EFFECTS_RANGE) exitWith {};

_source = "#particlesource" createVehicleLocal _pos;
_source setParticleCircle [0, [0, 0, 0]];
_source setParticleParams [["\A3\data_f\missileSmoke", 1, 0, 1], "", "Billboard", 1, 0.1, [0, 0, 0], [0, 0, 0], 0, 0, 1, 0.075, [9, 8, 8, 8, 8, 8, 8, 8], [[1, 0.2, 0.2, 0.25], [1, 0.2, 0.2, 0.25], [0.5, 0.5, 0.5, 0.25]], [0.08, 0.08, 0.08, 0.08], 0, 0, "", "", _target];
_source setParticleRandom [0, [0.25, 0.25, 0], [0, 0, 0], 0, 0, [0.1, 0, 0, 0], 0, 0];
_source setDropInterval 0.005;
_source attachTo [_target];
Sleep _duration;
deleteVehicle _source;