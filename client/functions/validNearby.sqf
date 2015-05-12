//
//      Name: validNearby
//      Desc: Checks in specified radius for valid GW vehicles, optionally check it's also in scope (visible)
//      Return: Bool (Found)
//

_source =  _this select 0;
_range = [_this, 1, 15, [0]] call filterParam;
_scope = [_this, 2, true, [false]] call filterParam;

_found = nil;

if (isNull _source) exitWith { _found };

_pos = (ASLtoATL (getPosASL _source));
_nearby = _pos nearEntities [["Car"], _range];

if (count _nearby == 0) exitWith { _found };

{
	_isVehicle = _x getVariable ["isVehicle", false];
	_isOwner = [_x, player, false] call checkOwner;
	if (_isVehicle && _isOwner) exitWith {	_found = _x; };
	false
} count _nearby > 0;

// Check it's visible to the player's camera (optional)
if (_scope && !isNil "_found") then {
	_inScope = [player, _found, 60] call checkScope;
	_found = if (_inScope) then { _found } else { nil };
};

_found