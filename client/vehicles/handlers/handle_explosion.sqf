//
//      Name: handleExplosion
//      Return: None
//

private ["_vehicle"];

_vehicle = _this select 0;

[_vehicle] spawn checkTyres; 

_status = _vehicle getVariable ["status", []];

if ('cloak' in _status) then {

	[       
		[
			_vehicle,
			"['cloak']"
		],
		"removeVehicleStatus",
		_vehicle,
		false 
	] call gw_fnc_mp;  

};	

// Deal sporadic damage to attached items
{
    if !(_x call isWeapon || _x call isModule) then {
        _curHealth = _x getVariable ['GW_Health', 0];
        _x setVariable['GW_Health', ([(_curHealth - (random 2)), 0, 100] call limitToRange), true];
    };
    false
} count (attachedObjects _vehicle);

false