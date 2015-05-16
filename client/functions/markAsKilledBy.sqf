//
//      Name: markAsKilledBy
//      Desc: Tags a vehicle as killed by the local player
//      Return: None
//

private ['_v', '_m'];

_v = [_this, 0, objNull, [objNull]] call filterParam;
_m = [_this, 1, "", [""]] call filterParam;

if (isNull _v) exitWith {};
if (!alive _v) exitWith {};

// Don't tag our own vehicle
if (_v == GW_CURRENTVEHICLE) exitWith {};

_v setVariable['killedBy', format['%1', [name player, _m, (GW_CURRENTVEHICLE getVariable ['name', '']), (typeOf GW_CURRENTVEHICLE) ] ], true];	

_driver = driver _v;

// Oh look! There's a driver
if (!isNil "_driver") then {
	_driver setVariable['killedBy', format['%1', [name player, _m, (GW_CURRENTVEHICLE getVariable ['name', '']), (typeOf GW_CURRENTVEHICLE) ] ], true];	
};

if (GW_DEBUG) then { systemChat format['Tagged %1', _v]; };