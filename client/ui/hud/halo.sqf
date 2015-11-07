//
//	  createHalo
//	  Desc: Create a temporary circular indicator around the target vehicle
//	  return (none)
//

private ['_vehicle', '_condition'];

_vehicle = [_this,0, objNull , [objNull]] call filterParam;
_duration = [_this,1, 0 , [0]] call filterParam;
_texture = [_this,2, "" , [""]] call filterParam;
_condition = [_this,3, { true } , [{}]] call filterParam;
_rotate = [_this,4, true, [false]] call filterParam;
_offset = [_this,5, [0,0,0], [[]]] call filterParam;
_isLocal = [_this,6, false, [false]] call filterParam;


if (isNull _vehicle || _duration == 0 || _texture == "") exitWith {};
if (!local _vehicle) exitWith {};

_pos = (ASLtoATL visiblePositionASL _vehicle);
_pos set[2, 0.35];

_ringTop = objNull;
_ringBottom = objNull;

if (_isLocal) then {
	_ringTop = "UserTexture10m_F" createVehicleLocal _pos;
	_ringBottom = "UserTexture10m_F" createVehicleLocal _pos;
	_ringTop setPos _pos;
	_ringBottom setPos _pos;
} else {
	_ringTop = createVehicle ['UserTexture10m_F', _pos, [], 0, 'CAN_COLLIDE'];
	_ringBottom = createVehicle ['UserTexture10m_F', _pos, [], 0, 'CAN_COLLIDE'];
};

_ringTop attachTo [_vehicle, (_vehicle worldToModelVisual (ASLtoATL getPosASL _ringTop)) vectorAdd _offset];
_ringBottom attachTo [_vehicle, (_vehicle worldToModelVisual (ASLtoATL getPosASL _ringBottom)) vectorAdd _offset];

[_ringTop, [-90,0,0]] call setPitchBankYaw;
[_ringBottom, [90,0,0]] call setPitchBankYaw;

_timeout = time + _duration;
_dir = getDir _ringTop;

Sleep 0.01;

_ringTop setObjectTextureGlobal [0, _texture];
_ringBottom setObjectTextureGlobal [0, _texture];

waitUntil {
	
	if (_rotate) then { 
		_dir = _dir + (	if (_dir > 360) then [{-360},{2}]	);
		[_ringTop, [-90,0,_dir]] call setPitchBankYaw;
		[_ringBottom, [90,0,_dir]] call setPitchBankYaw;
	};

	( (time > _timeout) || !([_ringTop, _ringBottom] call _condition) )
};

deleteVehicle _ringTop;	
deleteVehicle _ringBottom;
