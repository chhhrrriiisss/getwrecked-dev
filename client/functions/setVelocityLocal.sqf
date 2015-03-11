//
//      Name: setVelocityLocal
//      Desc: Executed remotely to set velocity on target vehicle
//      Return: None
//

private ['_source', '_destination', '_ignore'];

_vehicle = [_this,0, objNull, [objNull]] call filterParam;
_velocity = [_this,1, [], [[]]] call filterParam;	

if (isNull _vehicle || count _velocity == 0) exitWith {};
if ((_velocity distance [0,0,0]) <= 0) exitWith {};

_vehicle setVelocity _velocity;