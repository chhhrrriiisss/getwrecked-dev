//
//      Name: setVehicleOnFire
//      Desc: Attempts to set light to target vehicle (Checks for conditions not to and % chance)
//      Return: None
//

private ['_target', '_chance'];

_target = _this select 0;
_chance = [_this,1, 15, [0]] call BIS_fnc_param; // Chance of setting something alight default 15%
_minDuration = [_this,2, 3, [0]] call BIS_fnc_param; // Default minimum duration of fire

_isVehicle = _target getVariable ["isVehicle", false];
_status = _target getVariable ["status", []];
_rnd = random 100;

if ( !('fire' in _status) && !('nofire' in _status) && _isVehicle && _rnd < _chance) then {

	// Fire duration
	_rnd = random 6 + _minDuration;

	if (_target != (vehicle player) ) then { [_target] call markAsKilledBy;  };

	[       
        [
            _target,
            ['fire'],
            _rnd
        ],
        "addVehicleStatus",
        _target,
        false 
	] call BIS_fnc_MP;  

	[
		[
			_target,
			_rnd
		],
		"burnEffect"
	] call BIS_fnc_MP;

};