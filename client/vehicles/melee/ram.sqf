private ['_source', '_target', '_collide', '_velocity', '_damage', '_multiplier'];

if (isNil "GW_LAST_COLLISION") then { GW_LAST_COLLISION = time - 1; };
if (time - GW_LAST_COLLISION < 1) exitWith { true };
GW_LAST_COLLISION = TIME;

_source = _this select 0;
_target = _this select 1;
	
_status = _target getVariable ['status', []];
if ('invulnerable' in _status || 'cloak' in _status) exitWith { true };

_vehicle = attachedTo _source;
_velocity = (velocity _vehicle) distance [0,0,0];	
_multiplier = [((random (_velocity/100)) + ((_velocity/100) * 0.25)), 0.04, 0.5] call limitToRange;

_damage = [( _multiplier / (['CRR', _vehicle] call hasType) ), 2] call roundTo;

[       
    [
        _source modelToWorldVisual [0,-2,0]
    ],
    "impactEffect",
    true,
    false 
] call gw_fnc_mp; 

_target setDammage (getDammage _target) + _damage;

[       
    _target,
    "updateVehicleDamage",
    _target,
    false 
] call gw_fnc_mp; 

if (GW_DEBUG) then { systemchat format['damage: %1 / %2', _damage, getdammage _target]; };

true

// if ((_target isKindOf "Car") && !('forked' in _status || 'nofork' in _status) ) then  {

// 	[       
// 	    [
// 	        _target,
// 	        _vehicle,
// 	        _damage,
// 	        _vP
// 	    ],
// 	    "forkEffect",
// 	    _target,
// 	    false 
// 	] call gw_fnc_mp; 

// 	[_target, 'FRK'] call checkMark;

// } else {
	
// 	_target setDammage ((getDammage _target) + _damage);

// };
