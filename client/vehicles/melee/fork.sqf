_source = _this select 0;
_target = _this select 1;
	
_status = _target getVariable ['status', []];
if ('invulnerable' in _status || 'cloak' in _status) exitWith {};

_vehicle = attachedTo _source;
_vP = _vehicle worldToModelVisual (_target modelToWorldVisual [0,0,0]);				
_damage = [( ((random 0.2) + 0.2) / (['FRK', _vehicle] call hasType) ), 2] call roundTo;

[       
    [
        _source modelToWorldVisual [1,0,0]
    ],
    "impactEffect",
    true,
    false 
] call gw_fnc_mp; 


if ((_target isKindOf "Car") && !('forked' in _status || 'nofork' in _status) ) then  {

	[       
	    [
	        _target,
	        _vehicle,
	        _damage,
	        _vP
	    ],
	    "forkEffect",
	    _target,
	    false 
	] call gw_fnc_mp; 

	[_target, 'FRK'] call checkMark;

} else {
	
	_target setDammage ((getDammage _target) + _damage);

};


systemchat format['damage: %2 / %3', _vehicle, _damage, getdammage _target];

true