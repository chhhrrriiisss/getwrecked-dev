private ['_vehicle', '_currentWeapons', '_currentModules', '_maxModules', '_maxWeapons'];

_currentWeapons = 0;
_currentModules = 0;
_maxWeapons = 999;
_maxModules = 999;

_vehicle = _this;

_data = [typeof _vehicle, GW_VEHICLE_LIST] call getData;
if (!isNil "_data") then {
    _maxWeapons = (_data select 2) select 1;
    _maxModules = (_data select 2) select 2;
};

{
	// Delete anything that's not in the active loot list
	_isHolder = _x call isHolder;
	_class = if (_isHolder) then { (_x getVariable ['GW_Tag', '']) } else { (typeof _x) };
	_data = [_class, GW_LOOT_LIST] call getData;
	if (isNil "_data") then { deleteVehicle _x; } else {
		if (_x call isWeapon) then { if (_currentWeapons < _maxWeapons) then { _currentWeapons = _currentWeapons + 1; } else { deleteVehicle _x; }; };
		if (_x call isModule) then { if (_currentModules < _maxModules) then { _currentModules = _currentModules + 1; } else { deleteVehicle _x; }; };
	};

	false

} count (attachedObjects _vehicle) > 0;


