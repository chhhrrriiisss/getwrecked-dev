_pos = (ASLtoATL visiblePositionASL (vehicle player));
_pos set[2, 0.35];

_ringTop = createVehicle ['UserTexture10m_F', _pos, [], 0, 'CAN_COLLIDE'];
_ringBottom = createVehicle ['UserTexture10m_F', _pos, [], 0, 'CAN_COLLIDE'];

_ringTop attachTo [(vehicle player), (vehicle player) worldToModelVisual (ASLtoATL getPosASL _ringTop)];
_ringBottom attachTo [(vehicle player), (vehicle player) worldToModelVisual (ASLtoATL getPosASL _ringBottom)];

[_ringTop, [-90,0,0]] call setPitchBankYaw;
[_ringBottom, [90,0,0]] call setPitchBankYaw;

_timeout = time + 15;
_dir = getDir _ringTop;

Sleep 0.1;

_ringTop setObjectTextureGlobal [0, 'client\images\ring3.paa'];
_ringBottom setObjectTextureGlobal [0, 'client\images\ring3.paa'];


waitUntil {

	_dir = _dir + (	if (_dir > 360) then [{-360},{2}]	);
	[_ringTop, [-90,0,_dir]] call setPitchBankYaw;
	[_ringBottom, [90,0,_dir]] call setPitchBankYaw;

	time > _timeout
};

deleteVehicle _ringTop;	
deleteVehicle _ringBottom;

