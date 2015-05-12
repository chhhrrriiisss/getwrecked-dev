//
//      Name: createObject
//      Desc: Create a get wrecked item and apply object data
//      Return: None
//

private ['_pos', '_dir', '_type', '_cycle', '_collide', '_handlers'];

_pos = [_this, 0, [0,0,0], [[]]] call filterParam;
_dir = [_this, 1, 0, [0]] call filterParam;
_type = [_this, 2, '', ['']] call filterParam;
_cycle = [_this, 3, 0, [0]] call filterParam;
_collide = [_this, 4, "NONE", [""]] call filterParam;
_handlers = [_this, 5, false, [false]] call filterParam;

_isHolder = if (_type in GW_HOLDERARRAY) then { true } else { false };

_rnd = random 100;

if ( (_rnd < _cycle) || _type == '') then {  _rndValue = random 100;  _type = [ (_rndValue / 100) ] call findLoot; };

_newObj = nil;

// It's a weapon holder object
if (_isHolder) then {

	_holder = nil;
	_holder = createVehicle ["groundWeaponHolder", _pos, [], 0, 'CAN_COLLIDE']; // So it doesnt collide when spawned in]
	_holder setDir _dir;
	
	if ( isClass (configFile >> "CFGWeapons" >> _type )) then {
		_holder addWeaponCargoGlobal [_type, 1];
	} else {
		_holder addMagazineCargoGlobal [_type, 1];	
	};

	_holder setVariable ['GW_Tag', _type, true];

	removeAllActions _holder;
	_newObj = _holder;

};

if (!_isHolder) then {	_newObj = createVehicle [_type, _pos, [], 0, _collide]; };

if (isServer) then { 

	[_newObj] call setupObject;

} else {
	
	[		
		[
			_newObj
		],
		"setupObject",
		false,
		false 
	] call gw_fnc_mp;
};

_newObj setDir _dir;

if (_handlers) then { [_newObj] call setObjectHandlers; };

_newObj



